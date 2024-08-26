class collectd::monitoring (
  Boolean $consul,
  Hash $consul_meta = {},
) {
  if $consul {
    tools::consul_cfg { $module_name:
      port => 9103,
      meta => $consul_meta,
    }
    tools::consul_alert { $module_name:
      cfg => {
        alert => "$fqdn InstanceDown",
        expr => "up{fqdn='$fqdn'} == 0",
        for => "5m",
        labels => {
          severity => "critical",
        },
        annotations => {
          description => "$fqdn instance down",
        },
      },
    }
  }
}
