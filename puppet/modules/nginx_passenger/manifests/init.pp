class nginx_passenger(
  $ruby_version,
  $rails_env,
  $source_location,
  $logdir = '/var/log/nginx',
  $installdir='/opt/nginx') {

  exec { 'nginx-install':
    command => "/opt/rbenv/versions/$ruby_version/bin/passenger-install-nginx-module --auto --auto-download  --prefix=/opt/nginx",
    path    => [ "/opt/rbenv/shims", "/opt/rbenv/bin", '/usr/bin', '/bin', '/usr/local/bin' ],
    group  => 'root',
    unless => "/usr/bin/test -d /opt/nginx",
    require => [Package["libcurl4-openssl-dev"], Exec["gem-install-passenger-$main_ruby"]]
  }

  file { 'nginx-service':
    path      => '/etc/init.d/nginx',
    owner     => 'root',
    group     => 'root',
    mode      => '0755',
    content   => template('nginx_passenger/nginx.init.erb')
  }

  file { 'nginx-config':
    path    => "${installdir}/conf/nginx.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nginx_passenger/nginx.conf.erb'),
    require => Exec['nginx-install'],
  }

  file { $logdir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['nginx-config'],
    require    => [ File[$logdir], File['nginx-service']],
  }
}