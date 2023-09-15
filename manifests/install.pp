class collectd::install (
  Hash $packages,
) {
  if ( $facts['os']['family'] == "Debian" ) and ( $facts['os']['distro']['codename'] == "xenial" ) {
    $apt_ensure = present
  } else {
    $apt_ensure = absent
  }
  case $facts['os']['family'] {
    "Debian": {
      apt::key { "F806817DC3F5EA417F9FA2963994D24FB8543576":
        ensure => $apt_ensure,
        source => "http://pkg.ci.collectd.org/pubkey.asc",
      }
      -> apt::source { "collectd-ci":
        ensure => $apt_ensure,
        location => "http://pkg.ci.collectd.org/deb/",
        release => $facts['os']['distro']['codename'],
        repos => "collectd-5.8",
        before => Package[keys($packages)],
      }
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
