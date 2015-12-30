# == Class: heat::config
#
# This class is used to manage arbitrary Heat configurations.
#
# === Parameters
#
# [*heat_config*]
#   (optional) Allow configuration of arbitrary Heat configurations.
#   The value is a hash of heat_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   heat_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class heat::config (
  $heat_config = {},
) {

  include ::heat::deps

  validate_hash($heat_config)

  create_resources('heat_config', $heat_config)
}
