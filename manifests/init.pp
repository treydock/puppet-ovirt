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
  $ovirt_repo_baseurl = $ovirt::params::ovirt_repo_baseurl
) inherits ovirt::params {

  include epel

  yumrepo { 'glusterfs-epel':
    baseurl   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/',
    descr     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled   => '1',
    gpgcheck  => '0',
    require   => Yumrepo['epel'],
  }->
  yumrepo { 'glusterfs-noarch-epel':
    baseurl   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch',
    descr     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled   => '1',
    gpgcheck  => '0',
  }->
  yumrepo { 'ovirt-stable':
    baseurl   => $ovirt_repo_baseurl,
    descr     => 'Older Stable builds of the oVirt project',
    enabled   => '1',
    gpgcheck  => '0',
  }
}
