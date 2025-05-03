if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Break
}

Get-Process | Where-Object { $_.Name -like "*edge*" } | Stop-Process -Force

$edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe"
Start-Process -FilePath $(Resolve-Path $edgePath) -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait

$startMenuPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
)
foreach ($path in $startMenuPaths) {
    Remove-Item -Path $path -Force
}

$edgePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge",
    "$env:PROGRAMFILES\Microsoft\Edge",
    "${env:ProgramFiles(x86)}\Microsoft\Edge",
    "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate",
    "${env:ProgramFiles(x86)}\Microsoft\EdgeCore",
    "$env:LOCALAPPDATA\Microsoft\EdgeUpdate",
    "$env:PROGRAMDATA\Microsoft\EdgeUpdate",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:PUBLIC\Desktop\Microsoft Edge.lnk"
)
foreach ($path in $edgePaths) {
    takeown /F $path /R /D Y | Out-Null
    icacls $path /grant administrators:F /T | Out-Null
    Remove-Item -Path $path -Recurse -Force
}

$edgeRegKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update",
    "HKLM:\SOFTWARE\Microsoft\EdgeUpdate",
    "HKCU:\Software\Microsoft\Edge",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeUpdate",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeUpdate",
    "HKLM:\SOFTWARE\Microsoft\Edge",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update"
)
foreach ($key in $edgeRegKeys) {
    Remove-Item -Path $key -Recurse -Force
}

$edgeUpdatePath = "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe"
Start-Process $edgeUpdatePath -ArgumentList "/uninstall" -Wait

$services = @(
    "edgeupdate",
    "edgeupdatem",
    "MicrosoftEdgeElevationService"
)
foreach ($service in $services) {
    Stop-Service -Name $service -Force
    sc.exe delete $service | Out-Null
}

$edgeSetup = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe"
Start-Process $edgeSetup.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait

Stop-Process -Name explorer -Force
Start-Process explorer

$protectiveFolders = @(
    @{
        Base = "${env:ProgramFiles(x86)}\Microsoft\Edge"
        App = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
        CreateSubFolder = $true
    },
    @{
        Base = "${env:ProgramFiles(x86)}\Microsoft\EdgeCore"
        CreateSubFolder = $false
    }
)
foreach ($folder in $protectiveFolders) {
    New-Item -Path $folder.Base -ItemType Directory -Force | Out-Null
    if ($folder.CreateSubFolder) {
        New-Item -Path $folder.App -ItemType Directory -Force | Out-Null
    }
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    if (!$folder.CreateSubFolder) {
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $acl.SetOwner([System.Security.Principal.NTAccount]$currentUser)
        $acl.SetAccessRuleProtection($true, $false)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $currentUser, 
            "FullControl,TakeOwnership,ChangePermissions", 
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $acl.AddAccessRule($accessRule)
        $systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
        $adminsSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
        $trustedInstallerSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464")
        $authenticatedUsersSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11")
        $denyRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $systemSid,
            "TakeOwnership,ChangePermissions",
            "ContainerInherit,ObjectInherit",
            "None",
            "Deny"
        )
        $denyRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $adminsSid,
            "TakeOwnership,ChangePermissions",
            "ContainerInherit,ObjectInherit",
            "None",
            "Deny"
        )
        $denyRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $trustedInstallerSid,
            "TakeOwnership,ChangePermissions",
            "ContainerInherit,ObjectInherit",
            "None",
            "Deny"
        )
        $denyRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $authenticatedUsersSid,
            "TakeOwnership,ChangePermissions",
            "ContainerInherit,ObjectInherit",
            "None",
            "Deny"
        )
        $acl.AddAccessRule($denyRule1)
        $acl.AddAccessRule($denyRule2)
        $acl.AddAccessRule($denyRule3)
        $acl.AddAccessRule($denyRule4)
        Set-Acl $folder.Base $acl
    }
    else {
        Get-ChildItem -Path $folder.Base -Recurse | ForEach-Object {
            $acl = New-Object System.Security.AccessControl.DirectorySecurity
            $acl.SetOwner([System.Security.Principal.NTAccount]$currentUser)
            $acl.SetAccessRuleProtection($true, $false)
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $currentUser, 
                "FullControl,TakeOwnership,ChangePermissions", 
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            $acl.AddAccessRule($accessRule)
            $systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
            $adminsSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
            $trustedInstallerSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464")
            $authenticatedUsersSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11")
            $denyRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $systemSid,
                "TakeOwnership,ChangePermissions",
                "ContainerInherit,ObjectInherit",
                "None",
                "Deny"
            )
            $denyRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $adminsSid,
                "TakeOwnership,ChangePermissions",
                "ContainerInherit,ObjectInherit",
                "None",
                "Deny"
            )
            $denyRule3 = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $trustedInstallerSid,
                "TakeOwnership,ChangePermissions",
                "ContainerInherit,ObjectInherit",
                "None",
                "Deny"
            )
            $denyRule4 = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $authenticatedUsersSid,
                "TakeOwnership,ChangePermissions",
                "ContainerInherit,ObjectInherit",
                "None",
                "Deny"
            )
            $acl.AddAccessRule($denyRule1)
            $acl.AddAccessRule($denyRule2)
            $acl.AddAccessRule($denyRule3)
            $acl.AddAccessRule($denyRule4)
            Set-Acl $_.FullName $acl
        }
    }
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -WindowStyle Hidden
    exit
}

