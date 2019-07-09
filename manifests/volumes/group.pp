# @summary Manages LVM volume group.
#
# @param devices
#   Block devices to use for this VG.
# @param vg_name
#   Name of LVM VG to use.
# @param volumes
#   Creates volumes with g_server::volumes::vol type.
# @param thin_pools
#   Creates thinly provisioned pools (not volumes) with g_server::volumes::thinpool type.
# @param raids
#   Creates lvm raids with g_server::volumes::raid type.
define g_server::volumes::group (
  Array[String] $devices,
  String $vg_name = $title,
  Hash $volumes = {},
  Hash $thin_pools = {},
  Hash $raids = {}
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
  create_resources(g_server::volumes::raid, $raids, {'vg_name' => $vg_name})
}
