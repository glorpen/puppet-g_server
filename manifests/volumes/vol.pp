define g_server::volumes::vol (
  Enum['present','absent'] $ensure = 'present',
  String $lv_name = $title,
  String $vg_name,
  String $mountpoint,
  String $size,
  String $fs = 'ext4',
  String $fs_options = '',
  String $mount_options = 'noatime,nodiratime',
  Integer $pass = 0,
  Optional[String] $thinpool = undef,
  Optional[String] $mountpoint_user = undef,
  Optional[String] $mountpoint_group = undef,
  Optional[String] $mountpoint_mode = undef
){
  
  lvm::logical_volume { $lv_name:
    ensure       => $ensure,
    volume_group => $vg_name,
    size         => $size,
    mountpath => $mountpoint,
    mountpath_require => false,
    fs_type => $fs,
    mkfs_options => $fs_options,
    options => $mount_options,
    pass => $pass,
    thinpool => $thinpool?{
      undef => false,
      default => $thinpool
    }
  }
  
  if $ensure == 'present' {
    
    file { $mountpoint:
      ensure => $ensure?{
        'present' => directory,
        default => $ensure
      },
      backup => false,
      force => true,
      recurse => false,
      owner => $mountpoint_user,
      group => $mountpoint_group,
      mode => $mountpoint_mode
    }
    
    /*File[$mountpoint]
    ->Mount[$mountpoint]*/
  } else {
    # fix for puppetlabs-lvm
    Exec <| title=="ensure mountpoint '${mountpoint}' exists" |> {
      unless => "true",
    }
    # fix for dependency cycle when ensure=>absent and file is autorequiring parent
    # https://tickets.puppetlabs.com/browse/PUP-2451
    exec { "g_server remove vol mountpoint ${mountpoint}":
      path     => '/usr/bin:/usr/sbin:/bin',
      command  => "rmdir '${mountpoint}'",
      onlyif   => "test -d '${mountpoint}'"
    }
    
    Mount[$mountpoint]
    ->Exec["g_server remove vol mountpoint ${mountpoint}"]
  }
}
