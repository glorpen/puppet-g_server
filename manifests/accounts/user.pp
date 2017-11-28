define g_server::accounts::user(
  String $username = $title,
  Hash $ssh_keys = {},
  Boolean $admin = false,
  Array $groups = [],
  Optional[String] $home = undef,
  Optional[String] $password_hash = undef
){
  include ::stdlib
  include ::g_server
  include ::g_server::accounts
  
  if $admin {
    $base_groups = $::g_server::accounts::admin_groups
  } else {
    $base_groups = $groups
  }
  
  if defined(Class['g_server::services::ssh']) {
    
    include ::g_server::services::ssh
      
    if $ssh_keys {
      $ssh_keys.each | $place, $key | {
        ssh_authorized_key { "${username}@${place}":
          user => $username,
          type => 'ssh-rsa',
          key  => $key,
        }
      }
    }
    
    $_groups = concat($base_groups, $::g_server::services::ssh::group)
    
#    ssh::server::match_block { "User ${username}":
#      type => '',
#      options => {
#        'PasswordAuthentication' => 'no',
#        'AllowTcpForwarding' => 'no',
#        'X11Forwarding' => 'no',
#      }
#    }
  } else {
    $_groups = $base_groups
  }
  
  user { $username:
    ensure => 'present',
    home => $home?{
      undef => "/home/${username}",
      default => $home
    },
    groups => $_groups,
    managehome => true,
    purge_ssh_keys => true,
    password => $password_hash
  }
  
  if $::g_server::manage_sudo {
    sudo::conf { "g_server-admin-${username}":
      content => "${username}  ALL=(ALL) ALL"
    }
  }
}
