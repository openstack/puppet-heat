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
#   Defaults to '$heat::params::api_cfn_service_name'
#
class heat::api_cfn (
  Stdlib::Ensure::Package $package_ensure = 'present',
  Boolean $manage_service                 = true,
  Boolean $enabled                        = true,
  String[1] $service_name                 = $heat::params::api_cfn_service_name,
) inherits heat::params {
  include heat
  include heat::deps
  include heat::params
  include heat::policy

  package { 'heat-api-cfn':
    ensure => $package_ensure,
    name   => $heat::params::api_cfn_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  if $manage_service {
    case $service_name {
      'httpd': {
        Service <| title == 'httpd' |> { tag +> 'heat-service' }

        service { 'heat-api-cfn':
          ensure => 'stopped',
          name   => $heat::params::api_cfn_service_name,
          enable => false,
          tag    => ['heat-service'],
        }
        # we need to make sure heat-api-cfn/eventlet is stopped before trying to start apache
        Service['heat-api-cfn'] -> Service['httpd']

        # On any paste-api.ini config change, we must restart Heat API.
        Heat_api_paste_ini<||> ~> Service['httpd']
      }
      default: {
        $service_ensure = $enabled ? {
          true    => 'running',
          default => 'stopped',
        }

        service { 'heat-api-cfn':
          ensure     => $service_ensure,
          name       => $service_name,
          enable     => $enabled,
          hasstatus  => true,
          hasrestart => true,
          tag        => 'heat-service',
        }

        # On any paste-api.ini config change, we must restart Heat API.
        Heat_api_paste_ini<||> ~> Service['heat-api-cfn']
        # On any uwsgi config change, we must restart Heat API.
        Heat_api_cfn_uwsgi_config<||> ~> Service['heat-api-cfn']
      }
    }
  }
}
