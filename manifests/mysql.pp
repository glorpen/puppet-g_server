class g_server::mysql(
  $port = '3306'
){

  firewall { '010 Allow mysql from loopback':
    dport     => $port,
    proto    => tcp,
    action   => accept,
    iniface => 'lo'
  }->
	class { '::mysql::server':
    root_password => 'asdasd',
	  remove_default_accounts => true,
	  override_options => {
	   'client'=> {
	     'port' => $port,
	   },
	   'mysqld' => {
	     'port' => $port,
	   }
	  },
	  restart => true
	}
	
	if $::osfamily == 'Gentoo' {
    g_portage::package_use { 'g_mysql':
      atom => 'dev-db/mariadb',
      use => ['-pam', '-perl']
    }->Class['mysql::server']
  }

}
