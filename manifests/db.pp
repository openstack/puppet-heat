# == Class: heat::db
#
#  Configure the Heat database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/heat/heat.sqlite'.
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_retry_interval*]
#   Interval between retries of opening a sql connection.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $::os_service_default.
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# [*database_db_max_retries*]
#   (Optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*sync_db*]
#   (Optional) Run db sync on nodes after connection setting has been set.
#   Defaults to true
#
# DEPRECATED PARAMETERS
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to undef
#
class heat::db (
  $database_connection              = 'sqlite:////var/lib/heat/heat.sqlite',
  $database_connection_recycle_time = $::os_service_default,
  $database_max_pool_size           = $::os_service_default,
  $database_max_retries             = $::os_service_default,
  $database_retry_interval          = $::os_service_default,
  $database_max_overflow            = $::os_service_default,
  $database_pool_timeout            = $::os_service_default,
  $database_db_max_retries          = $::os_service_default,
  $sync_db                          = true,
  # DEPRECATED PARAMETERS
  $database_min_pool_size           = undef,
) {

  include heat::deps

  if $::heat::database_min_pool_size or $database_min_pool_size {
    warning('The database_min_pool_size parameter is deprecated, and will be removed in a future release.')
  }

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use heat::<myparam> if heat::db::<myparam> isn't specified.
  $database_connection_real = pick($::heat::database_connection, $database_connection)
  $database_connection_recycle_time_real = pick($::heat::database_idle_timeout, $database_connection_recycle_time)
  $database_max_pool_size_real = pick($::heat::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::heat::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::heat::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::heat::database_max_overflow, $database_max_overflow)
  $sync_db_real = pick($::heat::sync_db, $sync_db)

  oslo::db { 'heat_config':
    connection              => $database_connection_real,
    connection_recycle_time => $database_connection_recycle_time_real,
    max_pool_size           => $database_max_pool_size_real,
    max_retries             => $database_max_retries_real,
    retry_interval          => $database_retry_interval_real,
    max_overflow            => $database_max_overflow_real,
    pool_timeout            => $database_pool_timeout,
    db_max_retries          => $database_db_max_retries,
  }

  if $sync_db_real {
    include heat::db::sync
  }

}
