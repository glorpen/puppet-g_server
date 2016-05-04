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
  $dnsmasq = false,
  $nginx = false,
  $avahi = false
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
  
  if $puppetmaster {
    firewall { '012 Allow puppetmaster':
      dport     => 8140,
      proto    => tcp,
      action   => accept
    }
  }
  
  if $nginx {
    firewall { "020.${iface} Allow external nginx":
      dport   => [80, 443],
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::external_iface
    }
  }
  
  if $transmission {
    #iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 51413 -j ACCEPT
    #iptables -A OUTPUT -p udp --sport 51413 -j ACCEPT
    #TODO check
    firewall { '010.udp Allow Transmission daemon':
      dport    => 51413,
      proto    => udp,
      action   => accept,
      iniface  => $::g_server::external_iface
    }
    firewall { "010.tcp Allow Transmission daemon":
      dport    => 51413,
      proto    => tcp,
      action   => accept,
      iniface  => $::g_server::external_iface
    }
    
    $::g_server::internal_ifaces.each |$iface| {
	    firewall { "011.${iface} Allow Transmission daemon web interface":
	      dport     => 9091,
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
    }
  }
  
  $::g_server::internal_ifaces.each |$iface| {
	  
	  if $tor {
	    firewall { "013.${iface} Allow internal tor":
	      dport   => 9050,
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $ntp {
	    firewall { "014.${iface} Allow internal NTP":
	      dport   => 123,
	      proto    => udp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $cups {
	    firewall { "015.tcp.${iface} Allow internal Cups":
	      dport   => 631,
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	    firewall { "015.udp.${iface} Allow internal Cups":
	      dport   => 631,
	      proto    => udp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $samba {
	    firewall { "016.${iface} Allow internal SMBD":
	      dport   => [139, 445],
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	    firewall { "017.${iface} Allow internal SMBD":
	      dport   => [137, 138],
	      proto    => udp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $rsync {
	    firewall { "018.${iface} Allow internal rsync":
	      dport   => 873,
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $dnsmasq {
	    firewall { "019.tcp.${iface} Allow internal dnsmasq":
	      dport   => 53,
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	    firewall { "019.udp.${iface} Allow internal dnsmasq":
	      dport   => [53, 67],
	      proto    => udp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  
	  if $nginx {
	    firewall { "020.${iface} Allow internal nginx":
	      dport   => [80, 443],
	      proto    => tcp,
	      action   => accept,
	      iniface  => $iface
	    }
	  }
	  if $avahi {
      firewall { "021.${iface} Allow internal avahi":
        dport   => 5353,
        proto    => udp,
        action   => accept,
        iniface  => $iface
      }
    }
  }

}