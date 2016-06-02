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
#   Defaults to 'true'.
#
# [*configure_service*]
#   (Optional) Should heat service be configured?
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
#   Defaults to 'heat'.
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'orchestration'.
#
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'Openstack Orchestration Service'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*tenant*]
#   (Optional) Tenant for heat user.
#   Defaults to 'services'.
#
# [*trusts_delegated_roles*]
#    (optional) Array of trustor roles to be delegated to heat.
#    Defaults to ['heat_stack_owner']
#
# [*configure_delegated_roles*]
#    (optional) Whether to configure the delegated roles.
#    Defaults to false until the deprecated parameters in heat::engine
#    are removed after Kilo.
#
# [*public_url*]
#   (optional) The endpoint's public url. (Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*admin_url*]
#   (optional) The endpoint's admin url. (Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*internal_url*]
#   (optional) The endpoint's internal url. (Defaults to 'http://127.0.0.1:8004/v1/%(tenant_id)s')
#   This url should *not* contain any trailing '/'.
#
# [*heat_stack_user_role*]
#   (optional) Keystone role for heat template-defined users.
#   In this context this will create the role for the heat_stack_user.
#   It will not set the value in the config file, if you want to do
#   that you must set heat::engine::heat_stack_user_role. Generally
#   these should be set to the same value.
#   Defaults to 'heat_stack_user'

# [*manage_heat_stack_user_role*]
#   (optional) If true, this will manage the Keystone role for
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
  $password                    = false,
  $email                       = 'heat@localhost',
  $auth_name                   = 'heat',
  $service_name                = 'heat',
  $service_type                = 'orchestration',
  $service_description         = 'Openstack Orchestration Service',
  $region                      = 'RegionOne',
  $tenant                      = 'services',
  $configure_endpoint          = true,
  $configure_service           = true,
  $configure_user              = true,
  $configure_user_role         = true,
  $trusts_delegated_roles      = ['heat_stack_owner'],
  $configure_delegated_roles   = false,
  $public_url                  = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  $admin_url                   = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  $internal_url                = 'http://127.0.0.1:8004/v1/%(tenant_id)s',
  $heat_stack_user_role        = 'heat_stack_user',
  $manage_heat_stack_user_role = true,
) {

  include ::heat::deps

  validate_string($password)

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
    public_url          => $public_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  }

  if $configure_user_role {
    Keystone_user_role["${auth_name}@${tenant}"] ~>
      Service <| name == 'heat-api' |>
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
