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
}
