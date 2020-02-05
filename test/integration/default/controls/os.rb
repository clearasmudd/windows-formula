# frozen_string_literal: true

#   OS Name: windows_10_enterprise_evaluation
#   OS Family: windows
# Verifying <py3-windows-10-1903>
#   OS Family: windows
#   OS Name: windows_10_enterprise_evaluation
#   OS Release: 10.0.18362
#   OS Architecture: x86_64

# puts "OS Family: " + os.family# puts "OS Name: " + os.name
# puts "OS Release: " + os.release
# puts "OS Architecture: " + os.arch

control 'Operating System' do
  title ''
  # only_if {
  #   !registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'].match? "Enterprise"
  # }
  # describe os.family do
  #   it { should eq 'windows' }
  # end
  describe.one do
    describe os.name do
      it { should include 'windows' }
    end
  end

  # describe os.windows? do
  #   it { should eq true }
  # end

  # describe.one do
  #   describe os.release do
  #     it { should include '10.0' }
  #   end
  # end

  # describe.one do
  #   describe os.arch do
  #     it { should eq 'x86_64' }
  #   end
  # end

  # describe registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion') do
  #   its('ProductName') { should_not match 'Server' }
  # end

  # # it { should have_property_value 'value' }
  # describe registry_key('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion')['ProductName'] do
  #   it { should match 'Enterprise' }
  # end
end
