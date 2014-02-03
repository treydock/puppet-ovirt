# == Class: ovirt
#
# This class contains the common requirements of ovirt::engine and ovirt::node.
#
# === Parameters
#
# [*ovirt_repo_baseurl*]
#   The baseurl for the ovirt repo.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt (
  $release_version            = '3.3.3',
  $ovirt_stable_repo_baseurl  = $ovirt::params::ovirt_stable_repo_baseurl,
  $ovirt_release_repo_baseurl = 'UNSET'
) inherits ovirt::params {

  include epel

  $ovirt_release_repo_baseurl_real = $ovirt_release_repo_baseurl ? {
    'UNSET' => regsubst($ovirt::params::ovirt_release_repo_baseurl, 'RELEASE', $release_version),
    default => $ovirt_release_repo_baseurl,
  }

  yumrepo { 'glusterfs':
    name      => $ovirt::params::glusterfs_repo_name,
    baseurl   => $ovirt::params::glusterfs_repo_baseurl,
    descr     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled   => '1',
    gpgcheck  => '0',
    require   => Yumrepo['epel'],
  }->
  yumrepo { 'glusterfs-noarch':
    name      => $ovirt::params::glusterfs_noarch_repo_name,
    baseurl   => $ovirt::params::glusterfs_noarch_repo_baseurl,
    descr     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled   => '1',
    gpgcheck  => '0',
  }->
  yumrepo { 'ovirt-stable':
    baseurl   => $ovirt_stable_repo_baseurl,
    descr     => 'Older Stable builds of the oVirt project',
    enabled   => '1',
    gpgcheck  => '0',
  }->
  yumrepo { 'ovirt-release':
    name      => "ovirt-${release_version}",
    baseurl   => $ovirt_release_repo_baseurl_real,
    descr     => "oVirt ${release_version} release",
    enabled   => '1',
    gpgcheck  => '0',
  }
}
