class g_server::mysql(
  $port = '3306',
  $internal = true
){
  
  firewall { 'Allow mysql from loopback':
    dport     => $port,
    proto    => tcp,
    action   => accept
    iniface => 'lo'
  }->
	class { '::mysql::server':
    create_root_user => false,
	  remove_default_accounts => true,
	  override_options => {
	   'client'=> {
	     'port' => $port,
	   },
	   'mysqld' => {
	     'port' => $port,
	   }
	  }
	}
	
	if $::osfamily == 'Gentoo' {
    g_portage::package_use { 'dev-db/mariadb/g_mysql':
      atom => 'dev-db/mariadb',
      use => ['-pam', '-perl']
    }->Class['mysql::server']
  }

}
