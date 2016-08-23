class db {

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.2',
  }->
  class { 'postgresql::server':
    listen_addresses           => '*'
  }

  postgresql::server::pg_hba_rule { 'allow application network to access app database':
    description => "Open up postgresql for access from all",
    type => 'local',
    database => 'all',
    user => 'all',
    address => '',
    auth_method => 'trust',
  }

  postgresql::server::pg_hba_rule { 'allow localhost to access app database':
    description => "Open up postgresql for access from localhost",
    type => 'host',
    database => 'all',
    user => 'all',
    address => '127.0.0.1/32',
    auth_method => 'md5',
  }

  package {'libpq-dev': }
}