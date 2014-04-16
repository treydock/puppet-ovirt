# == Class: ovirt::node::firewall::post
#
class ovirt::node::firewall::post {

  firewall { '998 reject all':
    action  => 'reject',
    proto   => 'all',
    reject  => 'icmp-host-prohibited',
    before  => undef,
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
