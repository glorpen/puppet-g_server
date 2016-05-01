class g_server::firewall::pre {
  Firewall {
    require => undef,
  }
   # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  # for TOR but looks good for others too
  firewall { '004 drop invalid packets':
    proto => 'all',
    state => ['INVALID'],
    action => 'drop'
  }->
  firewall { '005 drop invalid packets':
    proto => 'all',
    ctstate => ['INVALID'],
    action => 'drop'
  }
  
}
