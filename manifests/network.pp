# @summary Setups network interfaces and hosts.
#
# @param internal_tld
#   Domain used for hostname on internal interfaces
# @param additional_hosts
#   Additional hosts passed to ::hosts
# @param interfaces
#   Sets interfaces using g_server::network::iface
# @param enable_macvlan
#   Enables or disables installing scripts for macvlan interfaces support               
#
class g_server::network(
  String $internal_tld = 'internal',
  Array $additional_hosts = [],
  Hash[String, Optional[Hash]] $interfaces = {},
  Boolean $enable_macvlan = false,
  Boolean $collect_public_hosts = true
){

  $_short_hostname = regsubst($::g_server::hostname, '\..*', '')
  $internal_hostname = "${_short_hostname}.${internal_tld}"
  $tag_prefix = 'g_server.network.scope.'
  $iface_public_scope = "${tag_prefix}.public"

  case $::osfamily {
    'Gentoo': {
      class { '::g_server::network::gentoo::network': }
    }
    default: {
      class { 'network':
        ipv6enable => true
      }
    }
  }

  class { 'hosts':
    hosts => $additional_hosts
  }

  $_interfaces = Hash($interfaces.map | $k, $v | {
    [
      $k,
      $v?{
        undef => {},
        default => $v
      }
    ]
  })

  create_resources(g_server::network::iface, $_interfaces)

  $macvlan_ensure = $enable_macvlan?{
    true    => present,
    default => absent
  }
  if $::osfamily == 'RedHat' {
    ['ifdown-macvlan', 'ifup-macvlan'].each | $f | {
      file { "/etc/sysconfig/network-scripts/${f}":
        ensure => $macvlan_ensure,
        mode   => 'a+rx,u+w',
        source => "puppet:///modules/g_server/network-scripts/${f}"
      }
    }
  }

  if $collect_public_hosts {
    Hosts::Host <<| tag == $iface_public_scope |>>
  }
}
