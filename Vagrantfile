# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://bertvv.github.io/notes-to-self/2015/10/05/one-vagrantfile-to-rule-them-all/
# https://app.vagrantup.com/<organization name>/boxes/<box name>/versions/<version>/providers/<provider>.box
# https://app.vagrantup.com/aahmed-se/boxes/osx-10.14-python-dev/versions/0.2/providers/virtualbox.box
# https://github.com/scottslowe/learning-tools/tree/master/vagrant
#
# WSL Settings
#   ~/.bash_profile
#   eval "$(chef shell-init bash)"
#   export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH='/mnt/c/users/Peter Mudd/'
#   export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS='1'
#   export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
#   export DOCKER_HOST=tcp://127.0.0.1:2375
# eval "$(chef shell-init bash)"

# 'StefanScherer/windows_2019', 'StefanScherer/windows_10', 'gusztavvargadr/windows-server', 'generic/ubuntu1604', 'StefanScherer/windows_2019_docker'
LOG_LEVEL = 'debug'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO
# logger.datetime_format = '%Y-%m-%d %H:%M:%S'
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

if ARGV[0] == 'up'
  if Vagrant::Util::Platform.windows? then
    logger.info('Launched from Windows')
    if Vagrant::Util::Platform.windows_admin? then
      logger.info('Running with Windows admin permissions')
      myHomeDir = ENV['USERPROFILE']
      if Vagrant::Util::Platform.windows_hyperv_enabled? then
        logger.info('Hyper-v is enabled')
        if Vagrant::Util::Platform.windows_hyperv_admin? then
          logger.info('Running with Hyper-V admin permissions')
        end
      end
    end
  elsif Vagrant::Util::Platform.wsl? then
    logger.info('Launched from WSL')
    if Vagrant::Util::Platform.wsl_windows_access? then
      puts 'Has access to vagrant machines outside of WSL'
      puts ' -appdata local: ' + Vagrant::Util::Platform.wsl_windows_appdata_local
      puts ' -windows home: ' + Vagrant::Util::Platform.wsl_windows_home
      puts ' -username: ' + Vagrant::Util::Platform.wsl_windows_username
      myHomeDir = '~'
    end
  elsif Vagrant::Util::Platform.linux? then
    logger.info('Launched from Linux')
    myHomeDir = '~'
  end
end
# https://www.vagrantup.com/docs/other/environmental-variables.html
# puts 'Operating System'
# puts ENV['VAGRANT_DETECTED_OS']
# puts ENV['VAGRANT_DETECTED_ARCH']
virtual_machines = {
  :w19 => {
    :hostname => 'w19',
    :os => 'windows',
    :box => 'StefanScherer/windows_2019',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  },
  :w16 => {
    :hostname => 'w16',
    :os => 'windows',
    :box => 'StefanScherer/windows_2016',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  }, 
  :w10 => {
    :hostname => 'w10',
    :os => 'windows',
    :box => 'StefanScherer/windows_10',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => true
  },
  :so => {
    :hostname => 'vbso',
    :os => 'linux',
    :box => 'generic/ubuntu1604',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  },
  :vbw19 => {
    :hostname => 'vbw19',
    :os => 'windows',
    :box => 'StefanScherer/windows_2019',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  },
  :vbw16 => {
    :hostname => 'vbw16',
    :os => 'windows',
    :box => 'StefanScherer/windows_2016',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  }, 
  :vbw10 => {
    :hostname => 'vbw10',
    :os => 'windows',
    :box => 'StefanScherer/windows_10',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => true
  },
  :vbso => {
    :hostname => 'vbso',
    :os => 'linux',
    :box => 'generic/ubuntu1604',
    :v_cpu => '4',
    :v_mem => '2048',
    :reboot_after_up => false
  }
}

