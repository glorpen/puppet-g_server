class g_server::services (
  $fail2ban = false,
  $ssh = true,
  $transmission = false,
  $puppetmaster = false,
  $tor = false,
  $ntp = false,
  $cups = false,
  $samba = false,
  $rsync = false,
  $dnsmasq = false
){

  if $fail2ban {
	  #todo temporary fix - register f2b chains
	  firewallchain { 'f2b-postfix:filter:IPv4':
	     ensure => present
	  }
	  firewallchain { 'f2b-sshd:filter:IPv4':
	    ensure => present
	  }
  }
  
  if $ssh {
	  firewall { '006 Allow inbound SSH':
	    dport     => 22,
	    proto    => tcp,
	    action   => accept
	  }
  }
  
  if $transmission {
    #iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 51413 -j ACCEPT
    #iptables -A OUTPUT -p udp --sport 51413 -j ACCEPT
    #TODO check
    firewall { '010.tcp Allow Transmission daemon':
      dport    => 51413,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::external_iface
    }
    firewall { '010.udp Allow Transmission daemon':
      dport    => 51413,
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::external_iface
    }
    firewall { '011 Allow Transmission daemon web interface':
      dport     => 9091,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $puppetmaster {
    firewall { '012 Allow puppetmaster':
      dport     => 8140,
      proto    => tcp,
      action   => accept
    }
  }
  
  if $tor {
    firewall { '013 Allow internal tor':
      dport   => 9050,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $ntp {
    firewall { '014 Allow internal NTP':
      dport   => 123,
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $cups {
    firewall { '015.tcp Allow internal Cups':
      dport   => 631,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
    firewall { '015.udp Allow internal Cups':
      dport   => 631,
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $samba {
    firewall { '016 Allow internal SMBD':
      dport   => [139, 445],
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
    firewall { '017 Allow internal SMBD':
      dport   => [137, 138],
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $rsync {
    firewall { '018 Allow internal rsync':
      dport   => 873,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $dnsmasq {
    firewall { '019.tcp Allow internal dnsmasq':
      dport   => 53,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
    firewall { '019.udp Allow internal dnsmasq':
      dport   => [53, 67],
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }
  
  if $nginx {
    firewall { '020 Allow internal nginx':
      dport   => [80, 443],
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::internal_ifaces
    }
  }

}