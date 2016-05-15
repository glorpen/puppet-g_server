class g_server::git(
  $ensure = present,
  $user = 'git',
  $group = 'git',
  $home_dir = '/var/lib/gitolite',
  $users = {},
  $repos = {}
){

  $version = "3.6.5"
  $pkg_name = 'dev-vcs/gitolite-gentoo'
  
  $daemon = false
  $gitweb = false

  package_keywords { $pkg_name:
    version => "=${version}",
    ensure   => present,
    target => 'puppet',
    keywords => ['~amd64']
  }~>
  package { $pkg_name:
    ensure   => $ensure ? {
       'present' => $version,
       default => absent
    }
  }->
  exec { 'gitolite.setup':
    user => $user,
    path => ['/usr/bin', '/bin'],
    cwd => $home_dir,
    command => "gitolite setup -a dummy && rm -rf repositories/* .gitolite/conf/*",
    creates => "${home_dir}/.gitolite",
    environment => ["HOME=${home_dir}"]
  }~>
  file { "${home_dir}/.gitolite.rc":
    content => template('g_server/git/gitolite.rc.erb'),
    owner => $user,
    group => $group,
    mode => 'u=rw'
  }~>
  exec { 'gitolite.refresh':
    user => $user,
    environment => ["HOME=${home_dir}"],
    cwd => $home_dir,
    command => 'gitolite compile; gitolite trigger POST_COMPILE',
    path => ['/usr/bin', '/bin'],
    refreshonly => true
  }
  
  
  #http://gitolite.com/gitolite/odds-and-ends.html#gh
  
  #/usr/share/mercurial-server/init/hginit
  #"/usr/bin/ssh-keygen -q -t #{type} -N '' -C '#{comment}' -f #{keyfile}"
  
  #@g_server::git::replicator {$::facts["clientcert"]:
  #  server => $::facts["fqdn"],
  #}
  #G_server::Git::Replicator <| |>
  
  $users.each | $name, $keys | {
    g_server::git::user{ $name:
      ssh_keys_source => $keys,
      ensure => $ensure
    }
  }
  
}
