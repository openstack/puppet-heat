# == Class: heat::keystone::auth_cfn
#
# Configures heat-api-cfn user, service and endpoint in Keystone.
#
# === Parameters
# [*password*]
#   (Mandatory) Password for heat-cfn user.
#
# [*email*]
#   (Optional) Email for heat-cfn user.
#   Defaults to 'heat-cfn@localhost'.
#
# [*auth_name*]
#   (Optional) Username for heat-cfn service.
#   Defaults to 'heat-cfn'.
#
# [*configure_endpoint*]
#   (Optional) Should heat-cfn endpoint be configured?
#   Defaults to 'true'.
#
# [*configure_service*]
#   (Optional) Should heat-cfn service be configured?
#   Defaults to 'true'.
#
# [*configure_user*]
#   (Optional) Whether to create the service user.
#   Defaults to 'true'.
#
# [*configure_user_role*]
#   (Optional) Whether to configure the admin role for the service user.
#   Defaults to 'true'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to the value of auth_name.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'cloudformation'.

# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*tenant*]
#   (Optional) Tenant for heat-cfn user.
#   Defaults to 'services'.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8000/v1')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8000/v1')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8000/v1')
#   This url should *not* contain any trailing '/'.
#
# === Examples
#
#  class { 'heat::keystone::auth_cfn':
#    public_url   => 'https://10.0.0.10:8000/v1',
#    internal_url => 'https://10.0.0.11:8000/v1',
#    admin_url    => 'https://10.0.0.11:8000/v1',
#  }
#
class heat::keystone::auth_cfn (
  $password             = false,
  $email                = 'heat-cfn@localhost',
  $auth_name            = 'heat-cfn',
  $service_name         = undef,
  $service_type         = 'cloudformation',
  $region               = 'RegionOne',
  $tenant               = 'services',
  $configure_endpoint   = true,
  $configure_service    = true,
  $configure_user       = true,
  $configure_user_role  = true,
  $public_url           = 'http://127.0.0.1:8000/v1',
  $admin_url            = 'http://127.0.0.1:8000/v1',
  $internal_url         = 'http://127.0.0.1:8000/v1',
) {

  include ::heat::deps

  validate_string($password)

  $real_service_name = pick($service_name, $auth_name)

  keystone::resource::service_identity { $auth_name:
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_type        => $service_type,
    service_description => 'Openstack Cloudformation Service',
    service_name        => $real_service_name,
    region              => $region,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~>
      Service <| name == 'heat-api-cfn' |>
  }

}
