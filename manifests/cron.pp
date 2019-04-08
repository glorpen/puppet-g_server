class g_server::cron (
  Hash[String, Hash] $jobs = {}
){
  class { ::cron:
    manage_package => true,
  }
  create_resources(g_server::cron::job, $jobs)
}
