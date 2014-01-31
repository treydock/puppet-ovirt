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
  $management_port    = '54321',
  $ssl                = 'true',
  $nfs_mount_options  = 'soft,nosharecache',
  $vdsm_configs       = {}
) {

  validate_hash($vdsm_configs)

  include ovirt
  include sudo

  Package['vdsm'] -> Vdsm_config<| |> -> File['/etc/vdsm/vdsm.conf']
  Vdsm_config<| |> ~> Service['vdsmd']

  package { 'python-cpopen':
    ensure  => installed,
    name    => 'python-cpopen',
  }->
  package { 'vdsm':
    ensure  => installed,
    name    => 'vdsm',
    before  => [ File['/etc/vdsm/vdsm.conf'],File['/etc/vdsm/vdsm.id'] ],
    require => Yumrepo['ovirt-stable'],
  }

  file { '/etc/vdsm/vdsm.conf':
    path  => '/etc/vdsm/vdsm.conf',
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { '/etc/vdsm/vdsm.id':
    ensure  => present,
    path    => '/etc/vdsm/vdsm.id',
    source  => '/proc/sys/kernel/random/uuid',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    replace => false,
    before  => Service['vdsmd'],
  }

  service { 'vdsmd':
    ensure      => 'running',
    name        => 'vdsmd',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    subscribe   => File['/etc/vdsm/vdsm.conf'],
  }

  sudo::conf { 'vdsm':
    ensure    => 'present',
    priority  => 50,
    content   => template('ovirt/vdsm.sudo.erb'),
    before    => Service['vdsmd'],
  }

  vdsm_config { 'addresses/management_port': value => $management_port }
  vdsm_config { 'vars/ssl': value => $ssl }
  vdsm_config { 'irs/nfs_mount_options': value => $nfs_mount_options }

  if $vdsm_configs and !empty($vdsm_configs) {
    create_resources(vdsm_config, $vdsm_configs)
  }

}
