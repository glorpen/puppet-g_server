class g_server::rocketchat (
  $ensure = present
){
	ensure_packages(['media-gfx/imagemagick'])
	
  g_portage::package_keywords { '=net-libs/http-parser-2.6.2':
	  keywords => ['~amd64'],
	  ensure   => $ensure,
	}->
	g_portage::package_keywords { '=dev-db/mongodb-3.2.5':
    keywords => ['~amd64'],
    ensure   => $ensure,
  }->
  g_portage::package_keywords { '=dev-libs/boost-1.60.0':
    keywords => ['~amd64'],
    ensure   => $ensure,
  }->
  g_portage::package_keywords { '=app-admin/mongo-tools-3.2.5':
    keywords => ['~amd64'],
    ensure   => $ensure,
  }->
  g_portage::package_keywords { '=dev-util/boost-build-1.60.0':
    keywords => ['~amd64'],
    ensure   => $ensure,
  }->
	Package['media-gfx/imagemagick']->
	package { 'net-im/rocketchat-server':
	  ensure   => $ensure ? {
	     'present' => '0.31.0',
       default => absent
	  }
	}~>
	G_server::Rocketchat::Instance<| |>

}
