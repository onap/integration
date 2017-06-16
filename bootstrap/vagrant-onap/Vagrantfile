# -*- mode: ruby -*-
# vi: set ft=ruby :

conf = {
# Generic parameters used across all ONAP components
  'public_net_id'       => '00000000-0000-0000-0000-000000000000',
  'key_name'            => 'ecomp_key',
  'pub_key'             => '',
  'nexus_repo'          => 'https://nexus.onap.org/content/sites/raw',
  'nexus_docker_repo'   => 'nexus3.onap.org:10001',
  'nexus_username'      => 'docker',
  'nexus_password'      => 'docker',
  'dmaap_topic'         => 'AUTO',
  'artifacts_version'   => '1.0.0',
  'docker_version'      => '1.0-STAGING-latest',
  'gerrit_branch'       => 'master',
# Parameters for DCAE instantiation
  'dcae_zone'           => 'iad4',
  'dcae_state'          => 'vi',
  'openstack_tenant_id' => '',
  'openstack_username'  => '',
  'openstack_api_key'   => '',
  'openstack_password'  => '',
  'nexus_repo_root'     => 'https://nexus.onap.org',
  'nexus_url_snapshot'  => 'https://nexus.onap.org/content/repositories/snapshots',
  'gitlab_branch'       => 'master',
  'build_image'         => 'True'
}

vd_conf = ENV.fetch('VD_CONF', 'etc/settings.yaml')
if File.exist?(vd_conf)
  require 'yaml'
  user_conf = YAML.load_file(vd_conf)
  conf.update(user_conf)
end

deploy_mode = ENV.fetch('DEPLOY_MODE', 'individual')
sdc_volume='vol1-sdc-data.vdi'

Vagrant.configure("2") do |config|

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil and ENV['no_proxy'] != nil
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy']
    config.proxy.https    = ENV['https_proxy']
    config.proxy.no_proxy = ENV['no_proxy']
  end

  #config.vm.box = 'sputnik13/trusty64'
  config.vm.box = 'ubuntu/trusty64'
  #config.vm.provision "docker"
  config.vm.synced_folder './opt', '/opt/', create: true
  config.vm.synced_folder './lib', '/var/onap/', create: true
  config.vm.synced_folder '~/.m2', '/root/.m2/', create: true

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 4 * 1024]
  end
  config.vm.provider "libvirt" do |v|
    v.memory = 4 * 1024
    v.nested = true
  end

  case deploy_mode

  when 'all-in-one'

    config.vm.define :all_in_one do |all_in_one|
      all_in_one.vm.hostname = 'all-in-one'
      all_in_one.vm.network :private_network, ip: '192.168.50.3'
      all_in_one.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", 12 * 1024]
        unless File.exist?(sdc_volume)
           v.customize ['createhd', '--filename', sdc_volume, '--size', 20 * 1024]
        end
        v.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', sdc_volume]
      end
      all_in_one.vm.provider "libvirt" do |v|
        v.memory = 12 * 1024
        v.nested = true
        v.storage :file, path: sdc_volume, bus: 'sata', device: 'vdb', size: '2G'
      end
      all_in_one.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['mr', 'sdc', 'aai', 'mso', 'robot', 'vid', 'sdnc', 'portal', 'dcae', 'policy', 'appc']
        s.env = conf
      end
    end

  when 'individual'

    config.vm.define :dns do |dns|
      dns.vm.hostname = 'dns'
      dns.vm.network :private_network, ip: '192.168.50.3'
      dns.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", 1 * 1024]
      end
      dns.vm.provider "libvirt" do |v|
        v.memory = 1 * 1024
        v.nested = true
      end
      dns.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.env = conf
      end 
    end

    config.vm.define :message_router do |message_router|
      message_router.vm.hostname = 'message-router'
      message_router.vm.network :private_network, ip: '192.168.50.4'
      message_router.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['mr']
        s.env = conf
      end
    end

    config.vm.define :sdc do |sdc|
      sdc.vm.hostname = 'sdc'
      sdc.vm.network :private_network, ip: '192.168.50.5'
      sdc.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", 4 * 1024]
        unless File.exist?(sdc_volume)
           v.customize ['createhd', '--filename', sdc_volume, '--size', 20 * 1024]
        end
        v.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', sdc_volume]
      end
      sdc.vm.provider "libvirt" do |v|
        v.memory = 4 * 1024
        v.nested = true
        v.storage :file, path: sdc_volume, bus: 'sata', device: 'vdb', size: '2G'
      end
      sdc.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['sdc']
        s.env = conf
      end
    end
  
    config.vm.define :aai do |aai|
      aai.vm.hostname = 'aai'
      aai.vm.network :private_network, ip: '192.168.50.6'
      aai.vm.provision 'shell' do |s| 
        s.path = 'postinstall.sh'
        s.args = ['aai']
        s.env = conf
      end 
    end
  
    config.vm.define :mso do |mso|
      mso.vm.hostname = 'mso-server'
      mso.vm.network :private_network, ip: '192.168.50.7'
      mso.vm.provision 'shell' do |s| 
        s.path = 'postinstall.sh'
        s.args = ['mso']
        s.env = conf
      end 
    end
  
    config.vm.define :robot do |robot|
      robot.vm.hostname = 'robot'
      robot.vm.network :private_network, ip: '192.168.50.8'
      robot.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['robot']
        s.env = conf
      end
    end
  
    config.vm.define :vid do |vid|
      vid.vm.hostname = 'vid'
      vid.vm.network :private_network, ip: '192.168.50.9'
      vid.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['vid']
        s.env = conf
      end
    end
  
    config.vm.define :sdnc do |sdnc|
      sdnc.vm.hostname = 'sdnc'
      sdnc.vm.network :private_network, ip: '192.168.50.10'
      sdnc.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['sdnc']
        s.env = conf
      end
    end
  
    config.vm.define :portal do |portal|
      portal.vm.hostname = 'portal'
      portal.vm.network :private_network, ip: '192.168.50.11'
      portal.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['portal']
        s.env = conf
      end
    end
  
    config.vm.define :dcae do |dcae|
      dcae.vm.hostname = 'dcae'
      dcae.vm.network :private_network, ip: '192.168.50.12'
      dcae.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['dcae']
        s.env = conf
      end
    end
  
    config.vm.define :policy do |policy|
      policy.vm.hostname = 'policy'
      policy.vm.network :private_network, ip: '192.168.50.13'
      policy.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['policy']
        s.env = conf
      end
    end
  
    config.vm.define :appc do |appc|
      appc.vm.hostname = 'appc'
      appc.vm.network :private_network, ip: '192.168.50.14'
      appc.vm.provision 'shell' do |s|
        s.path = 'postinstall.sh'
        s.args = ['appc']
        s.env = conf
      end
    end

  end
end
