class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $turnserver = false,
  $mysql = false,
  $mysql_options = {},
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }
  include ::g_server::services
  
  class { 'sudo': }
  
  if $turnserver {
    class { 'g_server::turnserver': }
  }
  
  if $mysql {
    create_resources('class', {
      'g_server::mysql' => $mysql_options
    })
  }
  
  class { 'fail2ban':
	  log_level => 'INFO',
    log_target => 'SYSLOG'
	}

	class { 'fail2ban::jail::sshd': }
  
  include ::g_server::repos
  
  #$manage_repo 
}
