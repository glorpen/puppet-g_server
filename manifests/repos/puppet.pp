class g_server::repos::puppet(
  $ensure = present,
  $version = 5,
  $priority   = 99,
){
  $osver = $::operatingsystem ? {
    'XenServer' => [ '5' ],
    default     => split($::operatingsystemrelease, '[.]')
  }
  $release = $::operatingsystem ? {
    /(?i:Centos|RedHat|Scientific|CloudLinux|XenServer)/ => $osver[0],
    default                                              => '6',
  }

  yumrepo { 'puppetx':
    ensure         => $ensure,
    descr          => "Puppet ${version} Repository el ${release} - \$basearch",
    baseurl        => "http://yum.puppetlabs.com/puppet${version}/el/${release}/\$basearch",
    enabled        => true,
    gpgcheck       => true,
    failovermethod => 'priority',
    gpgkey         => 'https://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
    priority       => $priority,
  }
}
