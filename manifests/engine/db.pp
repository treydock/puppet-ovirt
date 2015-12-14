# See README.md for details
define ovirt::engine::db ($password, $user = $title) {
  include postgresql::server

  postgresql::server::pg_hba_rule { "allow ${name} access on 0.0.0.0/0 using md5":
    type        => 'host',
    database    => $name,
    user        => $user,
    address     => '0.0.0.0/0',
    auth_method => 'md5',
    order       => '010',
  }

  postgresql::server::pg_hba_rule { "allow ${name} access on ::0/0 using md5":
    type        => 'host',
    database    => $name,
    user        => $user,
    address     => '::0/0',
    auth_method => 'md5',
    order       => '011',
  }

  postgresql::server::role { $name:
    username      => $user,
    password_hash => postgresql_password($user, $password),
    before        => Postgresql::Server::Database[$name],
  }

  postgresql::server::database { $name:
    encoding => 'UTF8',
    locale   => 'en_US.UTF-8',
    template => 'template0',
    owner    => $user,
  }
}
