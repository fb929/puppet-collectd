define collectd::bin (
  Any $source  = undef,
  Any $content = undef,
) {
  include ::collectd

  $cfg_dir = $::collectd::config::cfg_dir
  $bin_dir = $::collectd::config::bin_dir

  file { "${bin_dir}/${name}":
    content => $content,
    source  => $source,
    mode  => "0755",
    notify  => Service["collectd"],
    require => File[$bin_dir],
  }
}
