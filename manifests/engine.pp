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
  $manage_postgresql_server = true,
  $config_allinone          = false,
  $local_storage_path       = '/var/lib/images',
  $superuser_pass           = undef,
  $application_mode         = 'both',
  $storage_type             = 'nfs',
  $organization             = $::domain,
  $nfs_config_enabled       = true,
  $iso_domain_name          = 'ISO_DOMAIN',
  $iso_domain_mount_point   = '/var/lib/exports/iso',
  $admin_password           = 'admin',
  $db_name                  = 'engine',
  $db_user                  = 'engine',
  $db_password              = 'engine',
  $db_host                  = 'localhost',
  $db_port                  = '5432',
  $firewall_manager         = $ovirt::params::firewall_manager,
  $manage_firewall          = true,
  $update_firewall          = undef,
  $websocket_proxy_config   = true,
  $run_engine_setup         = true,
  $storeconfigs_enabled     = false,
  $notifier_config_path     = $ovirt::params::engine_notifier_config_path,
  $notifier_mail_server     = undef,
  $enable_reports           = false,
  $reports_admin_password   = 'admin',
  $reports_db_user          = 'ovirt_engine_reports',
  $reports_db_password      = 'ovirt_engine_reports',
  $reports_db_name          = 'ovirt_engine_reports',
  $reports_db_host          = 'localhost',
  $reports_db_port          = '5432',
  $dwh_db_user              = 'ovirt_engine_history',
  $dwh_db_password          = 'ovirt_engine_history',
  $dwh_db_name              = 'ovirt_engine_history',
  $dwh_db_host              = 'localhost',
  $dwh_db_port              = '5432',
) inherits ovirt::params {

  $answers_file = '/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf'

  validate_bool($manage_postgresql_server)
  validate_re($application_mode, ['^both$','^virt$','^gluster$'])
  validate_re($storage_type, ['^nfs$','^fs$','^iscsi$','^posixfs$', '^none$'])
  validate_bool($config_allinone)
  validate_bool($nfs_config_enabled)
  validate_bool($manage_firewall)
  validate_bool($websocket_proxy_config)
  validate_bool($storeconfigs_enabled)
  validate_bool($enable_reports)

  if $manage_postgresql_server {
    $postgres_provisioning_enabled = false
  } else {
    $postgres_provisioning_enabled = true
  }

  if $manage_firewall {
    $update_firewall_real = pick($update_firewall, false)
  } else {
    $update_firewall_real = pick($update_firewall, true)
  }

  include ovirt
  include ovirt::repo
  include ovirt::engine::postgresql
  include ovirt::engine::install
  include ovirt::engine::config
  include ovirt::engine::service

  anchor { 'ovirt::engine::start': }->
  Class['ovirt::repo']->
  Class['ovirt::engine::postgresql']->
  Class['ovirt::engine::install']->
  Class['ovirt::engine::config']->
  Class['ovirt::engine::service']->
  anchor { 'ovirt::engine::end': }

  if $config_allinone {
    class { 'ovirt::node':
      manage_firewall      => $manage_firewall,
      storeconfigs_enabled => $storeconfigs_enabled,
      register             => false,
      before               => Anchor['ovirt::engine::end'],
    }
  }

}
