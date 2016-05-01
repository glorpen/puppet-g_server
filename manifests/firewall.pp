class g_server::firewall(
){

	resources { 'firewall':
	  purge => true,
	}
	resources { 'firewallchain':
	  purge => true,
	}
	Firewall {
	  before  => Class['g_server::firewall::post'],
	  require => Class['g_server::firewall::pre'],
	}
  class { ['g_server::firewall::pre', 'g_server::firewall::post']: }
	class { 'firewall': }
	
	
	#allow ssh
	firewall { '006 Allow inbound SSH':
	  dport     => 22,
	  proto    => tcp,
	  action   => accept
	}
	
	#todo temporary fix - register f2b chains
	firewallchain { 'f2b-postfix:filter:IPv4':
	   ensure => present
  }
  firewallchain { 'f2b-sshd:filter:IPv4':
    ensure => present
  }

}
