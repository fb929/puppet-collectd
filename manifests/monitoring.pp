class collectd::monitoring (
  Boolean $consul,
  Hash $consul_meta,
  Hash $consul_alerts,
) {
  if $consul {
    tools::consul_cfg { $module_name:
      port => 9103,
      meta => $consul_meta,
    }
    ensure_resources(
      tools::consul_alert,
      $consul_alerts
    )
  }
}
