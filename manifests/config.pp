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
# [*heat_api_paste_ini*]
#   (optional) Allow configuration of /etc/heat/api-paste.ini options.
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class heat::config (
  Hash $heat_config        = {},
  Hash $heat_api_paste_ini = {},
) {
  include heat::deps

  create_resources('heat_config', $heat_config)
  create_resources('heat_api_paste_ini', $heat_api_paste_ini)
}
