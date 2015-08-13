#
# Class to execute heat dbsync
#
class heat::db::sync {

  include ::heat::params

  Package <| tag == 'heat-package' |> ~> Exec['heat-dbsync']
  Exec['heat-dbsync'] ~> Service <| tag == 'heat-service' |>

  Heat_config<||> -> Exec['heat-dbsync']
  Heat_config<| title == 'database/connection' |> ~> Exec['heat-dbsync']

  exec { 'heat-dbsync':
    command     => $::heat::params::dbsync_command,
    path        => '/usr/bin',
    user        => 'heat',
    refreshonly => true,
    logoutput   => on_failure,
  }

}
