class g_server::firewall::pre {
  Firewall {
    require => undef,
  }
  
  ['iptables', 'ip6tables'].each | $provider | {
    
    # Default firewall rules
    firewall { "000.${provider} accept all icmp":
      proto  => 'icmp',
      action => 'accept',
      provider => $provider,
    }->
    firewall { "001.${provider} accept all to lo interface":
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
      provider => $provider,
    }->
    firewall { "002.${provider} reject local traffic not on loopback interface":
      iniface     => '! lo',
      proto       => 'all',
      destination => $provider?{
        'iptables' => '127.0.0.1/8',
        'ip6tables' => '::1'
      },
      action      => 'reject',
      provider => $provider,
    }->
    firewall { "003.${provider} accept related established rules":
      proto  => 'all',
      state  => ['RELATED', 'ESTABLISHED'],
      action => 'accept',
      provider => $provider,
    }->
    # for TOR but looks good for others too
    firewall { "004.${provider} drop invalid packets":
      proto => 'all',
      state => ['INVALID'],
      action => 'drop',
      provider => $provider,
    }->
    firewall { "005.${provider} drop invalid packets":
      proto => 'all',
      ctstate => ['INVALID'],
      action => 'drop',
      provider => $provider,
    }
    
  }
  
  
}
