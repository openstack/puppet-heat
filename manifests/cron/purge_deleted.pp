# == Class: heat::cron::purge_deleted
#
# Installs a cron job to purge db entries marked as deleted and older than $age.
# Default will be 1 day.
#
# === Parameters
#
#  [*ensure*]
#    (optional) Defaults to present.
#    Valid values are present, absent.
#
#  [*minute*]
#    (optional) Defaults to '1'.
#
#  [*hour*]
#    (optional) Defaults to '0'.
#
#  [*monthday*]
#    (optional) Defaults to '*'.
#
#  [*month*]
#    (optional) Defaults to '*'.
#
#  [*weekday*]
#    (optional) Defaults to '*'.
#
#  [*maxdelay*]
#    (optional) Seconds. Defaults to 0. Should be a positive integer.
#    Induces a random delay before running the cronjob to avoid running all
#    cron jobs at the same time on all hosts this job is configured.
#
#  [*user*]
#    (optional) User with access to heat files.
#    Defaults to 'heat'.
#
#  [*age*]
#    (optional) Age value for $age_type.
#    Defaults to '1'.
#
#  [*age_type*]
#    (optional) Age type.
#    Can be days, hours, minutes, seconds
#    Defaults to 'days'.
#
#  [*destination*]
#    (optional) Path to file to which rows should be archived
#    Defaults to '/var/log/heat/heat-purge_deleted.log'.
#
class heat::cron::purge_deleted (
  $ensure      = present,
  $minute      = 1,
  $hour        = 0,
  $monthday    = '*',
  $month       = '*',
  $weekday     = '*',
  $maxdelay    = 0,
  $user        = 'heat',
  $age         = 1,
  $age_type    = 'days',
  $destination = '/var/log/heat/heat-purge_deleted.log'
) {

  if ! member(['days', 'hours', 'minutes', 'seconds'], $age_type) {
    fail('age_type possible values are only days, hours, minutes, or seconds.')
  }

  if $maxdelay == 0 {
    $sleep = ''
  } else {
    $sleep = "sleep `expr \${RANDOM} \\% ${maxdelay}`; "
  }

  cron { 'heat-manage purge_deleted':
    ensure      => $ensure,
    command     => "${sleep}heat-manage purge_deleted -g ${age_type} ${age} >>${destination} 2>&1",
    environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
    user        => $user,
    minute      => $minute,
    hour        => $hour,
    monthday    => $monthday,
    month       => $month,
    weekday     => $weekday
  }

  Package['heat-common'] -> Cron['heat-manage purge_deleted']
}
