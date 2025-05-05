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
            $diskApps = Get-Process | Where-Object { $_.MainWindowTitle -like "*Disk Space Notification*" }
            if ($diskApps) {
                foreach ($diskApp in $diskApps) {
                    Stop-Process -Id $diskApp.Id -Force
                }
                break  # Exit loop after closing
            }
            Start-Sleep -Seconds 3
        }

        Start-Sleep -Seconds 3
        $process.Close()
        exit
    }
}
