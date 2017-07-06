class g_server (
  Array $external_ifaces = [],
  Array $internal_ifaces = [],
  
  $admin_username = undef,
  $admin_ssh_keys = [],
  $root_password = undef,
  
  Boolean $manage_ssh = true,
  Boolean $manage_sudo = true,
  Boolean $manage_fail2ban = true
) {
  
  if ! $external_ifaces {
    fail("No external iface given")
  }
  
  include ::g_server::firewall
  include ::g_server::services
  include ::g_server::repos
  
  #TODO: change switch in ssh class, include ::fail2ban::jail::sshd
  if $manage_fail2ban {
    class { 'g_server::services::fail2ban':
      sshd => $manage_ssh
    }
	}
  
  if $admin_username {
    
    $default_groups = ['wheel']
    
    if $manage_ssh {
      
      include ::g_server::services::ssh
        
      if $admin_ssh_keys {
	      $admin_ssh_keys.each | $place, $key | {
	        ssh_authorized_key { "${admin_username}@${place}":
	          user => $admin_username,
	          type => 'ssh-rsa',
	          key  => $key,
	        }
	      }
      }
      
      $groups = concat($default_groups, $::g_server::services::ssh::group)
    } else {
      $groups = $default_groups
    }
    
    user { $admin_username:
      ensure => 'present',
      home => "/home/${admin_username}",
      groups => $groups,
      managehome => true,
      purge_ssh_keys => true
    }
    
    if $manage_sudo {
	    include g_server::sudo
    }
  }
  
  if $root_password != undef {
    user { 'root':
      ensure => present,
      password => $root_password?{
        false => undef,
        default => $root_password
      }
    }
  }
  
}
