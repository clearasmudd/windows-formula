# frozen_string_literal: true

# https://stackoverflow.com/questions/46591408/disable-virtualbox-guest-additions-for-testkitchen
Vagrant.configure('2') do |config|
  if Vagrant.has_plugin? 'vagrant-vbguest'
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
  end
end
