class g_server::repos(
  $yum_extra_repos = []
){
  
  include ::stdlib
  
  case $::osfamily {
    'Gentoo' : {
      include ::g_portage
    }
    'RedHat': {
	    class { 'yum':
	      clean_repos     => true,
	      extrarepo => concat(['epel'], $yum_extra_repos)
	    }
      class { 'g_server::repos::puppet': }
    }
  }
  
}
