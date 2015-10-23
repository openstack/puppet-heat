#
# Class to execute heat dbsync
#
class heat::db::sync {

  include ::heat::deps
  include ::heat::params

  exec { 'heat-dbsync':
    command     => $::heat::params::dbsync_command,
    path        => '/usr/bin',
    user        => 'heat',
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['heat::install::end'],
      Anchor['heat::config::end'],
      Anchor['heat::dbsync::begin']
    ],
    notify      => Anchor['heat::dbsync::end'],
  }
}
