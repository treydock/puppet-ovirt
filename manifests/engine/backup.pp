# == Class: ovirt::engine::backup
#
# The ovirt::engine::backup class enables backups of the oVirt engine.
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
class ovirt::engine::backup (
  $ensure               = 'present',
  $backup_dir           = '/tmp/engine-backup',
  $backup_rotate        = 30,
  $delete_before_backup = true,
  $backup_scope         = 'all',
  $time                 = ['23', '5'],
) {

  include ovirt::engine

  validate_bool($delete_before_backup)
  validate_re($backup_scope, ['^all$','^db$'])

  cron { 'engine-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/enginebackup.sh',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    require => File['enginebackup.sh'],
  }

  file { 'enginebackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/enginebackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('ovirt/enginebackup.sh.erb'),
    require => Package['ovirt-engine'],
  }

  file { 'enginebackupdir':
    ensure => 'directory',
    path   => $backup_dir,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

}
