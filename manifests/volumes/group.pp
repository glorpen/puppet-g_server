define g_server::volumes::group (
  String $vg_name = $title,
  Array[String] $devices,
  Hash $volumes = {}
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
}
