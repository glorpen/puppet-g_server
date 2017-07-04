class g_server::repos::puppet(
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

  yum::managed_yumrepo { 'puppetx':
    descr          => "Puppet ${version} Repository el ${release} - \$basearch",
    baseurl        => "http://yum.puppetlabs.com/puppet${version}/el/${release}/\$basearch",
    enabled        => 1,
    gpgcheck       => 1,
    failovermethod => 'priority',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetX',
    gpgkey_source  => "puppet:///modules/g_server/rpm-gpg/RPM-GPG-KEY-puppet${version}",
    priority       => $priority,
  }
}
