# == Class: lokkit
#
# This ensures that <code>lokkit<code> is installed and the firewall is enabled
# It is also included by the defined resource types in this module.
#
# === Parameters
#
# None
#
# === Examples
#
#  include ::lokkit
#
# === Copyright
#
# Copyright 2012 Russell Harrison
#
# === License
#
# This file is part of the rharrison-lokkit puppet module.
#
# rharrison-lokkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# rharrison-lokkit is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with rharrison-lokkit. If not, see http://www.gnu.org/licenses/.
#
class lokkit {
  include ::lokkit::params

  # Install lokkit
  package { $::lokkit::params::package:
    ensure => present,
  }

  # Script to check contents of the lokkit config file for the lines provided as arguments to the script.
  file { '/usr/local/bin/lokkit_chkconf_present.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/lokkit/lokkit_chkconf_present.sh',
  }

  # Script to check that the contents of two files have not changed after being sorted.
  file { '/usr/local/bin/lokkit_chkconf_diff.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/lokkit/lokkit_chkconf_diff.sh',
  }

  # Script to check that the contents of custom files haven't changed.
  file { '/usr/local/bin/lokkit_chkconf_custom_diff.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/lokkit/lokkit_chkconf_custom_diff.sh',
  }

  # This is a bit of a hack but is intended to keep iptables from restarting on
  # every puppet run. We'll make a copy of the existing lokkit config file
  # before lokkit runs to compare the new configuration to. First we need to
  # make sure all the files are in place.
  $backup_postfix          = $lokkit::params::backup_postfix
  $lokkit_config           = $::lokkit::params::config_file
  $lokkit_pre_config       = "${::lokkit::params::config_file}${backup_postfix}"
  $lokkit_custom_file_list = $::lokkit::params::custom_file_list

  file { [
    '/etc/sysconfig/iptables',
    '/etc/sysconfig/iptables.old',
    $lokkit_config,
    "${lokkit_config}.old",
    $lokkit_pre_config,
  ]:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package[$::lokkit::params::package],
  }

  # Now lets copy the current lokkit config if they don't match the previous
  # copy
  exec { 'lokkit_pre_config':
    command   => "cp -f ${lokkit_config} ${lokkit_pre_config}",
    unless    => "/usr/local/bin/lokkit_chkconf_diff.sh ${lokkit_config} ${lokkit_pre_config}",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    require   => File[$lokkit_pre_config, '/usr/local/bin/lokkit_chkconf_diff.sh'],
  }

  # Now lets copy the current lokkit custom configs if they don't match the previous
  # copy
  exec { 'lokkit_pre_config_custom':
    command   => "/usr/local/bin/lokkit_chkconf_custom_diff.sh --copy -c ${lokkit_config} -p ${backup_postfix}",
    unless    => "/usr/local/bin/lokkit_chkconf_custom_diff.sh -c ${lokkit_config} -p ${backup_postfix}",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    require   => File[$lokkit_pre_config, '/usr/local/bin/lokkit_chkconf_custom_diff.sh'],
  }

  # Update and restart the firewall
  # Note $::lokkit::params::cmd always enables ssh so you don't lose connection
  # to the machine.
  exec { 'lokkit_update':
    command   => "${::lokkit::params::cmd} --update",
    unless    => "lokkit_chkconf_diff.sh ${lokkit_config} ${lokkit_pre_config} && lokkit_chkconf_diff.sh /etc/sysconfig/iptables /etc/sysconfig/iptables.old && lokkit_chkconf_custom_diff.sh -c ${lokkit_config} -p ${backup_postfix}",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
  }

  # sort the custom rules by name (only if they're not already sorted)
  exec{ 'sort_lokkit_custom':
    provider => 'shell',
    unless   => "awk '/^--custom-rules=/ { if (\$0 < l) {e=1; exit 1}; l=\$0; next} {l=\"\"} END{exit e}' ${lokkit_config}",
    # in-place edit ${lokkit_config} such that the group of --custom-rules is sorted
    command  => "awk '/^--custom-rules=/ { f=1; a[\$0]=0; next } f { f=0; n=asorti(a); for (i=1;i<=n;i++) print a[i]; delete a}; {print}' < ${lokkit_config} 1<> ${lokkit_config}",
    notify   => Exec['lokkit_update'],
  }
}
