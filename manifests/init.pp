class g_server (
  Array $external_ifaces = [],
  Array $internal_ifaces = [],
  Optional[String] $hostname = $::fqdn
#  
#  Boolean $manage_ssh = true,
#  Boolean $manage_sudo = true,
#  Boolean $manage_fail2ban = true,
#  Boolean $manage_network = true,
) {
  
  if ! $external_ifaces {
    fail("No external iface given")
  }
  
  include ::g_server::firewall
  include ::g_server::repos
  
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
	
	# mount tmpfs in /tmp
  service { 'tmp.mount':
    enable => true,
    ensure => running,
  }
  
  
}
