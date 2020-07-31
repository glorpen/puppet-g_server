define g_server::accounts::user(
  String $username = $title,
  Enum['present','absent'] $ensure = 'present',
  Hash $ssh_authorized_keys = {},
  Hash $ssh_keys = {},
  Boolean $admin = false,
  Array $groups = [],
  Optional[String] $home = undef,
  Optional[String] $password_hash = undef,
  String $shell = '/bin/bash',
  Boolean $ssh_login = true,
  Optional[String] $comment = undef,
){
  include ::stdlib
  include ::g_server
  include ::g_server::accounts

  $ensure_directory = $ensure?{
    'present' => 'directory',
    default => 'absent'
  }
  $ensure_file = $ensure?{
    'present' => 'file',
    default => 'absent'
  }

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
    ensure => $ensure_directory,
    owner  => $username,
    group  => $username,
    mode   => '0700'
  }

  if defined(Class['g_server::services::ssh']) and $ssh_login {

    include ::g_server::services::ssh

    if $ssh_authorized_keys and $ensure == 'present' {
      $ssh_authorized_keys.each | $place, $key | {
        ssh_authorized_key { "${username}@${place}":
          ensure => 'present',
          user   => $username,
          type   => 'ssh-rsa',
          key    => $key,
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
        ensure  => $ensure_file,
        owner   => $username,
        group   => $username,
        mode    => '0644',
        source  => $v['public_key_source'],
        content => $v['public_key_content'],
      }
      file {"${_home}/.ssh/id_${k}":
        ensure  => $ensure_file,
        owner   => $username,
        group   => $username,
        mode    => '0600',
        source  => $v['private_key_source'],
        content => $v['private_key_content'],
      }
    }
  }

  user { $username:
    ensure         => $ensure,
    home           => $_home,
    groups         => $_groups,
    managehome     => true,
    purge_ssh_keys => true,
    password       => $password_hash,
    shell          => $shell,
    comment        => $comment
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
      ensure  => $ensure,
      content => "${username} ALL=(ALL) ${_selinux_opts}ALL"
    }
  }
}
