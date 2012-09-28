# rharrison-lokkit

Manage iptables with lokkit.  This class uses the `lokkit` command line tool to allow access to ports and services   You can also supply a set of custom iptables rules in a file using the `lokkit::custom` defined type.

**Note** To ensure this module will not prevent access to a node the `$lokkit::params::cmd` variable includes the `-s ssh` switch to make sure ssh access is always available.

## Warning

This module will clear any existing iptables rules you already have in place. Currently it cannot be used with another means of managing iptables

## Defined Types

### lokkit::custom

Define iptables custom rules to apply via `lokkit --custom-rules`

#### Parameters

##### type

Which ip protocol the rules are written for.  Either `'ipv4'` or `'ipv6'`

##### table

The iptables table to apply the rules to. The default is `'filter'`. Other valid values are `'nat'`, `'mangle'`, `'raw'`, and `'security'`.

##### content

String containing the content of the custom rules file.

##### source

The source location of a file containing the custom rules.

**Warning** You may provide a value for `content` or `source` *not* both.

#### Examples

    lokkit::custom { 'example_raw' :
      type    => 'ipv4',
      table   => 'raw',
      content => template('example/iptables-custom_raw.erb'),
    }

### lokkit::services

This will allow access to services `lokkit` knows how to manage on this node. *Notethis allows access for all connections to the ports managed by the service. If you wish to define more fine grained access to these ports use `lokkit::custom` instead.

#### Parameters

##### services

An array of services to be allowed on this node.  If nothing is provided for this parameter the default is to allow the single service provided by `$name`.  Valid values for services to be enabled can be found by running `lokkit --list-services` on a node with the same OS and release as the node you will be configuring.

#### Examples

    lokkit::services { 'apache' :
      services  => [ 'http', 'https' ],
    }

### lokkit::ports

This will allow access to specific ports and protocols. *Note* this allows access for all connections to the ports. If you wish to define more fine grained access to these ports use `lokkit::custom` instead.

#### Parameters

##### tcpPorts

>An array of ports to allow incoming TCP traffic on. Ports may be specified individually or as a range of ports. e.g. `[ '8080', '9101-9103' ]`.

##### udpPorts

An array of ports to allow incoming UDP traffic on. Ports may be specified individually or as a range of ports. e.g. `[ '8080', '9101-9103' ]`.

#### Examples

    lokkit::ports { 'puppet master' :
      ensure    => 'present',
      tcpPorts  => [ '8140' ],
    }

## TODO
* Blocking ICMP types
* Interface management 
* Port forwarding

Currently this module is developed against RHEL and should also work with Fedora and CentOS.  I don't use other distros so I'm unable to test them.  I will accept pull requests for patches to support your favorite distro of choice.



