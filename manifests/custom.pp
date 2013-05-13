# == Define: lokkit::custom
#
# Define iptables custom rules to apply via +lokkit --custom-rules+
#
# === Parameters
#
# [*type*]
#   Which ip protocol the rules are written for.  Either +'ipv4'+ or +'ipv6'+
#
# [*table*]
#   The iptables table to apply the rules to. The default is +'filter'+. Other
#   valid values are +'nat'+, +'mangle'+, +'raw'+, and +'security'+.
#
# [*content*]
#   String containing the content of the custom rules file.
#
# [*source*]
#   The source location of a file containing the custom rules.
#
# ==== Warning
#
# You may provide a value for +content+ or +source+ *not* both.
#
# === Examples
#
#   lokkit::custom { 'example_raw' :
#     type    => 'ipv4',
#     table   => 'raw',
#     content => template('example/iptables-custom_raw.erb'),
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
define lokkit::custom (
  $type    = 'ipv4',
  $table   = 'filter',
  $content = undef,
  $source  = undef
) {
  include ::lokkit
  include ::lokkit::params

  if $content and $source {
    fail('Only one of content or source may be provided NOT both')
  } elsif !$content and !$source {
    fail('Something must be supplied for content or source')
  }

  $rules_file = "${::lokkit::params::config_dir}/lokkit-${type}-${table}-${name}"

  file { $rules_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $content,
    source  => $source,
  }

  $cmd_args      = "--custom-rules=${type}:${table}:${rules_file}"
  $lokkit_config = $::lokkit::params::config_file
  # If the <code>lokkit::clear</code> class is defined we want to make sure this exec requires it so the clear happens before we
  # start making changes.
  $exec_require = defined(Class['::lokkit::clear']) ? {
    false   => File['/usr/local/bin/lokkit_chkconf_present.sh'],
    default => [
      File['/usr/local/bin/lokkit_chkconf_present.sh'],
      Class['::lokkit::clear'],
    ],
  }

  exec { "lokkit_custom ${name}":
    command   => "${::lokkit::params::cmd} -n ${cmd_args}",
    unless    => "/usr/local/bin/lokkit_chkconf_present.sh ${lokkit_config} ${cmd_args}",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    subscribe => File[$rules_file],
    require   => $exec_require,
    before    => Exec['lokkit_update'],
  }

}
