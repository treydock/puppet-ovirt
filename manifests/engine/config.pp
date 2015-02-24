# Private class
class ovirt::engine::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $ovirt::engine::manage_firewall {
    $update_firewall = pick($ovirt::engine::update_firewall, false)

    firewall { '100 allow ovirt-websocket-proxy':
      port    => '6100',
      proto   => 'tcp',
      action  => 'accept',
    }
  } else {
    $update_firewall = pick($ovirt::engine::update_firewall, true)
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
        ensure  => 'present',
        key     => $::ovirt_engine_ssh_pubkey,
        type    => 'ssh-rsa',
        user    => 'root',
        tag     => 'ovirt::engine',
      }
    }

    Host <<| tag == 'ovirt::node' |>>
  }
}
