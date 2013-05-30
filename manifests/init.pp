# Class heat
#
#  heat base package & configuration
#
# == parameters
#  [*package_ensure*]
#    ensure state for package. Optional. Defaults to 'present'
#  [*verbose*]
#    should the daemons log verbose messages. Optional. Defaults to 'False'
#  [*debug*]
#    should the daemons log debug messages. Optional. Defaults to 'False'
#  [*rabbit_host*]
#    ip or hostname of the rabbit server. Optional. Defaults to '127.0.0.1'
#  [*rabbit_port*]
#    port of the rabbit server. Optional. Defaults to 5672.
#  [*rabbit_hosts*]
#    array of host:port (used with HA queues). Optional. Defaults to undef.
#    If defined, will remove rabbit_host & rabbit_port parameters from config
#  [*rabbit_userid*]
#    user to connect to the rabbit server. Optional. Defaults to 'guest'
#  [*rabbit_password*]
#    password to connect to the rabbit_server. Optional. Defaults to empty.
#  [*rabbit_virtualhost*]
#    virtualhost to use. Optional. Defaults to '/'
#
class heat(
  $package_ensure     = 'present',
  $verbose            = 'False',
  $debug              = 'False',
  $rabbit_host        = '127.0.0.1',
  $rabbit_port        = 5672,
  $rabbit_hosts       = undef,
  $rabbit_userid      = 'guest',
  $rabbit_password    = '',
  $rabbit_virtualhost = '/',
) {

  include heat::params

  File {
    require => Package['heat-common'],
  }

  group { 'heat':
    name    => 'heat',
    require => Package['heat-common'],
  }

  user { 'heat':
    name    => 'heat',
    gid     => 'heat',
    groups  => ['nova'],
    system  => true,
    require => Package['heat-common'],
  }

  file { '/etc/heat/':
    ensure  => directory,
    owner   => 'heat',
    group   => 'heat',
    mode    => '0750',
  }

  file { '/etc/heat/heat-api.conf':
    owner   => 'heat',
    group   => 'heat',
    mode    => '0640',
  }

  file { '/etc/heat/heat-api-cloudwatch.conf':
    owner   => 'heat',
    group   => 'heat',
    mode    => '0640',
  }

  file { '/etc/heat/heat-api-cfn.conf':
    owner   => 'heat',
    group   => 'heat',
    mode    => '0640',
  }

  file { '/etc/heat/heat-engine.conf':
    owner   => 'heat',
    group   => 'heat',
    mode    => '0640',
  }

  package { 'heat-common':
    ensure => $package_ensure,
    name   => $::heat::params::common_package_name,
  }

  Package['heat-common'] -> heat_config<||>

  if $rabbit_hosts {
    heat_config { 'DEFAULT/rabbit_host': ensure => absent }
    heat_config { 'DEFAULT/rabbit_port': ensure => absent }
    heat_config { 'DEFAULT/rabbit_hosts':
      value => join($rabbit_hosts, ',')
    }
  } else {
    heat_config { 'DEFAULT/rabbit_host': value => $rabbit_host }
    heat_config { 'DEFAULT/rabbit_port': value => $rabbit_port }
    heat_config { 'DEFAULT/rabbit_hosts':
      value => "${rabbit_host}:${rabbit_port}"
    }
  }

  if size($rabbit_hosts) > 1 {
    heat_config { 'DEFAULT/rabbit_ha_queues': value => true }
  } else {
    heat_config { 'DEFAULT/rabbit_ha_queues': value => false }
  }

  heat_config {
    'DEFAULT/rabbit_userid'          : value => $rabbit_userid;
    'DEFAULT/rabbit_password'        : value => $rabbit_password;
    'DEFAULT/rabbit_virtualhost'     : value => $rabbit_virtualhost;
    'DEFAULT/debug'                  : value => $debug;
    'DEFAULT/verbose'                : value => $verbose;
    'DEFAULT/log_dir'                : value => $::heat::params::log_dir;
  }

}
