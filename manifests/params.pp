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

      if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
        $qemu_agent_service_name  = 'qemu-guest-agent'
        $ovirt_agent_package_name = 'ovirt-guest-agent-common'
      } else {
        $qemu_agent_service_name  = 'qemu-ga'
        $ovirt_agent_package_name = 'ovirt-guest-agent'
      }

      $qemu_agent_package_name  = 'qemu-guest-agent'
      $ovirt_agent_service_name = 'ovirt-guest-agent'

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
