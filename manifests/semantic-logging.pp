node 'semantic-logging' {
  include rabbitmq
  rabbitmq::vhost { '/': }
  rabbitmq::plugin { 'rabbitmq_management': }
}
