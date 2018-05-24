# == Class: heat
#
#  Heat base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to undef.
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored
#   If set to $::os_service_default, it will not log to any directory
#   Defaults to undef.
#
# [*default_transport_url*]
#   (optional) A URL representing the messaging driver to use and its full
#   configuration. Transport URLs take the form:
#   transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default
#
# [*control_exchange*]
#   (Optional) The default exchange under which topics are scoped. May be
#   overridden by an exchange name specified in the transport_url
#   option.
#   Defaults to $::os_service_default
#
# [*rpc_response_timeout*]
#   (Optional) Configure the timeout (in seconds) for rpc responses
#   Defaults to $::os_service_default.
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ (x-ha-policy: all).
#   Defaults to $::os_service_default.
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to $::os_service_default.
#
# [*rabbit_heartbeat_rate*]
#   (optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to $::os_service_default.
#
# [*rabbit_use_ssl*]
#   (Optional) Connect over SSL for RabbitMQ.
#   Defaults to $::os_service_default.
#
# [*kombu_ssl_ca_certs*]
#   (Optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $::os_service_default.
#
# [*kombu_ssl_certfile*]
#   (Optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $::os_service_default.
#
# [*kombu_ssl_keyfile*]
#   (Optional) SSL key file (valid only if SSL enabled).
#   Defaults to $::os_service_default.
#
# [*kombu_ssl_version*]
#   (Optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $::os_service_default.
#
# [*kombu_reconnect_delay*]
#   (Optional) How long to wait before reconnecting in response
#   to an AMQP consumer cancel notification. (floating point value)
#   Defaults to $::os_service_default
#
# [*kombu_failover_strategy*]
#   (Optional) Determines how the next RabbitMQ node is chosen in case the one
#   we are currently connected to becomes unavailable. Takes effect only if
#   more than one RabbitMQ node is provided in config. (string value)
#   Defaults to $::os_service_default
#
# [*kombu_compression*]
#   (optional) Possible values are: gzip, bz2. If not set compression will not
#   be used. This option may notbe available in future versions. EXPERIMENTAL.
#   (string value)
#   Defaults to $::os_service_default
#
# [*amqp_durable_queues*]
#   (Optional) Use durable queues in amqp.
#   Defaults to $::os_service_default.
#
# [*amqp_server_request_prefix*]
#   (Optional) Address prefix used when sending to a specific server
#   Defaults to $::os_service_default.
#
# [*amqp_broadcast_prefix*]
#   (Optional) address prefix used when broadcasting to all servers
#   Defaults to $::os_service_default.
#
# [*amqp_group_request_prefix*]
#   (Optional) address prefix when sending to any server in group
#   Defaults to $::os_service_default.
#
# [*amqp_container_name*]
#   (Optional) Name for the AMQP container
#   Defaults to $::os_service_default.
#
# [*amqp_idle_timeout*]
#   (Optional) Timeout for inactive connections
#   Defaults to $::os_service_default.
#
# [*amqp_trace*]
#   (Optional) Debug: dump AMQP frames to stdout
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_ca_file*]
#   (Optional) CA certificate PEM file to verify server certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_cert_file*]
#   (Optional) Identifying certificate PEM file to present to clients
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_file*]
#   (Optional) Private key PEM file used to sign cert_file certificate
#   Defaults to $::os_service_default.
#
# [*amqp_ssl_key_password*]
#   (Optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to $::os_service_default.
#
# [*amqp_allow_insecure_clients*]
#   (Optional) Accept clients using either SSL or plain TCP
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_mechanisms*]
#   (Optional) Space separated list of acceptable SASL mechanisms
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_config_dir*]
#   (Optional) Path to directory that contains the SASL configuration
#   Defaults to $::os_service_default.
#
# [*amqp_sasl_config_name*]
#   (Optional) Name of configuration file (without .conf suffix)
#   Defaults to $::os_service_default.
#
# [*amqp_username*]
#   (Optional) User name for message broker authentication
#   Defaults to $::os_service_default.
#
# [*amqp_password*]
#   (Optional) Password for message broker authentication
#   Defaults to $::os_service_default.
#
# [*host*]
#   (Optional) Name of this node. This is typically a hostname, FQDN, or
#   IP address.
#   Defaults to $::os_service_default.
#
# [*max_template_size*]
#   (Optional) Maximum raw byte size of any template.
#   Defaults to $::os_service_default
#
# [*max_json_body_size*]
#   (Optional) Maximum raw byte size of JSON request body.
#   Should be larger than max_template_size.
#   Defaults to $::os_service_default
#
# [*notification_transport_url*]
#   (optional) A URL representing the messaging driver to use for notifications
#   and its full configuration. Transport URLs take the form:
#     transport://user:pass@host1:port[,hostN:portN]/virtual_host
#   Defaults to $::os_service_default
#
# [*notification_driver*]
#   (Optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to $::os_service_default
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to ::os_service_default
#
# [*keystone_ec2_uri*]
#   (optional) Authentication Endpoint URI for ec2 service.
#   Defaults to ::os_service_default
#
# [*database_connection*]
#   (optional) Connection url for the heat database.
#   Defaults to undef.
#
# [*database_max_retries*]
#   (optional) Maximum database connection retries during startup.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle database connections are reaped.
#   Defaults to undef.
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   Defaults to undef.
#
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.

# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to undef.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef.
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to undef.
#
# [*flavor*]
#   (optional) Specifies the Authentication method.
#   Set to 'standalone' to get Heat to work with a remote OpenStack
#   Tested versions include 0.9 and 2.2
#   Defaults to $::os_service_default.
#
# [*region_name*]
#   (Optional) Region name for services. This is the
#   default region name that heat talks to service endpoints on.
#   Defaults to $::os_service_default.
#
# [*enable_stack_adopt*]
#   (Optional) Enable the stack-adopt feature.
#   Defaults to $::os_service_default.
#
# [*enable_stack_abandon*]
#   (Optional) Enable the stack-abandon feature.
#   Defaults to $::os_service_default.
#
# [*sync_db*]
#   (Optional) Run db sync on nodes after connection setting has been set.
#   Defaults to true
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# [*heat_clients_url*]
#   (optional) Heat url in format like http://0.0.0.0:8004/v1/%(tenant_id)s.
#   Defaults to $::os_service_default.
#
# [*heat_clients_keystone_uri*]
#   (optional) Heat clients auth url in format like http://127.0.0.1:5000/.
#   Defaults to $::os_service_default.
#
# [*heat_clients_endpoint_type*]
#   (optional) Type of endpoint in Identity service catalog to use for
#   communication with the OpenStack service.
#   Defaults to $::os_service_default.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the heat config.
#   Defaults to false.
#
# [*auth_strategy*]
#   (optional) Type of authentication to use
#   Defaults to 'keystone'
#
# [*yaql_limit_iterators*]
#   (optional) The maximum number of elements YAQL collection expressions can
#     take for evaluation.
#   Defaults to $::os_service_default.
#
# [*yaql_memory_quota*]
#   (optional) The maximum size of memory in bytes that YAQL expressions can
#     take for evaluation.
#   Defaults to $::os_service_default.
#
class heat(
  $package_ensure                     = 'present',
  $debug                              = undef,
  $log_dir                            = undef,
  $keystone_ec2_uri                   = $::os_service_default,
  $default_transport_url              = $::os_service_default,
  $rpc_response_timeout               = $::os_service_default,
  $control_exchange                   = $::os_service_default,
  $rabbit_ha_queues                   = $::os_service_default,
  $rabbit_heartbeat_timeout_threshold = $::os_service_default,
  $rabbit_heartbeat_rate              = $::os_service_default,
  $rabbit_use_ssl                     = $::os_service_default,
  $kombu_ssl_ca_certs                 = $::os_service_default,
  $kombu_ssl_certfile                 = $::os_service_default,
  $kombu_ssl_keyfile                  = $::os_service_default,
  $kombu_ssl_version                  = $::os_service_default,
  $kombu_reconnect_delay              = $::os_service_default,
  $kombu_failover_strategy            = $::os_service_default,
  $kombu_compression                  = $::os_service_default,
  $amqp_durable_queues                = $::os_service_default,
  $amqp_server_request_prefix         = $::os_service_default,
  $amqp_broadcast_prefix              = $::os_service_default,
  $amqp_group_request_prefix          = $::os_service_default,
  $amqp_container_name                = $::os_service_default,
  $amqp_idle_timeout                  = $::os_service_default,
  $amqp_trace                         = $::os_service_default,
  $amqp_ssl_ca_file                   = $::os_service_default,
  $amqp_ssl_cert_file                 = $::os_service_default,
  $amqp_ssl_key_file                  = $::os_service_default,
  $amqp_ssl_key_password              = $::os_service_default,
  $amqp_allow_insecure_clients        = $::os_service_default,
  $amqp_sasl_mechanisms               = $::os_service_default,
  $amqp_sasl_config_dir               = $::os_service_default,
  $amqp_sasl_config_name              = $::os_service_default,
  $amqp_username                      = $::os_service_default,
  $amqp_password                      = $::os_service_default,
  $host                               = $::os_service_default,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_facility                       = undef,
  $database_connection                = undef,
  $database_max_retries               = undef,
  $database_idle_timeout              = undef,
  $database_retry_interval            = undef,
  $database_min_pool_size             = undef,
  $database_max_pool_size             = undef,
  $database_max_overflow              = undef,
  $flavor                             = $::os_service_default,
  $region_name                        = $::os_service_default,
  $enable_stack_adopt                 = $::os_service_default,
  $enable_stack_abandon               = $::os_service_default,
  $sync_db                            = undef,
  $max_template_size                  = $::os_service_default,
  $max_json_body_size                 = $::os_service_default,
  $notification_transport_url         = $::os_service_default,
  $notification_driver                = $::os_service_default,
  $notification_topics                = $::os_service_default,
  $enable_proxy_headers_parsing       = $::os_service_default,
  $heat_clients_url                   = $::os_service_default,
  $heat_clients_keystone_uri          = $::os_service_default,
  $heat_clients_endpoint_type         = $::os_service_default,
  $purge_config                       = false,
  $auth_strategy                      = 'keystone',
  $yaql_memory_quota                  = $::os_service_default,
  $yaql_limit_iterators               = $::os_service_default,
) {

  include ::heat::logging
  include ::heat::db
  include ::heat::deps
  include ::heat::params

  if $auth_strategy == 'keystone' {
    include ::heat::keystone::authtoken
  }

  package { 'heat-common':
    ensure => $package_ensure,
    name   => $::heat::params::common_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  resources { 'heat_config':
    purge => $purge_config,
  }

  oslo::messaging::rabbit { 'heat_config':
    kombu_ssl_version           => $kombu_ssl_version,
    kombu_ssl_keyfile           => $kombu_ssl_keyfile,
    kombu_ssl_certfile          => $kombu_ssl_certfile,
    kombu_ssl_ca_certs          => $kombu_ssl_ca_certs,
    kombu_reconnect_delay       => $kombu_reconnect_delay,
    kombu_failover_strategy     => $kombu_failover_strategy,
    kombu_compression           => $kombu_compression,
    heartbeat_timeout_threshold => $rabbit_heartbeat_timeout_threshold,
    heartbeat_rate              => $rabbit_heartbeat_rate,
    rabbit_use_ssl              => $rabbit_use_ssl,
    amqp_durable_queues         => $amqp_durable_queues,
    rabbit_ha_queues            => $rabbit_ha_queues,
  }

  oslo::messaging::amqp { 'heat_config':
    server_request_prefix  => $amqp_server_request_prefix,
    broadcast_prefix       => $amqp_broadcast_prefix,
    group_request_prefix   => $amqp_group_request_prefix,
    container_name         => $amqp_container_name,
    idle_timeout           => $amqp_idle_timeout,
    trace                  => $amqp_trace,
    ssl_ca_file            => $amqp_ssl_ca_file,
    ssl_cert_file          => $amqp_ssl_cert_file,
    ssl_key_file           => $amqp_ssl_key_file,
    ssl_key_password       => $amqp_ssl_key_password,
    allow_insecure_clients => $amqp_allow_insecure_clients,
    sasl_mechanisms        => $amqp_sasl_mechanisms,
    sasl_config_dir        => $amqp_sasl_config_dir,
    sasl_config_name       => $amqp_sasl_config_name,
    username               => $amqp_username,
    password               => $amqp_password,
  }

  # TODO(aschultz): remove this after completely switched to www_authenticate_uri
  $auth_uri = pick($::heat::keystone::authtoken::auth_uri, $::heat::keystone::authtoken::www_authenticate_uri)
  $auth_url = $::heat::keystone::authtoken::auth_url
  $keystone_username = $::heat::keystone::authtoken::username
  $keystone_password = $::heat::keystone::authtoken::password
  $keystone_project_domain_name = $::heat::keystone::authtoken::project_domain_name
  $keystone_user_domain_name = $::heat::keystone::authtoken::user_domain_name
  if (defined($heat_clients_keystone_uri)) {
    $heat_clients_keystone_uri_real = $heat_clients_keystone_uri
  } else {
    $heat_clients_keystone_uri_real = $auth_uri
  }


  heat_config {
    'trustee/auth_type':           value => 'password';
    'trustee/auth_url':            value => $auth_url;
    'trustee/username':            value => $keystone_username;
    'trustee/password':            value => $keystone_password, secret => true;
    'trustee/project_domain_name': value => $keystone_project_domain_name;
    'trustee/user_domain_name':    value => $keystone_user_domain_name;
    'clients_keystone/auth_uri':   value => $heat_clients_keystone_uri_real;
    'clients_heat/url':            value => $heat_clients_url;
    'clients/endpoint_type':       value => $heat_clients_endpoint_type;
  }

  if (!is_service_default($enable_stack_adopt)) {
    validate_bool($enable_stack_adopt)
  }

  if (!is_service_default($enable_stack_abandon)) {
    validate_bool($enable_stack_abandon)
  }

  heat_config {
    'DEFAULT/host':                         value => $host;
    'DEFAULT/max_template_size':            value => $max_template_size;
    'DEFAULT/max_json_body_size':           value => $max_json_body_size;
    'DEFAULT/region_name_for_services':     value => $region_name;
    'DEFAULT/enable_stack_abandon':         value => $enable_stack_abandon;
    'DEFAULT/enable_stack_adopt':           value => $enable_stack_adopt;
    'ec2authtoken/auth_uri':                value => $keystone_ec2_uri;
    'paste_deploy/flavor':                  value => $flavor;
    'yaql/limit_iterators':                 value => $yaql_limit_iterators;
    'yaql/memory_quota':                    value => $yaql_memory_quota;
  }

  oslo::messaging::notifications { 'heat_config':
    transport_url => $notification_transport_url,
    driver        => $notification_driver,
    topics        => $notification_topics,
  }

  oslo::messaging::default { 'heat_config':
    transport_url        => $default_transport_url,
    rpc_response_timeout => $rpc_response_timeout,
    control_exchange     => $control_exchange,
  }

  oslo::middleware { 'heat_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
  }

}
