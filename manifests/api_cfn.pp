# == Class: heat::api_cfn
#
# This class deprecates heat::api-cfn.
#
# Installs & configure the heat CloudFormation API service
#
# === Parameters
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to 'true'.
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of heat-api-cfn.
#   If the value is 'httpd', this means heat-api-cfn will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'heat::wsgi::apache_api_cfn'...}
#   to make heat-api-cfn be a web app using apache mod_wsgi.
#   Defaults to '$::heat::params::api_cfn_service_name'
#
# == Deprecated Parameters
#
# [*bind_host*]
#   (Optional) Address to bind the server. Useful when
#   selecting a particular network interface.
#   Defaults to undef.
#
# [*bind_port*]
#   (Optional) The port on which the server will listen.
#   Defaults to undef.
#
# [*workers*]
#   (Optional) The number of workers to spawn.
#   Defaults to undef.
#
# [*use_ssl*]
#   (Optional) Whether to use ssl or not.
#   Defaults to undef.
#
# [*cert_file*]
#   (Optional) Location of the SSL certificate file to use for SSL mode.
#   Defaults to undef
#
# [*key_file*]
#   (Optional) Location of the SSL key file to use for enabling SSL mode.
#   Defaults to undef
#
class heat::api_cfn (
  $package_ensure         = 'present',
  Boolean $manage_service = true,
  Boolean $enabled        = true,
  $service_name           = $::heat::params::api_cfn_service_name,
  # DEPRECATED PARAMETERS
  $bind_host              = undef,
  $bind_port              = undef,
  $workers                = undef,
  $use_ssl                = undef,
  $cert_file              = undef,
  $key_file               = undef,
) inherits heat::params {

  include heat
  include heat::deps
  include heat::params
  include heat::policy

  [
    'bind_host', 'bind_port', 'workers',
    'use_ssl', 'cert_file', 'key_file'
  ].each |String $opt| {
    if getvar($opt) != undef {
      warning("The ${opt} parameter is deprecated and has no effect.")
    }
  }

  package { 'heat-api-cfn':
    ensure => $package_ensure,
    name   => $::heat::params::api_cfn_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    if $service_name == $::heat::params::api_cfn_service_name {
      service { 'heat-api-cfn':
        ensure     => $service_ensure,
        name       => $::heat::params::api_cfn_service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => 'heat-service',
      }

      # On any paste-api.ini config change, we must restart Heat API.
      Heat_api_paste_ini<||> ~> Service['heat-api-cfn']
      # On any uwsgi config change, we must restart Heat API.
      Heat_api_cfn_uwsgi_config<||> ~> Service['heat-api-cfn']

    } elsif $service_name == 'httpd' {
      service { 'heat-api-cfn':
        ensure => 'stopped',
        name   => $::heat::params::api_cfn_service_name,
        enable => false,
        tag    => ['heat-service'],
      }
      Service <| title == 'httpd' |> { tag +> 'heat-service' }

      # we need to make sure heat-api-cfn/eventlet is stopped before trying to start apache
      Service['heat-api-cfn'] -> Service[$service_name]

      # On any paste-api.ini config change, we must restart Heat API.
      Heat_api_paste_ini<||> ~> Service[$service_name]

    } else {
      fail("Invalid service_name. Either heat-api-cfn/openstack-heat-api-cfn for \
running as a standalone service, or httpd for being run by a httpd server")
    }
  }

  heat_config {
    'heat_api_cfn/bind_host': ensure => absent;
    'heat_api_cfn/bind_port': ensure => absent;
    'heat_api_cfn/workers':   ensure => absent;
    'heat_api_cfn/cert_file': ensure => absent;
    'heat_api_cfn/key_file':  ensure => absent;
  }
}
