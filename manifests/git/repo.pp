define g_server::git::repo(
  $ensure = present,
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
  
  $parts = $title.split('/')
  $parts[0,-1].each | $index, $part | {
    $p = join($parts[0,$index+1],'/')
    ensure_resource('file', "${::g_server::git::repo_dir}/${p}", {
	    owner => $::g_server::git::user,
	    group => $::g_server::git::group,
	    recurse => true,
	    purge => true,
	    force => true,
	    mode => '0700',
    })
  }
  
  Exec['gitolite.refresh']->
  file { "${::g_server::git::repo_dir}/${title}.git":
    ensure => $ensure? {
      'present' => 'directory',
      default => 'absent'
    },
    owner => $::g_server::git::user,
    group => $::g_server::git::group,
    recurse => true,
    purge => true,
    force => true,
    mode => '0700',
  }
}
