class g_server::network(
  String $export_tld = 'internal',
  Hash $additional_hosts = {},
){
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    enable_fqdn_entry => false,
  }
  
  $additional_hosts.each | $name, $conf | {
    hosts::host { "${::fqdn}-${conf['ip']}-${name}":
      name => $name,
      * => $conf
    }
  }
}
