define g_server::wordpress::instance(
  $host = $title,
  $user = undef,
  $ensure => present
){

  validate_string($user)

  group { $user:
    ensure => $ensure
  }
  
  user { $user:
    $home => "/var/www/${host}",
    ensure => $ensure,
    shell => '/bin/false'
  }
  
  g_portage::webapp{ $title:
    application => 'wordpress',
    version => $::g_server::wordpress::version,
    user => $user,
    group => $user
  }
}
