class g_server::git(
  $ensure = present,
  $user = 'git',
  $group = 'git',
  $home_dir = '/var/lib/gitolite',
){

  $repo_dir = "${home_dir}/repositories"
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
  file { "${home_dir}/.gitolite/keydir":
    ensure => 'directory',
    owner => $::g_server::git::user,
    group => $::g_server::git::group,
    recurse => true,
    purge => true,
    force => true,
    mode => '0700'
  }~>
  file { $repo_dir:
    ensure => 'directory',
    owner => $::g_server::git::user,
    group => $::g_server::git::group,
    recurse => true,
    purge => true,
    force => true,
    mode => '0700'
  }~>
  concat { 'g_server::gitolite.conf' :
    ensure => $ensure,
    owner => $::g_server::git::user,
    group => $::g_server::git::group,
    mode => 'u=rw',
    path => "${home_dir}/.gitolite/conf/gitolite.conf"
  }~>
  exec { 'gitolite.refresh':
    user => $user,
    environment => ["HOME=${home_dir}"],
    cwd => $home_dir,
    command => 'gitolite compile; gitolite trigger POST_COMPILE',
    path => ['/usr/bin', '/bin'],
    refreshonly => true
  }
  
  #"/usr/bin/ssh-keygen -q -t #{type} -N '' -C '#{comment}' -f #{keyfile}"
  
  #@g_server::git::replicator {$::facts["clientcert"]:
  #  server => $::facts["fqdn"],
  #}
  #G_server::Git::Replicator <| |>
}
