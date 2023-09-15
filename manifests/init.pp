class collectd {
  class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> class { "${module_name}::service": }
  -> class { "${module_name}::monitoring": }
}