VAGRANTFILE_API_VERSION = '2'
VM_USERNAME = 'vagrant'
VM_PASSWORD = 'vagrant'
SMB_USERNAME = 'vagrantmount'
SMB_PASSWORD = '3zL4h3Ntt7QePw3oqqsKQp8gQm'
HYPERV_SWITCH ='Default Switch'
TIMEZONE = 'Eastern Standard Time'
VAGRANT_MOUNTPOINT = '/vagrant'
TEMP = 'C:/tmp'
SALTSTACK_VERSION = '2019.2.3'
# SALTSTACK_LOG_LEVEL: ( quiet | critical | error | warning | info | profile | debug | trace | garbage | all )
SALTSTACK_LOG_LEVEL = LOG_LEVEL
SALTSTACK_VERBOSE = 'true'
# SALTSTACK_PYTHON_VERSION: ( 2 | 3 )
SALTSTACK_PYTHON_VERSION = '2'
SMB_HOST = ''

# Install missing plugins
# vagrant-guest_ansible vagrant-ansible-local vagrant-winrm-syncedfolders vagrant-reload vagrant-vbguest
required_plugins = ['vagrant-hostmanager', 'vagrant-timezone', 'vagrant-vbguest']
if Vagrant::Util::Platform.linux?
  required_plugins << 'vagrant-winrm'
end
plugin_installed = false
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system 'vagrant plugin install #{plugin}'
    plugin_installed = true
  end
