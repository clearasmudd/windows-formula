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
#

require_relative '../libraries/helpers'

pillar = get_pillar

control 'Saltstack Package Installed' do
  impact 'critical'
  title 'windows.system.packages.saltstack.installed'
  tag 'package','saltstack','windows.system.packages.saltstack','windows.system.packages.saltstack.installed','configuration management'
  ref 'salt.states.pkg.installed', url: 'https://docs.saltstack.com/en/latest/ref/states/all/salt.states.pkg.html#salt.states.pkg.installed'
  pillar_packages_saltstack = pillar.dig('windows', 'system', 'packages', 'saltstack')
  # There is a bug with multiple only_if statements, if any fail it will always report that
  # it `Skipped control due to only_if condition:` for the last only_if statement.
  only_if ("saltstack packages are enabled in pillar") do
    !pillar_packages_saltstack.nil? and pillar_packages_saltstack['enabled']
  end
  only_if ("`installed` key is iterable") do
    pillar_packages_saltstack.dig('installed').respond_to? :each
  end
  # require 'pp'; pp
  pillar_packages_saltstack.dig('installed').each do |package|
    describe package(get_saltstack_package_full_name(package[0])) do
      it { should be_installed }
      if package[1].respond_to? :key?
        if package[1].key?('version')
          its('version') { should cmp package[1]['version'] }
        end
      end
    end
  end
end

# require 'safe_yaml'
# require 'open-uri'

# full_names = {}
# pillar = YAML.safe_load(File.read('test/salt/pillar/windows.sls'))
# url = 'https://raw.githubusercontent.com/saltstack/salt-winrepo-ng/master/'

# pillar['windows']['system']['packages']['saltstack']['installed'].each do |package|
#   # example: package = "7zip"=>{"version"=>"18.06.00.0", "refresh_minion_env_path"=>false}
#   files = [package[0] + ".sls", package[0] + "/init.sls"]
#   full_names[package[0]] = files.find do |checkme|
#     ps = "$f = (((Get-ChildItem -Path $env:LOCALAPPDATA -Filter 'salt-winrepo-ng' -Recurse -Directory).Fullname[0]) + '\\#{checkme.sub('/', '\\')}'); if (Test-Path $f -PathType Leaf) {Get-Content -Path $f}"
#     begin
#       file = (open(url + checkme) {|f| f.read })
#     rescue
#       begin
#         file = (powershell(ps).stdout)
#       rescue
#         next
#       end
#     end
#     unless file.nil? or file.empty?
#       candidate = file.match(/full_name: '([\S]+).*'/).captures[0]
#     end
#     break candidate unless candidate.nil?
#   end
# end

# if pillar['windows']['system']['packages']['saltstack']['enabled']
#   control 'Saltstack Packages' do
#     title ''
#     pillar['windows']['system']['packages']['saltstack']['installed'].each do |package|
#       # example: full_names['7zip] = "7-Zip"
#       describe package(full_names[package[0]]) do
#         it { should be_installed }
#         unless package[1].nil?
#           if package[1].key?('version')
#             its('version') { should cmp package[1]['version'] }
#           end
#         end
#       end
#     end
#   end
# end