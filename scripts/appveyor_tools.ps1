
Param(
    [Parameter(Mandatory=$true,
    ParameterSetName="Functions")]
    [String[]]
    $function,

    [Parameter(Mandatory=$false,
    ParameterSetName="User")]
    [String[]]
    $UserName,

    [Parameter(Mandatory=$false, ParameterSetName="Computer")]
    [Parameter(Mandatory=$false, ParameterSetName="User")]
    [Switch]
    $Summary
)


switch ($function)
{
  sysinfo
  {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Screen]::AllScreens
    [System.Windows.Forms.SystemInformation]::ScreenOrientation
    [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
      
    ; Break
  }

  uninstall-apps-for-saltstack-testing
  {
    # Need to uninstall git and 7-zip to test installation using saltstack
    #
    # section sourced from: https://github.com/Limech/git-powershell-silent-install/blob/master/git-silent-uninstall.ps1

    $allPrograms = New-Object System.Collections.Generic.HashSet[String]
    $allProgramsUninstallers = New-Object System.Collections.Generic.HashSet[String]
    $possibleInstalledPaths = @(
      "C:\Program Files\Git\",
      "C:\Program Files (x64)\Git\",
      "c:\git\",
      "C:\Program Files\Git LFS\",
      "C:\Program Files\7-Zip\")

    foreach ($installPath in $possibleInstalledPaths)
    {
      if ($installPath -like '*Git*')
      {
        $program_name = 'Git'
      }
      elseif ($installPath -like '*7-Zip*')
      {
        $program_name = '7-Zip'
      }
      $allPrograms.Add($program_name)

      if (Test-Path($installPath))
      {
        $allProgramsUninstallers.Add($program_name)
        write-output "Current set of uninstallers: $allProgramsUninstallers"
        ## Some Git stuff might be running.. kill them.
        if ($program_name == 'Git')
        {
          Stop-Process -processname Bash -erroraction 'silentlycontinue'
          Stop-Process -processname Putty* -erroraction 'silentlycontinue'
        }

        $uninstallers = Get-ChildItem $installPath"\unins*.exe"
        foreach ($uninstaller in $uninstallers)
        {
          $uninstallerCommandLineOptions = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /S"
          Start-Process -Wait -FilePath $uninstaller -ArgumentList $uninstallerCommandLineOptions
        }

        if (Test-Path($installPath))
        {
          Remove-Item -Recurse -Force $installPath
        }
      }
    }

    $allProgramsUninstallers.SymmetricExceptWith($allPrograms)
    foreach ($program in $allProgramsUninstallers)
    {
      write-Output "No uninstallers found for $program."
    }

    foreach ($program in $allPrograms)
    {
      $confirmation = Get-Package -Provider Programs -IncludeWindowsInstaller -Name "$program*" -ErrorAction:SilentlyContinue
      if ($confirmation)
      {
        $host.SetShouldExit($LastExitCode)
        Write-Output $confirmation
        throw "$program not uninstalled"
      }
      else
      {
        Write-Output "All $program instances successfully uninstalled"
      }
    }
    ; Break
  }
}
