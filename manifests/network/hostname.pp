class g_server::network::hostname(
  $hostname
){
  case $::osfamily {
    'Gentoo': {
      ensure_resource('service', 'hostname', {
        'ensure'  => 'running',
        'enabled' => true
      })

      file { '/etc/conf.d/hostname':
        content => "# Set to the hostname of this machine\nhostname=\"${hostname}\"\n",
      }
      ~>Service['hostname']
    }
    default: {
      file { '/etc/hostname':
        content => "${hostname}\n",
      }
      ~> exec { 'g_server update hostname':
        command     => 'hostname -F /etc/hostname',
        path        => ['/bin', '/usr/bin', '/usr/local/bin'],
        refreshonly => true,
        require     => Package['hostname']
      }
    }
  }
}
