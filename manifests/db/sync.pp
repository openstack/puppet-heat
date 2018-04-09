#
# Class to execute heat dbsync
#
# ==Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the heat-manage db_sync command. These will be inserted
#   in the command line between 'heat-manage' and 'db_sync'.
#   Defaults to '--config-file /etc/heat/heat.conf'
#
class heat::db::sync(
  $extra_params = '--config-file /etc/heat/heat.conf',
) {

  include ::heat::deps

  exec { 'heat-dbsync':
    command     => "heat-manage ${extra_params} db_sync",
    path        => '/usr/bin',
    user        => 'heat',
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
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
