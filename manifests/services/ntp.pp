class g_server::services::ntp(
  G_server::Side $side = 'none',
  Array[String] $servers = ['pool.ntp.org']
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

  $_restrict = $side?{
    'none' => [ # localhost only
      'default kod notrap nomodify nopeer noquery limited',
      '127.0.0.1',
      '[::1]',
      'source notrap nomodify noquery',
    ],
    default => fail("NTP server on ${side} side is not yet supported")
  }

  class { 'ntp':
    servers  => $servers,
    restrict => $_restrict
  }
}
