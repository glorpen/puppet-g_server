class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $nginx = false,
  $turnserver = false,
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
      eselect_ensure => installed
    }
		include g_server::portage
  } else {
    fail("System ${::osfamily} is not yet supported")
  }

}
