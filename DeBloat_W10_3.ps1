﻿# Useage: ScriptName.ps1 -Silent True/False -Runtype Debloat/Revert -SystemRestore True/False -ForceReboot True/False -RevertDefaultPDF True/False
param([switch]$Silent, [string]$RunType, [switch]$SystemRestore, [switch]$ForceReboot, [switch]$RevertDefaultPDF)


if (-not ([string]::IsNullOrEmpty($LogPath)))
{

    #If a log path is provided, dump output to a file. If log file exists, it will append to it.
    If (Test-Path $LogPath)
    {
    $ErrorActionPreference="SilentlyContinue"
    Stop-Transcript | out-null
    $ErrorActionPreference = "Continue"
    Start-Transcript -path $LogPath -append
    }
    Else
    {
        Write-Output "The path provided does not yet exist. Please create the path and try again, or try another path."
        Exit;
    }

}


Function Start-Debloat {
    
    [CmdletBinding()]
        
    Param()
    
    #Removes AppxPackages
    Get-AppxPackage -AllUsers | 
        Where-Object {$_.AppxPackage -notlike "*Microsoft.FreshPaint*"} | 
        Where-Object {$_.AppxPackage -notlike "*Microsoft.WindowsCalculator*"} |
        Where-Object {$_.AppxPackage -notlike "*Microsoft.WindowsStore*"} | 
        Where-Object {$_.AppxPackage -notlike "*Microsoft.Windows.Photos*"} |
        Remove-AppxPackage -ErrorAction SilentlyContinue 
        
    #Removes AppxProvisionedPackages
    Get-AppxProvisionedPackage -online |
        Where-Object {$_.AppxProvisionedPackage -notlike "*Microsoft.FreshPaint*"} |
        Where-Object {$_.AppxProvisionedPackage -notlike "*Microsoft.WindowsCalculator*"} |
        Where-Object {$_.AppxProvisionedPackage -notlike "*Microsoft.WindowsStore*"} |
        Where-Object {$_.AppxProvisionedPackage -notlike "*Microsoft.Windows.Photos*"} |
        Remove-AppxProvisionedPackage -online -ErrorAction SilentlyContinue


}
Function Remove-Keys {
    
    [CmdletBinding()]
        
    Param()
    
    #These are the registry keys that it will delete.
        
    $Keys = @(
        
        #Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
        #Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        
        #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
        #Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        
        #Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
           
        #Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
    
    #This writes the output of each key it is removing and also removes the keys listed above.
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
    }
}
        
Function Protect-Privacy {
    
    [CmdletBinding()]
    
    Param()
        
    #Disables Windows Feedback Experience
    Write-Output "Disabling Windows Feedback Experience program"
    If (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo') {
        $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
        Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
    }
        
    #Stops Cortana from being used as part of your Windows Search Function
    Write-Output "Stopping Cortana from being used as part of your Windows Search Function"
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search') {
        $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
        Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
    }
        
    #Stops the Windows Feedback Experience from sending anonymous data
    Write-Output "Stopping the Windows Feedback Experience program"
    If ('HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds') { 
        $Period1 = 'HKCU:\Software\Microsoft\Siuf'
        $Period2 = 'HKCU:\Software\Microsoft\Siuf\Rules'
        $Period3 = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
        mkdir $Period1 -ErrorAction SilentlyContinue
        mkdir $Period2 -ErrorAction SilentlyContinue
        mkdir $Period3 -ErrorAction SilentlyContinue
        New-ItemProperty $Period3 -Name PeriodInNanoSeconds -Value 0 -Verbose -ErrorAction SilentlyContinue
    }
               
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
    #Prevents bloatware applications from returning
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content') {
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
        Mkdir $registryPath -ErrorAction SilentlyContinue
        New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue
    }          
    
    Write-Output "Setting Mixed Reality Portal value to 1 so that you can uninstall it in Settings"
    If ('HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic') {
        $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
        Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 1 -Verbose
    }
    
    #Disables live tiles
    Write-Output "Disabling live tiles"
    If (!(Test-Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications')) {
        mkdir 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications' -ErrorAction SilentlyContinue     
        $Live = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
        New-ItemProperty $Live -Name NoTileApplicationNotification -Value 1 -Verbose
    }
    
    #Turns off Data Collection via the AllowTelemtry key by changing it to 0
    If ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection') {
        $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
        Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 0 -Verbose
    }
    
    #Disables People icon on Taskbar
    Write-Output "Disabling People icon on Taskbar"
    If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People')) {
        mkdir 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' -ErrorAction SilentlyContinue
        $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
        New-ItemProperty $People -Name PeopleBand -Value 0 -Verbose
    }

    #Disables suggestions on start menu
    Write-Output "Disabling suggestions on the Start Menu"
    If ('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager') {
        $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 Verbose
    }
    
    #Disables scheduled tasks that are considered unnecessary 
    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Disable-ScheduledTask
    Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask
    Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask
    Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask
    Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask
    Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask
}
    
