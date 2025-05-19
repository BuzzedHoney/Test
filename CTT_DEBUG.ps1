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

        # Wait forever for "Disk Space Notification" to appear and close it
        while ($true) {
            $diskApps = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk*" }
            if ($diskApps) {
                foreach ($diskApp in $diskApps) {
                    Stop-Process -Id $diskApp.Id -Force
                }
                break  # Exit loop after closing
            }
            Start-Sleep -Seconds 3
        }

        Start-Sleep -Seconds 3
            New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master" | Out-Null
            Invoke-RestMethod 'https://raw.githubusercontent.com/bluethedoor/Test/main/FinalAppList' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master\CustomAppsList"
            & ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableDesktopSpotlight -DisableWidgets -ShowHiddenFolders -ShowKnownFileExt -DisableFastStartup -DisableStickyKeys
            # Start-Process powershell -ArgumentList "-WindowStyle Minimized -Command & ([scriptblock]::Create((Invoke-RestMethod 'https://debloat.raphi.re/'))) -Custom CMDS"
            # -DisableStartRecommended -HideSearchTb
        $process.Close()
        exit
    }
}
