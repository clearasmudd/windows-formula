$Config = @{
    AllNodes = @(
        @{ NodeName = 'localhost'; PSDscAllowPlainTextPassword = $True }
    )
}
# https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
$User = "Admin"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($WIN10DSC_USER_ADMIN_PASSWORD | ConvertTo-SecureString)

Configuration Win10DSC
{
    Param
    (
        [String[]]$Node='localhost',
        [PSCredential]$Cred
    )
    #Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName cChoco
    #Import-DscResource -ModuleName PSDesiredStateConfiguration -Name 'File'
    
    $ChocoPackages = "notepadplusplus", "ConEmu", "GoogleChrome", "vscode", `
    "putty.install","sysinternals", "python", "vim"

    # "windirstat", "awscli", "awstools.powershell", "pycharm-community", "7zip.install",  "nodejs.install", "yarn", "chromium","winscp", "wireshark", "windows-adk", "sourcetree", "pdfcreator", "kdiff3", "nmap"
    #, "teamviewer", "gimp", "ruby", "dropbox", "firefox", "virtualbox", "nssm", "golang", 
    # "office365business", "office365proplus", "octopus", "spotify", "microsoft-teams.install", "audacity", "openvpn"
    # ,"googledrive", "evernote", "terraform", "rufus", "pgadmin3", "nmap", "googleearth", "lastpass", "eclipse", 
    # "dbeaver", "packer", "beyondcompare", "mobaxterm", "selenium-chrome-driver", "rsat", "unixutils", "saltminion", 
    # "ossec-agent", "sonos-controller", "goodsync", "kindle", "selenium", "rdmfree", "onenote", "icloud", 
    # "ubiquiti-unifi-controller", "lessmsi", "postman",  "squid", "visioviewer", "amazon-workspaces"

    # "xmind", "freemind", "thebrain.install", "freeplane", "thebrain.install"
   
    $WindowsFeatures = "TelnetClient"

    Node $Node
    {
        ForEach($Feature in $WindowsFeatures)
        {
            WindowsOptionalFeature $Feature
            {
                Name      = $Feature
                # Ensure    = 'Enable'
                Ensure    = 'Present'
                LogLevel  = 'ErrorsAndWarningAndInformation'
            }
        }
        User 'LocalAdmin'
        {
            Username = 'DSCAdmin'
            Description = 'DSC configuration test'
            Ensure = 'Present'
            FullName = 'Administrator Extraordinaire'
            Password = $Cred
            PasswordChangeRequired = $False
            PasswordNeverExpires = $True
        }
        Group 'AddToAdmin'
        {
            GroupName = 'Administrators'
            DependsOn = '[User]LocalAdmin'
            Ensure = 'Present'
            MembersToInclude = 'DSCAdmin'
        }
        User 'Administrator'
        {
            Username = 'Administrator'
            Disabled = $True
        }
        User 'Guest'
        {
            Username = 'Guest'
            Disabled = $True
        }
        User 'DefaultAccount'
        {
            Username = 'DefaultAccount'
            Disabled = $True
        }
        #DestinationPath = "$env:HOMEDRIVE\Software"
        DestinationPath = "${env:HOMEDRIVE}\Software\readme.txt"
        File FileDemo {
            Type            = 'Directory'
            DestinationPath = "c:\Software"
            Ensure          = 'Present'
        }
        File HelloWorld {
            DestinationPath = "c:\Software\readme.txt"
            Ensure          = "Present"
            Contents        = "test from DSC!"
        }
        # https://github.com/chocolatey/cChoco/blob/development/ExampleConfig.ps1
        cChocoinstaller installChoco {
            InstallDir = "${env:HOMEDRIVE}\Choco"
        }
        cChocoFeature allowGlobalConfirmation {
            FeatureName = "allowGlobalConfirmation"
            Ensure      = 'Present'
        }
        cChocoFeature powershellHost {
            FeatureName = "powershellHost"
            Ensure      = 'Absent'
        }
        cChocoFeature showDownloadProgress {
            FeatureName = "showDownloadProgress"
            Ensure      = 'Absent'
        }
        ForEach($Package in $ChocoPackages)
        {
            CChocoPackageInstaller $Package
            {
                Name      = $Package
                Ensure    = 'Present'
                DependsOn = "[cChocoInstaller]installChoco"
            }
        }
        CChocoPackageInstaller git.install {
            Ensure    = 'Present'
            Name      = 'git.install'
            Params    = "/GitAndUnixToolsOnPath /NoGitLfs /SChannel /NoAutoCrlf"
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }
}
        # $out = Get-DscResource | Where-Object {$_.ModuleName -eq 'PSDscResources'}
        # if ($out -ne $null) { $Ensure_setting = 'Present'} else {$Ensure_setting = 'Enable'}
# $LCM = Get-DscLocalConfigurationManager
# $LCM.DebugMode
# Enable-DscDebug -BreakAll
Set-Location   "${env:HOMEDRIVE}/DSC/"
Win10DSC -Cred $Credential -Node 'localhost' -ConfigurationData $Config -WarningAction SilentlyContinue -WarningVariable +buildWarnings
ForEach ($warn in $buildWarnings)
{
    if (!($warn -Match "PSDesiredStateConfiguration")) {Write-Warning ${warn}}
}
# Win10DSC
# Start-DscConfiguration -ComputerName 'localhost' -Wait -Force -Verbose -Path '.\Win10DSC'