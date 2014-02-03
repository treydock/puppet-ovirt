# == Class: ovirt::params
#
# The ovirt configuration settings.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt::params {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          $glusterfs_repo_name            = 'glusterfs-fedora'
          $glusterfs_repo_baseurl         = 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/Fedora/fedora-$releasever/$basearch/'
          $glusterfs_noarch_repo_name     = 'glusterfs-noarch-fedora'
          $glusterfs_noarch_repo_baseurl  = 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/Fedora/fedora-$releasever/noarch/'
          $ovirt_stable_repo_baseurl      = 'http://ovirt.org/releases/stable/rpm/Fedora/$releasever/'
          $ovirt_release_repo_baseurl     = 'http://resources.ovirt.org/releases/RELEASE/rpm/Fedora/$releasever/'
          $firewall_manager               = 'firewalld'

        }
        default: {
          $glusterfs_repo_name            = 'glusterfs-epel'
          $glusterfs_repo_baseurl         = 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/'
          $glusterfs_noarch_repo_name     = 'glusterfs-noarch-epel'
          $glusterfs_noarch_repo_baseurl  = 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch'
          $ovirt_stable_repo_baseurl      = 'http://ovirt.org/releases/stable/rpm/EL/$releasever/'
          $ovirt_release_repo_baseurl     = 'http://resources.ovirt.org/releases/RELEASE/rpm/EL/$releasever/'
          $firewall_manager               = 'iptables'
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
