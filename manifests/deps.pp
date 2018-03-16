# == Class: heat::deps
#
#  Heat anchors and dependency management
#
class heat::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'heat::install::begin': }
  -> Package<| tag == 'heat-package'|>
  ~> anchor { 'heat::install::end': }
  -> anchor { 'heat::config::begin': }
  -> Heat_config<||>
  ~> anchor { 'heat::config::end': }
  -> anchor { 'heat::db::begin': }
  -> anchor { 'heat::db::end': }
  ~> anchor { 'heat::dbsync::begin': }
  -> anchor { 'heat::dbsync::end': }
  ~> anchor { 'heat::service::begin': }
  ~> Service<| tag == 'heat-service' |>
  ~> anchor { 'heat::service::end': }

  # all cache settings should be applied and all packages should be installed
  # before service startup
  Oslo::Cache<||> -> Anchor['heat::service::begin']

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db<||> -> Anchor['heat::dbsync::begin']

  # Installation or config changes will always restart services.
  Anchor['heat::install::end'] ~> Anchor['heat::service::begin']
  Anchor['heat::config::end']  ~> Anchor['heat::service::begin']
}
