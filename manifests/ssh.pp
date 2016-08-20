class g_server::ssh (
  $group = 'ssh-users',
  $ports = [22],
){
  
  group { $group:
    ensure => 'present',
    system => true
  }->
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'UsePAM' => 'yes',
      'GSSAPIAuthentication' => 'no',

      'ChallengeResponseAuthentication' => 'no',
      'PasswordAuthentication' => 'no',
      'PermitRootLogin'        => 'no',
      'Port'                   => $ports,
      
      'Subsystem' => 'sftp  /usr/libexec/openssh/sftp-server',
      'AllowGroups' => [$group],
      "Match Group ${group}" => {
        'PasswordAuthentication' => 'yes',
        'AllowTcpForwarding' => 'yes',
        'X11Forwarding' => 'yes',
      },
      
      'AcceptEnv' => [
        'LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES',
        'LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT',
        'LC_IDENTIFICATION LC_ALL LANGUAGE',
        'XMODIFIERS',
      ],
    }
  }
}
