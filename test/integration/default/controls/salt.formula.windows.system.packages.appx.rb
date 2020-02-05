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

control 'Windows AppX Provisioned Package Uninstalled' do
  impact 'critical'
  title 'salt.formula.windows.system.packages.appx.provisioned.uninstalled'
  tag 'timezone', 'saltstack', 'salt.formula.windows.system.packages.appx',
      'salt.formula.windows.system.packages.appx.provisioned.uninstalled',
      'configuration management'
  ref '', url: ''
  pillar_packages_appx = pillar.dig('windows', 'system', 'packages', 'appx')
  # There is a bug with multiple only_if statements, if any fail it will always report that
  # it `Skipped control due to only_if condition:` for the last only_if statement.
  only_if 'appx provisioned is enabled in pillar' do
    !pillar_packages_appx.nil? && pillar_packages_appx['enabled']
  end
  only_if '`uninstalled` key is iterable' do
    pillar_packages_appx.dig('provisioned', 'uninstalled').respond_to? :each
  end
  # require 'pp'; pp
  pillar_packages_appx.dig('provisioned', 'uninstalled').each do |package|
    describe windows_appx(package[0]) do
      it { should_not be_installed }
    end
  end
end

# require 'safe_yaml'
# pillar = YAML.safe_load(File.read('test/salt/pillar/windows.sls'))

# if pillar['windows']['system']['desktop']['packages']['appx']['enabled']
#   control 'AppX Provisioned Applications' do
#     title 'should not be installed'
#     only_if {
#       !registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? "Server"
#     }
#     pillar['windows']['system']['desktop']['packages']['appx']['provisioned']['uninstalled'].each do |package|
#       # ps_cmd = "if (Get-AppxPackage #{package[0]} -eq $null) {exit 1}"
#       ps_cmd = "Get-salt.states.win_dism #{package[0]} | select Name -ExpandProperty Name"
#       describe powershell(ps_cmd) do
#         its('stdout') { should_not match package[0] }
#         # All the following do work
#         # its('strip') { should_not include package[0] }
#         # its('strip') { should_not match package[0] }
#         # its('strip') { should_not cmp package[0] }
#         # its('stdout') { should_not include package[0] }
#         # The following works with the first ps_cmd
#         # its('exit_status') { should eq 1 }
#       end
#     end
#   end
# end
