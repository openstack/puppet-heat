# Installs & configure the heat CloudFormation api service
#
# == Parameters
#  [*enabled*]
#    should the service be enabled. Optional. Defaults to true
#
#  [*keystone_host*]
#    keystone's admin endpoint IP/Host. Optional. Defaults to 127.0.0.1
#
#  [*keystone_port*]
#    keystone's admin endpoint port. Optional. Defaults to 35357
#
#  [*keystone_protocol*] http/https
#    Optional. Defaults to https
#
#  [*keytone_user*] user to authenticate with
#    Optional. Defaults to heat
#
#  [*keystone_tenant*] tenant to authenticate with
#    Optional. Defaults to services
#
#  [*keystone_password*] password to authenticate with
#    Mandatory.
#
class heat::api-cfn (
  $enabled           = true,
  $keystone_host     = '127.0.0.1',
  $keystone_port     = '35357',
  $keystone_protocol = 'http',
  $keystone_user     = 'heat',
  $keystone_tenant   = 'services',
  $keystone_password = false,
) {

  include heat::params

  validate_string($keystone_password)

  heat_api_cfn_config<||> ~> Service['heat-api-cfn']

  Package['heat-api-cfn'] -> heat_api_cfn_config<||>
  Package['heat-api-cfn'] -> Service['heat-api-cfn']
  package { 'heat-api-cfn':
    ensure => installed,
    name   => $::heat::params::api_package_name,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  Package['heat-common'] -> Service['heat-api-cfn']

  if $rabbit_hosts {
    heat_api_cfn_config { 'DEFAULT/rabbit_host': ensure => absent }
    heat_api_cfn_config { 'DEFAULT/rabbit_port': ensure => absent }
    heat_api_cfn_config { 'DEFAULT/rabbit_hosts':
      value => join($rabbit_hosts, ',')
    }
  } else {
    heat_api_cfn_config { 'DEFAULT/rabbit_host': value => $rabbit_host }
    heat_api_cfn_config { 'DEFAULT/rabbit_port': value => $rabbit_port }
    heat_api_cfn_config { 'DEFAULT/rabbit_hosts':
      value => "${rabbit_host}:${rabbit_port}"
    }
  }

  if size($rabbit_hosts) > 1 {
    heat_api_cfn_config { 'DEFAULT/rabbit_ha_queues': value => true }
  } else {
    heat_api_cfn_config { 'DEFAULT/rabbit_ha_queues': value => false }
  }

  service { 'heat-api-cfn':
    ensure     => $service_ensure,
    name       => $::heat::params::api_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['heat::db'],
    subscribe  => Exec['heat-dbsync']
  }

  heat_api_cfn_config {
    'DEFAULT/rabbit_userid'          : value => $rabbit_userid;
    'DEFAULT/rabbit_password'        : value => $rabbit_password;
    'DEFAULT/rabbit_virtualhost'     : value => $rabbit_virtualhost;
    'DEFAULT/debug'                  : value => $debug;
    'DEFAULT/verbose'                : value => $verbose;
    'DEFAULT/log_dir'                : value => $::heat::params::log_dir;
    'keystone_authtoken/auth_host'         : value => $keystone_host;
    'keystone_authtoken/auth_port'         : value => $keystone_port;
    'keystone_authtoken/auth_protocol'     : value => $keystone_protocol;
    'keystone_authtoken/admin_tenant_name' : value => $keystone_tenant;
    'keystone_authtoken/admin_user'        : value => $keystone_user;
    'keystone_authtoken/admin_password'    : value => $keystone_password;
  }
}
