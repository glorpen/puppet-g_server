define g_server::network::tuntap(
  Enum['present', 'absent'] $ensure = 'present',
  $ipv4addr = undef,
  $ipv4netmask = undef,
  $ipv6addr = undef,
  $ipv6gw = undef
) {
  $ipv6init = $ipv6addr?{undef=>'no', default=>'yes'}

  ::network::interface { $name:
      ensure         => $ensure,
      type           => 'Tap',
      ipaddress      => $ipv4addr,
      netmask        => $ipv4netmask,
      ipv6init       => $ipv6init,
      ipv6_autoconf  => false,
      ipv6addr       => $ipv6addr,
      ipv6_defaultgw => $ipv6gw,
  }
}
