# Class heat::trustee
#
#  heat trustee configuration
#
# == Parameters
#
# [*password*]
#   (optional) Password for connecting to Cinder services in
#   admin context through the OpenStack Identity service.
#   Defaults to $facts['os_service_default']
#
# [*auth_type*]
#   (optional) Name of the auth type to load (string value)
#   Defaults to 'password'
#
# [*auth_url*]
#   (optional) Points to the OpenStack Identity server IP and port.
#   This is the Identity (keystone) admin API server IP and port value,
#   and not the Identity service API IP and port.
#   Defaults to 'http://127.0.0.1:5000/'
#
# [*username*]
#   (optional) Username for connecting to Cinder services in admin context
#   through the OpenStack Identity service.
#   Defaults to 'heat'
#
# [*user_domain_name*]
#   (optional) User Domain name for connecting to Cinder services in
#   admin context through the OpenStack Identity service.
#   Defaults to 'Default'
#
class heat::trustee (
  $password         = undef,
  $auth_type        = undef,
  $auth_url         = undef,
  $username         = undef,
  $user_domain_name = undef,
) {

  include heat::deps

  if defined(Class[heat::keystone::authtoken]) {
    # TODO(tkajinam): The following logic was added to keep compatibility with
    # the old version which determines the trustee parameters based on
    # authtoken parameters. This should be removed after Y release.
    $password_real         = pick($password, $::heat::keystone::authtoken::password)
    $auth_type_real        = pick($auth_type, $::heat::keystone::authtoken::auth_type)
    $auth_url_real         = pick($auth_url, $::heat::keystone::authtoken::auth_url)
    $username_real         = pick($username, $::heat::keystone::authtoken::username)
    $user_domain_name_real = pick($user_domain_name, $::heat::keystone::authtoken::user_domain_name)
  } else {
    $password_real         = pick($password, $facts['os_service_default'])
    $auth_type_real        = pick($auth_type, 'password')
    $auth_url_real         = pick($auth_url, 'http://127.0.0.1:5000/')
    $username_real         = pick($username, 'heat')
    $user_domain_name_real = pick($user_domain_name, 'Default')
  }

  heat_config {
    'trustee/password':         value => $password_real, secret => true;
    'trustee/auth_type':        value => $auth_type_real;
    'trustee/auth_url':         value => $auth_url_real;
    'trustee/username':         value => $username_real;
    'trustee/user_domain_name': value => $user_domain_name_real;
  }
}
