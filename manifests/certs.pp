class g_server::certs{

	g_portage::package_keywords { 'dev-python/zope-component@certs':
	  atom => '=dev-python/zope-component-4.2.2',
	  ensure   => present,
	  notify => Package['letsencrypt'],
	  keywords => ['~amd64']
	}
	
	g_portage::package_keywords { 'dev-python/zope-event@certs':
    atom => "=dev-python/zope-event-4.2.0",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'dev-python/pythondialog/certs@certs':
    atom => "=dev-python/pythondialog-3.3.0-r200",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'dev-python/parsedatetime@certs':
    atom => "=dev-python/parsedatetime-2.1",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'app-crypt/acme@certs':
    atom => "=app-crypt/acme-0.14.1",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'dev-python/pyrfc3339@certs':
    atom => "=dev-python/pyrfc3339-1.0",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'dev-python/psutil@certs':
    atom => "=dev-python/psutil-4.1.0",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'dev-python/cryptography@certs':
    atom => "=dev-python/cryptography-1.3.1",
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }
  
  g_portage::package_keywords { 'app-crypt/certbot@certs':
    atom => '=app-crypt/certbot-0.14.1',
    ensure   => present,
    notify => Package['letsencrypt'],
    keywords => ['~amd64']
  }

  file{ "/var/www/letsencrypt":
    ensure => "directory",
    mode => "a=rx,u+w"
  }
  ->Nginx::Resource::Location['localhost-letsencrypt']

  class { 'letsencrypt': }
}
