class g_server::volumes (
  Hash $groups = {}
){
  class { 'lvm':
    manage_pkg => true
  }
  create_resources(g_server::volumes::group, $groups)
}
