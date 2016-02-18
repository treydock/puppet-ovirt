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
  $engine               = 'engine',
  $management_port      = '54321',
  $manage_firewall      = true,
  $storeconfigs_enabled = false,
  $register             = true,
  $register_address     = $::ipaddress,
  $ssh_port             = '22',
  $ssh_key_fingerprint  = 'UNSET',
  $ssh_user             = 'root',
  $register_name        = $::hostname,
  $ovirtmgmt_interface  = 'ovirtmgmt',
  $vdsm_configs         = [],
) inherits ovirt::params {

  validate_bool($manage_firewall)
  validate_bool($storeconfigs_enabled)
  validate_bool($register)

  if $vdsm_configs {
    validate_array($vdsm_configs)
  }

  $ssh_key_fingerprint_real = $ssh_key_fingerprint ? {
    'UNSET' => '$(ssh-keygen -lf /etc/ssh/ssh_host_rsa_key | awk -F\' \' \'{ print $2 }\')',
    default => $ssh_key_fingerprint,
  }

  $ovirtmgmt_ipaddress = getvar("::ipaddress_${ovirtmgmt_interface}")

  include ovirt
  require 'ovirt::repo'
  include sudo

  if $manage_firewall {
    include ovirt::node::firewall
  }

  if $storeconfigs_enabled and $ovirtmgmt_ipaddress {
    @@host { $::fqdn:
      ensure       => 'present',
      host_aliases => [$::hostname],
      ip           => $ovirtmgmt_ipaddress,
      tag          => 'ovirt::node',
    }
  }

  if $storeconfigs_enabled {
    Ssh_authorized_key <<| tag == 'ovirt::engine' |>>
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
    ensure   => 'present',
    priority => 50,
    content  => template($ovirt::params::vdsm_sudo_template),
  }

  if $register {
    file { '/etc/pki/vdsm': ensure => 'directory' }->
    file { '/etc/pki/vdsm/certs': ensure => 'directory' }->
    file { '/root/ovirt_node_register.sh':
      ensure  => 'file',
      content => template('ovirt/node/ovirt_node_register.sh.erb'),
      require => File['/etc/vdsm/vdsm.id'],
    }
  }

  file { '/etc/ovirt-host-deploy.conf.d': ensure  => 'directory' }->
  file { '/etc/ovirt-host-deploy.conf.d/40-custom-vdsm-config.conf':
    ensure  => 'file',
    content => template('ovirt/node/40-custom-vdsm-config.conf.erb'),
  }
}
