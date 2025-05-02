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
