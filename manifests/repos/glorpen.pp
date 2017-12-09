class g_server::repos::glorpen(
  $ensure = present,
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

  yumrepo { 'glorpen':
    ensure         => $ensure,
    descr          => "Glorpen Repository el ${release} - \$basearch",
    baseurl        => "https://rpm.glorpen.eu/${::operatingsystem.downcase}/${release}/\$basearch",
    enabled        => true,
    gpgcheck       => false,
    failovermethod => 'priority',
    priority       => $priority,
  }
}