Set-ExecutionPolicy Bypass -Scope Process -Force

Get-Process | Where-Object { $_.ProcessName -like "*outlook*" } | Stop-Process -Force
Start-Sleep -Seconds 2

Get-AppxPackage *Microsoft.Office.Outlook* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Microsoft.Office.Outlook*"} | Remove-AppxProvisionedPackage -Online
Get-AppxPackage *Microsoft.OutlookForWindows* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*Microsoft.OutlookForWindows*"} | Remove-AppxProvisionedPackage -Online

$windowsAppsPath = "C:\Program Files\WindowsApps"
$outlookFolders = Get-ChildItem -Path $windowsAppsPath -Directory | Where-Object { $_.Name -like "Microsoft.OutlookForWindows*" }
foreach ($folder in $outlookFolders) {
    $folderPath = Join-Path $windowsAppsPath $folder.Name
    takeown /f $folderPath /r /d Y | Out-Null
    icacls $folderPath /grant administrators:F /t | Out-Null
    Remove-Item -Path $folderPath -Recurse -Force
}

$shortcutPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Outlook.lnk",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\Outlook.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Office\Outlook.lnk",
    "$env:PUBLIC\Desktop\Outlook.lnk",
    "$env:USERPROFILE\Desktop\Outlook.lnk",
    "$env:PUBLIC\Desktop\Microsoft Outlook.lnk",
    "$env:USERPROFILE\Desktop\Microsoft Outlook.lnk",
    "$env:PUBLIC\Desktop\Outlook (New).lnk",
    "$env:USERPROFILE\Desktop\Outlook (New).lnk",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook (New).lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Outlook (New).lnk"
)
$shortcutPaths | ForEach-Object { Remove-Item $_ -Force }

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force

$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TaskbarMRU",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TaskBar",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
)
foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        @("Favorites", "FavoritesResolve", "FavoritesChanges", "FavoritesRemovedChanges", "TaskbarWinXP", "PinnedItems") | 
        ForEach-Object { Remove-ItemProperty -Path $path -Name $_ }
    }
}

Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml" -Force
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*" -Force

Get-Process | Where-Object { $_.ProcessName -like "*onedrive*" } | Stop-Process -Force
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    & "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall
} elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    & "$env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
}

@(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
    "$env:PUBLIC\Desktop\OneDrive.lnk",
    "$env:USERPROFILE\Desktop\OneDrive.lnk",
    "$env:USERPROFILE\OneDrive",
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft\OneDrive",
    "$env:SystemDrive\OneDriveTemp"
) | ForEach-Object { Remove-Item $_ -Force -Recurse }

@(
    "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
) | ForEach-Object { Remove-Item -Path $_ -Recurse -Force }

Get-Process explorer | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process explorer

$directoryPath = "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master"
New-Item -ItemType Directory -Force -Path $directoryPath | Out-Null

Set-Content -Path "$directoryPath\CustomAppsList" -Value "
Microsoft.Edge
"

Start-Process powershell -ArgumentList "-WindowStyle Minimized -Command & ([scriptblock]::Create((Invoke-RestMethod 'https://debloat.raphi.re/'))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableWidgets -DisableStartRecommended -ShowHiddenFolders -ShowKnownFileExt -HideSearchTb -DisableFastStartup -DisableStickyKeys"

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = '-NoProfile -Command "iex \"& { $(irm christitus.com/win) } -Config https://raw.githubusercontent.com/bluethedoor/Test/main/Tweaks.json -Run\""'
$psi.RedirectStandardOutput = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($psi)
$reader = $process.StandardOutput

while (-not $reader.EndOfStream) {
    $line = $reader.ReadLine()
    Write-Host $line
    if ($line -match "Tweaks are Finished") {
        Write-Host "DEBUG: Detected 'Tweaks are Finished'. Checking open apps..."

        $apps = Get-Process | Where-Object { $_.MainWindowTitle }

        $found = $false
        foreach ($app in $apps) {
            Write-Host "- $($app.ProcessName): $($app.MainWindowTitle)"
            if ($app.MainWindowTitle -like "*Chris Titus Tech's Windows Utility*") {
                $found = $true
                Write-Host "DEBUG: Found PowerShell: Chris Titus Tech's Windows Utility. Closing in 3 seconds..."
                Start-Sleep -Seconds 3
                try {
                    Stop-Process -Id $app.Id -Force
                    Write-Host "DEBUG: Closed Chris Titus Tech's Windows Utility window."
                } catch {
                    Write-Host "DEBUG: Failed to close the window: $_"
                }
            }
        }
        if (-not $found) {
            Write-Host "DEBUG: Did not find a window titled 'Chris Titus Tech's Windows Utility'."
        }
        Write-Host "DEBUG: App check finished. Exiting in 3 seconds..."
        Start-Sleep -Seconds 3
        $process.Close()
        exit
    }
}
