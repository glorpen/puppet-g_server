define g_server::certs::domain(
  $domain = $title,
  $vhost  = "${domain}"
){
  
  contain(g_server::certs)
  
  file{ "/var/www/letsencrypt/${domain}":
    ensure => "directory",
    mode => "a=rx,u+w"
  }->
  nginx::resource::location { "${vhost}_letsencrypt":
    ensure          => present,
    ssl             => false,
    vhost           => "${vhost}",
    location => "/.well-known",
    www_root => "/var/www/letsencrypt/${domain}"
  }->
  letsencrypt::certonly { $domain:
    domains => [$domain],
    plugin  => 'webroot',
    webroot_paths => ["/var/www/letsencrypt/${domain}"]
  }->
  exec { "dhparams for letsencrypt/${domain}":
    command => "openssl dhparam -out /etc/letsencrypt/live/${domain}/dhparams.pem 2048",
    path    => [ '/usr/bin/', '/bin/' ],
    creates => "/etc/letsencrypt/live/${domain}/dhparams.pem"
  }
}
