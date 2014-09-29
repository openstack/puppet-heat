# == Class: heat::heat::auth_cfn
#
# Configures heat-api-cfn user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   Password for heat-cfn user. Required.
#
# [*email*]
#   Email for heat-cfn user. Optional. Defaults to 'heat@localhost'.
#
# [*auth_name*]
#   Username for heat-cfn service. Optional. Defaults to 'heat'.
#
# [*configure_endpoint*]
#   Should heat-cfn endpoint be configured? Optional. Defaults to 'true'.
#
# [*configure_user*]
#   Whether to create the service user. Defaults to 'true'.
#
# [*configure_user_role*]
#   Whether to configure the admin role for the service user. Defaults to 'true'.
#
# [*service_name*]
#   Name of the service. Optional. Defaults to the value of auth_name.
#
# [*service_type*]
#    Type of service. Optional. Defaults to 'cloudformation'.
#
# [*public_address*]
#    Public address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*admin_address*]
#    Admin address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*internal_address*]
#    Internal address for endpoint. Optional. Defaults to '127.0.0.1'.
#
# [*port*]
#    Port for endpoint. Optional. Defaults to '8000'.
#
# [*version*]
#    Version for API.  Optional.  Defaults to 'v1'

# [*region*]
#    Region for endpoint. Optional. Defaults to 'RegionOne'.
#
# [*tenant*]
#    Tenant for heat-cfn user. Optional. Defaults to 'services'.
#
# [*protocol*]
#    Protocol for public endpoint. Optional. Defaults to 'http'.
#
class heat::keystone::auth_cfn (
  $password             = false,
  $email                = 'heat-cfn@localhost',
  $auth_name            = 'heat-cfn',
  $service_name         = undef,
  $service_type         = 'cloudformation',
  $public_address       = '127.0.0.1',
  $admin_address        = '127.0.0.1',
  $internal_address     = '127.0.0.1',
  $port                 = '8000',
  $version              = 'v1',
  $region               = 'RegionOne',
  $tenant               = 'services',
  $public_protocol      = 'http',
  $admin_protocol       = 'http',
  $internal_protocol    = 'http',
  $configure_endpoint   = true,
  $configure_user       = true,
  $configure_user_role  = true,
) {

  validate_string($password)

  if $service_name == undef {
    $real_service_name = $auth_name
  } else {
    $real_service_name = $service_name
  }

  if $configure_user {
    keystone_user { $auth_name:
      ensure   => present,
      password => $password,
      email    => $email,
      tenant   => $tenant,
    }
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~>
      Service <| name == 'heat-api-cfn' |>

    keystone_user_role { "${auth_name}@${tenant}":
      ensure  => present,
      roles   => ['admin'],
    }
  }

  keystone_service { $real_service_name:
    ensure      => present,
    type        => $service_type,
    description => 'Openstack Cloudformation Service',
  }
  if $configure_endpoint {
    keystone_endpoint { "${region}/${real_service_name}":
      ensure       => present,
      public_url   => "${public_protocol}://${public_address}:${port}/${version}/",
      admin_url    => "${admin_protocol}://${admin_address}:${port}/${version}/",
      internal_url => "${internal_protocol}://${internal_address}:${port}/${version}/",
    }
  }
}
