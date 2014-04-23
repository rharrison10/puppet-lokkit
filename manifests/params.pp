# == Class: lokkit::params
#
# Default values for variables in the <code>lokkit</code> module.
#
# === Parameters
#
# None
#
# === Examples
#
#  include ::lokkit::params
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
class lokkit::params {
  $backup_postfix = '.pre_lokkit'
  $cmd            = '/usr/sbin/lokkit -q -s ssh'
  $config_dir     = '/etc/sysconfig'
  $config_file    = "${config_dir}/system-config-firewall"
  $exec_path      = ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/sbin', '/usr/bin',]
  $package        = 'system-config-firewall-base'
}
