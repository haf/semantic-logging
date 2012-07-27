class kibana {

  $kpath = '/tmp/kibana.tar.gz'
  $wwwpath = '/var/www/kibana'

  file { "$kpath":
    source => 'puppet:///files/rashidkpc-Kibana-v0.1.5-44-gf5c80c3.tar.gz',
    ensure => present,
    mode => '0755'
  }
  
  file { '/var/www':
  	ensure => 'directory',
  	mode => '0755',
  	owner => 'root',
  	group => 'root'
  }
  
  exec { "$kpath":
    command => "tar -zxvf $kpath -C /var/www && mv `ls /var/www | head -n 1` $wwwpath",
    unless  => "find $wwwpath",
    creates => "$wwwpath",
    require => [
      File['/var/www'],
      File["$kpath"]
    ],
    path    => "/usr/local/bin:/usr/sbin:/usr/bin:/bin",
    cwd     => '/var/www'
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
    mode => '0755',
    require => Exec["$kpath"]
  }

  group { 'kibana':
    ensure => present
  }
  
  user { 'kibana':
    ensure => present,
    gid => 'kibana',
    home => $wwwpath,
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
  
  host { 'elasticsearch':
  	ip => '::1',
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
    require         => [ 
      Service['php5-fpm'] ,
      Host['elasticsearch']
    ],
    template        => 'nginx/fcgi_site.erb',
    listen          => '80'
  }
}
