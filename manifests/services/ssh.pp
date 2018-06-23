class g_server::services::ssh(
  G_server::Side $side = 'both',
  $group = 'ssh-users',
  $ports = [22],
){
  include ::g_server
  
  if defined(Class['g_server::firewall']) {
    g_server::get_interfaces($side).each | $iface | {
      g_firewall { "006 Allow inbound SSH from ${iface}":
        dport    => 22,
        proto    => tcp,
        action   => accept,
        iniface  => $iface
      }
    }
  }
  
  $sftp_path = $::osfamily?{
    'Gentoo' => '/usr/lib64/misc/sftp-server',
    default => '/usr/libexec/openssh/sftp-server'
  }
  
  $ssh_options = {}
  
  group { $group:
    ensure => 'present',
    system => true
  }->
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'UsePAM' => 'yes',
      'AddressFamily' => 'any',
      'SyslogFacility' => 'AUTHPRIV',
      'GSSAPIAuthentication' => 'yes',

      'ChallengeResponseAuthentication' => 'no',
      'PasswordAuthentication' => 'no',
      'PermitRootLogin'        => 'without-password',
      'Port'                   => $ports,
      
      'Subsystem' => "sftp  ${sftp_path}",
      'AllowGroups' => [$group],
      'AcceptEnv' => [
        'LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES',
        'LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT',
        'LC_IDENTIFICATION LC_ALL LANGUAGE',
        'XMODIFIERS',
      ],
      'Ciphers' => 'aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr',
      'MACs' => 'hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160',
      'KexAlgorithms' => 'diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1',
      'X11Forwarding' => 'no',
    }
  }
  
  ssh::server::match_block { "Group ${group}":
    type => '',
    options => {
      'PasswordAuthentication' => 'yes',
      'AllowTcpForwarding' => 'yes',
      'X11Forwarding' => 'yes',
    }
  }
  
}