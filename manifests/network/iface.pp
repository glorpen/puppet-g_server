define g_server::network::iface(
  $ipv4addr = undef,
  $ipv4netmask = undef,
  $ipv4gw = undef,
  
  $ipv6addr = undef,
  $ipv6gw = undef,
  
  String $scope = 'internal', # tag of internal network - eg. vlan_1, vlan_2, ... 
){
  include g_server
  include g_server::network
  
  $side = g_server::get_side($name)
  
  $export_hostname = $side ? {
    'internal' => "${::g_server::network::internal_hostname}",
    default => $::trusted['certname']
  }
  
  $local_tag = $side ? {
    'internal' => $scope,
    default => 'public'
  }
  
  if $ipv6addr != undef {
    @@hosts::host { "${::trusted['certname']}.${name}.ipv6":
      aliases => $export_hostname,
      ip => regsubst($ipv6addr, "/.*", ""),
      tag => $local_tag
    }
  }
  if $ipv4addr != undef {
    @@hosts::host { "${::trusted['certname']}.${name}.ipv4":
      aliases => $export_hostname,
      ip => $ipv4addr,
      tag => $local_tag
    }
  }
  
  network::interface { $name:
    ipaddress => $ipv4addr,
    netmask => $ipv4netmask,
    gateway => $ipv4gw,
    ipv6init => $ipv6addr?{undef=>'no', default=>'yes'},
    ipv6_autoconf => false,
    ipv6addr => $ipv6addr,
    ipv6_defaultgw => $ipv6gw,
    bootproto => 'static'
  }
  
  if $side == 'internal' {
    Hosts::Host <<| tag == $scope |>>
  } else {
    Hosts::Host <<| tag == 'public' |>>
  }
  
}
