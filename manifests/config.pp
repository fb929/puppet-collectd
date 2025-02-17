class collectd::config (
  String $cfg_dir,
  String $bin_dir,
  Hash $cfg,
  String $vmswap_process,
  Boolean $syslog_ng,
) {
  file {
    "/etc/collectd.conf":
      content => template("${module_name}/collectd.conf.erb"),
      notify => Service[$module_name],
    ;
    [
      $cfg_dir,
      $bin_dir,
    ]:
      ensure => directory,
      recurse => true,
      purge => true,
      force => true,
      notify => Service[$module_name],
      ignore  => [
        ".*",
        "*.pyc",
        "__pycache__",
      ],
    ;
  }
  if $syslog_ng {
    syslog_ng::cfg { $module_name: }
    collectd::cfg { "log": order => 01, content => template("${module_name}/conf.d/syslog.conf.erb") }
  } else {
    file {
      "/var/log/collectd/": ensure => directory;
      "/etc/logrotate.d/collectd": content => template("${module_name}/logrotate.erb");
    }
    collectd::cfg { "log": order => 01, content => template("${module_name}/conf.d/logfile.conf.erb") }
  }
  systemd::unit_file { "${module_name}.service":
    content => template("${module_name}/service.erb"),
    enable => true,
    active => true,
  }
  -> collectd::cfg {
    "write_prometheus": order => 01, content => template("${module_name}/conf.d/write_prometheus.conf.erb");
    "processes": order => 10, content => template("${module_name}/conf.d/processes.conf.erb");
    "netlink": content => template("${module_name}/conf.d/netlink.conf.erb");
    "disk": content => template("${module_name}/conf.d/disk.conf.erb");
    "df": content => template("${module_name}/conf.d/df.conf.erb");
    "interface": content => template("${module_name}/conf.d/interface.conf.erb");
    "tcpconns": content => template("${module_name}/conf.d/tcpconns.conf.erb");
    "protocols": content => template("${module_name}/conf.d/protocols.conf.erb");
  }
  if $facts['memory']['swap'] {
    collectd::cfg { "swap": content => template("${module_name}/conf.d/swap.conf.erb"); }
    # monitoring swap by process {{
    collectd::bin { "vmswap.py": content => template("${module_name}/bin/vmswap.py"); }
    -> collectd::cfg { "vmswap": content => template("${module_name}/conf.d/vmswap.conf.erb"); }
    # }}
  }
  if $cfg {
    ensure_resources( "collectd::cfg", $cfg )
  }
}
