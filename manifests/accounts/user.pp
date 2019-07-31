define g_server::accounts::user(
  String $username = $title,
  Hash $ssh_authorized_keys = {},
  Hash $ssh_keys = {},
  Boolean $admin = false,
  Array $groups = [],
  Optional[String] $home = undef,
  Optional[String] $password_hash = undef,
  String $shell = '/bin/bash',
  Boolean $ssh_login = true,
){
  include ::stdlib
  include ::g_server
  include ::g_server::accounts

  if $admin {
    $base_groups = concat($groups, $::g_server::accounts::admin_groups)
  } else {
    $base_groups = $groups
  }

  $_home = $home?{
    undef => "/home/${username}",
    default => $home
  }

  User[$username]
  ->file {"${_home}/.ssh":
    ensure => 'directory',
    owner  => $username,
    group  => $username,
    mode   => '0700'
  }

  if defined(Class['g_server::services::ssh']) and $ssh_login {

    include ::g_server::services::ssh

    if $ssh_authorized_keys {
      $ssh_authorized_keys.each | $place, $key | {
        ssh_authorized_key { "${username}@${place}":
          user => $username,
          type => 'ssh-rsa',
          key  => $key,
        }
      }
    }

    $_groups = concat($base_groups, $::g_server::services::ssh::group)

  } else {
    $_groups = $base_groups
  }

  if $ssh_keys {
    $ssh_keys.each | $k, $v | {
      file {"${_home}/.ssh/id_${k}.pub":
        ensure  => 'file',
        owner   => $username,
        group   => $username,
        mode    => '0644',
        source  => $v['public_key_source'],
        content => $v['public_key_content'],
      }
      file {"${_home}/.ssh/id_${k}":
        ensure  => 'file',
        owner   => $username,
        group   => $username,
        mode    => '0600',
        source  => $v['private_key_source'],
        content => $v['private_key_content'],
      }
    }
  }

  user { $username:
    ensure         => 'present',
    home           => $_home,
    groups         => $_groups,
    managehome     => true,
    purge_ssh_keys => true,
    password       => $password_hash,
    shell          => $shell
  }

  if $::g_server::manage_sudo and $admin {
    if $::facts['os']['selinux']['enabled'] {
      $_selinux_opts = join(delete_undef_values([
        $::g_server::accounts::root_selinux_role?{
          false => undef,
          default => "ROLE=\"${::g_server::accounts::root_selinux_role}\" "
        },
        $::g_server::accounts::root_selinux_role?{
          false => undef,
          default => "TYPE=\"${::g_server::accounts::root_selinux_type}\" ",
        }
      ]), '')
    } else {
      $_selinux_opts = ''
    }
    sudo::conf { "g_server-admin-${username}":
      content => "${username} ALL=(ALL) ${_selinux_opts}ALL"
    }
  }
}
