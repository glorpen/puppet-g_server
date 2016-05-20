class g_server::wordpress(
){

  $pkg_name = 'www-apps/wordpress'

  g_php::extension { 'mysql:7.0': }~>
  g_php::extension { 'pdo:7.0': }~>
  Package[$pkg_name]
  
  if $::osfamily == 'Gentoo' {
    g_portage::package_keywords { 'www-apps/wordpress/wordpress':
      atom => 'www-apps/wordpress',
      keywords => ['~amd64']
    }~>
    g_portage::package_use { 'www-apps/wordpress/wordpress':
      atom => 'www-apps/wordpress',
      use => ['vhosts']
    }~>
    Package[$pkg_name]
  }
  
  package { $pkg_name:
    ensure => 'latest'
  }
}
