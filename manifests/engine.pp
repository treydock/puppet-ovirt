# == Class: ovirt::engine
#
# The ovirt::engine class installs oVirt Engine.
#
# === Parameters
#
# [*config_allinone*]
#   Boolean.  Install engine and node in an
#   all-in-one setup.
#   Default: false
#
# [*application_mode*]
#   Override the default ovirt application.
#   Valid options are both, virt, gluster.
#   Default: 'both'
#
# [*storage_type*]
#   Override the default ovirt storage type.
#   Valid options are nfs, fc, iscsi, and posixfs.
#   Default: 'nfs'
#
# [*organization*]
#   Override the default ovirt PKI organization.
#   Default: $::domain
#
# [*nfs_config_enabled*]
#   Boolean.  Sets if engine-setup configures NFS.
#   Setting to false disables the ISO domain setup.
#   Default: true
#
# [*iso_domain_name*]
#   ISO domain name used during engine-setup.
#   Default: 'ISO_DOMAIN'
#
# [*iso_domain_mount_point*]
#   ISO domain mount point
#   Default: '/var/lib/exports/iso'
#
# [*admin_password*]
#   Admin password used during engine-setup.
#   Default: 'admin'
#
# [*db_user*]
#   Database user of engine.
#   Default: 'engine'
#
# [*db_password*]
#   Database password of engine.
#   Default: 'dbpassword'
#
# [*db_host*]
#   Database host for engine.
#   Default: 'localhost'
#
# [*db_port*]
#   Database port for engine.
#   Default: '5432'
#
# [*firewall_manager*]
#   Firewall manager for engine-setup.
#   Default for EL: 'iptables'
#   Default for Fedora: 'firewalld'
#
# [*websocket_proxy_config*]
#   Boolean.  Sets if engine-setup and Puppet should manage
#   the ovirt-websocket-proxy service.
#   Default: true
#
# === Examples
#
#  class { 'ovirt::engine':
#    application_mode => 'virt',
#    storage_type     => 'iscsi',
#    organization     => 'example.com',
#  }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt::engine (
  $config_allinone          = false,
  $local_storage_path       = undef,
  $superuser_pass           = undef,
  $application_mode         = 'both',
  $storage_type             = 'nfs',
  $organization             = $::domain,
  $nfs_config_enabled       = true,
  $iso_domain_name          = 'ISO_DOMAIN',
  $iso_domain_mount_point   = '/var/lib/exports/iso',
  $admin_password           = 'admin',
  $db_user                  = 'engine',
  $db_password              = 'dbpassword',
  $db_host                  = 'localhost',
  $db_port                  = '5432',
  $firewall_manager         = $ovirt::params::firewall_manager,
  $websocket_proxy_config   = true
) inherits ovirt::params {

  include ovirt

  $answers_file = '/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf'

  validate_re($application_mode, ['^both$','^virt$','^gluster$'])
  validate_re($storage_type, ['^nfs$','^fs$','^iscsi$','^posixfs$'])
  validate_bool($nfs_config_enabled)
  validate_bool($websocket_proxy_config)

  package { 'ovirt-engine':
    ensure  => installed,
    require => Yumrepo['ovirt-release'],
    before  => File['ovirt-engine-setup.conf'],
  }

  if $config_allinone {
    package { 'ovirt-engine-setup-plugin-allinone':
      ensure  => installed,
      require => Package['ovirt-engine'],
      before  => File['ovirt-engine-setup.conf'],
    }
  }

  file { 'ovirt-engine-setup.conf':
    ensure  => present,
    path    => $answers_file,
    content => template('ovirt/answers.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  service { 'ovirt-engine':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    subscribe   => Exec['engine-setup'],
  }

  if $websocket_proxy_config {
    service { 'ovirt-websocket-proxy':
      ensure      => 'running',
      enable      => true,
      hasstatus   => true,
      hasrestart  => true,
      subscribe   => Exec['engine-setup'],
    }
  }

  exec { 'engine-setup':
    refreshonly => true,
    path        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
    command     => "yes 'Yes' | engine-setup --config-append=${answers_file}",
    subscribe   => Package['ovirt-engine'],
    require     => File['ovirt-engine-setup.conf'],
  }
}