Function Stop-EdgePDF {
    
    Write-Output "Stopping Edge from taking over as the default .PDF viewer" 
    #Stops edge from taking over as the default .PDF viewer
    If (!(Get-ItemProperty 'HKCR:\.pdf' -Name NoOpenWith)) {
        $NoOpen = 'HKCR:\.pdf'
        New-ItemProperty $NoOpen -Name NoOpenWith -Verbose -ErrorAction SilentlyContinue
    }
    
    If (!(Get-ItemProperty 'HKCR:\.pdf' -Name NoStaticDefaultVerb)) {
        $NoStatic = 'HKCR:\.pdf'
        New-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose -ErrorAction SilentlyContinue
    }
    
    If (!(Get-ItemProperty 'HKCR:\.pdf\OpenWithProgids' -Name NoOpenWith)) {
        $NoOpen = 'HKCR:\.pdf\OpenWithProgids'
        New-ItemProperty $NoOpen -Name NoOpenWith -Verbose -ErrorAction SilentlyContinue
    }
    
    If (!(Get-ItemProperty 'HKCR:\.pdf\OpenWithProgids' -Name NoStaticDefaultVerb)) {
        $NoStatic = 'HKCR:\.pdf\OpenWithProgids'
        New-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose -ErrorAction SilentlyContinue
    }
    
    If (!(Get-ItemProperty 'HKCR:\.pdf\OpenWithList' -Name NoOpenWith)) {
        $NoOpen = 'HKCR:\.pdf\OpenWithList'
        New-ItemProperty $NoOpen -Name NoOpenWith -Verbose -ErrorAction SilentlyContinue
    }
    
    If (!(Get-ItemProperty 'HKCR:\.pdf\OpenWithList' -Name NoStaticDefaultVerb)) {
        $NoStatic = 'HKCR:\.pdf\OpenWithList'
        New-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose -ErrorAction SilentlyContinue
    }
    
    #Appends an underscore '_' to the Registry key for Edge
    If ('HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723') {
        $Edge = 'HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723'
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_ -Verbose
    }
}
Function Revert-Changes {   
        
    [CmdletBinding()]
        
    Param()
    
    #This function will revert the changes you made when running the Start-Debloat function.
    
    #This line reinstalls all of the bloatware that was removed
    Get-AppxPackage -AllUsers | ForEach {Add-AppxPackage -Verbose -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} -ErrorAction SilentlyContinue
    
    Write-Output "Re-enabling key to show advertisement information"
    #Tells Windows to enable your advertising information.
    If ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo') {
        $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
        Set-ItemProperty $Advertising -Name Enabled -Value 1 -Verbose
    }
        
    #Enables Cortana to be used as part of your Windows Search Function
    Write-Output "Re-enabling Cortana to be used in your Windows Search"
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search') {
        $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
        Set-ItemProperty $Search -Name AllowCortana -Value 1 -Verbose
    }
        
    #Re-enables the Windows Feedback Experience for sending anonymous data
    Write-Output "Re-enabling Windows Feedback Experience"
    If (!('HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds')) { 
        mkdir 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
        $Period = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
        New-Item $Period -ErrorAction SilentlyContinue
        Set-ItemProperty -Name PeriodInNanoSeconds -Value 1 -Verbose
    }
               
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
    #Enables bloatware applications
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content') {
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
        Mkdir $registryPath -ErrorAction SilentlyContinue
        New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 0 -Verbose -ErrorAction SilentlyContinue
    }
    
    #Changes Mixed Reality Portal Key 'FirstRunSucceeded' to 0
    Write-Output "Setting Mixed Reality Portal value to 0"
    If ('HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic') {
        $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
        Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
    }
    
    #Re-enables live tiles
    Write-Output "Enabling live tiles"
    If ('HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications') {
        mkdir 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications' -ErrorAction SilentlyContinue       
        $Live = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
        New-ItemProperty $Live -Name NoTileApplicationNotification -Value 0 -Verbose -ErrorAction SilentlyContinue
    }
           
    Write-Output "Changing the 'Cloud Content' registry key value to 1 to allow bloatware apps to reinstall"
    #Prevents bloatware applications from returning
    If ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content\") {
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
        Mkdir $registryPath -ErrorAction SilentlyContinue
        New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue
    }
    
    #Re-enables data collection
    Write-Output "Re-enabling data collection"
    If ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection') {
        $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
        Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 1 -Verbose
    }
    
    #Re-enables People Icon on Taskbar
    Write-Output "Enabling People icon on Taskbar"
    If ('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People') {
        $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
        New-ItemProperty $People -Name PeopleBand -Value 1 -Verbose -ErrorAction SilentlyContinue
    }

    #Re-enables suggestions on start menu
    Write-Output "Enabling suggestions on the Start Menu"
    If ('HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager') {
        $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 1 -Verbose
    }
    
    #Re-enables scheduled tasks that were disabled when running the Debloat switch
    Write-Output "Enabling scheduled tasks that were disabled"
    Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Enable-ScheduledTask
    Get-ScheduledTask -TaskName XblGameSaveTask | Enable-ScheduledTask
    Get-ScheduledTask -TaskName Consolidator | Enable-ScheduledTask
    Get-ScheduledTask -TaskName UsbCeip | Enable-ScheduledTask
    Get-ScheduledTask -TaskName DmClient | Enable-ScheduledTask
    Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Enable-ScheduledTask
}

