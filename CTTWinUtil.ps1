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
    Write-Output $line

    if ($line -match "Tweaks are Finished") {
        $apps = Get-Process | Where-Object { $_.MainWindowTitle }
        foreach ($app in $apps) {
            if ($app.MainWindowTitle -like "*WinUtil*") {
                Start-Sleep -Seconds 3
                Stop-Process -Id $app.Id -Force
            }
        }

        while ($true) {
            $diskCleanup = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk Cleanup*" }
            $diskNotif = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk Space Notification*" }

            if ($diskCleanup.Count -gt 0) {
                Start-Sleep -Seconds 3
                continue
            }

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

        New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat" | Out-Null

        Invoke-RestMethod 'https://raw.githubusercontent.com/bluethedoor/Test/main/CustomAppsList.txt' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\CustomAppsList"

        & ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) `
        -Silent `
        -RemoveAppsCustom `
        -DisableTelemetry `
        -DisableSuggestions `
        -DisableLockscreenTips `
        -DisableDesktopSpotlight `
        -DisableWidgets `
        -ShowHiddenFolders `
        -ShowKnownFileExt `
        -DisableFastStartup `
        -DisableStickyKeys

        # --- Default Browser Detection Section ---
$regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
$hasDefault = $false

if (Test-Path $regPath) {
    $progId = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProgId
    $hasDefault = ($progId -and $progId -ne "")
}

if ($hasDefault) {
    Write-Output "BROWSER_FOUND"
} else {
    Write-Output "NO_BROWSER"
}
# --- End Default Browser Detection Section ---

        
        $process.Close()
        exit
    }
}
