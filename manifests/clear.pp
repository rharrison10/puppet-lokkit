# == Class: lokkit::clear
#
# Clear the existing firewall configuration so that we can start from scratch
# changes are not applied until all +lokkit+ defined resources have completed.
# Note +$lokkit::params::cmd+ always enables ssh so you don't lose connection
# to the machine.
#
# === Parameters
#
# [*puppet_schedule*]
#   Puppet
#   +schedule[http://docs.puppetlabs.com/references/stable/type.html#schedule]+
#   defining when the +lokkit+ configuration should be cleared.  By default the
#   automatically created +'puppet'+ schedule is used so that the configuration
#   will be cleared on every run.  If you only wish to ensure new configurations
#   are applied and do not want to clear the configuration call the class using
#   +'never'+ as the value for +schedule+.  You may also pass any valid schedule
#   that you have defined elsewhere in the catalog.
#
# === Examples
#
# Only clear the +lokkit+ configuration once daily during working hours.
#
#  schedule { 'daily_working_hours':
#    period  => daily,
#    range   => '9-17',
#  }
#
#  class { 'lokkit::clear':
#    puppet_schedule => 'daily_working_hours',
#  }
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
class lokkit::clear (
  $puppet_schedule = 'puppet'
) {
  include ::lokkit
  include lokkit::params

  exec { 'lokkit_clear':
    command   => "${lokkit::params::cmd} -n -f",
    logoutput => on_failure,
    require   => Exec['lokkit_pre_config'],
    before    => Exec['lokkit_update'],
    schedule  => $puppet_schedule,
  }
}
