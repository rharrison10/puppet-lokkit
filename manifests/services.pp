# == Define: lokkit::services
#
# This will allow access to services <code>lokkit</code> knows how to manage on this node.
# *Note* this allows access for all connections to the ports managed by the
# service. If you wish to define more fine grained access to these ports use
# <code>lokkit::custom</code> instead.
#
# === Parameters
#
# [*services*]
#   An array of services to be allowed on this node.  If nothing is provided
#   for this parameter the default is to allow the single service provided by
#   <code>$name</code>.  Valid values for services to be enabled can be found by
#   running <code>lokkit --list-services</code> on a node with the same OS and release as
#   the node you will be configuring.
#
# === Examples
#
#   lokkit::services { 'apache' :
#     services  => [ 'http', 'https' ],
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
define lokkit::services (
  $services = undef
) {
  include ::lokkit
  include ::lokkit::params

  $services_real = $services ? {
    undef   => [$name],
    default => $services,
  }

  case type($services_real) {
    string  : { $service_switches = prefix(split($services_real, ' '), '--service=') }
    array   : { $service_switches = prefix($services_real, '--service=') }
    default : { fail('services must be an array or string') }
  }

  $cmd_args      = shellquote($service_switches)
  $lokkit_config = $::lokkit::params::config_file
  # If the <code>lokkit::clear</code> class is defined we want to make sure this exec requires it so the clear happens before we
  # start making changes.
  $exec_require  = defined(Class['::lokkit::clear']) ? {
    false   => [
      Exec['lokkit_pre_config'],
      File['/usr/local/bin/lokkit_chkconf_present.sh'],
    ],
    default => [
      Exec['lokkit_pre_config'],
      File['/usr/local/bin/lokkit_chkconf_present.sh'],
      Class['::lokkit::clear'],
    ],
  }

  exec { "lokkit_services ${name}":
    command   => "${::lokkit::params::cmd} -n ${cmd_args}",
    unless    => "/usr/local/bin/lokkit_chkconf_present.sh ${lokkit_config} ${cmd_args}",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    require   => $exec_require,
    before    => Exec['lokkit_update'],
  }

}
