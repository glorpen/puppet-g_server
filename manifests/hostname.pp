class g_server::hostname(
  $hostname
){
  file { '/etc/hostname':
    content => $hostname,
  }~>
  exec { 'g_server update hostname':
    command => 'hostname -F /etc/hostname',
    path => ['/bin', '/usr/bin', '/usr/local/bin'],
    refreshonly => true
  }
}
