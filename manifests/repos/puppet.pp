class g_server::repos::puppet(
  $ensure = present,
  $version = 5,
  $priority   = 99,
){
  $release = $::facts['os']['release']['major']
  $os_name = $::facts['os']['name']
  $repo_os_name = $os_name? {
    'Centos' => 'el',
    'Fedora' => 'fedora',
    default => fail("Unknown os name ${os_name}")
  }

  yumrepo { "puppet${version}":
    ensure         => $ensure,
    descr          => "Puppet ${version} Repository el ${release} - \$basearch",
    baseurl        => "http://yum.puppetlabs.com/puppet${version}/${repo_os_name}/${release}/\$basearch",
    enabled        => true,
    gpgcheck       => true,
    failovermethod => 'priority',
    gpgkey         => 'https://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
    priority       => $priority,
  }
}
