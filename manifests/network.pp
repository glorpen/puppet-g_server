class g_server::network(
  String $export_tld = 'internal',
  Hash $additional_hosts = {},
){
  class { 'network':
    ipv6enable => true,
  }
  
  class { 'hosts':
    purge_hosts => true
  }
  
  host {'ip6-localhost':
    ip => '::1',
    aliases => ['ip6-loopback']
  }
  host { 'ip6-localnet': ip => 'fe00::0'}
  host { 'ip6-mcastprefix': ip => 'ff00::0'}
  host { 'ip6-allnodes': ip => 'ff02::1'}
  host { 'ip6-allrouters': ip => 'ff02::2'}
  host { 'ip6-allhosts': ip => 'ff02::3'}
  
  $additional_hosts.each | $name, $conf | {
    host { "${::fqdn}-${name}":
      name => $name,
      * => $conf
    }
  }
}
