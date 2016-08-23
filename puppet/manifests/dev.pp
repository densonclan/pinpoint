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

class { 'platform': }

class { 'db': }

postgresql::server::role { "developer":
  password_hash => postgresql_password('developer', 'password'),
  createdb => true,
  superuser => true,
}

class {'app': 
  ruby_version => $main_ruby,
  passenger_version => $passenger_version
}

class {'nginx_passenger':
  ruby_version => $main_ruby,
  rails_env => 'development',
  source_location => '/vagrant',
  require    => Class['app']
}

class {'monit':
  user => 'vagrant',
  app_root => '/vagrant',
  rails_env => 'development',
  require    => Class['app']
}