class g_server::network(
  String $export_tld = 'internal',
  Array $additional_hosts = [],
){
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    enable_fqdn_entry => false,
    hosts => $additional_hosts
  }
}
