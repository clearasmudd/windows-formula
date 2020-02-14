# Need to uninstall git and 7-zip to test installation using saltstack
#
# section sourced from: https://github.com/Limech/git-powershell-silent-install/blob/master/git-silent-uninstall.ps1
## There can be many places where git could have been installed.  Check likely places.
### List of likely places where Git could be
$possibleInstalledPaths = @("C:\Program Files\Git\", "C:\Program Files (x64)\Git\", "c:\git\", "C:\Program Files\Git LFS\", "C:\Program Files\7-Zip\")

$foundAnInstallation = $false
### For all places where Git "could" be.
foreach ($installPath in $possibleInstalledPaths)
{
  ### If the path where Git could be exists
  if (Test-Path($installPath))
  {
    ## Some Git stuff might be running.. kill them.
    Stop-Process -processname Bash -erroraction 'silentlycontinue'
    Stop-Process -processname Putty* -erroraction 'silentlycontinue'
    $foundAnInstallation = $true
    Write-Output "Removing Git from " $installPath
    ### Find if there's an uninstaller in the folder.
    $uninstallers = Get-ChildItem $installPath"\unins*.exe"
    ### In reality, there should only be just one that matches.
    foreach ($uninstaller in $uninstallers)
    {
      ### Invoke the uninstaller.
      $uninstallerCommandLineOptions = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /FORCECLOSEAPPLICATIONS /S"
      Start-Process -Wait -FilePath $uninstaller -ArgumentList $uninstallerCommandLineOptions
    }
    ### Remove the folder if it didn't clean up properly.
    if (Test-Path($installPath))
    {
      Remove-Item -Recurse -Force $installPath
    }
  }
}
# Add confirmation
if (!($foundAnInstallation))
{
   Write-Output "No installation found. Nothing to uninstall"
}
else
{
  if ($installPath -like '*Git*')
  {
    $program_name = 'Git'
  }
  elseif ($installPath -like '*7-Zip*')
  {
    $program_name = '7-Zip'
  }
  $confirmation = Get-Package -Provider Programs -IncludeWindowsInstaller -Name "$program_name*" -ErrorAction:SilentlyContinue
  if ($confirmation)
  {
    $host.SetShouldExit($LastExitCode)
    Write-Output $confirmation
    throw "$program_name not uninstalled"
  }
  else
  {
    Write-Output "All $program_name instances successfully uninstalled"
  }
}

# # - ps: Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty |
# # Where-Object {$_.DisplayName -match "7-Zip"} | Select-Object -Property DisplayName, UninstallString
# if (Test-Path "C:\Program Files\7-Zip\Uninstall.exe" -PathType Leaf)
# {
#   write-host "Removing 7-Zip from C:\Program Files\7-Zip\";
#   start-process -FilePath "C:\Program Files\7-Zip\Uninstall.exe" -ArgumentList "/S"
# }
