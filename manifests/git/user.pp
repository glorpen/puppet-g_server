define g_server::git::user(
  $username = $title,
  $ssh_rsa_keys = {},
  $ensure = true
){
  keys($ssh_rsa_keys).each | $index, $alias | {
    
    $parent = "${::g_server::git::home_dir}/.gitolite/keydir/${index}"
    $key = $ssh_rsa_keys[$alias]
    
    ensure_resource('file', $parent, {
      ensure => 'directory',
      owner => $::g_server::git::user,
      group => $::g_server::git::group,
      recurse => true,
      purge => true,
      force => true,
      mode => '0700'
    })
    
    File[$parent]->
    file{ "${parent}/${username}.pub":
      owner   => $::g_server::git::user,
      group   => $::g_server::git::group,
      content  => "ssh-rsa ${key} ${alias}",
      mode    => '0600',
      notify  => Exec['gitolite.refresh']
    }
  }
}
