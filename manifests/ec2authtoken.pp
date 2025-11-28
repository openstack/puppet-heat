# class: heat::ec2authtoken
#
# Configure the ec2authtoken section in the configuration file
#
# === Parameters
#
# [*password*]
#   (Required) Password for connecting to Keystone services
#
# [*username*]
#   (Optional) The name of the service user
#   Defaults to 'heat'
#
# [*auth_url*]
#   (Optional) The URL to use for authentication.
#   Defaults to 'http://127.0.0.1:5000'
#
# [*project_name*]
#   (Optional) Service project name
#   Defaults to 'services'
#
# [*user_domain_name*]
#   (Optional) Name of domain for $username
#   Defaults to 'Default'
#
# [*project_domain_name*]
#   (Optional) Name of domain for $project_name
#   Defaults to 'Default'
#
# [*system_scope*]
#   (Optional) Scope for system operations
#   Defaults to $facts['os_service_default']
#
# [*auth_type*]
#   (Optional) Authentication type to load
#   Defaults to 'password'
#
# [*insecure*]
#   (Optional) If true, explicitly allow TLS without checking server cert
#   against any certificate authorities.  WARNING: not recommended.  Use with
#   caution.
#   Defaults to $facts['os_service_default']
#
# [*cafile*]
#   (Optional) A PEM encoded Certificate Authority to use when verifying HTTPs
#   connections.
#   Defaults to $facts['os_service_default'].
#
# [*certfile*]
#   (Optional) Required if identity server requires client certificate
#   Defaults to $facts['os_service_default'].
#
# [*keyfile*]
#   (Optional) Required if identity server requires client certificate
#   Defaults to $facts['os_service_default'].
#
# [*region_name*]
#   (Optional) The region in which the identity server can be found.
#   Defaults to $facts['os_service_default'].
#
# [*valid_interfaces*]
#   (Optional) List of interfaces, in order of preference, for endpoint URL.
#   Defaults to $facts['os_service_default'].
#
# [*service_name*]
#  (Optional) The name of the service as it appears in the service catalog.
#  Defaults to $facts['os_service_default'].
#
# [*service_type*]
#  (Optional) The type of the service as it appears in the service catalog.
#  Defaults to $facts['os_service_default'].
#
# [*timeout*]
#  (Optional) Timeout value for http requests .
#  Defaults to $facts['os_service_default'].
#
class heat::ec2authtoken (
  String[1] $password,
  $username            = 'heat',
  $auth_url            = 'http://127.0.0.1:5000',
  $project_name        = 'services',
  $user_domain_name    = 'Default',
  $project_domain_name = 'Default',
  $system_scope        = $facts['os_service_default'],
  $auth_type           = 'password',
  $insecure            = $facts['os_service_default'],
  $cafile              = $facts['os_service_default'],
  $certfile            = $facts['os_service_default'],
  $keyfile             = $facts['os_service_default'],
  $region_name         = $facts['os_service_default'],
  $valid_interfaces    = $facts['os_service_default'],
  $service_name        = $facts['os_service_default'],
  $service_type        = $facts['os_service_default'],
  $timeout             = $facts['os_service_default'],
) {
  include heat::deps

  if is_service_default($system_scope) {
    $project_name_real = $project_name
    $project_domain_name_real = $project_domain_name
  } else {
    $project_name_real = $facts['os_service_default']
    $project_domain_name_real = $facts['os_service_default']
  }

  heat_config {
    'ec2authtoken/password':            value => $password, secret => true;
    'ec2authtoken/username':            value => $username;
    'ec2authtoken/auth_url':            value => $auth_url;
    'ec2authtoken/project_name':        value => $project_name_real;
    'ec2authtoken/user_domain_name':    value => $user_domain_name;
    'ec2authtoken/project_domain_name': value => $project_domain_name_real;
    'ec2authtoken/system_scope':        value => $system_scope;
    'ec2authtoken/auth_type':           value => $auth_type;
    'ec2authtoken/insecure':            value => $insecure;
    'ec2authtoken/cafile':              value => $cafile;
    'ec2authtoken/certfile':            value => $certfile;
    'ec2authtoken/keyfile':             value => $keyfile;
    'ec2authtoken/region_name':         value => $region_name;
    'ec2authtoken/valid_interfaces':    value => join(any2array($valid_interfaces), ',');
    'ec2authtoken/service_name':        value => $service_name;
    'ec2authtoken/service_type':        value => $service_type;
    'ec2authtoken/timeout':             value => $timeout;
  }
}
