$passenger_version='3.0.18'
$main_ruby = "1.9.3-p551"

stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}

class { 'apt_get_update':
  stage => preinstall
}

class { 'db': }

postgresql::server::db { 'pinpoint_production':
  user     => 'pinpoint',
  password => postgresql_password('pinpoint', 'P1nP01nt!'),
}
