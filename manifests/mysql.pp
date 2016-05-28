class g_server::mysql(
  $port = '3306',
  $root_password = undef
){

  validate_string($root_password)

  firewall { '010 Allow mysql from loopback':
    dport     => $port,
    proto    => tcp,
    action   => accept,
    iniface => 'lo'
  }->
	class { '::mysql::server':
   root_password => $root_password,
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
	}->
 class {'::mysql::client':
   package_manage => false
 }
	
	if $::osfamily == 'Gentoo' {
    g_portage::package_use { 'g_mysql':
      atom => 'dev-db/mariadb',
      use => ['-pam', '-perl']
    }->Class['mysql::server']
  }

}
