class g_server::firewall(
){

	resources { 'firewall':
	  purge => false,
	}
	
	['PREROUTING','OUTPUT'].each | $v | {
		firewallchain { "${v}:raw:IPv4":
	    ensure => present,
	    purge => true,
	  }
	}
	
	['PREROUTING','OUTPUT','INPUT','POSTROUTING'].each | $v | {
		firewallchain { "${v}:nat:IPv4":
		  ensure => present,
	    purge => true,
		}
	}
	
	['FORWARD','OUTPUT','INPUT'].each | $v | {
		firewallchain { "${v}:filter:IPv4":
	    ensure => present,
	    purge => true,
	  }
	}
	
	['IPv4','IPv6'].each | $ip | {
		['PREROUTING','INPUT','FORWARD','OUTPUT','POSTROUTING'].each | $v | {
	    firewallchain { "${v}:mangle:${ip}":
	      ensure => present,
	      purge => true,
	    }
	  }
  }
	
	Firewall {
	  before  => Class['g_server::firewall::post'],
	  require => Class['g_server::firewall::pre'],
	}
  class { ['g_server::firewall::pre', 'g_server::firewall::post']: }
	class { '::firewall': }
	
	['iptables', 'ip6tables'].each | $provider | {
  	firewall { '200 allow all external output':
  	  outiface => $::g_server::external_iface,
      chain  => 'OUTPUT',
      proto  => 'all',
      action => 'accept',
      provider => $provider
    }
    
    firewall { '201 allow all loopback output':
      outiface => 'lo',
      chain  => 'OUTPUT',
      proto  => 'all',
      action => 'accept',
      provider => $provider
    }
  }

}
