class g_server::rocketchat (
){
	ensure_packages(['media-gfx/imagemagick'])
	
  package_keywords { 'net-libs/http-parser':
	  keywords => ['~amd64'],
	  target   => 'puppet',
	  version  => '>=2.6.1',
	  ensure   => present,
	}->
	Package['media-gfx/imagemagick']->
	package { 'net-im/rocketchat-server':
	  ensure   => '0.28.0'
	}~>
	G_server::Rocketchat::Instance<| |>

}
