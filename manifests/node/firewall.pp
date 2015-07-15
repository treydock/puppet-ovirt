# == Class: ovirt::node::firewall
#
class ovirt::node::firewall {

  include ovirt::node

  firewall { '100 vdsm':
    dport   => $ovirt::node::management_port,
    proto   => 'tcp',
    action  => 'accept',
    chain   => 'INPUT',
  }
  firewall { '101 snmp':
    dport   => '161',
    proto   => 'udp',
    action  => 'accept',
    chain   => 'INPUT',
  }
  firewall { '102 libvirt tls':
    dport   => '16514',
    proto   => 'tcp',
    action  => 'accept',
    chain   => 'INPUT',
  }
  firewall { '103 guest consoles':
    dport   => '5900-6923',
    proto   => 'tcp',
    action  => 'accept',
    chain   => 'INPUT',
  }
  firewall { '104 migration':
    dport   => '49152-49216',
    proto   => 'tcp',
    action  => 'accept',
    chain   => 'INPUT',
  }

  firewall { '100 allow forward across bridge':
    physdev_is_bridged => true,
    proto              => 'all',
    action             => 'accept',
    chain              => 'FORWARD',
  }

}
