# Installs & configure the heat CloudFormation API service
#
class heat::api_cfn (
  $enabled           = true,
  $keystone_host     = '127.0.0.1',
  $keystone_port     = '35357',
  $keystone_protocol = 'http',
  $keystone_user     = 'heat',
  $keystone_tenant   = 'services',
  $keystone_password = false,
  $keystone_ec2_uri  = 'http://127.0.0.1:5000/v2.0/ec2tokens',
  $auth_uri          = 'http://127.0.0.1:5000/v2.0',
  $bind_host         = '0.0.0.0',
  $bind_port         = '8000',
  $verbose           = false,
  $debug             = false,
) {

  include heat::params

  validate_string($keystone_password)

  Heat_config<||> ~> Service['heat-api-cfn']

  Package['heat-api-cfn'] -> Heat_config<||>
  Package['heat-api-cfn'] -> Service['heat-api-cfn']
  package { 'heat-api-cfn':
    ensure => installed,
    name   => $::heat::params::api_cfn_package_name,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  Package['heat-common'] -> Service['heat-api-cfn']

  service { 'heat-api-cfn':
    ensure     => $service_ensure,
    name       => $::heat::params::api_cfn_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['heat::db'],
  }

  heat_config {
    'DEFAULT/debug'                  : value => $debug;
    'DEFAULT/verbose'                : value => $verbose;
    'DEFAULT/log_dir'                : value => $::heat::params::log_dir;
    'DEFAULT/bind_host'              : value => $bind_host;
    'DEFAULT/bind_port'              : value => $bind_port;
    'ec2authtoken/keystone_ec2_uri'  : value => $keystone_ec2_uri;
    'ec2authtoken/auth_uri'          : value => $auth_uri;
    'keystone_authtoken/auth_host'         : value => $keystone_host;
    'keystone_authtoken/auth_port'         : value => $keystone_port;
    'keystone_authtoken/auth_protocol'     : value => $keystone_protocol;
    'keystone_authtoken/admin_tenant_name' : value => $keystone_tenant;
    'keystone_authtoken/admin_user'        : value => $keystone_user;
    'keystone_authtoken/admin_password'    : value => $keystone_password;
  }
}
