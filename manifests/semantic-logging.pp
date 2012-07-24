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
}
