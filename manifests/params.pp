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
          $ovirt_release_url              = 'http://resources.ovirt.org/releases/ovirt-release-fedora.noarch.rpm'
          $firewall_manager               = 'firewalld'

        }
        default: {
          $ovirt_release_url              = 'http://resources.ovirt.org/releases/ovirt-release-el.noarch.rpm'
          $firewall_manager               = 'iptables'
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
