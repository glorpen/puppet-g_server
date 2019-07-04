define g_server::volumes::raid (
  String $vg_name,
  String $mountpoint,
  String $size,
  String $lv_name = $title,
  Optional[Integer] $mirrors = undef,
  Optional[Integer] $stripes = undef,
  Integer $level = 1,
  Enum['present','absent'] $ensure = 'present',
  String $fs = 'ext4',
  String $fs_options = '',
  String $mount_options = 'noatime,nodiratime',
  Integer $pass = 0,
  Variant[String,Integer,Undef] $mountpoint_user = undef,
  Variant[String,Integer,Undef] $mountpoint_group = undef,
  Optional[String] $mountpoint_mode = undef,
  Boolean $manage_mountpoint = true
){
  lvm::logical_volume { $lv_name:
    ensure            => $ensure,
    volume_group      => $vg_name,
    size              => $size,
    mountpath         => $mountpoint,
    mountpath_require => false,
    fs_type           => $fs,
    mkfs_options      => $fs_options,
    options           => $mount_options,
    pass              => $pass,
    mirror            => $mirrors,
    stripes           => $stripes,
    type              => "raid${level}"
  }

  g_server::volumes::mountpoint{ $mountpoint:
      ensure => $ensure,
      user   => $mountpoint_user,
      group  => $mountpoint_group,
      mode   => $mountpoint_mode,
      manage => $manage_mountpoint
  }
}
