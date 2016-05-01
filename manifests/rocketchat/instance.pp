define g_server::rocketchat::instance(
  $domain = undef,
  $internal_port = undef,
  $mongo_url = undef,
){
  
  $site_url = "http://${domain}"
  
  file { "/etc/init.d/rocketchat.${title}":
    ensure => 'link',
    target => '/etc/init.d/rocketchat'
  }~>
  file { "/etc/conf.d/rocketchat.${title}":
    content => template('g_server/rocketchat/instance.conf.erb')
  }~>
  service { "rocketchat.${title}":
    ensure => "running",
    enable => true
  }
  
  #firewall for internal port
  firewall { "100 drop external Rocket.Chat[${title}] access":
    dport   => $internal_port,
    proto  => tcp,
    action => drop,
    iniface => '! lo'
  }
  
  #nginx proxy
  
  nginx::resource::vhost { $domain:
	  listen_port => 80,
	  proxy       => "http://localhost:${internal_port}",
    location_cfg_append => {
      proxy_http_version => '1.1',
      proxy_set_header => 'Upgrade $http_upgrade',
      proxy_set_header => 'Connection "upgrade"',
      proxy_set_header => 'Host $http_host',

      proxy_set_header => 'X-Real-IP $remote_addr',
      proxy_set_header => 'X-Forward-For $proxy_add_x_forwarded_for',
      proxy_set_header => 'X-Forward-Proto http',
      proxy_set_header => 'X-Nginx-Proxy true',

      proxy_redirect => 'off'
    }
	}
  
  #letsencrypt ssl
  #run service
}
