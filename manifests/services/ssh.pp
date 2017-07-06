class g_server::services::ssh(
  G_server::Side $side = 'both',
){
  g_server::get_interfaces($side).each | $iface | {
    g_firewall { "006 Allow inbound SSH from ${iface}":
      dport    => 22,
      proto    => tcp,
      action   => accept,
      iniface  => $iface
    }
  }
}
