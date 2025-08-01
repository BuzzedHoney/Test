Set-ExecutionPolicy Bypass -Scope Process -Force

function TakeOwnershipAndDelete {
    param([string]$Path)
    if (Test-Path $Path) {
        takeown /F $Path /R /D Y | Out-Null
        icacls $Path /grant administrators:F /T | Out-Null
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function RemoveRegistryKeys {
    param([string[]]$Keys)
    foreach ($key in $Keys) {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Get-Process | Where-Object { $_.Name -like "*edge*" } | Stop-Process -Force
$edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe"
$resolvedEdgePath = (Resolve-Path $edgePath -ErrorAction SilentlyContinue)
if ($resolvedEdgePath) {
    Start-Process -FilePath $resolvedEdgePath -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
}
$edgeStartMenuLinks = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
)
foreach ($link in $edgeStartMenuLinks) {
    Remove-Item $link -Force -ErrorAction SilentlyContinue
}
$edgeFolders = @(
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
foreach ($folder in $edgeFolders) {
    TakeOwnershipAndDelete $folder
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
RemoveRegistryKeys -Keys $edgeRegKeys
$edgeUpdateExe = "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe"
if (Test-Path $edgeUpdateExe) {
    Start-Process $edgeUpdateExe -ArgumentList "/uninstall" -Wait
}
$edgeServices = @("edgeupdate","edgeupdatem","MicrosoftEdgeElevationService")
foreach ($svc in $edgeServices) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    sc.exe delete $svc | Out-Null
}
$edgeSetup = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
if ($edgeSetup) {
    Start-Process $edgeSetup.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
}
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
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
$adminsSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
$trustedInstallerSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464")
$authenticatedUsersSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-11")

foreach ($folder in $protectiveFolders) {
    New-Item -Path $folder.Base -ItemType Directory -Force | Out-Null
    if ($folder.CreateSubFolder) {
        New-Item -Path $folder.App -ItemType Directory -Force | Out-Null
    }
    if (-not $folder.CreateSubFolder) {
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $acl.SetOwner([System.Security.Principal.NTAccount]$currentUser)
        $acl.SetAccessRuleProtection($true, $false)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser, "FullControl,TakeOwnership,ChangePermissions", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($accessRule)
        $denyRules = @($systemSid, $adminsSid, $trustedInstallerSid, $authenticatedUsersSid) | ForEach-Object {
            New-Object System.Security.AccessControl.FileSystemAccessRule($_, "TakeOwnership,ChangePermissions", "ContainerInherit,ObjectInherit", "None", "Deny")
        }
        foreach ($rule in $denyRules) { $acl.AddAccessRule($rule) }
        Set-Acl $folder.Base $acl
    }
    else {
        Get-ChildItem -Path $folder.Base -Recurse | ForEach-Object {
            $acl = New-Object System.Security.AccessControl.DirectorySecurity
            $acl.SetOwner([System.Security.Principal.NTAccount]$currentUser)
            $acl.SetAccessRuleProtection($true, $false)
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser, "FullControl,TakeOwnership,ChangePermissions", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.AddAccessRule($accessRule)
            $denyRules = @($systemSid, $adminsSid, $trustedInstallerSid, $authenticatedUsersSid) | ForEach-Object {
                New-Object System.Security.AccessControl.FileSystemAccessRule($_, "TakeOwnership,ChangePermissions", "ContainerInherit,ObjectInherit", "None", "Deny")
            }
            foreach ($rule in $denyRules) { $acl.AddAccessRule($rule) }
            Set-Acl $_.FullName $acl
        }
    }
}
Write-Host "Removed Edge"

Start-Sleep 3

Write-Host "Removing Outlook"
Get-Process | Where-Object { $_.ProcessName -like "*outlook*" } | Stop-Process -Force
Start-Sleep -Seconds 2
Get-AppxPackage *Microsoft.Office.Outlook* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*Microsoft.Office.Outlook*" } | Remove-AppxProvisionedPackage -Online
Get-AppxPackage *Microsoft.OutlookForWindows* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*Microsoft.OutlookForWindows*" } | Remove-AppxProvisionedPackage -Online
$windowsAppsPath = "C:\Program Files\WindowsApps"
$outlookFolders = Get-ChildItem -Path $windowsAppsPath -Directory | Where-Object { $_.Name -like "Microsoft.OutlookForWindows*" }
foreach ($folder in $outlookFolders) {
    TakeOwnershipAndDelete (Join-Path $windowsAppsPath $folder.Name)
}
$outlookShortcuts = @(
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
foreach ($shortcut in $outlookShortcuts) {
    Remove-Item $shortcut -Force -ErrorAction SilentlyContinue
}
Write-Host "Removed Outlook"

Start-Sleep 3

Write-Host "Moving OneDrive files to main drive"
irm "https://raw.githubusercontent.com/BuzzedHoney/Test/main/OneDrive%20Cleanup.ps1" | iex
Write-Host "Removing OneDrive"
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    & "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall
}
elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    & "$env:SystemRoot\System32\OneDriveSetup.exe" /uninstall
}
$oneDrivePaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
    "$env:PUBLIC\Desktop\OneDrive.lnk",
    "$env:USERPROFILE\Desktop\OneDrive.lnk",
    "$env:USERPROFILE\OneDrive",
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft\OneDrive",
    "$env:SystemDrive\OneDriveTemp"
)
foreach ($path in $oneDrivePaths) { TakeOwnershipAndDelete $path }
$oneDriveRegKeys = @(
    "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)
RemoveRegistryKeys -Keys $oneDriveRegKeys
Write-Host "Removed OneDrive"

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force

$taskbarRegistryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TaskbarMRU",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
)
foreach ($regPath in $taskbarRegistryPaths) {
    if (Test-Path $regPath) {
        @("Favorites", "FavoritesResolve", "FavoritesChanges", "FavoritesRemovedChanges", "TaskbarWinXP", "PinnedItems") | ForEach-Object {
            Remove-ItemProperty -Path $regPath -Name $_ -ErrorAction SilentlyContinue
        }
    }
}
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*" -Force -ErrorAction SilentlyContinue

Write-Host "Successfully Removed Edge, Outlook, & OneDrive"
