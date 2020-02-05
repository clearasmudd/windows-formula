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

control 'Windows Features' do
  impact 'critical'
  title 'salt.formula.windows.system.server.features'
  tag 'timezone','saltstack','salt.states.win_servermanager','salt.states.win_servermanager.installed','salt.formula.windows.system.server.features.enabled','configuration management'
  ref 'salt.states.win_servermanager.installed', url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_servermanager.html#salt.states.win_servermanager.installed'
  pillar_server_features = pillar.dig('windows', 'system', 'server', 'features')
  # There is a bug with multiple only_if statements, if any fail it will always report that
  # it `Skipped control due to only_if condition:` for the last only_if statement.
  only_if ("server features is enabled in pillar") do
    !pillar_server_features.nil? and pillar_server_features['enabled']
  end
  only_if ("`installed` key is iterable") do
    pillar_server_features.dig('installed').respond_to? :each
  end
  only_if ("only supported on servers") do
    server?
    # registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? "Server"
  end
  pillar_server_features.dig('installed').each do |feature|
    describe windows_feature(feature[0]) do
      it{ should be_installed }
    end
  end
end

# if pillar['windows']['system']['server']['features']['enabled']
#   control 'Features' do
#     title 'should be installed'
#     only_if {
#       registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? "Server"
#     }
#     pillar['windows']['system']['server']['features']['installed'].each do |feature|
#       describe windows_feature(feature[0]) do
#         it{ should be_installed }
#       end
#     end
#   end
# end