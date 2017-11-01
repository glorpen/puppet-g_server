class g_server::sudo(
){
  class { 'sudo': }
  
  sudo::conf { 'g_server-defaults':
    priority => 0,
    content => 'Defaults rootpw'
  }
}
