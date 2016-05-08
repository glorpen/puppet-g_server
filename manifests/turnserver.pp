class g_server::turnserver(
  $ensure = present,
  $listening_port = 3478,
  $alt_listening_port = 3479,
  $tls_listening_port = 5349,
  $alt_tls_listening_port = 5350,
  $fingerprint = true,
  $long_time_cred = true,
  $users = {},
  $realm = undef,
  $cert = undef,
  $pkey = undef,
  $server_name = undef,
  $min_port = undef,
  $max_port = undef
){

  validate_hash($users)
  validate_bool($fingerprint)
  validate_bool($long_time_cred)
  validate_string($realm)
  
  if $server_name {
    validate_string($server_name)
  }
  
  $tls_enabled = $cert and $pkey
  
  validate_integer($listening_port)
  validate_integer($alt_listening_port)
  
  if $tls_enabled {
	  validate_integer($tls_listening_port)
	  validate_integer($alt_tls_listening_port)
	  validate_integer($cert)
	  validate_integer($pkey)
  }

	package_use { 'net-misc/coturn':
	  use     => ['-*'],
	  target  => 'puppet-flags',
	  ensure  => present,
	}~>
  package { 'net-misc/coturn':
    ensure   => $ensure ? {
       'present' => '4.5.0.3',
       default => absent
    }
  }~>
  service { "coturn":
    ensure => $ensure ? {
      'present' => "running",
      default => 'absent'
    },
    enable => true
  }
  
  $listening_ips = concat($::g_server::internal_ifaces, $::g_server::external_iface).map | $iface | {
    $facts['networking']['interfaces'][$iface]["ip"]
  }
  
  $ports = concat([$listening_port, $alt_listening_port], $tls_enabled ? {
    true => [$tls_listening_port, $alt_tls_listening_port],
    default => []
  })
  
  file { '/etc/turnserver.conf':
    content => template('g_server/turnserver/turnserver.conf.erb')
  }~>
  Service['coturn']
  
  ["tcp", "udp"].each | $proto | {
	  $ports.each | $port | {
		  firewall { "100.${proto}.${port} allow external turnserver":
		    dport   => $port,
		    proto  => $proto,
		    action => accept,
		    iniface => $::g_server::external_iface
		  }
		  
		  $::g_server::internal_ifaces.each | $iface | {
			  firewall { "101.${proto}.${iface}.${port} allow internal turnserver":
			    dport   => $port,
			    proto  => $proto,
			    action => accept,
			    iniface => $iface
			  }
		  }
	  }
  }
  
  
  
}
