# == Define: lokkit::module
#
# This will add or remove an iptables module from the firewall configuration.
#
# === Parameters
#
# [*ensure*]
#   Should the module be <code>present</code> (default) or <code>absent</code> from the fire wall config.
#
# [*module*]
#   The name of the iptables module to manage.
#
# === Examples
#
#   lokkit::module { 'puppet master' :
#     ensure => 'present',
#     module => 'nf_conntrack',
#   }
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
define lokkit::module (
  $ensure = present,
  $module = $name,
) {
  include ::lokkit
  include ::lokkit::params

  case $ensure {
    absent: {
      $cmd_args = "--removemodule=${module}"
      $onlyif_cmd = "grep IPTABLES_MODULES= /etc/sysconfig/iptables-config | grep -q ${module}"
      $unless_cmd = undef
    }
    present: {
      $cmd_args = "--addmodule=${module}"
      $onlyif_cmd = undef
      $unless_cmd = "grep IPTABLES_MODULES= /etc/sysconfig/iptables-config | grep -q ${module}"
    }
    default: {
      fail("ensure = ${ensure} Must be either 'absent' or 'present'")
    }
  }
  $lokkit_config = $::lokkit::params::config_file
  # If the <code>lokkit::clear</code> class is defined we want to make sure this exec requires it so the clear happens before we
  # start making changes.
  $exec_require  = defined(Class['::lokkit::clear']) ? {
    false   => undef,
    default => Class['::lokkit::clear'],
  }

  exec { "lokkit_module ${name}":
    command   => "${::lokkit::params::cmd} -n ${cmd_args}",
    onlyif    => $onlyif_cmd,
    unless    => $unless_cmd,
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    require   => $exec_require,
    before    => Exec['lokkit_update'],
  }

}
