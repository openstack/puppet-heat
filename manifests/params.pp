# == Class: heat::params
#
# Parameters for puppet-heat
#
class heat::params {
  include openstacklib::defaults

  $pybasedir = $openstacklib::defaults::pybasedir

  $client_package_name = 'python3-heatclient'
  $user                = 'heat'
  $group               = 'heat'

  case $facts['os']['family'] {
    'RedHat': {
      # package names
      $api_package_name            = 'openstack-heat-api'
      $api_cfn_package_name        = 'openstack-heat-api-cfn'
      $engine_package_name         = 'openstack-heat-engine'
      $common_package_name         = 'openstack-heat-common'
      # service names
      $api_service_name            = 'openstack-heat-api'
      $api_cfn_service_name        = 'openstack-heat-api-cfn'
      $engine_service_name         = 'openstack-heat-engine'
      # WSGI scripts
      $heat_wsgi_script_path           = '/var/www/cgi-bin/heat'
      $heat_api_wsgi_script_source     = "${pybasedir}/heat/wsgi/api.py"
      $heat_api_cfn_wsgi_script_source = "${pybasedir}/heat/wsgi/cfn.py"
    }
    'Debian': {
      # package names
      $api_package_name            = 'heat-api'
      $api_cfn_package_name        = 'heat-api-cfn'
      $engine_package_name         = 'heat-engine'
      $common_package_name         = 'heat-common'
      # service names
      $api_service_name            = 'heat-api'
      $api_cfn_service_name        = 'heat-api-cfn'
      $engine_service_name         = 'heat-engine'
      # WSGI scripts
      $heat_wsgi_script_path           = '/usr/lib/cgi-bin/heat'
      $heat_api_wsgi_script_source     = "${pybasedir}/heat/wsgi/api.py"
      $heat_api_cfn_wsgi_script_source = "${pybasedir}/heat/wsgi/cfn.py"
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
