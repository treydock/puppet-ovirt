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
          $ovirt_repo_baseurl = 'http://ovirt.org/releases/stable/rpm/Fedora/$releasever/'
          $firewall_manager   = 'firewalld'

        }
        default: {
          $ovirt_repo_baseurl = 'http://ovirt.org/releases/stable/rpm/EL/$releasever/'
          $firewall_manager   = 'iptables'
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
