class g_server::nginx(
  $external = true,
  $ssl = true,
  $letsencrypt = true,
){
  
  include ::stdlib
  include ::nginx
  include ::g_server
  
  validate_bool($ssl)
  validate_bool($letsencrypt)
  validate_bool($external)
  
  $ports = $ssl?{
    true => [80, 443],
    default => [80]
  }
  
  if $external {
	  firewall { "020 Allow external nginx":
	    dport   => $ports,
	    proto    => tcp,
	    action   => accept,
	    iniface  => $::g_server::external_iface
	  }
  }
  
  $::g_server::internal_ifaces.each |$iface| {
    firewall { "020.${iface} Allow internal nginx":
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
  
  if $ssl and $letsencrypt {
	  nginx::resource::location { 'localhost-letsencrypt':
	    vhost    => "localhost",
	    location => '/.well-known',
	    www_root => '/var/www/letsencrypt/$host'
    }
	  
	  class { 'g_server::certs': }
  }
  
}
