# == Class: ovirt::node::firewall
#
class ovirt::node::firewall {

  resources { 'firewall':
    purge => false,
  }

  Firewall {
    before  => Class['ovirt::node::firewall::post'],
    require => Class['ovirt::node::firewall::pre'],
  }

  class { 'ovirt::node::firewall::pre': }
  class { 'ovirt::node::firewall::app': }
  class { 'ovirt::node::firewall::post': }

  class { '::firewall': }

}
