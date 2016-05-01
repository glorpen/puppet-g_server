class g_server::rocketchat (
  $instances = {}
){
  package_keywords { 'net-libs/http-parser':
	  keywords => ['~amd64'],
	  target   => 'puppet',
	  version  => '>=2.6.1',
	  ensure   => present,
	}->
	package { 'net-im/rocketchat-server':
	  ensure   => '0.28.0'
	}
	
	g_server::rocketchat::instance {
	   'rocketchat-instances-aggregator':
	       instances => $instances
	}
	
}
