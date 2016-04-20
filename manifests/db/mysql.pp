# == Class: heat::db::mysql
#
# The heat::db::mysql class creates a MySQL database for heat.
# It must be used on the MySQL server
#
# === Parameters
#
# [*password*]
#   (Mandatory) Password to connect to the database.
#   Defaults to 'false'.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'heat'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'heat'.
#
# [*host*]
#   (Optional) The default source host user is allowed to connect from.
#   Defaults to '127.0.0.1'
#
# [*allowed_hosts*]
#   (Optional) Other hosts the user is allowed to connect from.
#   Defaults to 'undef'.
#
# [*charset*]
#   (Optional) The database charset.
#   Defaults to 'utf8'
#
# [*collate*]
#   (Optional) The database collate.
#   Only used with mysql modules >= 2.2.
#   Defaults to 'utf8_general_ci'
#
class heat::db::mysql(
  $password      = false,
  $dbname        = 'heat',
  $user          = 'heat',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
) {

  include ::heat::deps

  validate_string($password)

  ::openstacklib::db::mysql { 'heat':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  Anchor['heat::db::begin']
  ~> Class['heat::db::mysql']
  ~> Anchor['heat::db::end']
}
