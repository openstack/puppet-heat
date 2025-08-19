# == Class: heat::keystone::auth
#
# Configures heat user, service and endpoint in Keystone.
#
# === Parameters
# [*password*]
#   (Required) Password for heat user.
#
# [*email*]
#   (Optional) Email for heat user.
#   Defaults to 'heat@localhost'.
#
# [*auth_name*]
#   (Optional) Username for heat service.
#   Defaults to 'heat'.
#
# [*configure_endpoint*]
#   (Optional) Should heat endpoint be configured?
#   Defaults to true.
#
# [*configure_service*]
#   (Optional) Should heat service be configured?
#   Defaults to true.
#
# [*configure_user*]
#   (Optional) Whether to create the service user.
#   Defaults to true.
#
# [*configure_user_role*]
#   (Optional) Whether to configure the admin role for the service user.
#   Defaults to true.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'heat'.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'orchestration'.
#
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'OpenStack Orchestration Service'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*tenant*]
#   (Optional) Tenant for heat user.
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
# [*trusts_delegated_roles*]
#    (Optional) Array of trustor roles to be delegated to heat.
#    Defaults to ['heat_stack_owner']
#
# [*configure_delegated_roles*]
#    (Optional) Whether to configure the delegated roles.
#    Defaults to false until the deprecated parameters in heat::engine
#    are removed after Kilo.
#
# [*public_url*]
#   (Optional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s'
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s'
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s'
#
# [*heat_stack_user_role*]
#   (Optional) Keystone role for heat template-defined users.
#   In this context this will create the role for the heat_stack_user.
#   It will not set the value in the config file, if you want to do
#   that you must set heat::engine::heat_stack_user_role. Generally
#   these should be set to the same value.
#   Defaults to 'heat_stack_user'

# [*manage_heat_stack_user_role*]
#   (Optional) If true, this will manage the Keystone role for
#   $heat_stack_user_role.
#   Defaults to true
#
#
# === Examples
#
#  class { 'heat::keystone::auth':
#    public_url   => 'https://10.0.0.10:8004/v1/%(tenant_id)s',
#    internal_url => 'https://10.0.0.11:8004/v1/%(tenant_id)s',
#    admin_url    => 'https://10.0.0.11:8004/v1/%(tenant_id)s',
#  }
#
class heat::keystone::auth (
  String[1] $password,
  String[1] $email                         = 'heat@localhost',
  String[1] $auth_name                     = 'heat',
  String[1] $service_name                  = 'heat',
  String[1] $service_type                  = 'orchestration',
  String[1] $service_description           = 'OpenStack Orchestration Service',
  String[1] $region                        = 'RegionOne',
  String[1] $tenant                        = 'services',
  Array[String[1]] $roles                  = ['admin'],
  String[1] $system_scope                  = 'all',
  Array[String[1]] $system_roles           = [],
  Boolean $configure_endpoint              = true,
  Boolean $configure_service               = true,
  Boolean $configure_user                  = true,
  Boolean $configure_user_role             = true,
  Array[String[1]] $trusts_delegated_roles = ['heat_stack_owner'],
  Boolean $configure_delegated_roles       = false,
  Keystone::PublicEndpointUrl $public_url  = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  Keystone::EndpointUrl $admin_url         = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  Keystone::EndpointUrl $internal_url      = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  String[1] $heat_stack_user_role          = 'heat_stack_user',
  Boolean $manage_heat_stack_user_role     = true,
) {
  include heat::deps

  Keystone::Resource::Service_identity['heat'] -> Anchor['heat::service::end']

  keystone::resource::service_identity { 'heat':
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

  if $manage_heat_stack_user_role {
    keystone_role { $heat_stack_user_role:
      ensure => present,
    }
  }

  if $configure_delegated_roles {
    # if this is a keystone only node, we configure the role here
    # but let engine.pp set the config file. A keystone only node
    # will not have a heat.conf file.
    keystone_role { $trusts_delegated_roles:
      ensure => present,
    }
  }
}
