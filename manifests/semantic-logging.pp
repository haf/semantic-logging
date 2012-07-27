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