Function Enable-EdgePDF {
    Write-Output "Setting Edge back to default"
    #Sets edge back to default
    If (Get-ItemProperty 'HKCR:\.pdf' -Name NoOpenWith) {
        $NoOpen = 'HKCR:\.pdf'
        Remove-ItemProperty $NoOpen -Name NoOpenWith -Verbose
    }
    
    If (Get-ItemProperty 'HKCR:\.pdf' -Name NoStaticDefaultVerb) {
        $NoStatic = 'HKCR:\.pdf'
        Remove-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose
    }
    
    If (Get-ItemProperty 'HKCR:\.pdf\OpenWithProgids' -Name NoOpenWith) {
        $NoOpen = 'HKCR:\.pdf\OpenWithProgids'
        Remove-ItemProperty $NoOpen -Name NoOpenWith -Verbose
    }
    
    If (Get-ItemProperty 'HKCR:\.pdf\OpenWithProgids' -Name NoStaticDefaultVerb) {
        $NoStatic = 'HKCR:\.pdf\OpenWithProgids'
        Remove-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose
    }
    
    If (Get-ItemProperty 'HKCR:\.pdf\OpenWithList' -Name NoOpenWith) {
        $NoOpen = 'HKCR:\.pdf\OpenWithList'
        Remove-ItemProperty $NoOpen -Name NoOpenWith -Verbose
    }
    
    If (Get-ItemProperty 'HKCR:\.pdf\OpenWithList' -Name NoStaticDefaultVerb) {
        $NoStatic = 'HKCR:\.pdf\OpenWithList'
        Remove-ItemProperty $NoStatic -Name NoStaticDefaultVerb -Verbose
    }
    
    #Removes an underscore '_' from the Registry key for Edge
    If ('HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723') {
        $Edge = 'HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723'
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723 -Verbose
    }
}

