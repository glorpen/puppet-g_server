define g_server::volumes::vol (
  Enum['present','absent'] $ensure = 'present',
  String $lv_name = $title,
  String $vg_name,
  String $mountpoint,
  String $size,
  String $fs = 'ext4',
  String $fs_options = '',
  String $mount_options = 'noatime,nodiratime',
  Integer $pass = 0
){
  file { $mountpoint: 
    ensure => $ensure?{
      'present' => directory,
      default => $ensure
    },
    backup => false,
    force => true,
    recurse => false
  }
  
  lvm::logical_volume { $lv_name:
    ensure       => $ensure,
    volume_group => $vg_name,
    size         => $size,
    mountpath => $mountpoint,
    mountpath_require => false,
    fs_type => $fs,
    mkfs_options => $fs_options,
    options => $mount_options,
    pass => $pass
  }
  
  if $ensure == 'present' {
    /*File[$mountpoint]
    ->Mount[$mountpoint]*/
  } else {
    # fix for puppetlabs-lvm
    Exec <| title=="ensure mountpoint '${mountpoint}' exists" |> {
      unless => "true",
    }
    
    Mount[$mountpoint]
    ->File[$mountpoint]
  }
}
