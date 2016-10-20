class g_server::sudo(
  $admin_username = undef
){
  class { 'sudo': }
  
  sudo::conf { 'g_server-defaults':
    priority => 0,
    content => 'Defaults rootpw'
  }
  
  if $admin_username {
    sudo::conf { 'g_server-admin':
      content => "${admin_username}  ALL=(ALL) ALL"
    }
  }
}