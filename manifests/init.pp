class collectd (
  Boolean $lm_sensors,
  Boolean $rasdaemon,
){
  class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> class { "${module_name}::service": }
  -> class { "${module_name}::monitoring": }

  if $facts['virtual'] == 'physical' and $lm_sensors {
    class { "${module_name}::lm_sensors::install": }
    -> class { "${module_name}::lm_sensors::service": }
    -> class { "${module_name}::lm_sensors::monitoring": }
  }

  if $facts['virtual'] == 'physical' and $rasdaemon {
    class { "${module_name}::rasdaemon::install": }
    -> class { "${module_name}::rasdaemon::config": }
    -> class { "${module_name}::rasdaemon::service": }
    -> class { "${module_name}::rasdaemon::monitoring": }
  }
}
