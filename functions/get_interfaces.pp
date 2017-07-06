function g_server::get_interfaces(Enum["internal", "external", "both"] $side) >> Array {
  include ::stdlib
  include ::g_server
  
  return $side ? {
    'internal' => $::g_server::internal_ifaces,
    'external' => $::g_server::external_ifaces,
    'both' => $all_ifaces = concat($::g_server::internal_ifaces, $::g_server::external_ifaces),
    default => []
  }
}
