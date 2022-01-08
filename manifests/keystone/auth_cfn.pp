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
# [*service_description*]
#   (Optional) Description of the service.
#   Default to 'Openstack Cloudformation Service'
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'heat'.
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
# [*roles*]
#   (Optional) List of roles assigned to heat user.
#   Defaults to ['admin']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to heat user.
#   Defaults to []
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
  $service_name         = 'heat-cfn',
  $service_description  = 'Openstack Cloudformation Service',
  $service_type         = 'cloudformation',
  $region               = 'RegionOne',
  $tenant               = 'services',
  $roles                = ['admin'],
  $system_scope         = 'all',
  $system_roles         = [],
  $configure_endpoint   = true,
  $configure_service    = true,
  $configure_user       = true,
  $configure_user_role  = true,
  $public_url           = 'http://127.0.0.1:8000/v1',
  $admin_url            = 'http://127.0.0.1:8000/v1',
  $internal_url         = 'http://127.0.0.1:8000/v1',
) {

  include heat::deps

  validate_legacy(String, 'validate_string', $password)

  Keystone_user_role<| name == "${auth_name}@${tenant}" |> -> Anchor['heat::service::end']
  Keystone_user_role<| name == "${auth_name}@::::${system_scope}" |> -> Anchor['heat::service::end']

  if $configure_endpoint {
    Keystone_endpoint["${region}/${service_name}::${service_type}"] -> Anchor['heat::service::end']
  }

  keystone::resource::service_identity { 'heat-cfn':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $service_name,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

}
