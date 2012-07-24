stage { pre: before => Stage[main] }

class apt_get_update {
  $sentinel = "/var/lib/apt/first-puppet-run"
  exec { "apt-get update":
    command => "/usr/bin/apt-get update && touch ${sentinel}",
    onlyif => "/usr/bin/env test \\! -f ${sentinel} || /usr/bin/env test \\! -z \"$(find /etc/apt -type f -c
newer ${sentinel})\"",
    timeout => 3600,
    notify => Exec['apt-get upgrade']
  }
  exec { "apt-get upgrade":
    command => "/usr/bin/apt-get upgrade -y",
    refreshonly => true
  }
}

class kibana {

  $kpath = '/tmp/kibana.tar.gz'
  $wwwpath = '/var/www/kibana'

  file { "$kpath":
    source => 'puppet:///files/rashidkpc-Kibana-v0.1.5-44-gf5c80c3.tar.gz',
    ensure => present,
    mode => '0755'
  }
  
  exec { "$kpath":
    command => "tar -zxvf $kpath -C $wwwpath",
    unless  => "find $wwwpath",
    creates => "$wwwpath",
    require => [
      File["$kpath"],
      File['/var/www/kibana']
    ],
    path    => "/usr/local/bin:/usr/sbin:/usr/bin:/bin"
  }

  package { 'php':
    name => ["php5-cli", "php5-common", "php5-suhosin", "php5-curl"],
    ensure => present
  }

  package { 'php-fpm':
    name => [ "php5-fpm", "php5-cgi" ],
    ensure => present,
    require => Package['php']
  }

  file { "$wwwpath":
    ensure => "directory",
    owner => 'kibana',
    group => 'kibana',
    mode => '0755'
  }

  group { 'kibana':
    ensure => present
  }
  
  user { 'kibana':
    ensure => present,
    gid => 'kibana',
    home => '',
    managehome => true,
    require => Group['kibana'] 
  }
  
  service { 'php5-fpm':
  	ensure => running,
  	enable => true,
  	hasrestart => true,
  	hasstatus => true,
  	require => Package['php-fpm']
  }

  include nginx
  include nginx::fcgi
  
  nginx::site { 'default':
    ensure => absent
  }

  nginx::fcgi::site { 'nginx-kibana-enable':
    root            => "$wwwpath",
    fastcgi_pass    => "127.0.0.1:9000",
    server_name     => ["localhost", "$::hostname", "$::fqdn"],
    require         => Service['php5-fpm'],
    template        => 'nginx/fcgi_site.erb',
    listen          => '80'
  }
}

node 'semantic-logging' {
  class { 'apt_get_update':
    stage => pre
  }
  
  include rabbitmq
  rabbitmq::vhost { '/': }
  rabbitmq::plugin { 'rabbitmq_management': }
  
  class { 'elasticsearch':
    version      => '0.19.8',
    java_package => 'openjdk-6-jre-headless',
    dbdir        => '/var/lib/elasticsearch',
    logdir       => '/var/log/elasticsearch',
  }
  
  class { 'logstash': }
  class { 'kibana': }
}
