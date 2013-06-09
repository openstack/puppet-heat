node default {
  Exec {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  }

  # First, install a mysql server
  class { 'mysql::server': }
  # And create the database
  class { 'heat::db::mysql':
    password => 'heat',
  }

  # Configure the heat database
  # Only needed if heat::engine is declared
  class { 'heat::db':
  }
  # Common class
  class { 'heat': }
#  class { 'heat::params': }

  # Install the heat-api service
  # The keystone_password parameter is mandatory
  class { 'heat::api':
    keystone_password => 'password'
  }

  # Install heat-engine
  class { 'heat::engine':
  }

}
