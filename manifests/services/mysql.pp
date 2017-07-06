class g_server::services::mysql(
  $port = undef,
  $root_password = undef,
  $data_dir = undef,
  G_server::Side $side = 'none',
){

  include ::stdlib
  
  validate_string($root_password)
  include ::mysql::params
  
  $_port = pick($port, $::mysql::params::default_options['mysqld']['port'])
  $_datadir = pick($data_dir, $::mysql::params::default_options['mysqld']['datadir'])
  
  if $data_dir {
    file { $data_dir:
      ensure => directory,
      owner => $::mysql::params::default_options['mysqld']['user'],
      group => $::mysql::params::default_options['mysqld']['user'],
      notify => Class['mysql::server::service'],
      require => Package['mysql-server']
    }
    
    if $::facts['selinux'] {
      selinux::fcontext { 'g-mysql-data-dir':
			  context => 'mysqld_db_t',
        pathname => "${data_dir}(/.*)?",
        restorecond_path => $data_dir,
        require => File[$data_dir],
        restorecond_recurse => true
			}
    }
  }

	class { '::mysql::server':
    root_password => $root_password,
	  remove_default_accounts => true,
	  manage_config_file => true,
	  override_options => {
	   'client'=> {
	     'port' => $_port,
	   },
	   'mysqld' => {
	     'port' => $_port,
	     'datadir' => $_datadir
	   }
	  },
	  restart => true
	}->
  class {'::mysql::client':
    package_manage => false
  }

  g_server::get_interfaces($side).each | $iface | {
    g_firewall { "010 Allow mysql from ${iface}":
      dport     => $_port,
      proto    => tcp,
      action   => accept,
      iniface => $iface,
    }->Class['Mysql::Server']
  }
	
	if $::osfamily == 'Gentoo' {
    g_portage::package_use { 'g_mysql':
      atom => 'dev-db/mariadb',
      use => ['-pam', '-perl']
    }->Class['mysql::server']
  }

}
