define g_server::network::iface(
  $ipv4addr = undef,
  $ipv4netmask = undef,
  $ipv4gw = undef,
  $ipv4dhcp = true,

  $ipv6addr = undef,
  $ipv6gw = undef,

  String $scope = 'internal', # tag of internal network - eg. vlan_1, vlan_2, ...
  Optional[String] $macvlan_parent = undef,
  Optional[String] $mac_addr = undef,
  Boolean $dns = true,
  Array[Struct[{
    ipaddress => Stdlib::IP::Address::Nosubnet,
    cidr => Variant[Integer, Stdlib::IP::Address::Nosubnet],
    gateway => Optional[Stdlib::IP::Address::Nosubnet],
    metric => Optional[Integer],
    scope => Optional[String],
    source => Optional[Stdlib::IP::Address::Nosubnet],
    table => Optional[String]
  }]] $routes = [],
  Array[String, 0, 2] $nameservers = []
){
  include g_server
  include g_server::network

  $side = g_server::get_side($name)

  $export_hostname = $side ? {
    'internal' => $::g_server::network::internal_hostname,
    default => $::trusted['certname']
  }

  $local_tag = $side ? {
    'internal' => $scope,
    default => 'public'
  }

  if $ipv6addr != undef {
    @@hosts::host { "${::trusted['certname']}.${name}.ipv6":
      aliases => $export_hostname,
      ip      => regsubst($ipv6addr, '/.*', ''),
      tag     => $local_tag
    }
  }
  if $ipv4addr != undef {
    @@hosts::host { "${::trusted['certname']}.${name}.ipv4":
      aliases => $export_hostname,
      ip      => $ipv4addr,
      tag     => $local_tag
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
    $_desc_macvlan = ''
    $_device_opts = {}
  }

  if ! $macvlan_parent and $name.match(/.*\..*/) {
    $_vlan_opts = {
      'vlan' => 'yes'
    }
  } else {
    $_vlan_opts = {}
  }

  if $mac_addr != undef {
    $_desc_mac = "\nMACADDR=\"${mac_addr}\""
  } else {
    $_desc_mac = ''
  }

  $_dns_options = {
    peerdns => ($dns and $ipv4dhcp and $ipv4addr == undef)?{
      true => 'yes',
      default => 'no'
    },
    #debian
    'dns_nameservers' => $nameservers?{
      undef => undef,
      default => $nameservers.join(' ')
    },
    #redhat
    'dns1' => $nameservers[0],
    'dns2' => $nameservers[1]
  }

  case $::facts['os']['family'] {
    'Gentoo': {
      $config = $ipv4addr?{
        undef   => $ipv4dhcp?{
          true    => 'dhcp',
          default => '0.0.0.0/0'
        },
        default => "${$ipv4addr} netmask ${ipv4netmask}"
      }
      ::g_server::network::gentoo::iface { $name:
        config => $config,
      }
    }
    default: {
      $ipv6init = $ipv6addr?{undef=>'no', default=>'yes'}
      $bootproto = $ipv4addr?{
        undef   => '',
        default => 'static'
      }
      $enable_dhcp = $ipv4addr?{
        undef   => $ipv4dhcp,
        default => false
      }
      ::network::interface { $name:
        ipaddress      => $ipv4addr,
        netmask        => $ipv4netmask,
        gateway        => $ipv4gw,
        ipv6init       => $ipv6init,
        ipv6_autoconf  => false,
        ipv6addr       => $ipv6addr,
        ipv6_defaultgw => $ipv6gw,
        bootproto      => $bootproto,
        enable_dhcp    => $enable_dhcp,
        description    => " \n${_desc_mac}${_desc_macvlan}",
        *              => merge($_device_opts, $_vlan_opts, $_dns_options)
      }
    }
  }

  if $side == 'internal' {
    Hosts::Host <<| tag == $scope |>>
  } else {
    Hosts::Host <<| tag == 'public' |>>
  }

  if (! $routes.empty()) {

    $routes_auto = $routes.reduce({
      'family' => [],
      'cidr' => [],
      'netmask' => []
    }) | $memo, $value | {
      $_family = $value['ipaddress'] ? {
        Stdlib::IP::Address::V4::Nosubnet => 'inet4',
        default => 'inet6',
      }
      if ($value['cidr'] =~ Integer) {
        $_cidr = $value['cidr']
        #TODO convert cidr to netmask
        $_netmask = undef
      } else {
        $_cidr = undef
        $_netmask = $value['cidr']
        # netmask to cidr will be calculated in network::route
      }

      Hash({
        'family' => $memo['family'] + [$_family],
        'cidr' => $memo['cidr'] + [$_cidr],
        'netmask' => $memo['netmask'] + [$_netmask]
      })
    }

    $routes_normalized = $routes.reduce({
      'ipaddress' => [],
      'gateway' => [],
      'metric' => [],
      'scope' => [],
      'source' => [],
      'table' => []
    }) | $memo, $value | {
      Hash($memo.map | $k, $v | {
        if $value[$k] == undef {
          $normalized = false
        } else {
          $normalized = $value[$k]
        }
        [$k, $v + [$normalized]]
      })
    }

    ::network::route { $name:
      * => merge($routes_normalized, $routes_auto)
    }
  }
}
