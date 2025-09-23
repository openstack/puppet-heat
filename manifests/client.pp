# == Class: heat::client
#
# Installs the heat python library.
#
# === Parameters
#
# [*ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'present'.
#
class heat::client (
  Stdlib::Ensure::Package $ensure = 'present'
) {
  include heat::deps
  include heat::params

  # NOTE(tkajinam): heat-package tag is used because heatclient is required
  #                 by heat
  package { 'python-heatclient':
    ensure => $ensure,
    name   => $heat::params::client_package_name,
    tag    => ['openstack', 'openstackclient', 'heat-package'],
  }

  include openstacklib::openstackclient
}
