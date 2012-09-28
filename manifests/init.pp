# == Class: lokkit
#
# This ensures that +lokkit+ is installed and the firewall is enabled
# It is also included by the defined resource types in this module.
#
# === Parameters
#
# None
#
# === Examples
#
#  include lokkit
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
  include lokkit::params

# Install lokkit
  package { $lokkit::params::package:
    ensure  => present,
  }

# Clear the existing firewall configuration so that we can start from scratch
# changes are not applied until all lokkit defined resources have completed.
# Note $lokkit::params::cmd always enables ssh so you don't lose connection
# to the machine.
  exec { 'lokkit_clear':
    command   => "${lokkit::params::cmd} -n -f",
    logoutput => on_failure,
    require   => Package[$lokkit::params::package],
    notify    => Exec['lokkit_update'],
  }

# Update and restart the firewall
# Note $lokkit::params::cmd always enables ssh so you don't lose connection
# to the machine.
  exec { 'lokkit_update':
    command     => "${lokkit::params::cmd} --update",
    logoutput   => on_failure,
    refreshonly => true,
  }
}

