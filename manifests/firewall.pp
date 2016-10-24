class g_server::firewall(
){
  
  include ::g_firewall::setup
  
	g_firewall { "200 allow all external output":
	  outiface => $::g_server::external_iface,
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }
  
  g_firewall { "201 allow all loopback output":
    outiface => 'lo',
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }

}
