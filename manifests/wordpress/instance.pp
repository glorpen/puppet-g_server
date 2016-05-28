define g_server::wordpress::instance(
  $host = $title,
  $user = undef,
  $ensure = present
){

  validate_string($user)

  group { $user:
    ensure => $ensure
  }
  
  $app_dir = "/var/www/${host}"
  
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
  g_uwsgi::vassal { "wordpress-${title}":
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
}
