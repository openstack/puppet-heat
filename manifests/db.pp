# Configures the heat database
# This class will install the required libraries depending on the driver
# specified in the connection_string parameter
#
# == Parameters
#  [*database_connection*]
#    the connection string. format: [driver]://[user]:[password]@[host]/[database]
#
class heat::db (
  $database_connection = 'mysql://heat:heat@localhost/heat'
) {

  include heat::params

  Package<| title == 'heat-common' |> -> Class['heat::db']

  validate_re($database_connection,
    '(sqlite|mysql|posgres):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection {
    /^mysql:\/\//: {
      $backend_package = false
      include mysql::python
    }
    /^postgres:\/\//: {
      $backend_package = 'python-psycopg2'
    }
    /^sqlite:\/\//: {
      $backend_package = 'python-pysqlite2'
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'heat-backend-package':
      ensure => present,
      name   => $backend_package,
    }
  }

  heat_engine_config {
    'DEFAULT/database_connection': value => $database_connection;
  }

  heat_engine_config['DEFAULT/database_connection'] ~> Exec['heat-dbsync']

  exec { 'heat-db-setup':
    command     => $::heat::params::dbsync_command,
    path        => '/usr/bin',
    user        => $::heat::params::username,
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => heat_engine_config['DEFAULT/database_connection']
  }

}
