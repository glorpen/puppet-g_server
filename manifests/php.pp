class g_server::php(
  $ensure => 'present',
  $php70version => '7.0.6'
){
  
  package_keywords { 'virtual/httpd-php':
    keywords => ['~amd64'],
    target   => 'puppet',
    slot  => '7.0',
    ensure   => $ensure,
  }->
  package_keywords { 'dev-lang/php':
    keywords => ['~amd64'],
    target   => 'puppet',
    slot  => '7.0',
    ensure   => $ensure,
  }->
  package { 'dev-lang/php':
    ensure => $php70version
  }
  
}
