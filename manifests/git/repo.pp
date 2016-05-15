define g_server::git::repo(
  $read_only = [],
  $full_access = []
){
  concat::fragment {"gitolite-repo-${title}":
    target  => 'g_server::gitolite.conf',
    content => template('g_server/gitolite/repo.conf.erb'),
    require => Exec['gitolite.setup'],
    notify  => Exec['gitolite.refresh'],
  }
}
