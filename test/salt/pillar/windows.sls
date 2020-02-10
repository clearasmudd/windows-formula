# -*- coding: utf-8 -*-
# vim: ft=yaml
---
windows:
  states:
    enabled: false
    system:
      computer_desc:
        id: description
        enabled: true
        name: "Saltstack Computer Description"
        require:
          - windows.state.system.hostname.saltstack1
      hostname:
        name: "saltstack1"
    timezone:
      system:
        name: America/New_York
        utc: false
    wua:
      # settings:
      #   enabled: true
      #   level: 4
      #   recommended: true
      #   featured: false
      #   elevated: true
      #   msupdate: true
      #   day: Everyday
      #   time: "01:00"
      uptodate:
        enabled: false
        software: true
        drivers: true
        skip_hidden: false
        skip_mandatory: false
        skip_reboot: false
        categories:
          - Critical Updates
          - Definition Updates
          - Drivers
          - Feature Packs
          - Security Updates
          - Update Rollups
          - Updates
          - Update Rollups
          - Windows Defender
        severities:
          - Critical
          - Important
  modules:
    enabled: true
    system:
      reboot:
        enabled: true
        timeout: 5
        in_seconds: true
        only_on_pending_reboot: true
        wait_for_reboot: false
        onlyif: if /I "%CI%" EQU "True" exit 1
        order: last
    user:
      enabled: true
      current:
        enabled: true
        sam: true
    status:
      uptime:
        enabled: true
        human_readable: true
        require:
          - windows.module.user.current
  system:
    enabled: false
    reboot:
      enabled: false
      timeout_in_seconds: 10
      only_on_pending_reboot: true
    dsc:
      enabled: false
      client:
        root: c:\\DSC\\
      manifest:
        source: c:\\srv\\salt\\os_windows\\files\\dsc\\manifests\\
        configuration: Win10DSC
    user:
      enabled: false
      disable:
        Administrator:
          disable: false
        Guest:
          disable: true
    packages:
      enabled: true
      always_install_latest_version: false
      always_upgrade_to_latest_version: false
      providers:
        enabled: false
        installed:
          NuGet:
      powershell:
        modules:
          enabled: true
          installed:
            PSDscResources:
            cChoco:
      chocolatey:
        enabled: true
        installed:
          notepadplusplus:
          windirstat:
            version: '1.1.2.20161210'
      saltstack:
        enabled: true
        installed:
          git:
            refresh_minion_env_path: true
          7zip:
            version: '18.06.00.0'
            refresh_minion_env_path: false
          kdiff3:
      appx:
        enabled: true
        provisioned:
          uninstalled:
            # Microsoft.3DBuilder:
            # Microsoft.BingWeather:
            # Microsoft.DesktopAppInstaller:
            # Microsoft.Getstarted:
            # Microsoft.Messaging:
            # Microsoft.Microsoft3DViewer:
            # Microsoft.MicrosoftOfficeHub:
            Microsoft.MicrosoftSolitaireCollection:
            # Microsoft.MicrosoftStickyNotes:
            # Microsoft.MSPaint:
            # Microsoft.Office.OneNote:
            # Microsoft.OneConnect:
            # Microsoft.People:
            # Microsoft.SkypeApp:
            # Microsoft.StorePurchaseApp:
            Microsoft.Wallet:
            # Microsoft.Windows.Photos:
            # Microsoft.WindowsAlarms:
            # Microsoft.WindowsCalculator:
            # Microsoft.WindowsCamera:
            # microsoft.windowscommunicationsapps:
            # Microsoft.WindowsFeedbackHub:
            # Microsoft.WindowsMaps:
            # Microsoft.WindowsSoundRecorder:
            # Microsoft.WindowsStore:
            # Microsoft.XboxApp:
            # Microsoft.XboxGameOverlay:
            # Microsoft.XboxIdentityProvider:
            # Microsoft.XboxSpeechToTextOverlay:
            Microsoft.ZuneMusic:
            Microsoft.ZuneVideo:
            # Microsoft.GetHelp:
            # Microsoft.Print3D:
            # Microsoft.Xbox.TCUI:
            # Microsoft.WebMediaExtensions:
            # Microsoft.XboxGamingOverlay:
            # Microsoft.HEIFImageExtension:
            Microsoft.MixedReality.Portal:
            # Microsoft.ScreenSketch:
            # Microsoft.VP9VideoExtensions:
            # Microsoft.WebpImageExtension:
            # Microsoft.YourPhone:
    server:
      enabled: true
      features:
        enabled: true
        installed:
          telnet-client:
    desktop:
      enabled: true
      optional_features:
        enabled: true
        installed:
          # Client-DeviceLockdown:
          # Client-EmbeddedBootExp:
          # Client-EmbeddedLogon:
          # Client-EmbeddedShellLauncher:
          # ClientForNFS-Infrastructure:
          # Client-KeyboardFilter:
          # Client-ProjFS:
          # Client-UnifiedWriteFilter:
          # Containers:
          # Containers-DisposableClientVM:
          # DataCenterBridging:
          # DirectoryServices-ADAM-Client:
          # DirectPlay:
          # FaxServicesClientPackage:
          # HostGuardian:
          # HypervisorPlatform:
          # IIS-ApplicationDevelopment:
          # IIS-ApplicationInit:
          # IIS-ASP:
          # IIS-ASPNET:
          # IIS-ASPNET45:
          # IIS-BasicAuthentication:
          # IIS-CertProvider:
          # IIS-CGI:
          # IIS-ClientCertificateMappingAuthentication:
          # IIS-CommonHttpFeatures:
          # IIS-CustomLogging:
          # IIS-DefaultDocument:
          # IIS-DigestAuthentication:
          # IIS-DirectoryBrowsing:
          # IIS-FTPExtensibility:
          # IIS-FTPServer:
          # IIS-FTPSvc:
          # IIS-HealthAndDiagnostics:
          # IIS-HostableWebCore:
          # IIS-HttpCompressionDynamic:
          # IIS-HttpCompressionStatic:
          # IIS-HttpErrors:
          # IIS-HttpLogging:
          # IIS-HttpRedirect:
          # IIS-HttpTracing:
          # IIS-IIS6ManagementCompatibility:
          # IIS-IISCertificateMappingAuthentication:
          # IIS-IPSecurity:
          # IIS-ISAPIExtensions:
          # IIS-ISAPIFilter:
          # IIS-LegacyScripts:
          # IIS-LegacySnapIn:
          # IIS-LoggingLibraries:
          # IIS-ManagementConsole:
          # IIS-ManagementScriptingTools:
          # IIS-ManagementService:
          # IIS-Metabase:
          # IIS-NetFxExtensibility:
          # IIS-NetFxExtensibility45:
          # IIS-ODBCLogging:
          # IIS-Performance:
          # IIS-RequestFiltering:
          # IIS-RequestMonitor:
          # IIS-Security:
          # IIS-ServerSideIncludes:
          # IIS-StaticContent:
          # IIS-URLAuthorization:
          # IIS-WebDAV:
          # IIS-WebServer:
          # IIS-WebServerManagementTools:
          # IIS-WebServerRole:
          # IIS-WebSockets:
          # IIS-WindowsAuthentication:
          # IIS-WMICompatibility:
          # Internet-Explorer-Optional-amd64:
          # LegacyComponents:
          # MediaPlayback:
          # Microsoft-Hyper-V:
          # Microsoft-Hyper-V-All:
          # Microsoft-Hyper-V-Hypervisor:
          # Microsoft-Hyper-V-Management-Clients:
          # Microsoft-Hyper-V-Management-PowerShell:
          # Microsoft-Hyper-V-Services:
          # Microsoft-Hyper-V-Tools-All:
          # Microsoft-Windows-Client-EmbeddedExp-Package:
          # Microsoft-Windows-NetFx3-OC-Package:
          # Microsoft-Windows-NetFx3-WCF-OC-Package:
          # Microsoft-Windows-NetFx4-US-OC-Package:
          # Microsoft-Windows-NetFx4-WCF-US-OC-Package:
          # MicrosoftWindowsPowerShellV2:
          # MicrosoftWindowsPowerShellV2Root:
          # Microsoft-Windows-Subsystem-Linux:
          # MSMQ-ADIntegration:
          # MSMQ-Container:
          # MSMQ-DCOMProxy:
          # MSMQ-HTTP:
          # MSMQ-Multicast:
          # MSMQ-Server:
          # MSMQ-Triggers:
          # MSRDC-Infrastructure:
          # MultiPoint-Connector:
          # MultiPoint-Connector-Services:
          # MultiPoint-Tools:
          # NetFx3:
          # NetFx4-AdvSrvs:
          # NetFx4Extended-ASPNET45:
          # NFS-Administration:
          # Printing-Foundation-Features:
          # Printing-Foundation-InternetPrinting-Client:
          # Printing-Foundation-LPDPrintService:
          # Printing-Foundation-LPRPortMonitor:
          # Printing-PrintToPDFServices-Features:
          # Printing-XPSServices-Features:
          # SearchEngine-Client-Package:
          # ServicesForNFS-ClientOnly:
          # SimpleTCP:
          # SMB1Protocol:
          # SMB1Protocol-Client:
          # SMB1Protocol-Deprecation:
          # SMB1Protocol-Server:
          # SmbDirect:
          TelnetClient:
          # TFTP:
          # TIFFIFilter:
          # VirtualMachinePlatform:
          # WAS-ConfigurationAPI:
          # WAS-NetFxEnvironment:
          # WAS-ProcessModel:
          # WAS-WindowsActivationService:
          # WCF-HTTP-Activation:
          # WCF-HTTP-Activation45:
          # WCF-MSMQ-Activation45:
          # WCF-NonHTTP-Activation:
          # WCF-Pipe-Activation45:
          # WCF-Services45:
          # WCF-TCP-Activation45:
          # WCF-TCP-PortSharing45:
          # Windows-Defender-ApplicationGuard:
          # Windows-Defender-Default-Definitions:
          # Windows-Identity-Foundation:
          # WindowsMediaPlayer:
          # WorkFolders-Client:
      packages:
        enabled: true
  system_old:
    enabled: true
    timezone: America/New_York
    computer:
      enabled: true
      hostname: "saltstack1"
      description: "Saltstack Computer Description"
    wua:
      enabled: true
      settings:
        enabled: true
        level: 4
        recommended: true
        featured: false
        elevated: true
        msupdate: true
        day: Everyday
        time: "01:00"
      uptodate:
        enabled: true
        only_initial_build: true
        software: true
        drivers: true
        skip_hidden: false
        skip_mandatory: false
        skip_reboot: false
        categories:
          - Critical Updates
          - Definition Updates
          - Drivers
          - Feature Packs
          - Security Updates
          - Update Rollups
          - Updates
          - Update Rollups
          - Windows Defender
        severities:
          - Critical
          - Important
    user:
      enabled: false
      create:
        saltuser1:
          enabled: true
          password: P@55w0rd!
          fullname: User1 SaltStack
          description: SaltStack User1
          home: \\fileserver\home\foo
          homedrive: "c:"
          profile: \\fileserver\profiles\foo
          logonscript: logonscript.ps1
          groups:
            - Power Users
            - saltstack_users
          # update
          expiration_date: None
          expired: None
          account_disabled: false
          unlock_account: true
          password_never_expires: false
          disallow_change_password: false
        saltadmin1:
          enabled: false
          password: P@55w0rd!
          fullname: Admin1 SaltStack
          description: SaltStack Admin1
          home: \\fileserver\home\foo
          homedrive: "c:"
          profile: \\fileserver\profiles\foo
          logonscript: logonscript.ps1
          groups:
            - Administrators
            - saltstack_administrators
          # update
          expiration_date: None
          expired: None
          account_disabled: false
          unlock_account: true
          password_never_expires: false
          disallow_change_password: false
