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
class ovirt::node (
  $management_port      = '54321',
  $ssl                  = 'true',
  $manage_firewall      = true,
  $storeconfigs_enabled = false,
  $register             = true,
  $vdsm_configs         = {}
) {

  validate_bool($manage_firewall)
  validate_bool($storeconfigs_enabled)
  validate_bool($register)
  validate_hash($vdsm_configs)

  include ovirt
  include sudo

  if $manage_firewall {
    include ovirt::node::firewall
  }

  if $storeconfigs_enabled and $::ipaddress_ovirtmgmt {
    @@host { $::fqdn:
      ensure        => 'present',
      host_aliases  => [$::hostname],
      ip            => $::ipaddress_ovirtmgmt,
      tag           => 'ovirt::node',
    }
  }

  file { '/etc/vdsm':
    ensure  => 'directory',
  }->
  file { '/etc/vdsm/vdsm.id':
    ensure  => 'file',
    path    => '/etc/vdsm/vdsm.id',
    source  => '/proc/sys/kernel/random/uuid',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    replace => false,
  }

  sudo::conf { 'vdsm':
    ensure    => 'present',
    priority  => 50,
    content   => template('ovirt/vdsm.sudo.erb'),
  }

}
