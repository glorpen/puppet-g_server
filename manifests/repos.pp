class g_server::repos(
  $puppet = false
){

  include ::stdlib

  case $::facts['os']['name'] {
    'Gentoo' : {
      include ::g_portage
    }
    'Centos': {
      class { 'yum': }
      if $puppet {
        class { 'g_server::repos::puppet': }
      }
    }
    'Fedora': {
      if $puppet {
        class { 'g_server::repos::puppet': }
      }
    }
    default: {}
  }

}
