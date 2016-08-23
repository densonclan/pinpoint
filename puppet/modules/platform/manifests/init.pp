class platform {
  package { [ 'build-essential',
    'zlib1g-dev',
    'libssl-dev',
    'libreadline-dev',
    'git-core',
    'libxml2',
    'libxml2-dev',
    'libxslt1-dev',
    'sqlite3',
    'vim',
    'curl',
    'ruby1.9.1-dev',
    'libmagickwand-dev',
    'phantomjs',
    'imagemagick',
    'libcurl4-openssl-dev',
    'libsqlite3-dev']:
      ensure => installed,
  }

  user { 'app':
    ensure => present,
    password => '$6$u/D9QNqr$lO9mv.tDBojHODkck.AdvJVM0O0vAijjXK6pSBpMWF7SJjn3gFkWU9STIDcmSQUt7l4is/1ISzuGwAv8zI.Wz0',
    groups => 'www-data',
    uid  => 1050,
    shell => '/bin/bash',
    home => '/home/app'
  }

  exec { '/usr/sbin/adduser app sudo':
    require => User['app']
  }

  file { '/home/app':
    ensure => directory,
    owner  => 'app',
    group  => 'www-data',
    require => User['app'] 
  }

}