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

        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        $hasDefault = $false

        if (Test-Path $regPath) {
            $progId = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProgId
            $hasDefault = ($progId -and $progId -ne "")
        }

        if ($hasDefault) {
            Write-Output "NO_BROWSER"
            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
}

Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber -Confirm:$false

$iconUrl = "https://raw.githubusercontent.com/bluethedoor/Test/main/Chrome.ico"
$iconPath = "$env:TEMP\Chrome.ico"
Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath -UseBasicParsing

$scriptPath = "$env:TEMP\InstallChrome.ps1"
@'
$proc = Start-Process "winget" -ArgumentList "install -e --id LibreWolf.LibreWolf" -WindowStyle Minimized -PassThru
$proc.WaitForExit()
'@ | Set-Content -Path $scriptPath -Encoding UTF8

$exeOutput = "$env:USERPROFILE\Desktop\Google Chrome.exe"
Invoke-ps2exe -inputFile $scriptPath -outputFile $exeOutput -iconFile $iconPath -noConsole -noOutput

Remove-Item $scriptPath, $iconPath -Force
Uninstall-Module -Name ps2exe -Force -Confirm:$false

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1
Stop-Process -Name explorer -Force
Start-Process explorer.exe
        }
        
        $process.Close()
        exit
    }
}
