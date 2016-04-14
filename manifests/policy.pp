# == Class: heat::policy
#
# Configure the heat policies
#
# == Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for heat.
#   Defaults to empty hash.
#
#   Example:
#      {
#        'heat-context_is_admin' => {'context_is_admin' => 'true'},
#        'heat-default'          => {'default' => 'rule:admin_or_owner'}
#      }
#
# [*policy_path*]
#   (optional) Path to the heat policy.json file.
#   Defaults to '/etc/heat/policy.json'.
#
class heat::policy (
  $policies    = {},
  $policy_path = '/etc/heat/policy.json',
) {

  include ::heat::deps

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)
  oslo::policy { 'heat_config': policy_file => $policy_path }

  Anchor<| title == 'heat::config::start' |>
  -> Class['heat::policy']
  ~> Anchor<| title == 'heat::config::end' |>
}
