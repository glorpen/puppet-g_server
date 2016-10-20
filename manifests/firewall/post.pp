class g_server::firewall::post {
  ['iptables', 'ip6tables'].each | $provider | {
    firewall { '999 drop all':
      proto  => 'all',
      action => 'drop',
      before => undef,
      provider => $provider
    }
  }
}
