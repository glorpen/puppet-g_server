define g_server::volumes::vol (
  String $lv_name = $title,
  String $vg_name,
  String $mountpoint,
  String $size,
  String $fs = 'ext4',
  String $fs_options = ''
){
  file { $mountpoint: 
    ensure => directory
  }
  
  lvm::logical_volume { $lv_name:
    ensure       => present,
    volume_group => $vg_name,
    size         => $size,
    mountpath => $mountpoint,
    mountpath_require => true,
    fs_type => $fs,
    mkfs_options => $fs_options,
    options => 'noatime,nodiratime'
  }
}
