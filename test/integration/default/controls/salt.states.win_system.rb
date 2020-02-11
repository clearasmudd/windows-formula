# frozen_string_literal: true

# Copyright 2020 Peter Mudd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Peter Mudd (https://github.com/muddman)

require_relative '../libraries/helpers'

pillar = get_pillar

# https://www.inspec.io/docs/reference/resources/sys_info/
control 'Windows Computer Hostname' do
  impact 'critical'
  title 'salt.states.win_system.hostname'
  tag 'hostname','saltstack','salt.states.win_system','salt.states.win_system.hostname','configuration management'
  ref 'salt.states.win_system.hostname', url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_system.html#salt.states.win_system.hostname'
  desc 'Check if hostname is set correctly.'
  desc 'If not set correctly check if there is a pending rename to the correct hostname after reboot.'
  pillar_hostname = pillar.dig('windows', 'states', 'system', 'hostname', 'name')
  only_if ("hostname is defined in pillar") do
    !pillar_hostname.nil?
    # and reboot is enabled
    #and pillar.dig('windows', 'modules', 'system', 'reboot', 'enabled')
  end
  # only_if ("Running in CI environment, not able to reboot, skipping test.") do
  #   ENV["CI"] != 'True'
  # end
  #require 'pry'; binding.pry;\
  computername_value = registry_key('HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName')['ComputerName']
  ActiveComputerName_value = registry_key('HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName')['ComputerName']
  # puts "ComputerName: #{computername_value}"
  # puts "ActiveComputerName: #{ActiveComputerName_value}"
  describe.one do
  # if (computername_value == pillar_hostname)
    describe sys_info do
      its('hostname') { should cmp pillar_hostname }
    end
  # elsif (ActiveComputerName_value == pillar_hostname)
    describe registry_key('HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName') do
      its('ComputerName') { should cmp pillar_hostname }
    end 
  end
end

control 'Windows Computer Description' do
  impact 0.6
  title 'salt.states.win_system.computer_desc'
  tag 'computer description','saltstack','salt.states.win_system','salt.states.win_system.computer_desc','configuration management'
  ref 'salt.states.win_system.computer_desc', url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_system.html#salt.states.win_system.computer_desc'
  pillar_computer_description = pillar.dig('windows', 'states', 'system', 'computer_desc', 'name')
  only_if ('computer description is defined in pillar') do
    !pillar_computer_description.nil?
  end
  ps_cmd = "Get-WmiObject -Class Win32_OperatingSystem | Select Description -ExpandProperty description"
  #require 'pry'; binding.pry;
  describe powershell(ps_cmd) do
    its('stdout') { should match pillar_computer_description }
  end
end