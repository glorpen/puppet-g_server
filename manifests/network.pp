class g_server::network(
  String $export_tld = 'internal',
){
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    purge_hosts => true
  }
}
