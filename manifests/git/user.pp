class g_server::git::user(
  $username = $title,
  $ssh_keys = [],
  $ensure = true
){
  $ssh_keys.each | $index, $key | {
    #create if not exists, parent - purge recursive
    
    $parent = "${::g_server::git::home_dir}/.gitolite/keydir/${index}"
    
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
      content  => $key,
      mode    => '0600',
      notify  => Exec['gitolite.refresh']
    }
  }
}
