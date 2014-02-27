# == Define: lokkit::ports_from_ip4
#
# Define iptables custom rules to open ports only for specific IP v4 source networks.
#
# === Parameters
#
# [*ensure*]
#   Ensure the custom rules are <code>present</code> (default) or <code>absent</code>
# [*source_ips*]
#   An array of source IPv4 network ranges to allow traffic from on the provided ports. A network IP address (with /mask), or a
#   plain IP address is acceptable as members of the array.
# [*tcpPorts*]
#   An array of ports to allow incoming TCP traffic on. Ports may be specified
#   individually or as a range of ports. e.g. <code>[ '8080', '9101-9103', '8090:8099' ]</code>.
# [*udpPorts*]
#   An array of ports to allow incoming UDP traffic on. Ports may be specified
#   individually or as a range of ports. e.g. <code>[ '8080', '9101-9103', '8090:8099' ]</code>.
#
# === Examples
#
#   lokkit::ports_from_ip4 { 'example_service_from_internal' :
#     ensure     => present,
#     source_ips => ['10.0.0.0/8'],
#     tcpPorts   => ['8080', '9101-9103', '8090:8099'],
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
define lokkit::ports_from_ip4 (
  $ensure     = 'present',
  $source_ips = undef,
  $tcpPorts   = undef,
  $udpPorts   = undef,
  ) {
  include ::lokkit
  include ::lokkit::params

  validate_re($ensure, '(absent|present)')
  # There's a shorter way to validate the ip input I'm sure.
  validate_re(
    join($source_ips, ','),
    '^((\d{1,3})(\.(\d{1,3})){3,}(\/\d{1,2}|[\/-](\d{1,3})(\.(\d{1,3})){3,})?,)*(\d{1,3})(\.(\d{1,3})){3,}(\/\d{1,2}|[\/-](\d{1,3})(\.(\d{1,3})){3,})?$'
  )

  if $tcpPorts {
    validate_array($tcpPorts)
    validate_re(join($tcpPorts, ','), '(^((\d+[-:]?\d+),)*(\d+[-:]?\d+)$)')
    $tcpPorts_cleaned = regsubst($tcpPorts, '-', ':', 'G')
  } else {
    $tcpPorts_cleaned = undef
  }

  if $udpPorts {
    validate_array($udpPorts)
    validate_re(join($udpPorts, ','), '(^((\d+[-:]?\d+),)*(\d+[-:]?\d+)$)')
    $udpPorts_cleaned = regsubst($udpPorts, '-', ':', 'G')
  } else {
    $udpPorts_cleaned = undef
  }

  lokkit::custom { $name:
    ensure  => $ensure,
    type    => 'ipv4',
    table   => 'filter',
    content => template('lokkit/ports_from_ip4.erb'),
  }

}
