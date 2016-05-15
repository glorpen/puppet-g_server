define g_server::git::repo(
  $ensure => true,
  $read_only = [],
  $full_access = []
){

  if $ensure {
	  concat::fragment {"gitolite-repo-${title}":
	    target  => 'g_server::gitolite.conf',
	    content => template('g_server/git/repo.conf.erb'),
	    require => Exec['gitolite.setup'],
	    notify  => Exec['gitolite.refresh'],
	  }
  }
  
  Exec['gitolite.refresh']->
  file { "${::g_server::git::repo_dir}/${title}":
    ensure => $ensure? {
      true => 'directory',
      default => absent
    },
    owner => $::g_server::git::user,
    group => $::g_server::git::group,
    recurse => true,
    purge => true,
    force => true,
    mode => '0700',
  }
}
