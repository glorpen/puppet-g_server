class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $certs = false
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }
  
  if $certs {
    class { 'g_server::certs': }
  }

}
