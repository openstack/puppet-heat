# == Class: heat::db::postgresql
#
# Class that configures postgresql for heat
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'heat'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'heat'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
class heat::db::postgresql(
  $password,
  $dbname     = 'heat',
  $user       = 'heat',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  include heat::deps

  openstacklib::db::postgresql { 'heat':
    password   => $password,
    dbname     => $dbname,
    user       => $user,
    encoding   => $encoding,
    privileges => $privileges,
  }

  Anchor['heat::db::begin']
  ~> Class['heat::db::postgresql']
  ~> Anchor['heat::db::end']
}
