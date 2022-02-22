#
# Class to execute heat dbsync
#
# ==Parameters
#
# [*extra_params*]
#   (Optional) String of extra command line parameters to append
#   to the heat-manage db_sync command. These will be inserted
#   in the command line between 'heat-manage' and 'db_sync'.
#   Defaults to '--config-file /etc/heat/heat.conf'
#
# [*db_sync_timeout*]
#   (Optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
class heat::db::sync(
  $extra_params    = '--config-file /etc/heat/heat.conf',
  $db_sync_timeout = 300,
) {

  include heat::deps
  include heat::params

  exec { 'heat-dbsync':
    command     => "heat-manage ${extra_params} db_sync",
    path        => '/usr/bin',
    user        => $::heat::params::user,
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['heat::install::end'],
      Anchor['heat::config::end'],
      Anchor['heat::dbsync::begin']
    ],
    notify      => Anchor['heat::dbsync::end'],
    tag         => 'openstack-db',
  }
}
