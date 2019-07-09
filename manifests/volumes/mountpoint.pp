define g_server::volumes::mountpoint(
  String $ensure,
  String $mountpoint = $name,
  Variant[String,Integer,Undef] $user = undef,
  Variant[String,Integer,Undef] $group = undef,
  Optional[String] $mode = undef,
  Boolean $manage = true
){
  $ensure_directory = $ensure?{
    'present' => directory,
    default   => $ensure
  }

  if $ensure == 'present' {

    if $manage {
      file { $mountpoint:
        ensure  => $ensure_directory,
        backup  => false,
        force   => true,
        recurse => false,
        owner   => $user,
        group   => $group,
        mode    => $mode
      }
      if $user=~String {
        User[$user]
        -> File[$mountpoint]
      }
      if $group=~String {
        Group[$group]
        -> File[$mountpoint]
      }
    }

    File[$mountpoint]
    ->Mount[$mountpoint]
  } else {
    # fix for puppetlabs-lvm
    Exec <| title=="ensure mountpoint '${mountpoint}' exists" |> {
      # lint:ignore:quoted_booleans
      unless => 'true',
      # lint:endignore
    }

    if $manage {
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
