class g_server::repos(
){
  
  include ::stdlib
  
  case $::osfamily {
    'Gentoo' : {
      include ::g_portage
    }
    'RedHat': {
	    class { 'yum': }
      class { 'g_server::repos::puppet': }
    }
  }
  
}
