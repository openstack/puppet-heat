# Class heat::clients
#
#  default client configuration
#
# == Parameters
#
# [*endpoint_type*]
#   (Optional) Type of endpoint in Identity service catalog to use for
#   communication with the OpenStack service.
#   Defaults to $::os_service_default.
#
# [*ca_file*]
#   (Optional) Optional CA cert file to use in SSL communications.
#   Defaults to $::os_service_default.
#
# [*cert_file*]
#   (Optional) Optional PEM-formatted certificate chain file.
#   Defaults to $::os_service_default.
#
# [*key_file*]
#   (Optional) Optional PEM-formatted file that contains the private key.
#   Defaults to $::os_service_default.
#
# [*insecure*]
#   (Optional) If set, then the server's certificate will not be verified.
#   Defaults to $::os_service_default.
#
class heat::clients (
  $endpoint_type = $::os_service_default,
  $ca_file       = $::os_service_default,
  $cert_file     = $::os_service_default,
  $key_file      = $::os_service_default,
  $insecure      = $::os_service_default,
) {

  include heat::deps

  $endpoint_type_real = pick($::heat::heat_clients_endpoint_type, $endpoint_type)

  heat::clients::base { 'clients':
    endpoint_type => $endpoint_type_real,
    ca_file       => $ca_file,
    cert_file     => $cert_file,
    key_file      => $key_file,
    insecure      => $insecure,
  }
}
