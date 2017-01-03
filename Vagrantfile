# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # machine #1 the router
  config.vm.define "router" do |router|
    router.vm.box = "moozer/base-ob57"
    router.vm.synced_folder "shared", "/vagrant"
    router.vm.hostname = "router"
#    router.vm.box = "deb8-base"
#    router.vm.synced_folder "shared", "/vagrant"
#    router.vm.hostname = "router"

    # x.x.x.1 does work well with libvirt
    router.vm.network :private_network, 
      :ip => "10.10.0.5",
      :libvirt__forward_mode => "nat",
      :libvirt__network_name => "LAN_upstream",
      :auto_config => false,
      :libvirt__dhcp_enabled => false

    router.vm.network :private_network, 
      :ip => "10.10.10.5",
      :libvirt__forward_mode => "none",
      :libvirt__network_name => "LAN_A",
      :auto_config => false,
      :libvirt__dhcp_enabled => false

    router.vm.network :private_network, 
      :ip => "10.10.20.5",
      :libvirt__forward_mode => "none",
      :libvirt__network_name => "LAN_B",
      :auto_config => false,
      :libvirt__dhcp_enabled => false


    # to handle that openbsd has python located elsewhere
    # (won't fail on other *nux platforms)
    router.vm.provision "shell",
      inline: "ORIGPATH=/usr/local/bin/python; DESTPATH=/usr/bin/python; \
             if [ -e $ORIGPATH ] && [ ! -e $DESTPATH ]; then 
               ln -s $ORIGPATH $DESTPATH; 
             else 
               echo link already in place, or not relevant; 
             fi"
      
    # and do provisioning
    router.vm.provision "ansible" do |ansible|
      ansible.playbook = "test.yml"
      #ansible.inventory_path = "inventory"
      ansible.groups = {
        "routers" => ["router"],
        "servers" => ["serverA", "serverB"]
      }
    end

  end

  # machine #2 a debian 8 machine
  config.vm.define "serverA" do |server|
    server.vm.box = "deb8-base"
#    server.vm.hostname = "serverA"  
    server.vm.synced_folder "shared", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false
#    server.vm.synced_folder "shared", "/vagrant", type: "9p"
    
    # not setting IP address
    # specifying that DHCP trumps mgnt as gateway
   server.vm.network :private_network, 
      :ip => "10.10.10.200", # dummy IP
      :libvirt__forward_mode => "none",
      :libvirt__network_name => "LAN_A",
      :auto_config => false,
      :libvirt__dhcp_enabled => false
      
    server.vm.provision "shell", 
                 inline: "cp /vagrant/interfaces /etc/network/interfaces; \
                         cp /vagrant/default-gw /etc/network/if-up.d/; \
                         service networking restart;"
    
    # and do provisioning
    server.vm.provision "ansible" do |ansible|
      ansible.playbook = "test.yml"
      #ansible.inventory_path = "inventory"
      ansible.groups = {
        "routers" => ["router"],
        "servers" => ["serverA", "serverB"]
      }
    end
  end

  # machine #3 a debian 8 machine
  config.vm.define "serverB" do |serverB|
    serverB.vm.box = "deb8-base"
    serverB.vm.synced_folder "shared", "/vagrant", type: "9p"
#    serverB.vm.hostname = "serverB"

    # specifying that DHCP trumps mgnt as gateway
    serverB.vm.network :private_network, 
      :ip => "10.10.20.200", # dummy IP
      :libvirt__network_name => "LAN_B",
      :libvirt__forward_mode => "none",
      :use_dhcp_assigned_default_route => true,
      :auto_config=> false

    serverB.vm.provision "shell", 
                 inline: "cp /vagrant/interfaces /etc/network/interfaces; \
                         cp /vagrant/default-gw /etc/network/if-up.d/; \
                         service networking restart;"
    # and do provisioning
    serverB.vm.provision "ansible" do |ansible|
      ansible.playbook = "test.yml"
      #ansible.inventory_path = "inventory"
      ansible.groups = {
        "routers" => ["router_d8"],
        "servers" => ["serverA", "serverB"]
      }
    end
  end

  # start this on the localhost, not a remote kvm host
  config.vm.provider :libvirt do |libvirt|
    libvirt.host = ""
  end

end
