# Private class
class ovirt::engine::postgresql {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $ovirt::engine::manage_postgresql_server {
    include postgresql::server

    postgresql::server::config_entry { 'max_connections':
      value => 150,
    }

    ovirt::engine::db { $ovirt::engine::db_name:
      user     => $ovirt::engine::db_user,
      password => $ovirt::engine::db_password,
    }

    if $ovirt::engine::enable_reports {
      ovirt::engine::db { $ovirt::engine::reports_db_name:
        user     => $ovirt::engine::reports_db_user,
        password => $ovirt::engine::reports_db_password,
      }

      ovirt::engine::db { $ovirt::engine::dwh_db_name:
        user     => $ovirt::engine::dwh_db_user,
        password => $ovirt::engine::dwh_db_password,
      }
    }
  }
}
