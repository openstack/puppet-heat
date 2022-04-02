# Class heat::clients::heat
#
#  heat client configuration
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
# [*url*]
#   (Optional) Optional heat url in format.
#   Defaults to $::os_service_default.
#
class heat::clients::heat (
  $endpoint_type = $::os_service_default,
  $ca_file       = $::os_service_default,
  $cert_file     = $::os_service_default,
  $key_file      = $::os_service_default,
  $insecure      = $::os_service_default,
  $url           = $::os_service_default,
) {

  include heat::deps

  $url_real = pick($::heat::heat_clients_url, $url)

  heat::clients::base { 'clients_heat':
    endpoint_type => $endpoint_type,
    ca_file       => $ca_file,
    cert_file     => $cert_file,
    key_file      => $key_file,
    insecure      => $insecure,
  }

  heat_config {
    'clients_heat/url': value => $url_real;
  }
}
