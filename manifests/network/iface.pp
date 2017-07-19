define g_server::network::iface(
  $ipv4addr = undef,
  $ipv4netmask = undef,
  $ipv4gw = undef,
  
  $ipv6addr = undef,
  $ipv6gw = undef
  
  String $internal_tag = 'internal'
){
  include g_server
  include g_server::network
  
  $side = g_server::get_side($name)
  
  $export_hostname = $side ? {
    'internal' => "${::facts['networking']['hostname']}.${::g_server::network::export_tld}",
    default => $::facts['certname']
  }
  
  $local_tag = $side ? {
    'internal' => $internal_tag,
    default => 'public'
  }
  
  if $ipv6addr != undef {
    @@host { "${::facts['certname']}.ipv6":
      name => $export_hostname,
      ip => $ipv6addr,
      tag => $local_tag
    }
  }
  if $ipv4addr != undef {
    @@host { "${::facts['certname']}.ipv4":
      name => $export_hostname,
      ip => $ipv4addr,
      tag => $local_tag
    }
  }
  
  network::interface { $name:
    ipaddress => $ipv4addr,
    netmask => $ipv4netmask,
    gateway => $ipv4gw,
    ipv6init => $ipv6addr?{undef=>false, default=>true},
    ipv6_autoconf => false,
    ipv6addr => $ipv6addr,
    ipv6_defaultgw => $ipv6gw,
  }
  
  if $side == 'internal' {
    Hosts <<| tag == $internal_tag |>>
  } else {
    Hosts <<| tag == 'public' |>>
  }
  
}
