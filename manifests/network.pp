class g_server::network(
  String $export_tld = 'internal',
  Hash $additional_hosts = {}
){
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    purge_hosts => true
  }
  
  $additional_hosts.each | $name, $conf | {
    host { "${::fqdn}-${name}",
      name => $name,
      * => $conf
    }
  }
}
