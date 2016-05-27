define g_server::wordpress::instance(
  $user = undef
){

  validate_string($user)

  g_portage::webapp{ $title:
    application => 'wordpress',
    version => $::g_server::wordpress::version,
    user => $user,
    group => $user
  }
}
