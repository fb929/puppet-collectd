class collectd::lm_sensors::install (
  Hash $packages,
) {
  ensure_resources(
    package,
    $packages,
    {
      ensure => present,
      notify => Service["lm_sensors"],
    }
  )
  exec { "sensors-detect --auto":
    creates => "/etc/sysconfig/lm_sensors",
    notify => Service["lm_sensors"],
  }
}
