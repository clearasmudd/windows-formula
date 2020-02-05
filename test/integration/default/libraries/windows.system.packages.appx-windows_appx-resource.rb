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

require 'helpers'
require 'open-uri'

# if ((Get-AppxPackage {{ package }} ) -eq $null) {exit 1}
class WindowsAppx < Inspec.resource(1)
  name 'windows_appx'
  supports platform: 'windows'
  desc 'Windows Appx Provisioned Packages.'
  example <<~EXAMPLE
    describe windows_timezone('America/New_York') do
      it { should be_set }
    end
  EXAMPLE

  def initialize(package)
    @package = package

    return skip_resource "The `windows_timezone` resource is not supported on your OS." unless inspec.os.windows?
  end

  def installed?
    return check_appx_package_status == "Ok"
  end

  def to_s
    # "Timezone: #{@desired_timezone_linux} (linux) converted to #{@desired_timezone_windows} (windows)"
    "Windows AppX Provisioned Package `#{@package}`"
  end

  private

  def check_appx_package_status
    return @cache_appx_package_status if defined?(@cache_appx_package_status)
    ps_cmd = "Get-AppxPackage #{@package} | select Status -ExpandProperty Status"
    cmd = inspec.command(ps_cmd)
    if (cmd.exit_status == 0 and cmd.stderr == '')
      @cache_appx_package_status = cmd.stdout.strip
      return @cache_appx_package_status
    else 
      raise "Error performing `#{ps_cmd}` -- exit code #{cmd.exit_status}: #{cmd.stderr}."
    end
  end
end