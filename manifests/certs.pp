class g_server::certs(
){

	package_keywords { 'dev-python/zope-component':
	  version => "=4.2.2",
	  ensure   => present,
	  target => 'puppet-certs',
	  keywords => ['~amd64']
	}
	
	package_keywords { 'dev-python/zope-event':
    version => "=4.2.0",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'dev-python/pythondialog':
    version => "=3.3.0-r200",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'dev-python/parsedatetime':
    version => "=2.1",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'dev-python/configargparse':
    version => "=0.10.0",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'app-crypt/acme':
    version => "=0.5.0",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'dev-python/pyrfc3339':
    version => "=1.0",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'dev-python/psutil':
    version => "=4.1.0",
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }
  
  package_keywords { 'app-crypt/letsencrypt':
    ensure   => present,
    target => 'puppet-certs',
    keywords => ['~amd64']
  }

  ensure_packages(['app-crypt/letsencrypt'])

  Package_keywords<| target == 'puppet-certs' |>
  ->Package['app-crypt/letsencrypt']
  
  file{ "/var/www/letsencrypt":
    ensure => "directory",
    mode => "a=rx,u+w"
  }

	class { 'letsencrypt': }
}
