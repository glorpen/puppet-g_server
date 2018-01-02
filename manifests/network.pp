class g_server::network(
  String $internal_tld = 'internal',
  Array $additional_hosts = [],
  Hash $interfaces = {},
){
  
  $internal_hostname = "${::facts['networking']['hostname']}.${internal_tld}"
  
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    hosts => $additional_hosts
  }
  
  create_resources(g_server::network::iface, $interfaces)
  
  if $::osfamily == 'RedHat' {
    ['ifdown-macvlan', 'ifup-macvlan'].each | $f | {
      file { "/etc/sysconfig/network-scripts/${f}":
        ensure => present,
        mode => 'a+rx,u+w',
        source => "puppet:///modules/g_server/network-scripts/${f}"
      }
    }
  }
}
