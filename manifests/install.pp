class collectd::install (
  Hash $packages,
) {
  # apt::key needs apt-key, which is gone since Debian 13, so declare it only where it is used
  if ( $facts['os']['family'] == "Debian" ) and ( $facts['os']['distro']['codename'] == "xenial" ) {
    apt::key { "F806817DC3F5EA417F9FA2963994D24FB8543576":
      source => "http://pkg.ci.collectd.org/pubkey.asc",
    }
    -> apt::source { "collectd-ci":
      location => "http://pkg.ci.collectd.org/deb/",
      release => $facts['os']['distro']['codename'],
      repos => "collectd-5.8",
      before => Package[keys($packages)],
    }
  }
  ensure_resources(
    package,
    $packages,
    {
      ensure => present,
      notify => Service[$module_name],
    }
  )
}
