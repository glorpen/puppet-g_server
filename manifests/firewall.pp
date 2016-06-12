class g_server::firewall(
){

	resources { 'firewall':
	  purge => false,
	}
	
	firewallchain { 'INPUT:filter:IPv4':
     ensure => present,
     purge => true,
     ignore => [
      ' -j f2b-'
     ]
  }
	
	Firewall {
	  before  => Class['g_server::firewall::post'],
	  require => Class['g_server::firewall::pre'],
	}
  class { ['g_server::firewall::pre', 'g_server::firewall::post']: }
	class { '::firewall': }
	
	firewall { '200 allow all external output':
	  outiface => $::g_server::external_iface,
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }
  
  firewall { '201 allow all loopback output':
    outiface => 'lo',
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }

}
