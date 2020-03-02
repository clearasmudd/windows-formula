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
# Reference: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.timezone.html

require 'helpers'
require 'open-uri'

class WindowsTimezone < Inspec.resource(1)
  name 'windows_timezone'
  supports platform: 'windows'
  desc 'Use the windows_timezone InSpec audit resource to test the saltstack linux style timezone is set on Microsoft Windows.'
  example <<~EXAMPLE
    describe windows_timezone('America/New_York') do
      it { should be_set }
    end
  EXAMPLE

  def initialize(desired_timezone_linux)
    @desired_timezone_linux = desired_timezone_linux
    @desired_timezone_windows = lookup_windows_timezone(@desired_timezone_linux)
    return skip_resource "The `windows_timezone` resource is not supported on your OS." unless inspec.os.windows?
  end

  def set?
    @current_timezone_windows = get_current_timezone
    return @desired_timezone_windows == @current_timezone_windows
  end

  def to_s
    # "Timezone: #{@desired_timezone_linux} (linux) converted to #{@desired_timezone_windows} (windows)"
    "`#{@desired_timezone_windows}` timezone (converted from #{@desired_timezone_linux})"
  end  

  private

  def lookup_windows_timezone(linux_timezone)
    return @cache_windows_timezone if defined?(@cache_windows_timezone)

    file_url = 'https://raw.githubusercontent.com/saltstack/salt/master/salt/modules/win_timezone.py'
    file_local = 'test/integration/util/win_timezone.py'
    file_content = ''
    begin
      file_content = (open(file_url) {|f| f.read })
    rescue
      begin
        if File.file?(file_local)
          file_content = File.open(file_local)  
        end
      end
    end
    unless file_content.empty?
      file_content.each_line do |line|
        if line.match(linux_timezone)
          # example: "    'Eastern Standard Time': 'America/New_York',"
          @cache_windows_timezone = line.match(/'(.*)': '/).captures[0]
        end
      end
    end
    return @cache_windows_timezone
  end

  def get_current_timezone
    return @cache_current_timezone if defined?(@cache_current_timezone)
    ps_cmd = "Get-TimeZone | Select Id -ExpandProperty Id"
    cmd = inspec.command(ps_cmd)
    @cache_current_timezone = cmd.stdout.strip
    return @cache_current_timezone
  end

end

# require 'train'

# https://docs.saltstack.com/en/latest/ref/states/all/salt.states.timezone.html

# require 'pry'
# binding.pry
# https://github.com/inspec/train

# pillar_file = backend.file('c:\temp\p.txt').content
# puts pillar_file

# pillar = YAML.safe_load(pillar_file)
# puts "pillar: " + pillar['local']
# puts pillar['local']['windows']['states']

# if pillar['local']['windows']['states']
#   puts pillar['local']['windows']['states']['timezone']['system']['name']
#   puts pillar['local']['windows']['states']['system']['hostname']['name']
# end

# ps_cmd = 'c:\salt\salt-call.bat --config-dir=$env:temp\kitchen\etc\salt pillar.items --retcode-passthrough | Select-String -Pattern "----------" -NotMatch'
# pillar = YAML.safe_load(backend::backend.run_command(ps_cmd).stdout)['local']


# computer_timezone_windows = ''
# file_content = ''

# # Convert Linux timezone to windows timezone using saltstack mapping.
# # For example, convert America/New_York to Eastern Standard Time.
# if pillar['windows']['states']['timezone']
#   # example: "    'Eastern Standard Time': 'America/New_York',"
#   file_url = 'https://raw.githubusercontent.com/saltstack/salt/master/salt/modules/win_timezone.py'
#   file_local = 'test/integration/util/win_timezone.py'
#   begin
#     file_content = (open(file_url) {|f| f.read })
#   rescue
#     begin
#       if File.file?(file_local)
#         file_content = File.open(file_local)
#       end
#     end
#   end
#   unless file_content.empty?
#     file_content.each_line do |line|
#       if line.match(pillar['windows']['states']['timezone']['system']['name'])
#         computer_timezone_windows = line.match(/'(.*)': '/).captures[0]
#       end
#     end
#   end
# end

# control 'Computer Timezone' do
#   title ''
#   only_if {
#     !computer_timezone_windows.empty?
#   }
#   impact 1.0
#   ps_cmd = 'Get-TimeZone | Select Id -ExpandProperty Id'
#   describe powershell(ps_cmd) do
#     its('stdout') { should match computer_timezone_windows }
#   end
# end