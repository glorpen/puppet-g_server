class g_server::mercurial(
  $ensure = present
){
  package { 'dev-vcs/mercurial-server':
    ensure   => $ensure ? {
       'present' => '1.3',
       default => absent
    }
  }
}
