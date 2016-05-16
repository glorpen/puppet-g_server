class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $nginx = false,
  $turnserver = false,
  $makeconf = {}
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }
  
  if $nginx {
    class { 'g_server::nginx': }
  }
  
  if $turnserver {
    class { 'g_server::turnserver': }
  }
  
  if $::osfamily == 'Gentoo' {
    class { 'portage':
      layman_ensure => installed,
    }
    
    portage::makeconf { 'portdir_overlay':
		  content => '/var/lib/layman',
		  ensure  => present,
		}
		
		$makeconf.each | $key, $value | {
	    portage::makeconf { $key:
	      content => $value,
	      ensure  => present,
	    }
	  }
		
  } else {
    fail("System ${::osfamily} is not yet supported")
  }

}
