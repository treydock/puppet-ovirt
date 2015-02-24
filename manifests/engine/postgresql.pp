# Private class
class ovirt::engine::postgresql {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $ovirt::engine::manage_postgresql_server {
    class { 'postgresql::server':
      manage_firewall => $ovirt::engine::manage_firewall,
    }

    postgresql::server::config_entry { 'max_connections':
      value => 150,
    }

    postgresql::server::pg_hba_rule { 'allow engine access on 0.0.0.0/0 using md5':
      type        => 'host',
      database    => $ovirt::engine::db_name,
      user        => $ovirt::engine::db_user,
      address     => '0.0.0.0/0',
      auth_method => 'md5',
      order       => '010',
    }

    postgresql::server::pg_hba_rule { 'allow engine access on ::0/0 using md5':
      type        => 'host',
      database    => $ovirt::engine::db_name,
      user        => $ovirt::engine::db_user,
      address     => '::0/0',
      auth_method => 'md5',
      order       => '011',
    }

    postgresql::server::role { $ovirt::engine::db_user:
      password_hash => postgresql_password($ovirt::engine::db_user, $ovirt::engine::db_password),
      before        => Postgresql::Server::Database[$ovirt::engine::db_name],
    }

    postgresql::server::database { $ovirt::engine::db_name:
      encoding  => 'UTF8',
      locale    => 'en_US.UTF-8',
      template  => 'template0',
      owner     => $ovirt::engine::db_user,
    }
  }
}
