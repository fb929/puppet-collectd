# @summary
#   configure included config files for collectd
# @example create a collectd config for plugin prometheus
#   collectd::cfg { "write_prometheus":
#     order => 01,
#     source => "puppet:///modules/${module_name}/write_prometheus.conf",
#   }
# @param order
#   order for config file
# @param mode
#   file mode for config file
# @param source
#   set path to the "source"
# @param content
#   set path to the "content"
# @param source_typesdb
#   set path to the "source" for typesdb
# @param content_typesdb
#   set path to the "content" for typesdb

define collectd::cfg (
  Integer $order = 50,
  Optional[String] $mode = "0644",
  Optional[String] $source = undef,
  Optional[String] $content = undef,
  Optional[String] $source_typesdb = undef,
  Optional[String] $content_typesdb = undef,
) {
  include ::collectd

  $cfg_dir = $::collectd::config::cfg_dir
  $bin_dir = $::collectd::config::bin_dir

  $_order = sprintf("%02d", $order)

  file { "${cfg_dir}/${_order}_${name}.conf":
    content => $content,
    source => $source,
    mode => $mode,
    notify => Service["collectd"],
    require => File[$cfg_dir],
  }

  if $source_typesdb or $content_typesdb {
    file { "${cfg_dir}/${name}.db":
      content => $content_typesdb,
      source => $source_typesdb,
      mode => $mode,
      notify => Service["collectd"],
      require => File[$cfg_dir],
    }
  }
}
