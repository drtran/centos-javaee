#
# Centos 7 Virtual box for CSD 2015 - JEE Server only.
#

Vagrant.configure(2) do |config|
  config.vm.box = "chef/centos-7.1"
  config.vm.network "forwarded_port", guest: 8080, host: 18080
  config.vm.network "forwarded_port", guest: 9000, host: 19000
  config.vm.network "forwarded_port", guest: 3306, host: 13306
  config.vm.provision :shell, path: "bootstrap.sh"

  config.vm.provider "virtualbox" do |vb|
    # vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.name = "centos-jee"
    # vb.gui = true
  end

end
