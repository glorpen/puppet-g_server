class g_server::nginx(
  $ports = [80],
  $letsencrypt = false,
){
  
  include ::stdlib
  include ::g_server
  
  validate_bool($letsencrypt)
  validate_bool($external)
  
  
  class { ::nginx:
    manage_repo => false
  }
  
  case $::osfamily {
    'RedHat': {
      include ::yum::repo::nginx
      
      Class['yum::repo::nginx']
      ~>Class['nginx']
    }
    'Gentoo': {}
    default: {
      fail("OS not supported")
    }
  }
  
  if $external {
	  g_firewall { "020 Allow external nginx":
	    dport   => $ports,
	    proto    => tcp,
	    action   => accept,
	    iniface  => $::g_server::external_iface
	  }
  }
  
  $::g_server::internal_ifaces.each |$iface| {
    g_firewall { "020.${iface} Allow internal nginx":
      dport   => $ports,
      proto    => tcp,
      action   => accept,
      iniface  => $iface
    }
  }
  
  nginx::resource::vhost { 'localhost':
    ensure => present,
    listen_options => 'default_server',
    ssl => false,
    www_root => '/var/www/localhost',
  }
  
  if $letsencrypt {
	  nginx::resource::location { 'localhost-letsencrypt':
	    vhost    => "localhost",
	    location => '/.well-known',
	    www_root => '/var/www/letsencrypt/$host'
    }
	  
	  class { 'g_server::certs': }
  }
  
}
