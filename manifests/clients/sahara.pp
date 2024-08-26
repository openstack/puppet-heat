# Class heat::clients::sahara
#
#  DEPRECATED !!
#  sahara client configuration
#
# == Parameters
#
# [*endpoint_type*]
#   (Optional) Type of endpoint in Identity service catalog to use for
#   communication with the OpenStack service.
#   Defaults to $facts['os_service_default'].
#
# [*ca_file*]
#   (Optional) Optional CA cert file to use in SSL communications.
#   Defaults to $facts['os_service_default'].
#
# [*cert_file*]
#   (Optional) Optional PEM-formatted certificate chain file.
#   Defaults to $facts['os_service_default'].
#
# [*key_file*]
#   (Optional) Optional PEM-formatted file that contains the private key.
#   Defaults to $facts['os_service_default'].
#
# [*insecure*]
#   (Optional) If set, then the server's certificate will not be verified.
#   Defaults to $facts['os_service_default'].
#
class heat::clients::sahara (
  $endpoint_type = $facts['os_service_default'],
  $ca_file       = $facts['os_service_default'],
  $cert_file     = $facts['os_service_default'],
  $key_file      = $facts['os_service_default'],
  $insecure      = $facts['os_service_default'],
) {

  include heat::deps

  warning('The heat::clients::sahara class is deprecated.')

  heat::clients::base { 'clients_sahara':
    endpoint_type => $endpoint_type,
    ca_file       => $ca_file,
    cert_file     => $cert_file,
    key_file      => $key_file,
    insecure      => $insecure,
  }
}
