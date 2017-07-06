class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $turnserver = false,
  
  $admin_username = undef,
  $admin_ssh_keys = [],
  $root_password = undef,
  
  $manage_ssh = true,
  $manage_sudo = true,
  $manage_fail2ban = true
) {
  
  include ::stdlib
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall':
    ifaces => merge($internal_ifaces, $external_iface)
  }
  include ::g_server::services
  
  include ::g_server::repos
  
  
  if $turnserver {
    class { 'g_server::turnserver': }
  }
  
  
  if $manage_fail2ban {
	  
	  class { 'fail2ban':
		  log_level => 'INFO',
	    log_target => 'SYSLOG'
		}
	
		class { 'fail2ban::jail::sshd': }
		
	}
  
  if $admin_username {
    
    $default_groups = ['wheel']
    
    if $manage_ssh {
      
      class { 'g_server::ssh': }
      
      if $admin_ssh_keys {
	      $admin_ssh_keys.each | $place, $key | {
	        ssh_authorized_key { "${admin_username}@${place}":
	          user => $admin_username,
	          type => 'ssh-rsa',
	          key  => $key,
	        }
	      }
      }
      
      $groups = concat($default_groups, $::g_server::ssh::group)
    }
    
    user { $admin_username:
      ensure => 'present',
      home => "/home/${admin_username}",
      groups => $groups,
      managehome => true,
      purge_ssh_keys => true
    }
    
    if $manage_sudo {
	    class { 'g_server::sudo':
	      admin_username => $admin_username
	    }
    }
  }
  
  if $root_password {
    user { 'root':
      ensure => present,
      password => $root_password
    }
  }
  
}
