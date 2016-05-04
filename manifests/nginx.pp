class g_server::nginx(
  $letsencrypt = true,
  $external = true
){
  
  if $external {
	  firewall { "020 Allow external nginx":
	    dport   => [80, 443],
	    proto    => tcp,
	    action   => accept,
	    iniface  => $::g_server::external_iface
	  }
  }
  
  $::g_server::internal_ifaces.each |$iface| {
    firewall { "020.${iface} Allow internal nginx":
      dport   => [80, 443],
      proto    => tcp,
      action   => accept,
      iniface  => $iface
    }
  }
  
  if $letsencrypt {
	  nginx::resource::vhost { 'localhost':
	    ensure => present,
	    listen_options => 'default_server',
	    ssl => false,
	    www_root => '/var/www/localhost',
	    try_files => ['$uri', '/var/www/letsencrypt/$host/$uri']
	  }
	  
	  class { 'g_server::certs': }
  }
  
}
