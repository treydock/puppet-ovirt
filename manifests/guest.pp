# == Class: ovirt::guest
#
# The ovirt::guest class manages oVirt Virtual Machines
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt::guest (
  $manage_qemu_agent = true,
  $qemu_agent_package_ensure = 'present',
  $qemu_agent_package_name = $ovirt::params::qemu_agent_package_name,
  $qemu_agent_service_ensure = 'running',
  $qemu_agent_service_enable = true,
  $qemu_agent_service_name = $ovirt::params::qemu_agent_service_name,
  $ovirt_agent_package_ensure = 'present',
  $ovirt_agent_package_name = $ovirt::params::ovirt_agent_package_name,
  $ovirt_agent_service_ensure = 'running',
  $ovirt_agent_service_enable = true,
  $ovirt_agent_service_name = $ovirt::params::ovirt_agent_service_name,
) inherits ovirt::params {

  validate_bool($manage_qemu_agent)

  case $::manufacturer {
    'oVirt': {
      include epel

      if $manage_qemu_agent {
        package { 'qemu-guest-agent':
          ensure => $qemu_agent_package_ensure,
          name   => $qemu_agent_package_name,
          before => Service['qemu-guest-agent'],
        }

        service { 'qemu-guest-agent':
          ensure     => $qemu_agent_service_ensure,
          enable     => $qemu_agent_service_enable,
          name       => $qemu_agent_service_name,
          hasstatus  => true,
          hasrestart => true,
        }
      }

      package { 'ovirt-guest-agent':
        ensure  => $ovirt_agent_package_ensure,
        name    => $ovirt_agent_package_name,
        before  => Service['ovirt-guest-agent'],
        require => Yumrepo['epel'],
      }

      service { 'ovirt-guest-agent':
        ensure     => $ovirt_agent_service_ensure,
        enable     => $ovirt_agent_service_enable,
        name       => $ovirt_agent_service_name,
        hasstatus  => true,
        hasrestart => true,
      }
    }
    # If we are not oVirt, do not do anything.
    default: { }
  }



}
