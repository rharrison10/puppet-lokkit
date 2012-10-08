# == Define: lokkit::ports
#
# This will allow access to specific ports and protocols.
# *Note* this allows access for all connections to the ports. If you wish to
# define more fine grained access to these ports use +lokkit::custom+ instead.
#
# === Parameters
#
# [*tcpPorts*]
#   An array of ports to allow incoming TCP traffic on. Ports may be specified
#   individually or as a range of ports. e.g. +[ '8080', '9101-9103' ]+.
#
# [*udpPorts*]
#   An array of ports to allow incoming UDP traffic on. Ports may be specified
#   individually or as a range of ports. e.g. +[ '8080', '9101-9103' ]+.
#
# === Examples
#
#   lokkit::ports { 'puppet master' :
#     ensure    => 'present',
#     tcpPorts  => [ '8140' ],
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
define lokkit::ports (
  $tcpPorts = undef,
  $udpPorts = undef
) {
  include ::lokkit
  include lokkit::params

  if $tcpPorts {
    case type($tcpPorts) {
      string  : { $tcpPorts_switches = regsubst($tcpPorts, '\d+-\d+|\d+[^- ]', '--port=\0:tcp', 'G') }
      array   : { $tcpPorts_switches = join(regsubst($tcpPorts, '^\d+$|^\d+-\d+$', '--port=\0:tcp'), ' ') }
      default : { fail('tcpPorts must be an array or string') }
    }
  } else {
    $tcpPorts_switches = ''
  }

  if $udpPorts {
    case type($udpPorts) {
      string  : { $udpPorts_switches = regsubst($udpPorts, '\d+-\d+|\d+[^- ]', '--port=\0:udp', 'G') }
      array   : { $udpPorts_switches = join(regsubst($udpPorts, '^\d+$|^\d+-\d+$', '--port=\0:udp'), ' ') }
      default : { fail('udpPorts must be an array or string') }
    }
  } else {
    $udpPorts_switches = ''
  }

  $cmd_args      = "${tcpPorts_switches} ${udpPorts_switches}"
  $lokkit_config = $lokkit::params::config_file

  exec { "lokkit_ports ${name}":
    command   => "${lokkit::params::cmd} -n ${cmd_args}",
    unless    => "/usr/local/bin/lokkit_chkconf_present.sh ${lokkit_config} ${cmd_args}",
    logoutput => on_failure,
    require   => [
      File['/usr/local/bin/lokkit_chkconf_present.sh'],
      Exec['lokkit_clear'],
    ],
    before    => Exec['lokkit_update'],
  }
}
