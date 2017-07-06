class g_server::services::fail2ban(
  Boolean $sshd = false
){
  class { '::fail2ban':
    log_level => 'INFO',
    log_target => 'SYSLOG',
    manage_firewall => true
  }
  
  if ($sshd) {
    include ::fail2ban::jail::sshd
  }
}
