# == Class: heat::api_cloudwatch
#
# This class deprecates heat::api-cloudwatch
#
# Installs & configure the heat CloudWatch API service
#
# === Parameters
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*bind_host*]
#   (Optional) Address to bind the server. Useful when
#   selecting a particular network interface.
#   Defaults to $::os_service_default.
#
# [*bind_port*]
#   (Optional) The port on which the server will listen.
#   Defaults to $::os_service_default.
#
# [*workers*]
#   (Optional) The number of workers to spawn.
#   Defaults to $::os_service_default.
#
# [*use_ssl*]
#   (Optional) Whether to use ssl or not.
#   Defaults to 'false'.
#
# [*cert_file*]
#   (Optional) Location of the SSL certificate file to use for SSL mode.
#   Required when $use_ssl is set to 'true'.
#   Defaults to $::os_service_default.
#
# [*key_file*]
#   (Optional) Location of the SSL key file to use for enabling SSL mode.
#   Required when $use_ssl is set to 'true'.
#   Defaults to $::os_service_default.
#
# == Deprecated Parameters
#
# No Deprecated Parameters.
#
class heat::api_cloudwatch (
  $package_ensure    = 'present',
  $manage_service    = true,
  $enabled           = true,
  $bind_host         = $::os_service_default,
  $bind_port         = $::os_service_default,
  $workers           = $::os_service_default,
  $use_ssl           = false,
  $cert_file         = $::os_service_default,
  $key_file          = $::os_service_default,
) {

  include ::heat
  include ::heat::deps
  include ::heat::params
  include ::heat::policy

  if $use_ssl {
    if is_service_default($cert_file) {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if is_service_default($key_file) {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
  }

  package { 'heat-api-cloudwatch':
    ensure => $package_ensure,
    name   => $::heat::params::api_cloudwatch_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'heat-api-cloudwatch':
    ensure     => $service_ensure,
    name       => $::heat::params::api_cloudwatch_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => 'heat-service',
  }

  heat_config {
    'heat_api_cloudwatch/bind_host': value => $bind_host;
    'heat_api_cloudwatch/bind_port': value => $bind_port;
    'heat_api_cloudwatch/workers':   value => $workers;
  }

  if $use_ssl {
    heat_config {
      'heat_api_cloudwatch/cert_file': value => $cert_file;
      'heat_api_cloudwatch/key_file':  value => $key_file;
    }
  }
}
