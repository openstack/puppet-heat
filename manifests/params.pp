# Parameters for puppet-heat
#
class heat::params {

#TODO(EmilienM) fix db-setup command
  $dbsync_command =
    'heat-db-setup -p heat'
  $log_dir        = '/var/log/heat'

  case $::osfamily {
    'RedHat': {
      # package names
      $heat_api_package_name = 'openstack-heat-api'
      $heat_api_cloudwatch_package_name = 'openstack-heat-api-cloudwatch'
      $heat_api_cfn_package_name = 'openstack-heat-api-cfn'
      $heat_engine_package_name = 'openstack-heat-engine'
      # service names
      $heat_api_service_name = 'openstack-heat-api'
      $heat_api_cloudwatch_service_name = 'openstack-heat-api-cloudwatch'
      $heat_api_cfn_service_name = 'openstack-heat-api-cfn'
      $heat_engine_service_name = 'openstack-heat-engine'
    }
    'Debian': {
      # package names
      $heat_api_package_name = 'heat-api'
      $heat_api_cloudwatch_package_name = 'heat-api-cloudwatch'
      $heat_api_cfn_package_name = 'heat-api-cfn'
      $heat_engine_package_name = 'heat-engine'
      # service names
      $heat_api_service_name = 'heat-api'
      $heat_api_cloudwatch_service_name = 'heat-api-cloudwatch'
      $heat_api_cfn_service_name = 'heat-api-cfn'
      $heat_engine_service_name = 'heat-engine'
      # Operating system specific
      case $::operatingsystem {
        'Ubuntu': {
          $libvirt_group = 'libvirtd'
        }
        default: {
          $libvirt_group = 'libvirt'
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: \
${::operatingsystem}, module ${module_name} only support osfamily \
RedHat and Debian")
    }
  }
}
