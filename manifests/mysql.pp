class g_server::mysql(
  $port = undef,
  $root_password = undef,
  $datadir = undef
){

  include ::stdlib
  
  validate_string($root_password)
  include ::mysql::params
  
  $_port = pick($port, $::mysql::params::default_options['mysqld']['port'])
  $_datadir = pick($datadir, $::mysql::params::default_options['mysqld']['datadir'])
  
  if $datadir {
    file { $datadir:
      ensure => directory,
      owner => $::mysql::params::default_options['mysqld']['user'],
      group => $::mysql::params::default_options['mysqld']['user'],
      notify => Class['mysql::server::service'],
      require => Package['mysql-server']
    }
    
    if $::facts['selinux'] {
      selinux::fcontext { 'g-mysql-data-dir':
			  context => 'mysqld_db_t',
        pathname => "${datadir}(/.*)?",
        restorecond_path => $datadir,
        require => File[$datadir],
        restorecond_recurse => true
			}
    }
  }

  firewall { '010 Allow mysql from loopback':
    dport     => $_port,
    proto    => tcp,
    action   => accept,
    iniface => 'lo'
  }->
	class { '::mysql::server':
    root_password => $root_password,
	  remove_default_accounts => true,
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
	
	if $::osfamily == 'Gentoo' {
    g_portage::package_use { 'g_mysql':
      atom => 'dev-db/mariadb',
      use => ['-pam', '-perl']
    }->Class['mysql::server']
  }

}
