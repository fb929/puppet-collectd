class collectd::rasdaemon::install (
  Hash $packages,
) {
  ensure_resources(
    package,
    $packages,
    {
      ensure => present,
      notify => Service["rasdaemon"],
    }
  )
}
