define g_server::network::iface(
  $ipv4addr = undef,
  $ipv4netmask = undef,
  $ipv4gw = undef,
  $ipv4dhcp = true,
  
  $ipv6addr = undef,
  $ipv6gw = undef,
  
  String $scope = 'internal', # tag of internal network - eg. vlan_1, vlan_2, ...
  Optional[String] $macvlan_parent = undef,
  Optional[String] $mac_addr = undef
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
  
  if $macvlan_parent {
    if ! $::g_server::network::enable_macvlan {
      fail('You have to enable g_server::network::enable_macvlan to manage macvlan interfaces')
    }
    
    $_device_opts = {
      'nm_controlled' => 'no',
      'nozeroconf' => 'yes',
      'type' => 'macvlan',
      'devicetype' => 'macvlan',
    }
    $_desc_macvlan = "\nMACVLAN_PARENT=${macvlan_parent}\nMACVLAN_MODE=bridge"
  } else {
    $_desc_macvlan = ""
    $_device_opts = {}
  }
  
  if $mac_addr != undef {
    $_desc_mac = "\nMACADDR=\"${mac_addr}\""
  } else {
    $_desc_mac = ''
  }
  
  network::interface { $name:
    ipaddress => $ipv4addr,
    netmask => $ipv4netmask,
    gateway => $ipv4gw,
    ipv6init => $ipv6addr?{undef=>'no', default=>'yes'},
    ipv6_autoconf => false,
    ipv6addr => $ipv6addr,
    ipv6_defaultgw => $ipv6gw,
    bootproto => $ipv4addr?{
      undef => '',
      default => 'static'
    },
    enable_dhcp => $ipv4addr?{
      undef => $ipv4dhcp,
      default => false
    },
    description => " \n${_desc_mac}${_desc_macvlan}",
    * => $_device_opts
  }
  
  if $side == 'internal' {
    Hosts::Host <<| tag == $scope |>>
  } else {
    Hosts::Host <<| tag == 'public' |>>
  }
  
}
