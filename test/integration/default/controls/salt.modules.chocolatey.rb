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

control 'Chocolatey Installed' do
  impact 'critical'
  title 'salt.modules.chocolatey.bootstrap'
  tag 'chocolatey','saltstack','alt.modules.chocolatey','salt.modules.chocolatey.bootstrap','windows.system.packages.chocolatey','configuration management','application','program'
  ref 'salt.modules.chocolatey.bootstrap', url: 'https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.chocolatey.html#salt.modules.chocolatey.bootstrap'
  #require 'pry'; binding.pry;
  # C:\ProgramData\chocolatey\bin\choco.exe
  pillar_chocolatey = pillar.dig('windows', 'system', 'packages', 'chocolatey')
  only_if ("chocolatey is enabled in pillar") do
    !pillar_chocolatey.nil? and pillar_chocolatey['enabled']
    # !highstate_module_chocolatey_bootstrap.nil?
  end
  describe command('choco') do
    it { should exist }
  end
end