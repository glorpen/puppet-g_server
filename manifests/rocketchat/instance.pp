define g_server::rocketchat::instance(
  $site_url = undef,
  $internal_port = undef,
  $mongo_url = undef,
){
  file { "/etc/init.d/rocketchat.${title}":
    ensure => 'link',
    target => '/etc/init.d/rocketchat'
  }
  file { "/etc/conf.d/rocketchat.${title}":
    content => template('g_server/rocketchat/instance.conf.erb')
  }
  
  firewall { "100 drop external Rocket.Chat[${title}] access":
    dport   => $internal_port,
    proto  => tcp,
    action => drop,
    iniface => '! lo'
  }
  
  #firewall for internal port
  #nginx proxy
  #letsencrypt ssl
  #run service
}
