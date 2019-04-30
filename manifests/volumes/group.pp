define g_server::volumes::group (
  Array[String] $devices,
  String $vg_name = $title,
  Hash $volumes = {},
  Hash $thin_pools = {}
){
  $devices.each | $device | {
    physical_volume { $device:
        ensure => present,
        #unless_vg => $vg_name
    }
  }
  volume_group { $vg_name:
    ensure           => present,
    physical_volumes => $devices,
    #createonly => true
  }

  create_resources(g_server::volumes::vol, $volumes, {'vg_name' => $vg_name})
  create_resources(g_server::volumes::thinpool, $thin_pools, {'vg_name' => $vg_name})
}
