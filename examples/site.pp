node default {
  # First, install a mysql server
  class { 'mysql::server': }

  # And create the database
  class { 'heat::db::mysql':
    password => 'heat',
  }

  class { 'heat::keystone::authtoken':
    password => 'password',
  }
  class { 'heat::db':
    database_connection => 'mysql+pymysql://heat:heat@localhost/heat',
  }

  # Common class
  class { 'heat':
  }

  # Install heat-engine
  class { 'heat::engine':
    auth_encryption_key => 'whatever-key-you-like',
  }

  # Install the heat-api service
  class { 'heat::api': }

}
