class g_server::network::gentoo::iface(
  String $config,
  Optional[String] $modules = undef
){
  $conf_path = $::g_server::network::gentoo::network::conf_path
  
  $_config = {
    "config_${name}" => $config,
    "modules_${name}" => $modules
  }
  
  concat::fragment { "g_server:net:${name}":
    target  => $conf_path,
    content => String(delete_undef_values($_config), {
      Hash => {
        format => 'a',
        separator => "\n",
        separator2 => '=',
        string_formats => {
          Any => '"%s"'
        }
      }
    })
  }
}
