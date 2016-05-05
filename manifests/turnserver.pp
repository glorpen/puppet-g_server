class g_server::turnserver(
  $ensure = present
){
  package { 'net-misc/turnserver':
    ensure   => $ensure ? {
       'present' => '4.5.0.3',
       default => absent
    }
  }~>
  service { "coturn":
    ensure => "running",
    enable => true
  }
  
  #todo: config
  
  ["tcp", "udp"].each | $proto | {
	  [3478, 3479].each | $port | {
		  firewall { "100.${proto}.${port} allow external turnserver":
		    dport   => $port,
		    proto  => $proto,
		    action => accept,
		    iniface => $::g_server::external_iface
		  }
		  
		  $::g_server::internal_ifaces.each | $iface | {
			  firewall { "101.${proto}.${iface}.${port} allow internal turnserver":
			    dport   => $port,
			    proto  => $proto,
			    action => accept,
			    iniface => $iface
			  }
		  }
	  }
  }
}
