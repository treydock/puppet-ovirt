# Private class
class ovirt::engine::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $ovirt::engine::manage_firewall {
    firewall { '100 allow ovirt-websocket-proxy':
      port   => '6100',
      proto  => 'tcp',
      action => 'accept',
    }
  }

  file { 'ovirt-engine-setup.conf':
    ensure  => present,
    path    => $ovirt::engine::answers_file,
    content => template('ovirt/answers.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  if $ovirt::engine::run_engine_setup {
    exec { 'engine-setup':
      refreshonly => true,
      path        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
      command     => "yes 'Yes' | engine-setup --config-append=${ovirt::engine::answers_file}",
      timeout     => 0,
      subscribe   => Package['ovirt-engine'],
      require     => File['ovirt-engine-setup.conf'],
    }
  }

  if $ovirt::engine::storeconfigs_enabled {
    if $::ovirt_engine_ssh_pubkey {
      @@ssh_authorized_key { 'ovirt-engine':
        ensure => 'present',
        key    => $::ovirt_engine_ssh_pubkey,
        type   => 'ssh-rsa',
        user   => 'root',
        tag    => 'ovirt::engine',
      }
    }

    Host <<| tag == 'ovirt::node' |>>
  }

  if $ovirt::engine::notifier_mail_server {
    shellvar { 'ovirt-engine-notifier MAIL_SERVER':
      ensure   => present,
      target   => $ovirt::engine::notifier_config_path,
      variable => 'MAIL_SERVER',
      value    => $ovirt::engine::notifier_mail_server,
      notify   => Service['ovirt-engine-notifier'],
    }
  }
}
