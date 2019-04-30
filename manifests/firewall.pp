class g_server::firewall {

  include ::g_firewall::setup

  $ifaces = g_server::get_interfaces('both')

  $ifaces.each | $iface | {
    g_firewall { "200 allow all external output for ${iface}":
      outiface => $iface,
      chain    => 'OUTPUT',
      proto    => 'all',
      action   => 'accept',
    }
  }

  g_firewall { '201 allow all loopback output':
    outiface => 'lo',
    chain    => 'OUTPUT',
    proto    => 'all',
    action   => 'accept',
  }

}
