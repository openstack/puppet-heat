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
  $password         = $facts['os_service_default'],
  $auth_type        = 'password',
  $auth_url         = 'http://127.0.0.1:5000/',
  $username         = 'heat',
  $user_domain_name = 'Default',
) {
  include heat::deps

  heat_config {
    'trustee/password':         value => $password, secret => true;
    'trustee/auth_type':        value => $auth_type;
    'trustee/auth_url':         value => $auth_url;
    'trustee/username':         value => $username;
    'trustee/user_domain_name': value => $user_domain_name;
  }
}
