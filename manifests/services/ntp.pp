class g_server::services::ntp(
  G_server::Side $side = 'none',
  Array[String] $servers = [],
  Array[String] $pools = ['pool.ntp.org']
){
  include ::g_server

  if defined(Class['g_server::firewall']) {
    g_server::get_interfaces($side).each | $iface | {
      g_firewall { "006 Allow inbound NTP from ${iface}":
        dport   => 123,
        proto   => udp,
        action  => accept,
        iniface => $iface
      }
    }
  }

  $queryhosts = $side?{
    'none'  => [], # localhost only
    default => ['']
  }

  class { 'chrony':
    servers    => $servers,
    pools      => $pools,
    queryhosts => $queryhosts
  }
}
