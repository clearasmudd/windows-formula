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

control 'Windows Timezone' do
  impact 'critical'
  title 'salt.states.timezone.system'
  tag 'timezone','saltstack','salt.states.timezone','salt.states.timezone.system','configuration management'
  ref 'salt.states.timezone.system', url: 'https://docs.saltstack.com/en/master/ref/states/all/salt.states.timezone.html#salt.states.timezone.system'
  timezone = pillar.dig('windows', 'states', 'timezone', 'system', 'name')
  only_if ("timezone is defined in pillar") do
    !timezone.nil?
  end
  #require 'pry'; binding.pry;
  describe windows_timezone(timezone) do
    it { should be_set }
  end
end