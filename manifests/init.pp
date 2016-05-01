class g_server (
  $external_iface = undef,
  $internal_ifaces = []
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }

}
