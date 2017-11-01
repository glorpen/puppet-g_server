class g_server::accounts (
  Optional[String] $root_password_hash = undef,
  $admin_groups = ['wheel'],
  Hash $users = {}
){
  user { 'root':
    ensure => present,
    password => $root_password_hash,
    shell => '/bin/false'
  }
  
  create_resources(g_server::accounts::user, $users)
}
