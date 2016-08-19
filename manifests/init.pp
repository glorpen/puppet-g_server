class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $turnserver = false,
  
  $admin_account = undef,
  $admin_ssh_keys = []
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }
  include ::g_server::services
  
  class { 'sudo': }
  
  if $turnserver {
    class { 'g_server::turnserver': }
  }
  
  class { 'fail2ban':
	  log_level => 'INFO',
    log_target => 'SYSLOG'
	}

	class { 'fail2ban::jail::sshd': }
  
  include ::g_server::repos
  
  #$manage_repo
  
  #
  # + sudo
  #
  if $admin_account and $admin_ssh_keys {
  
    include ::g_server::ssh
    
	  user { $admin_account:
	    ensure => 'present',
	    home => "/home/${admin_account}",
	    groups => [ $::g_server::ssh::group, 'wheel' ],
	    managehome => true,
	    purge_ssh_keys => true
	  }
	  
	  $admin_ssh_keys.each | $place, $key | {
		  ssh_authorized_key { "${admin_account}@${place}":
			  user => $admin_account,
			  type => 'ssh-rsa',
			  key  => $key,
			}
		}
	}
}
