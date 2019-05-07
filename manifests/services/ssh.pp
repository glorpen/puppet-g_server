class g_server::services::ssh(
  G_server::Side $side = 'both',
  $group = 'ssh-users',
  $ports = [22],
  Hash $host_keys = {},
  Array[String] $ciphers = [
    'chacha20-poly1305@openssh.com', 'aes256-gcm@openssh.com', 'aes128-gcm@openssh.com', 'aes256-ctr', 'aes192-ctr', 'aes128-ctr'
  ],
  Array[String] $macs = [
    'hmac-sha2-512-etm@openssh.com', 'hmac-sha2-256-etm@openssh.com', 'umac-128-etm@openssh.com', 'hmac-sha2-512', 'hmac-sha2-256',
    'umac-128@openssh.com'
  ],
  Array[String] $kex_algorithms = [
    'curve25519-sha256@libssh.org', 'ecdh-sha2-nistp521', 'ecdh-sha2-nistp384', 'ecdh-sha2-nistp256', 'diffie-hellman-group-exchange-sha256'
  ],
  Array[String] $accept_env = [
    'LANG', 'LC_CTYPE', 'LC_NUMERIC', 'LC_TIME', 'LC_COLLATE', 'LC_MONETARY', 'LC_MESSAGES', 'LC_PAPER', 'LC_NAME', 'LC_ADDRESS',
    'LC_TELEPHONE', 'LC_MEASUREMENT', 'LC_IDENTIFICATION', 'LC_ALL LANGUAGE', 'XMODIFIERS'
  ]
){
  include ::g_server

  if defined(Class['g_server::firewall']) {
    g_server::get_interfaces($side).each | $iface | {
      g_firewall { "006 Allow inbound SSH from ${iface}":
        dport   => 22,
        proto   => tcp,
        action  => accept,
        iniface => $iface
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
  }
  -> class { 'ssh::server':
    # https://infosec.mozilla.org/guidelines/openssh
    storeconfigs_enabled => false,
    validate_sshd_file   => true,
    options              => {
      'UsePAM'                          => 'yes',
      'AddressFamily'                   => 'any',
      'SyslogFacility'                  => 'AUTHPRIV',
      'GSSAPIAuthentication'            => 'yes',

      'ChallengeResponseAuthentication' => 'no',
      'PasswordAuthentication'          => 'no',
      'PermitRootLogin'                 => 'no',
      'Port'                            => $ports,

      'Subsystem'                       => "sftp  ${sftp_path} -f AUTHPRIV -l INFO",
      'AllowGroups'                     => [$group],
      'AcceptEnv'                       => join($accept_env, ' '),
      'Ciphers'                         => join($ciphers, ','),
      'MACs'                            => join($macs, ','),
      'KexAlgorithms'                   => join($kex_algorithms, ','),
      'X11Forwarding'                   => 'no',
      'LogLevel'                        => 'VERBOSE',
      'UsePrivilegeSeparation'          => 'sandbox'
    }
  }

  ssh::server::match_block { "Group ${group}":
    type    => '',
    options => {
      'PasswordAuthentication' => 'yes',
      'AllowTcpForwarding'     => 'yes',
      'X11Forwarding'          => 'yes',
    }
  }

  $host_keys.each | $k, $v | {
    ssh::server::host_key {"ssh_host_${k}_key":
      * => $v
    }
  }
}
