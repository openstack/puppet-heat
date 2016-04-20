# == Class: heat::keystone::domain
#
# Configures Heat domain in Keystone.
#
# === Parameters
#
# [*domain_name*]
#   Heat domain name. Defaults to 'heat'.
#
# [*domain_admin*]
#   Keystone domain admin user which will be created. Defaults to 'heat_admin'.
#
# [*domain_admin_email*]
#   Keystone domain admin user email address. Defaults to 'heat_admin@localhost'.
#
# [*domain_password*]
#   Keystone domain admin user password. Defaults to 'changeme'.
#
# [*manage_domain*]
#   Whether manage or not the domain creation.
#   If using the default domain, it needs to be False because puppet-keystone
#   can already manage it.
#   Defaults to 'true'.
#
# [*manage_user*]
#   Whether manage or not the user creation.
#   Defaults to 'true'.
#
# [*manage_role*]
#   Whether manage or not the user role creation.
#   Defaults to 'true'.
#
class heat::keystone::domain (
  $domain_name        = 'heat',
  $domain_admin       = 'heat_admin',
  $domain_admin_email = 'heat_admin@localhost',
  $domain_password    = 'changeme',
  $manage_domain      = true,
  $manage_user        = true,
  $manage_role        = true,
) {

  include ::heat::deps
  include ::heat::params

  if $manage_domain {
    ensure_resource('keystone_domain', $domain_name, {
      'ensure'  => 'present',
      'enabled' => true,
    })
  }
  if $manage_user {
    ensure_resource('keystone_user', "${domain_admin}::${domain_name}", {
      'ensure'   => 'present',
      'enabled'  => true,
      'email'    => $domain_admin_email,
      'password' => $domain_password,
    })
  }
  if $manage_role {
    ensure_resource('keystone_user_role', "${domain_admin}::${domain_name}@::${domain_name}", {
      'roles' => ['admin'],
    })
  }

  heat_config {
    'DEFAULT/stack_domain_admin':          value => $domain_admin;
    'DEFAULT/stack_domain_admin_password': value => $domain_password, secret => true;
    'DEFAULT/stack_user_domain_name':      value => $domain_name;
  }
}
