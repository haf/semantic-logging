# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.host_name = 'semantic-logging'
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  # config.vm.boot_mode = :gui
  config.vm.forward_port 9292, 9292 # logstash default web
  config.vm.forward_port 5672, 5672 # rabbitmq
  config.vm.forward_port 9200, 9200 # elasticsearch
  # config.vm.forward_port 80, 8080 # kibana

  config.vm.share_folder "puppet-modules", "/etc/puppet/modules", "./modules"
  
  config.vm.customize do |vm|
    vm.memory_size = 1024
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "./modules"
    puppet.manifests_path = "."
    puppet.manifest_file = "manifests/semantic-logging.pp"
    puppet.options = [ "--verbose", "--debug" ]
  end

  
end
