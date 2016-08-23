class monit($user, $app_root, $rails_env) {
  package {'monit': 
  }->
  file { 'monit-config':
    ensure  => present,
    path    => '/etc/monit/conf.d/delayed_job',
    owner   => root,
    group   => root,
    content => template('monit/delayed_job'),
  }
}