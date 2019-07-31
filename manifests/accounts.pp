class g_server::accounts (
  Optional[String] $root_password_hash = undef,
  Hash $root_ssh_keys = {},
  Hash $root_ssh_authorized_keys = {},
  $admin_groups = ['wheel'],
  Hash $users = {},
  Variant[Boolean, String] $root_selinux_role = 'sysadm_r',
  Variant[Boolean, String] $root_selinux_type = 'sysadm_t',
){

  g_server::accounts::user { 'root':
    password_hash       => $root_password_hash,
    home                => '/root',
    shell               => '/bin/bash',
    groups              => ['root'],
    ssh_keys            => $root_ssh_keys,
    ssh_authorized_keys => $root_ssh_authorized_keys,

    admin               => false
  }

  if ($root_selinux_role == true or $root_selinux_type == true) {
    fail('Selinux role and type can be false or string.')
  }

  create_resources(g_server::accounts::user, $users)
}
