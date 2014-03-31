# == Class: ovirt
#
# The ovirt::node class installs oVirt Node.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt::node::firewall {

  include ovirt::node

  Firewall {
    ensure  => 'present',
    action  => 'accept',
    chain   => 'INPUT',
    proto   => 'tcp',
  }

  firewall { '001 allow established,related':
    proto   => 'all',
    state   => ['ESTABLISHED', 'RELATED'],
  }
  firewall { '002 allow loopback access':
    iniface => 'lo',
    proto   => 'all',
  }
  firewall { '100 vdsm':
    dport   => $ovirt::node::management_port,
  }
  firewall { '101 ssh':
    dport   => '22',
  }
  firewall { '102 snmp':
    dport   => '161',
    proto   => 'udp',
  }
  firewall { '103 libvirt tls':
    dport   => '16514',
  }
  firewall { '104 guest consoles':
    dport   => '5900-6923',
  }
  firewall { '105 migration':
    dport   => '49152-49216',
  }
  firewall { '998 reject':
    action  => 'reject',
    proto   => 'all',
    reject  => 'icmp-host-prohibited',
  }
# TODO: Can't yet manage the FORWARD rule
# -A FORWARD -m physdev ! --physdev-is-bridged -j REJECT --reject-with icmp-host-prohibited
#  firewall { '999 reject forward not bridged':
#    ensure  => 'present',
#    action  => 'reject',
#    chain   => 'FORWARD',
#    proto   => 'all',
#    reject  => 'icmp-host-prohibited',
#  }

}
