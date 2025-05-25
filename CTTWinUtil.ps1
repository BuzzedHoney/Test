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
     $process.Close()
        exit
    }
}
