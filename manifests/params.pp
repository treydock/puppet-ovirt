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

  $version = '3.5'

  case $::osfamily {
    'RedHat': {
      $engine_notifier_config_path  = '/etc/ovirt-engine/notifier/notifier.conf.d/99-local.conf'

      if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
        $qemu_agent_service_name  = 'qemu-guest-agent'
        $ovirt_agent_package_name = 'ovirt-guest-agent-common'
        $manage_jpackage_repo     = false
        $vdsm_sudo_template       = 'ovirt/vdsm.sudo.el7.erb'
      } else {
        $qemu_agent_service_name  = 'qemu-ga'
        $ovirt_agent_package_name = 'ovirt-guest-agent'
        $manage_jpackage_repo     = true
        $vdsm_sudo_template       = 'ovirt/vdsm.sudo.el6.erb'
      }

      $qemu_agent_package_name  = 'qemu-guest-agent'
      $ovirt_agent_service_name = 'ovirt-guest-agent'

      case $::operatingsystem {
        'Fedora': {
          $firewall_manager       = 'firewalld'
          $manage_gluster_repos   = false
          $patternfly1_repo_osbit = 'fedora-$releasever-$basearch'
        }
        default: {
          $firewall_manager       = 'iptables'
          $manage_gluster_repos   = true
          $patternfly1_repo_osbit = "epel-${::operatingsystemmajrelease}-\$basearch"
        }
      }

    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
