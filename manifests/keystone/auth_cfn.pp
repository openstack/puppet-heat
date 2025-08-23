# == Class: heat::keystone::auth_cfn
#
# Configures heat-api-cfn user, service and endpoint in Keystone.
#
# === Parameters
#
# [*configure_endpoint*]
#   (Optional) Should heat-cfn endpoint be configured?
#   Defaults to 'true'.
#
# [*configure_service*]
#   (Optional) Should heat-cfn service be configured?
#   Defaults to 'true'.
#
# [*service_description*]
#   (Optional) Description of the service.
#   Default to 'OpenStack Cloudformation Service'
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'heat'.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'cloudformation'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
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
# DEPRECATED PARAMETERS
#
# [*configure_user*]
#   (Optional) Whether to create the service user.
#   Defaults to undef
#
# [*configure_user_role*]
#   (Optional) Whether to configure the admin role for the service user.
#   Defaults to undef
#
# [*password*]
#   (Optioal) Password for heat-cfn user.
#   Defaults to undef
#
# [*email*]
#   (Optional) Email for heat-cfn user.
#   Defaults to undef
#
# [*auth_name*]
#   (Optional) Username for heat-cfn service.
#   Defaults to undef
#
# [*tenant*]
#   (Optional) Tenant for heat-cfn user.
#   Defaults to undef
#
# [*roles*]
#   (Optional) List of roles assigned to heat user.
#   Defaults to undef
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to undef
#
# [*system_roles*]
#   (Optional) List of system roles assigned to heat user.
#   Defaults to undef
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
  String[1] $service_name                 = 'heat-cfn',
  String[1] $service_description          = 'OpenStack Cloudformation Service',
  String[1] $service_type                 = 'cloudformation',
  String[1] $region                       = 'RegionOne',
  Boolean $configure_endpoint             = true,
  Boolean $configure_service              = true,
  Keystone::PublicEndpointUrl $public_url = 'http://127.0.0.1:8000/v1',
  Keystone::EndpointUrl $admin_url        = 'http://127.0.0.1:8000/v1',
  Keystone::EndpointUrl $internal_url     = 'http://127.0.0.1:8000/v1',
  # DEPRECATED PARAMETERS
  Optional[Boolean] $configure_user       = undef,
  Optional[Boolean] $configure_user_role  = undef,
  $password                               = undef,
  $email                                  = undef,
  $auth_name                              = undef,
  $tenant                                 = undef,
  $roles                                  = undef,
  $system_scope                           = undef,
  $system_roles                           = undef,
) {
  include heat::deps

  if $configure_user != undef {
    warning('The configure_user parameter is deprecated')
    if $configure_user {
      fail('Management of heat-cfn user is no longer supported.')
    }
  }

  if $configure_user_role != undef {
    warning('The configure_user_role parameter is deprecated')
    if $configure_user_role {
      fail('Management of heat-cfn user is no longer supported.')
    }
  }

  Keystone::Resource::Service_identity['heat-cfn'] -> Anchor['heat::service::end']

  keystone::resource::service_identity { 'heat-cfn':
    configure_user      => false,
    configure_user_role => false,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_type        => $service_type,
    service_description => $service_description,
    service_name        => $service_name,
    region              => $region,
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }
}
