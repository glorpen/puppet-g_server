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
    enable_fqdn_entry => false,
    hosts => $additional_hosts
  }
  
  create_resources(g_server::network::iface, $interfaces)
}
