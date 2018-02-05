#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Resource to serve Heat API with apache mod_wsgi in place of heat-api service.
#
# This is useful for the main API as well as the CFN API.
# Serving Heat API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses when running eventlet.
#
# When using this class you should disable your heat-api service.
#
# == Parameters
#
#   [*title*]
#     The heat API that will be running over this vhost.
#     The valid options are "api" and "api_cfn"
#
#   [*port*]
#     The port for the specific API.
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $::fqdn
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*path*]
#     The prefix for the endpoint.
#     Optional. Defaults to '/'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to $::os_workers
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to 1
#
#   [*ssl_cert*]
#   [*ssl_key*]
#   [*ssl_chain*]
#   [*ssl_ca*]
#   [*ssl_crl_path*]
#   [*ssl_crl*]
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
#   [*vhost_custom_fragment*]
#     (optional) Additional vhost configuration, if applicable.
#
#   [*access_log_file*]
#     The log file name for the virtualhost.
#     Optional. Defaults to false.
#
#   [*access_log_format*]
#     The log format for the virtualhost.
#     Optional. Defaults to false.
#
#   [*error_log_file*]
#     The error log file name for the virtualhost.
#     Optional. Defaults to undef.
#
#   [*custom_wsgi_process_options*]
#     (optional) gives you the oportunity to add custom process options or to
#     overwrite the default options for the WSGI main process.
#     eg. to use a virtual python environment for the WSGI process
#     you could set it to:
#     { python-path => '/my/python/virtualenv' }
#     Defaults to {}
#
#   [*wsgi_process_display_name*]
#     (optional) Name of the WSGI process display-name.
#     Defaults to undef
#
# == Dependencies
#
#   requires Class['apache'] & Class['heat']
#
# == Examples
#
#   include apache
#
#   class { 'heat::wsgi::apache': }
#
define heat::wsgi::apache (
  $port,
  $servername                  = $::fqdn,
  $bind_host                   = undef,
  $path                        = '/',
  $ssl                         = true,
  $workers                     = $::os_workers,
  $ssl_cert                    = undef,
  $ssl_key                     = undef,
  $ssl_chain                   = undef,
  $ssl_ca                      = undef,
  $ssl_crl_path                = undef,
  $ssl_crl                     = undef,
  $ssl_certs_dir               = undef,
  $threads                     = 1,
  $priority                    = '10',
  $vhost_custom_fragment       = undef,
  $access_log_file             = false,
  $access_log_format           = false,
  $error_log_file              = undef,
  $custom_wsgi_process_options = {},
  $wsgi_process_display_name   = undef,
) {
  if $title !~ /^api(|_cfn)$/ {
    fail('The valid options are api, api_cfn')
  }
  include ::heat::deps
  include ::heat::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  ::openstacklib::wsgi::apache { "heat_${title}_wsgi":
    bind_host                   => $bind_host,
    bind_port                   => $port,
    group                       => 'heat',
    path                        => $path,
    priority                    => $priority,
    servername                  => $servername,
    ssl                         => $ssl,
    ssl_ca                      => $ssl_ca,
    ssl_cert                    => $ssl_cert,
    ssl_certs_dir               => $ssl_certs_dir,
    ssl_chain                   => $ssl_chain,
    ssl_crl                     => $ssl_crl,
    ssl_crl_path                => $ssl_crl_path,
    ssl_key                     => $ssl_key,
    threads                     => $threads,
    user                        => 'heat',
    workers                     => $workers,
    wsgi_daemon_process         => "heat_${title}",
    wsgi_process_display_name   => $wsgi_process_display_name,
    wsgi_process_group          => "heat_${title}",
    wsgi_script_dir             => $::heat::params::heat_wsgi_script_path,
    wsgi_script_file            => "heat_${title}",
    wsgi_script_source          => getvar("::heat::params::heat_${title}_wsgi_script_source"),
    custom_wsgi_process_options => $custom_wsgi_process_options,
    allow_encoded_slashes       => 'on',
    require                     => Anchor['heat::install::end'],
    vhost_custom_fragment       => $vhost_custom_fragment,
    access_log_file             => $access_log_file,
    access_log_format           => $access_log_format,
    error_log_file              => $error_log_file,
  }
}
