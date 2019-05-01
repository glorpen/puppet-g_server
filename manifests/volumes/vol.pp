define g_server::volumes::vol (
  String $vg_name,
  String $mountpoint,
  String $size,
  String $lv_name = $title,
  Enum['present','absent'] $ensure = 'present',
  String $fs = 'ext4',
  String $fs_options = '',
  String $mount_options = 'noatime,nodiratime',
  Integer $pass = 0,
  Optional[String] $thinpool = undef,
  Optional[String] $mountpoint_user = undef,
  Optional[String] $mountpoint_group = undef,
  Optional[String] $mountpoint_mode = undef,
  Boolean $manage_mountpoint = true
){

  $ensure_directory = $ensure?{
    'present' => directory,
    default   => $ensure
  }
  $_thinpool = $thinpool?{
    undef   => false,
    default => $thinpool
  }

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
    thinpool          => $_thinpool
  }

  if $ensure == 'present' {

    if $manage_mountpoint {
      file { $mountpoint:
        ensure  => $ensure_directory,
        backup  => false,
        force   => true,
        recurse => false,
        owner   => $mountpoint_user,
        group   => $mountpoint_group,
        mode    => $mountpoint_mode
      }
      if $mountpoint_user {
        User[$mountpoint_user]
        -> File[$mountpoint]
      }
      if $mountpoint_group and $mountpoint_group != $mountpoint_user {
        Group[$mountpoint_group]
        -> File[$mountpoint]
      }
    }

    # File[$mountpoint]
    # ->Mount[$mountpoint]
  } else {
    # fix for puppetlabs-lvm
    Exec <| title=="ensure mountpoint '${mountpoint}' exists" |> {
      unless => 'true',
    }

    if $manage_mountpoint {
      # fix for dependency cycle when ensure=>absent and file is autorequiring parent
      # https://tickets.puppetlabs.com/browse/PUP-2451
      exec { "g_server remove vol mountpoint ${mountpoint}":
        path    => '/usr/bin:/usr/sbin:/bin',
        command => "rmdir '${mountpoint}'",
        onlyif  => "test -d '${mountpoint}'"
      }

      Mount[$mountpoint]
      ->Exec["g_server remove vol mountpoint ${mountpoint}"]
    }
  }
}
