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
    Write-Output $line      # <--- THIS LINE MAKES OUTPUT VISIBLE IN C#
    if ($line -match "Tweaks are Finished") {
        $apps = Get-Process | Where-Object { $_.MainWindowTitle }
        foreach ($app in $apps) {
            if ($app.MainWindowTitle -like "*Chris Titus Tech's Windows Utility*") {
                Start-Sleep -Seconds 3
                Stop-Process -Id $app.Id -Force
            }
        }

while ($true) {
    $diskCleanup = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk Cleanup*" }
    $diskNotif = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk Space Notification*" }
    # If there are any Disk Cleanup windows still open, keep waiting
    if ($diskCleanup.Count -gt 0) {
        Start-Sleep -Seconds 3
        continue
    }
    # If there are no Disk Cleanup windows and at least one notification, proceed
    if ($diskNotif.Count -gt 0) {
        Start-Sleep -Seconds 3
        foreach ($notif in $diskNotif) {
            Stop-Process -Id $notif.Id -Force
        }
        break
    }
    Start-Sleep -Seconds 3
}


        Start-Sleep -Seconds 3
        # Create the directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat" | Out-Null

# Download your CustomAppsList.txt from GitHub and save it as 'CustomAppsList' (no .txt) in the folder
Invoke-RestMethod 'https://raw.githubusercontent.com/bluethedoor/Test/main/CustomAppsList.txt' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\CustomAppsList"

# Run the debloat script with your custom app list and options
& ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableDesktopSpotlight -DisableWidgets -ShowHiddenFolders -ShowKnownFileExt -DisableFastStartup -DisableStickyKeys


     $process.Close()

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
        exit
    }
}
