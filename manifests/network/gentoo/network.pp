class g_server::network::gentoo::network(

){
  $conf_path = '/etc/conf.d/net'

  concat { $conf_path:
    ensure => present
  }
}