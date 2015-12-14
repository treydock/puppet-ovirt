# Private class
class ovirt::engine::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'ovirt-engine':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  if $ovirt::engine::websocket_proxy_config {
    service { 'ovirt-websocket-proxy':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Service['ovirt-engine'],
    }
  }

  if $ovirt::engine::notifier_mail_server {
    service { 'ovirt-engine-notifier':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Service['ovirt-engine'],
    }
  }
}
