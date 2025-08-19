# == Class: heat::reports
#
# Configure oslo_reports options
#
# === Parameters
#
# [*log_dir*]
#   (Optional) Path to a log directory where to create a file
#   Defaults to $facts['os_service_default']
#
# [*file_event_handler*]
#   (Optional) The path to a file to watch for changes to trigger the reports.
#   Defaults to $facts['os_service_default']
#
# [*file_event_handler_interval*]
#   (Optional) How many seconds to wait between pools when file_event_handler
#   is set.
#   Defaults to $facts['os_service_default']
#
class heat::reports (
  $log_dir                     = $facts['os_service_default'],
  $file_event_handler          = $facts['os_service_default'],
  $file_event_handler_interval = $facts['os_service_default'],
) {
  include heat::deps

  oslo::reports { 'heat_config':
    log_dir                     => $log_dir,
    file_event_handler          => $file_event_handler,
    file_event_handler_interval => $file_event_handler_interval,
  }
}
