class g_server::firewall(
  Array $ifaces = []
){
  
  include ::g_firewall::setup
  
  $ifaces.each | $iface | {
  	g_firewall { "200 allow all external output for ${iface}":
  	  outiface => $iface,
      chain  => 'OUTPUT',
      proto  => 'all',
      action => 'accept',
    }
  }
  
  g_firewall { "201 allow all loopback output":
    outiface => 'lo',
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }

}
