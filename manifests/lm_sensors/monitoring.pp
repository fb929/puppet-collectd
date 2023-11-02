class collectd::lm_sensors::monitoring {
  collectd::cfg { "sensors": content => inline_template("LoadPlugin sensors\n"); }
}
