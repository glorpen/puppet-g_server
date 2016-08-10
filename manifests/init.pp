class g_server (
  $external_iface = undef,
  $internal_ifaces = [],
  $nginx = false,
  $turnserver = false,
  $mysql = false,
) {
  
  if ! $external_iface {
    fail("No external iface given")
  }
  
  class { 'g_server::firewall': }
  include ::g_server::services
  
  if $nginx {
    class { 'g_server::nginx': }
  }
  
  if $turnserver {
    class { 'g_server::turnserver': }
  }
  
  if $mysql {
    include ::g_server::mysql
  }
  
  class { 'fail2ban':
	  log_level => 'INFO',
    log_target => 'SYSLOG'
	}

	class { 'fail2ban::jail::sshd': }
  
  include ::g_server::repos
}