If ($Silent)
{
    If ($SystemRestore)
    {
    #Enabling System Restore
    Write-Output "Enabling System Restore Functionality" ; $PublishSettings = $true
    Enable-ComputerRestore -Drive "C:\"
    #Saving Restore Point
    Write-Output "Creating a system restore checkpoint...." ; $PublishSettings = $true
    Checkpoint-Computer -Description "Windows 10 Debloat" -RestorePointType "APPLICATION_UNINSTALL"
    }
    If ($RunType = "Debloat")
    {
        #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
        Write-Output "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Sleep 1
        Write-Output "Uninstalling bloatware, please wait."
        Start-Debloat
        Write-Output "Bloatware removed."
        Sleep 1
        Write-Output "Removing specific registry keys."
        Remove-Keys
        Write-Output "Leftover bloatware registry keys removed."
        Sleep 1
        Write-Output "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
        Protect-Privacy
        Write-Output "Cortana disabled from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
        Sleep 1; $PublishSettings = $true

        If($RevertDefaultPDF)
            {
                Stop-EdgePDF
                Write-Output "Edge will no longer take over as the default PDF viewer."; $PublishSettings = $true
            }

        Write-Output "Unloading the HKCR drive..."
        Remove-PSDrive HKCR 
        Sleep 1
        Write-Output "Script has finished. Exiting."
        Sleep 2

        Exit; $PublishSettings = $false
        If ($ForceReboot)
        {
            Write-Output "Initiating reboot."; $PublishSettings = $true
            Sleep 2
            Restart-Computer
        }
    }
    If ($RunType = "Revert")
    {
        Write-Output "Reverting changes..."; $PublishSettings = $false
        Write-Output "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the modification of specific registry keys."
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Revert-Changes
               
        Enable-EdgePDF
        Write-Output "Edge will no longer be disabled from being used as the default Edge PDF viewer."; $PublishSettings = $true
          
        Write-Output "Unloading the HKCR drive..."
        Remove-PSDrive HKCR 
        Sleep 1
        If ($ForceReboot)
        {
            Write-Output "Initiating reboot."; $PublishSettings = $true
            Sleep 2
            Restart-Computer
        }    
    
        
    }
}
Else
{ 
    #Switch statement containing Yes/No options
    #This will ask you if you want to enable System Restore functionality and will enable it if you choose yes
    Write-Output "Do you want to enable System Restore Functionality? (!RECOMMENDED!)" 
    $Readhost = Read-Host " ( Yes / No ) " 
    Switch ($ReadHost) { 
        Yes {
            Write-Output "Enabling System Restore Functionality" ; $PublishSettings = $true
            Enable-ComputerRestore -Drive "C:\"
        } 
        No {$PublishSettings = $false} 
    }
        
    #Switch statement containing Yes/No options
    #It also allows you to create a system restore check point

    Write-Output "Do you want to create a System Restore Checkpoint? (!RECOMMENDED!)" 
    $Readhost = Read-Host " ( Yes / No ) " 
    Switch ($ReadHost) { 
        Yes {
            Write-Output "Creating a system restore checkpoint...." ; $PublishSettings = $true
            Checkpoint-Computer -Description "Windows 10 Debloat" -RestorePointType "APPLICATION_UNINSTALL"
        } 
        No {$PublishSettings = $false} 
    }
        
    #Switch statement containing Debloat/Revert options
    Write-Output "The following options will allow you to either Debloat Windows 10, or to revert changes made after Debloating Windows 10.
        Choose 'Debloat' to Debloat Windows 10 or choose 'Revert' to revert changes." 
    $Readhost = Read-Host " ( Debloat / Revert ) " 

        #This will debloat Windows 10
        Debloat {
            #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
            Write-Output "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
            Sleep 1
            Write-Output "Uninstalling bloatware, please wait."
            Start-Debloat
            Write-Output "Bloatware removed."
            Sleep 1
            Write-Output "Removing specific registry keys."
            Remove-Keys
            Write-Output "Leftover bloatware registry keys removed."
            Sleep 1
            Write-Output "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
            Protect-Privacy
            Write-Output "Cortana disabled from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
            Sleep 1; $PublishSettings = $true

            Write-Output "Do you want to stop edge from taking over as the default PDF viewer?"
            $ReadHost = Read-Host " (Yes / No ) "
            Switch ($ReadHost) {
                Yes {
                    Stop-EdgePDF
                    Write-Output "Edge will no longer take over as the default PDF viewer."; $PublishSettings = $true
                }
                No {$PublishSettings = $false}
            }
            #Switch statement asking if you'd like to reboot your machine
            Write-Output "For some of the changes to properly take effect it is recommended to reboot your machine. Would you like to restart?"
            $Readhost = Read-Host " ( Yes / No ) "
            Switch ($Readhost) {
                Yes {
                    Write-Output "Unloading the HKCR drive..."
                    Remove-PSDrive HKCR 
                    Sleep 1
                    Write-Output "Initiating reboot."; $PublishSettings = $true
                    Sleep 2
                    Restart-Computer
                }
                No {
                    Write-Output "Unloading the HKCR drive..."
                    Remove-PSDrive HKCR 
                    Sleep 1
                    Write-Output "Script has finished. Exiting."
                    Sleep 2
                    Exit; $PublishSettings = $false
                }
            }

        }
        Revert {
            Write-Output "Reverting changes..."; $PublishSettings = $false
            Write-Output "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the modification of specific registry keys."
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
            Revert-Changes
        
            Write-Output "Do you want to revert changes that disabled Edge as the default PDF viewer?"
            $ReadHost = Read-Host " (Yes / No ) "
            Switch ($ReadHost) {
                Yes {
                    Enable-EdgePDF
                    Write-Output "Edge will no longer be disabled from being used as the default Edge PDF viewer."; $PublishSettings = $true
                }
                No {$PublishSettings = $false}
            }

            #Switch statement asking if you'd like to reboot your machine
            Write-Output "For some of the changes to properly take effect it is recommended to reboot your machine. Would you like to restart?"
            $Readhost = Read-Host " ( Yes / No ) "
            Switch ($Readhost) {
                Yes {
                    Write-Output "Unloading the HKCR drive..."
                    Remove-PSDrive HKCR 
                    Sleep 1
                    Write-Output "Initiating reboot."; $PublishSettings = $true
                    Sleep 2
                    Restart-Computer
                }
                No {
                    Write-Output "Unloading the HKCR drive..."
                    Remove-PSDrive HKCR 
                    Sleep 1
                    Write-Output "Script has finished. Exiting."
                    Sleep 2
                    Exit; $PublishSettings = $false
                }
            }
        }
    
}

if (-not ([string]::IsNullOrEmpty($LogPath)))
{
    Stop-Transcript
}
