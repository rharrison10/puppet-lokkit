# == Define: lokkit::custom
#
# Define iptables custom rules to apply via <code>lokkit --custom-rules</code>
#
# Note: if you have more than one set of custom rules, the rule sets will be
# loaded in an order corresponding to the name of the set. For example, a
# custom rule set named 000-input would be applied before a rule set named
# 999-input-log.
#
# === Parameters
#
# [*ensure*]
#   Ensure the custom rules are <code>present</code> (default) or <code>absent</code>
# [*type*]
#   Which ip protocol the rules are written for.  Either <code>'ipv4'</code> (default) or <code>'ipv6'</code>
# [*table*]
#   The iptables table to apply the rules to. The default is <code>'filter'</code>. Other
#   valid values are <code>'nat'</code>, <code>'mangle'</code>, <code>'raw'</code>, and <code>'security'</code>.
# [*content*]
#   String containing the content of the custom rules file.
# [*source*]
#   The source location of a file containing the custom rules.
#
# ==== Warning
#
# You may provide a value for <code>content</code> or <code>source</code> *not* both.
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
  $ensure  = 'present',
  $type    = 'ipv4',
  $table   = 'filter',
  $content = undef,
  $source  = undef
) {
  include ::lokkit
  include ::lokkit::params

  validate_re($ensure, '(absent|present)', "ensure must be absent or present you provided ${ensure}")
  validate_re($type, '(ipv4|ipv6)', "type=${type} must be 'ipv4' or 'ipv6'")
  validate_re($table, '(filter|nat|mangle|raw|security)', "table=${table} must be one of filter, nat, mangle, raw, or security")

  if $content and $source {
    fail('Only one of content or source may be provided NOT both')
  } elsif !$content and !$source {
    fail('Something must be supplied for content or source')
  }

  $rules_file     = regsubst("${::lokkit::params::config_dir}/lokkit-${type}-${table}-${name}", '[^\w\/-]', '_', 'G')
  validate_absolute_path($rules_file)
  $backup_postfix = $lokkit::params::backup_postfix

  # Make sure the firewall is updated if the custom rules file changes.
  file { $rules_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $content,
    source  => $source,
    require => Exec['lokkit_pre_config_custom'],
  }

  file { "${rules_file}${backup_postfix}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['lokkit_pre_config_custom'],
  }

  $cmd_args      = "--custom-rules=${type}:${table}:${rules_file}"
  $lokkit_config = $::lokkit::params::config_file
  # If the <code>lokkit::clear</code> class is defined we want to make sure this exec requires it so the clear happens before we
  # start making changes.
  $exec_require  = defined(Class['::lokkit::clear']) ? {
    false   => [
      File[$rules_file, '/usr/local/bin/lokkit_chkconf_present.sh'],
      Exec['lokkit_pre_config'],
    ],
    default => [
      File[$rules_file, '/usr/local/bin/lokkit_chkconf_present.sh'],
      Class['::lokkit::clear'],
      Exec['lokkit_pre_config'],
    ],
  }

  if $ensure == 'present' {
    exec { "lokkit_custom ${name} ensure":
      command   => "${::lokkit::params::cmd} -n ${cmd_args}",
      unless    => "/usr/local/bin/lokkit_chkconf_present.sh ${lokkit_config} ${cmd_args}",
      path      => $::lokkit::params::exec_path,
      logoutput => on_failure,
      subscribe => File[$rules_file],
      require   => $exec_require,
      before    => [
                     Exec['lokkit_update'],
                     Exec['sort_lokkit_custom'],
                   ],
    }
  } else {
    augeas { "lokkit_custom ${name} remove":
      context => '/files/etc/sysconfig/system-config-firewall',
      incl    => '/etc/sysconfig/system-config-firewall',
      lens    => 'Lokkit.lns',
      changes => "rm custom-rules[ . = \"${rules_file}\" ]",
      require => $exec_require,
      before  => Exec['lokkit_update'],
    }
  }
}
