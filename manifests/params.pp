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
      $ovirt_release_url        = 'http://resources.ovirt.org/pub/yum-repo/ovirt-release34.rpm'
      $guest_agent_package_name = 'ovirt-guest-agent'
      $guest_agent_service_name = 'ovirt-guest-agent'
      case $::operatingsystem {
        'Fedora': {
          $firewall_manager     = 'firewalld'
        }
        default: {
          $firewall_manager     = 'iptables'
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
