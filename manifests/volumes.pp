class g_server::volumes (
  Hash $groups = {}
){
  contain ::lvm
  create_resources(g_server::volumes::group, $groups)
}
