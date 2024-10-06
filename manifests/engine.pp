# == Class: heat::engine
#
#  Installs & configure the heat engine service
#
# === Parameters
#
# [*auth_encryption_key*]
#   (required) Encryption key used for authentication info in database
#   Must be either 16, 24, or 32 bytes long.
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to 'true'
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*heat_stack_user_role*]
#   (optional) Keystone role for heat template-defined users.
#   This setting does not actually create the role. If you change
#   this to a different value you should also set
#   heat::keystone::auth::heat_stack_user_role if you want the
#   correct role created.
#   Defaults to $facts['os_service_default'].
#
# [*heat_metadata_server_url*]
#   (optional) URL of the Heat metadata server
#   Defaults to $facts['os_service_default'].
#
# [*heat_waitcondition_server_url*]
#   (optional) URL of the Heat waitcondition server
#   Defaults to $facts['os_service_default'].
#
# [*default_software_config_transport*]
#   (optional) Template default for how the server should receive the metadata
#   required for software configuration. POLL_SERVER_CFN will allow calls to the
#   cfn API action DescribeStackResource authenticated with the provided keypair
#   (requires enabled heat-api-cfn). POLL_SERVER_HEAT will allow calls to the
#   Heat API resource-show using the provided keystone credentials (requires
#   keystone v3 API, and configured stack_user_* config options). POLL_TEMP_URL
#   will create and populate a Swift TempURL with metadata for polling (requires
#   object-store endpoint which supports TempURL). (string value)
#   Allowed values: POLL_SERVER_CFN, POLL_SERVER_HEAT, POLL_TEMP_URL
#   Defaults to $facts['os_service_default'].
#
# [*default_deployment_signal_transport*]
#   (optional) Template default for how the server should signal to heat with
#   the deployment output values. CFN_SIGNAL will allow an HTTP POST to a CFN
#   keypair signed URL (requires enabled heat-api-cfn). TEMP_URL_SIGNAL will
#   create a Swift TempURL to be signaled via HTTP PUT (requires object-store
#   TempURL). HEAT_SIGNAL will allow calls to the Heat API resource-signal using
#   endpoint which supports the provided keystone credentials (string value)
#   Allowed values: CFN_SIGNAL, TEMP_URL_SIGNAL, HEAT_SIGNAL
#   Defaults to $facts['os_service_default'].
#
# [*default_user_data_format*]
#   (optional) Template default for how the user_data should be
#   formatted for the server. For HEAT_CFNTOOLS, the
#   user_data is bundled as part of the heat-cfntools
#   cloud-init boot configuration data. For RAW the
#   user_data is passed to Nova unmodified. For
#   SOFTWARE_CONFIG user_data is bundled as part of the
#   software config data, and metadata is derived from any
#   associated SoftwareDeployment resources.
#   Allowed values: HEAT_CFNTOOLS, RAW, SOFTWARE_CONFIG
#   Defaults to $facts['os_service_default'].
#
# [*reauthentication_auth_method*]
#   (Optional) Re-authentication method on token expiry.
#   Defaults to $facts['os_service_default'].
#
# [*allow_trusts_redelegation*]
#   (Optional) Create trusts with redelegation enabled.
#   Defaults to $facts['os_service_default'].
#
# [*trusts_delegated_roles*]
#   (optional) Array of trustor roles to be delegated to heat.
#   This value is also used by heat::keystone::auth if it is set to
#   configure the keystone roles.
#   Defaults to $facts['os_service_default'].
#
# [*action_retry_limit*]
#   (Optional) Number of times to retry to bring a resource to a non-error
#   state.
#   Defaults to $facts['os_service_default'].
#
# [*client_retry_limit*]
#   (Optional) Number of times to retry when a client encounters an expected
#   intermittent error.
#   Defaults to $facts['os_service_default'].
#
# [*max_server_name_length*]
#   (Optional) Maximum length of a server name to be used in nova.
#   Defaults to $facts['os_service_default'].
#
# [*max_interface_check_attempts*]
#   (Optional) Number of times to check whether an interface has been attached
#   or detached.
#   Defaults to $facts['os_service_default'].
#
# [*max_nova_api_microversion*]
#   (Optional) Maximum nova API version for client plugin.
#   Defaults to $facts['os_service_default'].
#
# [*max_cinder_api_microversion*]
#   (Optional) Maximum cinder API version for client plugin.
#   Defaults to $facts['os_service_default'].
#
# [*max_ironic_api_microversion*]
#   (Optional) Maximum ironic API version for client plugin.
#   Defaults to $facts['os_service_default'].
#
# [*event_purge_batch_size*]
#   (Optional) Controls how many events will be pruned whenever a stack's
#   events are purged.
#   Defaults to $facts['os_service_default'].
#
# [*max_events_per_stack*]
#   (Optional) Rough number of maximum events that will be available per stack.
#   Defaults to $facts['os_service_default'].
#
# [*stack_action_timeout*]
#   (Optional) Timeout in seconds for stack action.
#   Defaults to $facts['os_service_default'].
#
# [*error_wait_time*]
#   (Optional) The amount of time in seconds after an error has occurred that
#   tasks may continue to run before being cancelled.
#   Defaults to $facts['os_service_default'].
#
# [*engine_life_check_timeout*]
#   (optional) RPC timeout (in seconds) for the engine liveness check that is
#   used for stack locking
#   Defaults to $facts['os_service_default'].
#
# [*instance_connection_is_secure*]
#   (Optional) Instance connection to CFN/CW API via https.
#   Defaults to $facts['os_service_default']
#
# [*instance_connection_https_validate_certificates*]
#   (Optional) Instance connection to CFN/CW API validate certs if SSL is used.
#   Defaults to $facts['os_service_default']
#
# [*max_stacks_per_tenant*]
#   (optional) Maximum number of stacks any one tenant may have active at one
#   time.
#   Defaults to $facts['os_service_default'].
#
# [*max_resources_per_stack*]
#   (Optional) Maximum resources allowed per top-level stack.
#   Defaults to $facts['os_service_default']
#
# [*max_software_configs_per_tenant*]
#   (Optional) Maximum number of software configs any one tenant may have
#   active at one time.
#   Defaults to $facts['os_service_default'].
#
# [*max_software_deployments_per_tenant*]
#   (Optional) Maximum number of software deployments any one tenant may have
#   active at one time.
#   Defaults to $facts['os_service_default'].
#
# [*max_snapshots_per_stack*]
#   (Optional) Maximum number of snapshot any one stack may have active at one
#   time.
#   Defaults to $facts['os_service_default'].
#
# [*num_engine_workers*]
#   (Optional) The number of workers to spawn.
#   Defaults to $facts['os_workers_heat_engine']
#
# [*convergence_engine*]
#   (Optional) Enables engine with convergence architecture.
#   Defaults to $facts['os_service_default'].
#
# [*environment_dir*]
#   (Optional) The directory to search for environment files.
#   Defaults to $facts['os_service_default']
#
# [*template_dir*]
#   (Optional) The directory to search for template files.
#   Defaults to $facts['os_service_default']
#
# [*max_nested_stack_depth*]
#   (Optional) Maximum depth allowed when using nested stacks.
#   Defaults to $facts['os_service_default']
#
# [*plugin_dirs*]
#   (Optional) List of directories to search for plug-ins.
#   Defaults to $facts['os_service_default']
#
# [*server_keystone_endpoint_type*]
#   (Optional) If set, is used to control which authentication endpoint is used
#   by user-controlled servers to make calls back to Heat.
#   Defaults to $facts['os_service_default']
#
# [*hidden_stack_tags*]
#   (Optional) Stacks containing these tag names will be hidden.
#   Defaults to $facts['os_service_default']
#
# DEPRECATED PARAMETERS
#
# [*deferred_auth_method*]
#   (optional) Select deferred auth method.
#   Can be "password" or "trusts".
#   Defaults to undef
#
class heat::engine (
  Heat::AuthEncryptionKey $auth_encryption_key,
  $package_ensure                                  = 'present',
  Boolean $manage_service                          = true,
  Boolean $enabled                                 = true,
  $heat_stack_user_role                            = $facts['os_service_default'],
  $heat_metadata_server_url                        = $facts['os_service_default'],
  $heat_waitcondition_server_url                   = $facts['os_service_default'],
  $default_software_config_transport               = $facts['os_service_default'],
  $default_deployment_signal_transport             = $facts['os_service_default'],
  $default_user_data_format                        = $facts['os_service_default'],
  $reauthentication_auth_method                    = $facts['os_service_default'],
  $allow_trusts_redelegation                       = $facts['os_service_default'],
  $trusts_delegated_roles                          = $facts['os_service_default'],
  $instance_connection_is_secure                   = $facts['os_service_default'],
  $instance_connection_https_validate_certificates = $facts['os_service_default'],
  $max_stacks_per_tenant                           = $facts['os_service_default'],
  $max_resources_per_stack                         = $facts['os_service_default'],
  $max_software_configs_per_tenant                 = $facts['os_service_default'],
  $max_software_deployments_per_tenant             = $facts['os_service_default'],
  $max_snapshots_per_stack                         = $facts['os_service_default'],
  $action_retry_limit                              = $facts['os_service_default'],
  $client_retry_limit                              = $facts['os_service_default'],
  $max_server_name_length                          = $facts['os_service_default'],
  $max_interface_check_attempts                    = $facts['os_service_default'],
  $max_nova_api_microversion                       = $facts['os_service_default'],
  $max_cinder_api_microversion                     = $facts['os_service_default'],
  $max_ironic_api_microversion                     = $facts['os_service_default'],
  $event_purge_batch_size                          = $facts['os_service_default'],
  $max_events_per_stack                            = $facts['os_service_default'],
  $stack_action_timeout                            = $facts['os_service_default'],
  $error_wait_time                                 = $facts['os_service_default'],
  $engine_life_check_timeout                       = $facts['os_service_default'],
  $num_engine_workers                              = $facts['os_workers_heat_engine'],
  $convergence_engine                              = $facts['os_service_default'],
  $environment_dir                                 = $facts['os_service_default'],
  $template_dir                                    = $facts['os_service_default'],
  $max_nested_stack_depth                          = $facts['os_service_default'],
  $plugin_dirs                                     = $facts['os_service_default'],
  $server_keystone_endpoint_type                   = $facts['os_service_default'],
  $hidden_stack_tags                               = $facts['os_service_default'],
  # DEPRECATED PARAMETERS
  $deferred_auth_method                            = undef,
) {

  include heat::deps

  include heat
  include heat::params

  if is_service_default($plugin_dirs) {
    $plugin_dirs_real = $facts['os_service_default']
  } elsif empty($plugin_dirs) {
    $plugin_dirs_real = $facts['os_service_default']
  } else {
    $plugin_dirs_real = join(any2array($plugin_dirs), ',')
  }

  package { 'heat-engine':
    ensure => $package_ensure,
    name   => $::heat::params::engine_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'heat-engine':
      ensure     => $service_ensure,
      name       => $::heat::params::engine_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'heat-service',
    }
  }

  heat_config {
    'DEFAULT/auth_encryption_key':                             value => $auth_encryption_key, secret => true;
    'DEFAULT/heat_stack_user_role':                            value => $heat_stack_user_role;
    'DEFAULT/heat_metadata_server_url':                        value => $heat_metadata_server_url;
    'DEFAULT/heat_waitcondition_server_url':                   value => $heat_waitcondition_server_url;
    'DEFAULT/default_software_config_transport':               value => $default_software_config_transport;
    'DEFAULT/default_deployment_signal_transport':             value => $default_deployment_signal_transport;
    'DEFAULT/default_user_data_format':                        value => $default_user_data_format;
    'DEFAULT/reauthentication_auth_method':                    value => $reauthentication_auth_method;
    'DEFAULT/allow_trusts_redelegation':                       value => $allow_trusts_redelegation;
    'DEFAULT/trusts_delegated_roles':                          value => join(any2array($trusts_delegated_roles), ',');
    'DEFAULT/max_stacks_per_tenant':                           value => $max_stacks_per_tenant;
    'DEFAULT/max_resources_per_stack':                         value => $max_resources_per_stack;
    'DEFAULT/max_software_configs_per_tenant':                 value => $max_software_configs_per_tenant;
    'DEFAULT/max_software_deployments_per_tenant':             value => $max_software_deployments_per_tenant;
    'DEFAULT/max_snapshots_per_stack':                         value => $max_snapshots_per_stack;
    'DEFAULT/action_retry_limit':                              value => $action_retry_limit;
    'DEFAULT/client_retry_limit':                              value => $client_retry_limit;
    'DEFAULT/max_server_name_length':                          value => $max_server_name_length;
    'DEFAULT/max_interface_check_attempts':                    value => $max_interface_check_attempts;
    'DEFAULT/max_nova_api_microversion':                       value => $max_nova_api_microversion;
    'DEFAULT/max_cinder_api_microversion':                     value => $max_cinder_api_microversion;
    'DEFAULT/max_ironic_api_microversion':                     value => $max_ironic_api_microversion;
    'DEFAULT/event_purge_batch_size':                          value => $event_purge_batch_size;
    'DEFAULT/max_events_per_stack':                            value => $max_events_per_stack;
    'DEFAULT/stack_action_timeout':                            value => $stack_action_timeout;
    'DEFAULT/error_wait_time':                                 value => $error_wait_time;
    'DEFAULT/engine_life_check_timeout':                       value => $engine_life_check_timeout;
    'DEFAULT/instance_connection_https_validate_certificates': value => $instance_connection_https_validate_certificates;
    'DEFAULT/instance_connection_is_secure':                   value => $instance_connection_is_secure;
    'DEFAULT/num_engine_workers':                              value => $num_engine_workers;
    'DEFAULT/convergence_engine':                              value => $convergence_engine;
    'DEFAULT/environment_dir':                                 value => $environment_dir;
    'DEFAULT/template_dir':                                    value => $template_dir;
    'DEFAULT/max_nested_stack_depth':                          value => $max_nested_stack_depth;
    'DEFAULT/plugin_dirs':                                     value => $plugin_dirs_real;
    'DEFAULT/server_keystone_endpoint_type':                   value => $server_keystone_endpoint_type;
    'DEFAULT/hidden_stack_tags':                               value => join(any2array($hidden_stack_tags), ',');
  }

  if $deferred_auth_method != undef {
    warning('deferred_auth_method is deprecated and will be removed in a future release')
  }
  heat_config {
    'DEFAULT/deferred_auth_method': value => pick($deferred_auth_method, $facts['os_service_default']);
  }
}
