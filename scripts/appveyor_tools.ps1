[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope = 'Function', Target = 'install_chefdk')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope = 'Function', Target = 'run_rdp_script')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope = 'Function', Target = 'run_rdp_script')]

Param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [ValidateSet('sysinfo', 'submit', 'setup', 'uninstall')]
  [String[]]
  $function,

  [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [ValidateSet('test-kitchen', 'rdp', 'apps-saltstack-will-install')]
  [String[]]
  $program,

  [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [ValidateSet('inspec_tests')]
  [String[]]
  $results

  # [Parameter(Mandatory=$false, ParameterSetName='Installers')]
  # # [Parameter(Mandatory=$false, ParameterSetName='User')]
  # [Switch]
  # $program
)
switch ($function) {
  sysinfo {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Screen]::AllScreens
    [System.Windows.Forms.SystemInformation]::ScreenOrientation
    [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
    Get-ChildItem Env: | Sort Name
    Get-Package -Provider Programs -IncludeWindowsInstaller | Sort Name
    Get-CimInstance Win32_OperatingSystem | Format-List * | Out-String -Stream | Sort-Object
    $PSVersionTable | Sort Name
    ; Break
  }
  submit {
    switch ($results) {
      inspec_tests {
        $inspec_results = '.\test\results\appveyor-windows.xml'
        # $wc = New-Object 'System.Net.WebClient'
        # $url = "https://ci.appveyor.com/api/testresults/junit/$($env:APPVEYOR_JOB_ID)"
        # $wc.UploadFile($url, (Resolve-Path .\test\results\$env:local_kitchen_suite_platform.xml))
        if (Test-Path $inspec_results -PathType Leaf) {
          ((Get-Content -path $inspec_results -Raw) -replace 'default', 'InSpec') | Set-Content -Path $inspec_results
          # upload results to AppVeyor
          $wc = New-Object 'System.Net.WebClient'
          $url = "https://ci.appveyor.com/api/testresults/junit/$($env:APPVEYOR_JOB_ID)"
          $wc.UploadFile($url, (Resolve-Path $inspec_results))
          # Get-Content -path $inspec_results
        }
        else {
          # dir c:\projects\windows-formula\test\results
          dir .\test\results\
        }
        ; Break
      }
    }
  }
  setup {
    switch ($program) {
      test-kitchen {
        function install_chefdk {
          (& cmd /c); iex (irm https://omnitruck.chef.io/install.ps1); Install-Project -Project chefdk -channel stable -version 4.7.73
        }

        $env:machine_user = 'vagrant'
        $env:machine_pass = 'vagrant'
        $env:KITCHEN_LOCAL_YAML = '.kitchen.appveyor.yml'
        $env:CHEF_LICENSE = 'accept'
        install_chefdk
        c:\opscode\chefdk\bin\chef.bat exec ruby --version
        secedit /export /cfg $env:temp/export.cfg
        ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) |
        Out-File $env:temp/export.cfg
        ((get-content $env:temp/export.cfg) -replace ('MinimumPasswordLength = 8', 'MinimumPasswordLength = 0')) |
        Out-File $env:temp/export.cfg
        secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
        net user /add $env:machine_user $env:machine_pass
        net localgroup administrators $env:machine_user /add
        ; Break
      }

      rdp {
        function run_rdp_script {
          $blockRdp = $true
          iex ((new-object net.webclient).DownloadString($dlstring))
        }
        $env:APPVEYOR_RDP_PASSWORD = 'lj=adf89ASD0098_sd!fwe!==HUI'
        $dlstring = 'https://raw.githubusercontent.com/appveyor/ci/master/scripts/enable-rdp.ps1'
        run_rdp_script
        ; Break
      }
    }
    ; Break
  }
  uninstall {
    switch ($program) {
      apps-saltstack-will-install {
        # Need to uninstall git and 7-zip to test installation using saltstack
        #
        # section sourced from: https://github.com/Limech/git-powershell-silent-install/blob/master/git-silent-uninstall.ps1

        $allPrograms = New-Object System.Collections.Generic.HashSet[String]
        $allProgramsUninstallers = New-Object System.Collections.Generic.HashSet[String]
        $possibleInstalledPaths = @(
          'C:\Program Files\Git\',
          'C:\Program Files (x64)\Git\',
          'c:\git\',
          'C:\Program Files\Git LFS\',
          'C:\Program Files\7-Zip\')

        foreach ($installPath in $possibleInstalledPaths) {
          if ($installPath -like '*Git*') {
            $program_name = 'Git'
          }
          elseif ($installPath -like '*7-Zip*') {
            $program_name = '7-Zip'
          }
          $allPrograms.Add($program_name)

          if (Test-Path($installPath)) {
            $allProgramsUninstallers.Add($program_name)
            # write-output "Current set of uninstallers: $allProgramsUninstallers"
            ## Some Git stuff might be running.. kill them.
            if ($program_name -eq 'Git') {
              Stop-Process -processname Bash -erroraction 'silentlycontinue'
              Stop-Process -processname Putty* -erroraction 'silentlycontinue'
            }

            $uninstallers = Get-ChildItem $installPath'\unins*.exe'
            foreach ($uninstaller in $uninstallers) {
              $uninstallerCommandLineOptions = '/SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /S'
              Start-Process -Wait -FilePath $uninstaller -ArgumentList $uninstallerCommandLineOptions
            }

            if (Test-Path($installPath)) {
              Remove-Item -Recurse -Force $installPath
            }
          }
        }

        $allProgramsUninstallers.SymmetricExceptWith($allPrograms)
        foreach ($installed_program in $allProgramsUninstallers) {
          write-Output "No uninstallers found for $installed_program."
        }

        foreach ($installed_program in $allPrograms) {
          $confirmation = Get-Package -Provider Programs -IncludeWindowsInstaller -Name "$installed_program*" -ErrorAction:SilentlyContinue
          if ($confirmation) {
            $host.SetShouldExit($LastExitCode)
            # Write-Output $confirmation
            throw "$installed_program not uninstalled"
          }
          else {
            Write-Output "All $installed_program instances successfully uninstalled"
          }
        }
        ; Break
      }
    }
    ; Break
  }
}
