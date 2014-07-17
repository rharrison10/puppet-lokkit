# lokkit

Manage iptables with lokkit.  This module uses the `lokkit` command line tool to allow access to ports and services   You can also supply a set of custom iptables rules in a file using the `lokkit::custom` defined type.

**Note**: To ensure this module will not prevent access to a node the `$lokkit::params::cmd` variable includes the `-s ssh` switch to make sure ssh access is always available.

**Warning**: This module will clear any existing iptables rules you already have in place. Currently it cannot be used with another means of managing iptables

## Setup

You must specifically include the `lokkit::clear` class somewhere in your manifest since the other module classes and defines depend on it.  It includes the commands to clear the firewall configuration in order to ensure you have a cleanly defined config.

You will probably want to only have lokkit clear the firewall rules periodically rather than during every Puppet run because Puppet will report changes have been applied on every run it does clear.  Also because you are clearing the configuration the firewall will need to restart iptables once the specified configuration is complete. For more information on this see the documentation on the `lokkit::clear` class.

## Classes

### lokkit::clear

Clear the existing firewall configuration so that we can start from scratch changes are not applied until all `lokkit` defined resources have completed.

**Note**: The other classes and defines in this module have dependencies on `Exec['lokkit_clear']` which is contained in this class. You must either `include lokkit::clear` in one of your manifests which will ensure the firewall configuration is cleared on every run or you can pass a value to the `puppet_schedule` parameter to this class to control when the firewall configuration is cleared.

#### Parameters

##### puppet_schedule

Puppet [schedule](http://docs.puppetlabs.com/references/stable/type.html#schedule) defining when the `lokkit` configuration should be cleared.  By default the automatically created `'puppet'` schedule is used so that the configuration will be cleared on every run.  If you only wish to ensure new configurations are applied and do not want to clear the configuration call the class using `'never'` as the value for `puppet_schedule`.  You may also pass any valid schedule that you have defined elsewhere in the catalog.

#### Examples

Only clear the `lokkit` configuration once daily during working hours.

    schedule { 'daily_working_hours':
      period  => daily,
      range   => '9-17',
    }

    class { 'lokkit::clear':
      puppet_schedule => 'daily_working_hours',
    }

## Defined Types

### lokkit::custom

Define iptables custom rules to apply via `lokkit --custom-rules`

#### Parameters

**Warning**: You may provide a value for `content` **or** `source` **not** both.

##### ensure

Ensure the custom rules are `present` (default) or `absent`

##### type

Which ip protocol the rules are written for.  Either `'ipv4'` or `'ipv6'`

##### table

The iptables table to apply the rules to. The default is `'filter'`. Other valid values are `'nat'`, `'mangle'`, `'raw'`, and `'security'`.

##### content

String containing the content of the custom rules file.

##### source

The source location of a file containing the custom rules.

#### Examples

    lokkit::custom { 'example_raw' :
      type    => 'ipv4',
      table   => 'raw',
      content => template('example/iptables-custom_raw.erb'),
    }

### lokkit::module

This will add or remove an iptables module from the firewall configuration.

#### Parameters

##### ensure
Should the module be `present` (default) or `absent` from the fire wall config.

##### module

The name of the iptables module to manage.

### Examples

    lokkit::module { 'puppet master' :
      ensure => 'present',
      module => 'nf_conntrack',
    }

### lokkit::ports

This will allow access to specific ports and protocols.

**Note**: This allows access for all connections to the ports. If you wish to define more fine grained access to these ports use `lokkit::custom` instead.

#### Parameters

##### tcpPorts

An array of ports to allow incoming TCP traffic on. Ports may be specified individually or as a range of ports. e.g. `[ '8080', '9101-9103' ]`.

##### udpPorts

An array of ports to allow incoming UDP traffic on. Ports may be specified individually or as a range of ports. e.g. `[ '8080', '9101-9103' ]`.

#### Examples

    lokkit::ports { 'puppet master' :
      ensure    => 'present',
      tcpPorts  => [ '8140' ],
    }

### lokkit::ports_from_ip4

Define iptables custom rules to open ports only for specific IPv4 source networks.

#### Parameters

##### ensure

Ensure the custom rules are `present` (default) or `absent`

##### source_ips

An array of source IPv4 network ranges to allow traffic from on the provided ports. A network IP address (with /mask), or a plain IP address is acceptable as members of the array.

##### tcpPorts

An array of ports to allow incoming TCP traffic on. Ports may be specified individually or as a range of ports. e.g. `['8080', '9101-9103', '8090:8099']`.

##### udpPorts

An array of ports to allow incoming UDP traffic on. Ports may be specified individually or as a range of ports. e.g. `['8080', '9101-9103', '8090:8099']`.

#### Examples

    lokkit::ports_from_ip4 { 'example_service_from_internal' :
      ensure     => present,
      source_ips => ['10.0.0.0/8'],
      tcpPorts   => ['8080', '9101-9103', '8090:8099'],
    }

### lokkit::services

This will allow access to services `lokkit` knows how to manage on this node.

**Note**: this allows access for all connections to the ports managed by the service. If you wish to define more fine grained access to these ports use `lokkit::custom` instead.

#### Parameters

##### services

An array of services to be allowed on this node.  If nothing is provided for this parameter the default is to allow the single service provided by `$name`.  Valid values for services to be enabled can be found by running `lokkit --list-services` on a node with the same OS and release as the node you will be configuring.

#### Examples

    lokkit::services { 'apache' :
      services  => [ 'http', 'https' ],
    }
## TODO
* Add unit tests
* Blocking ICMP types
* Interface management
* Port forwarding
* Removing configuration lines / ensuring they are absent
* Migrate defined types to plugins

Currently this module is developed against RHEL and should also work with Fedora and CentOS.  I don't use other distros so I'm unable to test them.  I will accept pull requests for patches to support your favorite distro of choice.
