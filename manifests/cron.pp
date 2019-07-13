class g_server::cron (
  Hash[String, Hash] $jobs = {},
  Optional[String] $service_name = undef
){
  case $::osfamily {
    'Gentoo': {
      $_defaults = {
        'service_name' => 'cronie'
      }
    }
    default: {
      $_defaults = {}
    }
  }

  $_user_opts = {
    'service_name' => $service_name
  }

  class { '::cron':
    manage_package => true,
    *              => delete_undef_values(merge($_defaults, $_user_opts)),
  }
  create_resources(g_server::cron::job, $jobs)
}
