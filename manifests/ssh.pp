class g_server::ssh (
  $group = 'ssh-users',
  $ports = [22],
){
  
  $sftp_path = $::osfamily?{
    'Gentoo' => '/usr/lib64/misc/sftp-server',
    default => '/usr/libexec/openssh/sftp-server'
  }
  
  group { $group:
    ensure => 'present',
    system => true
  }->
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'UsePAM' => 'yes',
      #'GSSAPIAuthentication' => 'no',

      'ChallengeResponseAuthentication' => 'no',
      'PasswordAuthentication' => 'no',
      'PermitRootLogin'        => 'no',
      'Port'                   => $ports,
      
      'Subsystem' => "sftp  ${sftp_path}",
      'AllowGroups' => [$group],
      'AcceptEnv' => [
        'LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES',
        'LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT',
        'LC_IDENTIFICATION LC_ALL LANGUAGE',
        'XMODIFIERS',
      ],
    }
  }
  
  ssh::server::match_block { $group:
    type => 'Group',
    options => {
      'PasswordAuthentication' => 'yes',
      'AllowTcpForwarding' => 'yes',
      'X11Forwarding' => 'yes',
    }
  }
}
