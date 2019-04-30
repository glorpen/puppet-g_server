class g_server::repos(
){

  include ::stdlib

  case $::facts['os']['name'] {
    'Gentoo' : {
      include ::g_portage
    }
    'Centos': {
      class { 'yum': }
      class { 'g_server::repos::puppet': }
    }
    'Fedora': {
      class { 'g_server::repos::puppet': }
    }
    default: {}
  }

}
