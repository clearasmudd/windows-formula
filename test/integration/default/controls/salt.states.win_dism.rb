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

control 'Windows Optional Features' do
  impact 'critical'
  title 'salt.states.win_dism.feature_installed'
  tag 'optional feature','saltstack','salt.states.win_dism','salt.states.win_dism.feature_installed','configuration management'
  ref 'salt.states.win_dism.feature_installed', url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.win_dism.html#salt.states.win_dism.feature_installed'
  pillar_optional_features = pillar.dig('windows', 'system', 'desktop', 'optional_features')

  only_if ("optional features is enabled in pillar") do
    !pillar_optional_features.nil? and pillar_optional_features['enabled']
  end
  #require 'pry'; binding.pry;
  pillar_optional_features['installed'].each do |optional_feature|
    describe windows_optional_feature(optional_feature[0]) do
      it{ should be_installed }
    end
  end
end

# if pillar['windows']['system']['desktop']['optional_features']['enabled']
#   control 'salt.states.win_dism' do
#     title ''
#     pillar['windows']['system']['desktop']['optional_features']['installed'].each do |optional_feature|
#       describe windows_optional_feature(optional_feature[0]) do
#         it{ should be_installed }
#       end
#     end
#   end
# end

# if pillar['windows']['system']['desktop']['optional_features']['enabled']
#   control 'Optional Features' do
#     title 'should be installed'
#     only_if {
#       !registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? "Server"
#     }
#     pillar['windows']['system']['desktop']['optional_features']['installed'].each do |optional_feature|
#       ps_cmd = "Get-WindowsOptionalFeature -online | Where-Object {($_.FeatureName -eq '#{optional_feature[0]}') -and ($_.State -eq 'Enabled')} | Select FeatureName -ExpandProperty FeatureName"
#       describe powershell(ps_cmd) do
#         its('stdout') { should match optional_feature[0] }
#       end
#     end
#   end
# end