class g_server::mercurial(
  $ensure = present
){

  $version = "1.3"

  package_keywords { 'dev-vcs/mercurial-server':
    version => "=${version}",
    ensure   => present,
    target => 'puppet',
    keywords => ['~amd64']
  }~>
  package { 'dev-vcs/mercurial-server':
    ensure   => $ensure ? {
       'present' => $version,
       default => absent
    }
  }
  
  #http://gitolite.com/gitolite/odds-and-ends.html#gh
  
  #/usr/share/mercurial-server/init/hginit
  #"/usr/bin/ssh-keygen -q -t #{type} -N '' -C '#{comment}' -f #{keyfile}"
  
  @g_server::mercurial::replicator {$::facts["clientcert"]:
    server => $::facts["fqdn"],
  }
  G_server::Mercurial::Replicator <| |>
}
