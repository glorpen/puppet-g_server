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
	      extrarepo => concat(['epel', 'puppetlabs_collections'], $yum_extra_repos)
	    }
    }
  }
  
}
