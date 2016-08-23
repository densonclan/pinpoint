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

class {'app': 
  ruby_version => $main_ruby,
  passenger_version => $passenger_version,
  user => 'app',
  group => 'www-data',
  require => Class['platform']
}

class {'nginx_passenger':
  ruby_version => $main_ruby,
  rails_env => 'production',
  source_location => '/var/www/pinpoint/current',
  require    => Class['app']
}

class {'monit':
  user => 'app',
  app_root => '/var/www/pinpoint/current',
  rails_env => 'production',
  require    => Class['app']
}