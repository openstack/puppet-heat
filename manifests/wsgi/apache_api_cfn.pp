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
#     Optional. Defaults to 1
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to $::os_workers
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
  $port          = 8000,
  $servername    = $::fqdn,
  $bind_host     = undef,
  $path          = '/',
  $ssl           = true,
  $workers       = 1,
  $ssl_cert      = undef,
  $ssl_key       = undef,
  $ssl_chain     = undef,
  $ssl_ca        = undef,
  $ssl_crl_path  = undef,
  $ssl_crl       = undef,
  $ssl_certs_dir = undef,
  $threads       = $::os_workers,
  $priority      = '10',
) {

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
    port          => $port,
    servername    => $servername,
    bind_host     => $bind_host,
    path          => $path,
    ssl           => $ssl,
    workers       => $workers,
    ssl_cert      => $ssl_cert,
    ssl_key       => $ssl_key,
    ssl_chain     => $ssl_chain,
    ssl_ca        => $ssl_ca,
    ssl_crl_path  => $ssl_crl_path,
    ssl_crl       => $ssl_crl,
    ssl_certs_dir => $ssl_certs_dir,
    threads       => $threads,
    priority      => $priority,
  }
}
