# == Class: lokkit::clear
#
# Clear the existing firewall configuration so that we can start from scratch
# changes are not applied until all +lokkit+ defined resources have completed.
#
# *Note*: The other classes and defines in this module have dependencies on <code>Exec['lokkit_clear']</code> which is contained in this class.
# You must either <code>include ::lokkit::clear</code> in one of your manifests which will ensure the firewall configuration is cleared on every
# run or you can pass a value to the <code>puppet_schedule</code> parameter to this class to control when the firewall configuration is
# cleared.
#
# === Parameters
#
# [*puppet_schedule*]
#   Puppet schedule[http://docs.puppetlabs.com/references/stable/type.html#schedule] defining when the lokkit configuration should
#   be cleared.  By default the automatically created <code>'puppet'</code> schedule is used so that the configuration will be cleared on every
#   run.  If you only wish to ensure new configurations are applied and do not want to clear the configuration call the class using
#   <code>'never'</code> as the value for <code>puppet_schedule</code>.  You may also pass any valid schedule that you have defined elsewhere in the
#   catalog.
#
# === Examples
#
# Only clear the lokkit configuration once daily during working hours.
#
#  schedule { 'daily_working_hours':
#    period  => daily,
#    range   => '9-17',
#  }
#
#  class { '::lokkit::clear':
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
  include ::lokkit::params

  exec { 'lokkit_clear':
    command   => "${::lokkit::params::cmd} -n -f",
    path      => $::lokkit::params::exec_path,
    logoutput => on_failure,
    require   => Exec['lokkit_pre_config'],
    before    => Exec['lokkit_update'],
    schedule  => $puppet_schedule,
  }
}
