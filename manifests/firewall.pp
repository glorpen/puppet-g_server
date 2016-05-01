class g_server::firewall(
){

	resources { 'firewall':
	  purge => true,
	}
	resources { 'firewallchain':
	  purge => true,
	}
	
	Firewall {
	  before  => Class['my_fw::post'],
	  require => Class['my_fw::pre'],
	}
	
	class { 'firewall': }
	
	
	#allow ssh
	firewall { '006 Allow inbound SSH':
	  dport     => 22,
	  proto    => tcp,
	  action   => accept
	}

}
