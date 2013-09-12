# Installs & configure the heat engine service

class heat::engine (
  $enabled                       = true,
  $heat_stack_user_role          = 'heat_stack_user',
  $heat_metadata_server_url      = 'http://127.0.0.1:8000',
  $heat_waitcondition_server_url = 'http://127.0.0.1:8000/v1/waitcondition',
  $heat_watch_server_url         = 'http://127.0.0.1:8003',
) {

  include heat::params

  Heat_config<||> ~> Service['heat-engine']

  Package['heat-engine'] -> Heat_config<||>
  Package['heat-engine'] -> Service['heat-engine']
  package { 'heat-engine':
    ensure => installed,
    name   => $::heat::params::engine_package_name,
  }

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
    require    => [ File['/etc/heat/heat.conf'],
                    Exec['heat-encryption-key-replacement'],
                    Package['heat-common'],
                    Package['heat-engine']],
    subscribe  => Exec['heat-dbsync'],
  }

  exec {'heat-encryption-key-replacement':
    command => 'sed -i".bak" "s/%ENCRYPTION_KEY%/`hexdump -n 16 -v -e \'/1 "%02x"\' /dev/random`/" /etc/heat/heat.conf',
    path    => [ '/usr/bin', '/bin'],
    onlyif  => 'grep -c %ENCRYPTION_KEY% /etc/heat/heat.conf',
    require => File['/etc/heat/heat.conf'],
  }

  heat_config {
    'DEFAULT/auth_encryption_key'          : value => '%ENCRYPTION_KEY%'; # replaced above
    'DEFAULT/heat_stack_user_role'         : value => $heat_stack_user_role;
    'DEFAULT/heat_metadata_server_url'     : value => $heat_metadata_server_url;
    'DEFAULT/heat_waitcondition_server_url': value => $heat_waitcondition_server_url;
    'DEFAULT/heat_watch_server_url'        : value => $heat_watch_server_url;
  }
}
