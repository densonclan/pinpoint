class app(
  $ruby_version = '1.9.3-p551',
  $passenger_version = '3.0.18',
  $backup_version = '4.1.8',
  $user = 'vagrant',
  $group = 'vagrant',
  $app_root = '/var/www/pinpoint'
) {
  class { 'rbenv':
    install_dir => '/opt/rbenv',
    # latest      => true
  }

  file { ['/var/www', $app_root, "${app_root}/shared", "${app_root}/shared/config", "${app_root}/releases", "${app_root}/repo"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => 755
  }

  file { "${app_root}/shared/config/database.yml":
    source => 'puppet:///modules/app/database.yml',
    owner  => $user,
    group  => $group,
    replace => false,
    require => File["${app_root}/shared/config"]
  }

  rbenv::plugin { 'sstephenson/ruby-build': }
  rbenv::build { '1.9.3-p551': global => true }
  rbenv::gem { 'passenger': ruby_version => "$ruby_version", version => "$passenger_version" }
  rbenv::gem { 'backup': ruby_version => "$ruby_version", version => "$backup_version" }
}