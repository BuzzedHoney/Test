$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = '-NoProfile -Command "iex \"& { $(irm christitus.com/win) } -Config https://raw.githubusercontent.com/BuzzedHoney/Test/main/Tweaks.json -Run\""'
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($psi)
$readerOut = $process.StandardOutput
$readerErr = $process.StandardError

while (-not $readerOut.EndOfStream -or -not $readerErr.EndOfStream) {
    while (-not $readerOut.EndOfStream) {
        $line = $readerOut.ReadLine()
        Write-Output $line

        if ($line -match "Tweaks are Finished") {
            $apps = Get-Process | Where-Object { $_.MainWindowTitle }
            foreach ($app in $apps) {
                if ($app.MainWindowTitle -like "*WinUtil*") {
                    Stop-Process -Id $app.Id -Force
                }
            }

            New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat" | Out-Null

            Invoke-RestMethod 'https://raw.githubusercontent.com/BuzzedHoney/Test/main/CustomAppsList.txt' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\CustomAppsList"

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

            $process.Close()
            exit
        }
    }

    while (-not $readerErr.EndOfStream) {
        $errLine = $readerErr.ReadLine()
        Write-Output $errLine
    }
}

$process.WaitForExit()
$process.Close()
