class g_server::rocketchat (
){
	ensure_packages(['media-gfx/imagemagick'])
	
  package_keywords { 'net-libs/http-parser':
	  keywords => ['~amd64'],
	  target   => 'puppet',
	  version  => '>=2.6.1',
	  ensure   => present,
	}->
	package_keywords { 'dev-db/mongodb':
    keywords => ['~amd64'],
    target   => 'puppet',
    version  => '=3.2.5',
    ensure   => present,
  }->
  package_keywords { 'dev-libs/boost':
    keywords => ['~amd64'],
    target   => 'puppet',
    version  => '=1.60.0',
    ensure   => present,
  }->
  package_keywords { 'app-admin/mongo-tools':
    keywords => ['~amd64'],
    target   => 'puppet',
    version  => '=3.2.5',
    ensure   => present,
  }->
  package_keywords { 'dev-util/boost-build':
    keywords => ['~amd64'],
    target   => 'puppet',
    version  => '=1.60.0',
    ensure   => present,
  }->
	Package['media-gfx/imagemagick']->
	package { 'net-im/rocketchat-server':
	  ensure   => '0.29.0'
	}~>
	G_server::Rocketchat::Instance<| |>

}
