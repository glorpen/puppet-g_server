class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $nginx = false,
  $turnserver = false,
  $git = false
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
  
  if $git {
    class { 'g_server::git': }
  }

}
