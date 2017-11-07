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
# Serving Heat API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses when running eventlet.
#
# When using this class you should disable your heat-api service.
#
# == Parameters
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
class heat::wsgi::apache_api_cfn (
  $port                        = 8000,
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
  $access_log_file             = false,
  $access_log_format           = false,
  $error_log_file              = undef,
  $custom_wsgi_process_options = {},
  $wsgi_process_display_name   = undef,
) {

  # See custom fragment below
  include ::apache
  include ::apache::mod::headers

  validate_integer($port)

  # Workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1396553
  if $::osfamily == 'RedHat' and $port == 8000 and $::selinux {
    exec { "semanage port -m -t http_port_t -p tcp ${port}":
      unless => "semanage port -l | grep -q \"http_port_t.*${port}\"",
      path   => ['/usr/bin', '/usr/sbin'],
      notify => Heat::Wsgi::Apache['api_cfn'],
    }
  }

  heat::wsgi::apache { 'api_cfn':
    port                        => $port,
    servername                  => $servername,
    bind_host                   => $bind_host,
    path                        => $path,
    ssl                         => $ssl,
    workers                     => $workers,
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_chain                   => $ssl_chain,
    ssl_ca                      => $ssl_ca,
    ssl_crl_path                => $ssl_crl_path,
    ssl_crl                     => $ssl_crl,
    ssl_certs_dir               => $ssl_certs_dir,
    threads                     => $threads,
    priority                    => $priority,
    # Enforce content-type, see https://bugs.launchpad.net/tripleo/+bug/1641589
    vhost_custom_fragment       => 'RequestHeader set Content-Type "application/json"',
    custom_wsgi_process_options => $custom_wsgi_process_options,
    access_log_file             => $access_log_file,
    access_log_format           => $access_log_format,
    error_log_file              => $error_log_file,
    wsgi_process_display_name   => $wsgi_process_display_name,
  }
}
