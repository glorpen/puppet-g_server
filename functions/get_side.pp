function g_server::get_side(String $interface) >> G_server::Side {
  include ::stdlib
  include ::g_server
  
  $internal = $iface in $::g_server::internal_ifaces
  $external = $iface in $::g_server::external_ifaces
  
  if $internal and $external {
    'both'
  } elsif $internal {
    'internal'
  } elsif $external {
    'external'
  } else {
    undef
  }

}
