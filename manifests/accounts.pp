class g_server::accounts (
  Optional[String] $root_password_hash = undef,
  $admin_groups = ['wheel'],
  Hash $users = {}
){
  
  $root_base_groups = ['root']
  if defined(Class['g_server::services::ssh']) {
    include ::g_server::services::ssh
    $_root_groups = concat($root_base_groups, $::g_server::services::ssh::group)
  } else {
    $_root_groups = $root_base_groups
  }
  
  user { 'root':
    ensure => present,
    password => $root_password_hash,
    shell => '/bin/bash',
    groups => $_root_groups
  }
  
  create_resources(g_server::accounts::user, $users)
}
