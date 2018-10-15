class g_server (
  # TODO: move to g_server::network
  Array $external_ifaces = [],
  Array $internal_ifaces = [],
  Optional[String] $hostname = $::fqdn,
  # default values for variants has to be undef since puppet 5
  # translates it as "no value" and not "value of null"
  Variant[Boolean, Hash, Undef] $manage_ssh = undef,
#  Boolean $manage_fail2ban = true,
  Variant[Boolean, Hash, Undef] $manage_network = undef,
  Boolean $manage_firewall = true,
  Boolean $manage_repos = true,
  Boolean $manage_sudo = true,
  Variant[Boolean, Hash, Undef] $manage_accounts = undef,
  Variant[Boolean, Hash, Undef] $manage_volumes = undef,
) {
  
  if ! $external_ifaces {
    fail("No external iface given")
  }
  
  if $manage_volumes == true {
    contain ::g_server::volumes
  } elsif $manage_volumes =~ Hash {
    class { 'g_server::volumes':
      * => $manage_volumes
    }
  }
  
  if $manage_repos {
    contain ::g_server::repos
  }
  
  if $manage_firewall {
    contain ::g_server::firewall
  }
  
  if $manage_ssh == true {
    contain ::g_server::services::ssh
  } elsif $manage_ssh =~ Hash {
    class { 'g_server::services::ssh':
      * => $manage_ssh
    }
  }
  
  if $manage_accounts == true {
    contain ::g_server::accounts
  } elsif $manage_accounts =~ Hash {
    class { 'g_server::accounts':
      * => $manage_accounts
    }
  }
  
  if $manage_network == true {
    contain ::g_server::network
  } elsif $manage_network =~ Hash {
    class { 'g_server::network':
      * => $manage_network
    }
  }
  
  if $manage_sudo {
    contain ::g_server::sudo
  }
  
  if $hostname {
    class { 'g_server::network::hostname':
      hostname => $hostname
    }
  }
  
  #TODO: change switch in ssh class, include ::fail2ban::jail::sshd
#  if $manage_fail2ban {
#    class { 'g_server::services::fail2ban':
#      sshd => $manage_ssh
#    }
#	}
	
	if $::facts['os']['family'] == 'Redhat' {
  	# mount tmpfs in /tmp
    service { 'tmp.mount':
      enable => true,
      ensure => running,
    }
	}
  
}
