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
  $agent_package_ensure = 'present',
  $agent_package_name = $ovirt::params::guest_agent_package_name,
  $agent_service_ensure = 'running',
  $agent_service_enable = true,
  $agent_service_name = $ovirt::params::guest_agent_package_name,
  $manage_qemu_guest_agent = true,
  $qemu_guest_agent_ensure = 'running',
  $qemu_guest_agent_enable = true,
) inherits ovirt::params {

  include epel

  validate_bool($manage_qemu_guest_agent)

  if $manage_qemu_guest_agent {
    ensure_packages(['qemu-guest-agent'])

    service { 'qemu-ga':
      ensure      => $qemu_guest_agent_ensure,
      enable      => $qemu_guest_agent_enable,
      name        => 'qemu-ga',
      hasstatus   => true,
      hasrestart  => true,
      require     => Package['qemu-guest-agent'],
    }
  }

  package { 'ovirt-guest-agent':
    ensure  => $agent_package_ensure,
    name    => $agent_package_name,
    before  => Service['ovirt-guest-agent'],
    require => Yumrepo['epel'],
  }

  service { 'ovirt-guest-agent':
    ensure      => $agent_service_ensure,
    enable      => $agent_service_enable,
    name        => $agent_service_name,
    hasstatus   => true,
    hasrestart  => true,
  }

}