end
if plugin_installed === true
  exec "vagrant #{ARGV.join' '}"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |global_config|
  virtual_machines.each_pair do |name, options|
    global_config.vm.define name do |config|
      config.vm.guest = options[:os]
      config.vm.box = options[:box]
        # https://www.vagrantup.com/docs/provisioning/salt.html
      if options[:os] == 'windows'
        config.vm.hostname = options[:hostname]
        config.vm.communicator = 'winrm'
        config.windows.halt_timeout = 15
        config.winrm.username = VM_USERNAME
        config.winrm.password = VM_PASSWORD
        # config.vm.network :forwarded_port, guest: 3389, host: rdp_port
        # config.vm.network :forwarded_port, guest: 5985, host: winrm_port
        if Vagrant.has_plugin?('vagrant-timezone')
          config.timezone.value = TIMEZONE
        end
      elsif options[:os] == 'linux'
        config.vm.communicator = 'ssh'
        config.ssh.username = VM_USERNAME
        config.ssh.password = VM_PASSWORD
        if ARGV[0] == 'up' or ARGV[0] == 'reload'
          # vagrant reload [vm] --provision
          if SALTSTACK_PYTHON_VERSION == '3'
            config.vm.provision 'shell', inline: 'sudo apt-get update && sudo apt-get install python3-pygit2 python3-git -y'
          else
            config.vm.provision 'shell', inline: 'sudo apt-get update && sudo apt-get install python-pygit2 python-git -y'
          end
        end
      end
      
      if Vagrant::Util::Platform.windows_hyperv_enabled? then
        config.vm.provider 'hyperv' do |h|
          h.vmname = options[:hostname]
          h.cpus = options[:v_cpu]
          h.maxmemory = options[:v_mem]
        end
      else
        config.vm.provider 'virtualbox' do |v, override|
          v.name = options[:hostname]
          v.customize ['modifyvm', :id, '--memory', options[:v_mem]]
          v.customize ['modifyvm', :id, '--cpus', options[:v_cpu]]
        end
      end
      if ARGV[0] == 'up' or ARGV[0] == 'reload'
        if config.vm.provider :hyperv
          global_config.vm.network 'private_network', bridge: HYPERV_SWITCH, auto_config: true, use_dhcp_assigned_default_route: true, disabled: false
          SMB_HOST = `powershell -command "Get-NetIPAddress | where {($_.InterfaceAlias -Contains 'vEthernet (Default Switch)') -and ($_.AddressFamily -eq 'IPv4')} | select -expandproperty IPAddress | Write-Host -NoNewline"`
        else
          global_config.vm.network 'private_network'
          SMB_HOST = `powershell -command "Get-NetIPAddress | where {($_.InterfaceAlias -Contains 'VirtualBox Host-Only Network') -and ($_.AddressFamily -eq 'IPv4')} | select -expandproperty IPAddress | Write-Host -NoNewline"`
        end
      end

      config.vm.provision :salt do |salt|
        salt.version = SALTSTACK_VERSION
        salt.masterless = true
        salt.minion_config = "salt/minion-#{options[:os]}"
        salt.run_highstate = true
        salt.run_service = false
        salt.verbose = SALTSTACK_VERBOSE
        salt.always_install = false
        salt.colorize = true
        salt.log_level = SALTSTACK_LOG_LEVEL
        # salt.install_type: (stable | git | daily | testing) 
        salt.install_type = 'stable'
        salt.python_version = SALTSTACK_PYTHON_VERSION
        if SALTSTACK_PYTHON_VERSION == '3'
          salt.bootstrap_options = '-x python3'
        end
      end
      # handling with salt
      # if options[:reboot_after_up]
      #   #config.vm.provision :reload
      #   config.trigger.after [:up] do |t|
      #     t.name = 'Reboot after provisioning'
      #     t.run = {:inline => "vagrant reload #{options[:hostname]}" }
      #   end
      # end
    end
  end

  if Vagrant::Util::Platform.windows?
    global_config.vm.synced_folder '.', VAGRANT_MOUNTPOINT, type: 'smb', smb_host: SMB_HOST, smb_username: SMB_USERNAME, smb_password:SMB_PASSWORD, mount_options: ["username=#{SMB_USERNAME}", "password=#{SMB_PASSWORD}"]
    global_config.vm.synced_folder './salt/roots/salt/', '/srv/salt', type: 'smb', smb_host: SMB_HOST, smb_username: SMB_USERNAME, smb_password:SMB_PASSWORD, mount_options: ["username=#{SMB_USERNAME}", "password=#{SMB_PASSWORD}"]
    global_config.vm.synced_folder './salt/roots/pillar', '/srv/pillar', type: 'smb', smb_host: SMB_HOST, smb_username: SMB_USERNAME, smb_password:SMB_PASSWORD, mount_options: ["username=#{SMB_USERNAME}", "password=#{SMB_PASSWORD}"]
  elsif Vagrant::Util::Platform.linux?
    global_config.vm.synced_folder '.', VAGRANT_MOUNTPOINT
    global_config.vm.synced_folder './salt/roots/salt/', '/srv/salt'
    global_config.vm.synced_folder './salt/roots/pillar', '/srv/pillar'
    global_config.vm.allowed_synced_folder_types = [:rsync]
  end

  # clear-host; C:\salt\salt-call.bat state.highstate --retcode-passthrough --local --log-level=debug
  if Vagrant::Util::Platform.windows_hyperv_enabled?
    global_config.vm.provider 'hyperv' do |h|
      h.enable_virtualization_extensions = true
      h.linked_clone = true
      h.vm_integration_services = {
        guest_service_interface: true,
        heartbeat: true,
        key_value_pair_exchange: true,
        shutdown: true,
        time_synchronization: true,
        vss: true
      }
    end
  else
    global_config.vm.provider 'virtualbox' do |v, _override|
      v.gui = true
      v.linked_clone = true
      v.customize ['modifyvm', :id, '--vram', 128]
      v.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
      v.customize ['setextradata', 'global', 'GUI/SuppressMessages', 'all']
      v.customize ['modifyvm', :id, '--uartmode1', 'disconnected']
    end
  end
  # https://github.com/devopsgroup-io/vagrant-hostmanager
  if Vagrant.has_plugin?('vagrant-hostmanager')
    global_config.hostmanager.enabled = true
    global_config.hostmanager.manage_host = true
    global_config.hostmanager.manage_guest = true
    global_config.hostmanager.ignore_private_ip = false
    global_config.hostmanager.include_offline = true
  end
end
