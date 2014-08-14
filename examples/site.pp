### Begin top scope parameters ###
$configure_database     = true
$configure_keystone     = true
$configure_heat         = true
$region                 = 'RegionOne'
$keystone_host          = '127.0.0.1'
$keystone_password      = 'changeme'
$db_host                = '127.0.0.1'
$db_password            = 'changeme'
$db_package_name        = undef
$auth_encryption_key    = 'whatever-key-you-like'
$heat_keystone_password = 'changeme'
$heat_host              = '127.0.0.1'
### End top scope parameters ###

node default {
  Exec {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  }

  if ($configure_database) {
    # Install MySQL or MariaDB
    class { 'mysql::server':
      package_name => $db_package_name,
    }
    class { 'heat::db::mysql':
      mysql_module => '2.2',
      host         => $db_host,
      password     => $db_password,
    }
  }

  if ($configure_keystone) {
    # Configure Keystone for Heat support
    class { 'heat::keystone::auth':
      password         => $heat_keystone_password,
      public_address   => $heat_host,
      admin_address    => $heat_host,
      internal_address => $heat_host,
    }
  }

  if ($configure_heat) {
    # Common class
    class { 'heat':
      mysql_module      => '2.2',
      keystone_host     => $keystone_host,
      keystone_password => $keystone_password,
      sql_connection    => "mysql://heat:${db_password}@${db_host}/heat",
    }
    # Install heat-engine
    class { 'heat::engine':
      auth_encryption_key => $auth_encryption_key,
    }
    # Install the heat-api service
    class { 'heat::api': }
  }
}
