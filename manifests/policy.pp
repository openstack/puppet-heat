# == Class: heat::policy
#
# Configure the heat policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for heat
#   Example : { 'heat-context_is_admin' => {'context_is_admin' => 'true'}, 'heat-default' => {'default' => 'rule:admin_or_owner'} }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the heat policy.json file
#   Defaults to /etc/heat/policy.json
#
class heat::policy (
  $policies    = {},
  $policy_path = '/etc/heat/policy.json',
) {

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }
  class { 'openstacklib::policy' :
    policies => $policies,
  }

}
