class collectd::rasdaemon::monitoring {
  #collectd::cfg { "rasdaemon": content => inline_template("LoadPlugin rasdaemon\n"); }
}
