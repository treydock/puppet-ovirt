# Private class
class ovirt::engine::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'ovirt-engine':
    ensure  => installed,
  }

  if $ovirt::engine::config_allinone {
    package { 'ovirt-engine-setup-plugin-allinone':
      ensure  => installed,
      require => Package['ovirt-engine'],
    }
  }
}
