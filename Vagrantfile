VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box       = 'trusty64'
  config.vm.box_url   = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'
  config.vm.host_name = 'pinpoint'


  config.ssh.forward_agent = true

  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.synced_folder ".", "/home/vagrant/pinpoint", type: "nfs"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.enable :apt
  end

  config.vm.define :development do |development_config|

    # development_config.vm.network :forwarded_port, guest: 3000, host: 3000
    development_config.vm.network :forwarded_port, guest: 3001, host: 3001
    # development_config.vm.network :forwarded_port, guest: 80, host: 80
    development_config.vm.network :forwarded_port, guest: 3306, host: 3306
    development_config.vm.network :private_network, ip: "192.168.33.10"


    development_config.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'puppet/manifests'
      puppet.module_path    = 'puppet/modules'
      puppet.hiera_config_path = "puppet/hiera.yml"
      puppet.options        = '--verbose --confdir=/etc/puppet'
      puppet.manifest_file  = 'dev.pp'
    end

  end
end
