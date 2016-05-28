define g_server::wordpress::instance(
  $host = $title,
  $user = undef,
  $ensure = present,
  $additional_hosts = []
){

  validate_string($user)

  group { $user:
    ensure => $ensure
  }
  
  $app_dir = "/var/www/${host}"
  $uwsgi_name = "wordpress-${title}"
  
  user { $user:
    home => $app_dir,
    ensure => $ensure,
    shell => '/bin/false'
  }
  
  g_portage::webapp{ "wordpress-${title}":
    application => 'wordpress',
    version => $::g_server::wordpress::version,
    user => $user,
    group => $user,
    host => $host
  }~>
  g_uwsgi::vassal { $uwsgi_name:
    owner => $user,
    group => $user,
    config => @("EOT")
						app_dir = ${app_dir}
						project_dir = %(app_dir)
						
						chdir = %(project_dir)
						php-index = index.php
						php-docroot = %(project_dir)
						php-allowed-ext = .php
						
						processes = 10
						cheaper-overload = 60
						cheaper-step = 1
						cheaper = 2
						
						php-sapi-name = apache
						php-set = max_execution_time=900
      | EOT
  }
  
  nginx::resource::vhost { $host:
    index_files => ['index.php'],
    www_root => $app_dir,
    try_files => ['$uri', '$uri/', '/index.php?$args'],
    server_name => concat($host, $additional_hosts)
  }

		nginx::resource::location { "${host}-uwsgi":
    vhost => $host,
    location => '~ \.php$',
		  uwsgi => "unix:///var/uwsgi/${uwsgi_name}",
		  location_cfg_append => {
		    'uwsgi_modifier1' => 14
		  }
	 }
	 
	 nginx::resource::location { "${host}-uploads":
	   vhost => $host,
	   location => '~* ^/wp-content/uploads/.*\.(php|phps)$',
    internal => true
	 }
	 
	 nginx::resource::location { "${host}-config":
	   vhost => $host,
	   location => '/wp-config.php',
	   location_cfg_append => {'deny'=>'all'}
	 }
	 
}
