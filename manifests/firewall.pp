class g_server::firewall(
){

	resources { 'firewall':
	  purge => true,
	}
	#resources { 'firewallchain':
	#  purge => true,
	#}
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

}
