class g_server::portage(
  $cflags = undef,
  $chost = undef,
  $cxxflags = '${CFLAGS}',
  $portdir = '/usr/portage',
  $distdir = '${PORTDIR}/distfiles',
  $pkgdir = '${PORTDIR}/packages',
  $features = '${FEATURES} metadata-transfer splitdebug',
  $makeopts = undef,
  $cpu_flags_x86 = undef,
  $video_cards = undef,
  $use = undef,
  $policy_types = undef,
  $python_targets = undef,
  $use_python = undef,
  $python_single_target = undef,
  $ruby_targets = undef,
  $php_targets = undef
){
  $keys = ['cflags', 'cxxflags', 'chost', 'cpu_flags_x86', 'use', 'portdir', 'distdir', 'pkgdir',
           'makeopts', 'features', 'policy_types', 'video_cards', 'python_targets', 'use_python',
           'python_single_target', 'ruby_targets', 'php_targets']
  
  $keys.each | $key | {
    $value = getvar("::g_server::portage::${key}")
    
    if $value {
	    portage::makeconf { $key:
	      content => $value,
	      ensure  => present,
	    }
    }
  }
}
