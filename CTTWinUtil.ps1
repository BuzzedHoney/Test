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
                Stop-Process -Id $app.Id -Force
            }
        }

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

Invoke-WebRequest "https://raw.githubusercontent.com/bluethedoor/Test/main/Chrome.ico" -OutFile "$env:USERPROFILE\Desktop\Chrome.ico"
Set-Content "$env:USERPROFILE\Desktop\InstallChrome.ps1" 'winget install -e --id Google.Chrome'

$s = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\Install Google Chrome.lnk")
$s.TargetPath = "powershell.exe"
$s.Arguments = "-ExecutionPolicy Bypass -NoExit -File `"$env:USERPROFILE\Desktop\InstallChrome.ps1`""
$s.IconLocation = "$env:USERPROFILE\Desktop\Chrome.ico"
$s.WorkingDirectory = "$env:USERPROFILE\Desktop"
$s.Save()

Start-Process ie4uinit.exe -ArgumentList "-ClearIconCache"
Start-Process taskkill -ArgumentList "/IM explorer.exe /F" -Wait
Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

        
        $process.Close()
        exit
    }
}
