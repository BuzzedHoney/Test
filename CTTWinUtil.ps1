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
    Write-Output "NO_BROWSER"
    # Download the icon
Invoke-WebRequest "https://raw.githubusercontent.com/bluethedoor/Test/main/Chrome.ico" -OutFile "$env:USERPROFILE\Desktop\Chrome.ico"

# Write the PowerShell script to install Chrome
Set-Content "$env:USERPROFILE\Desktop\Google Chrome.ps1" 'winget install -e --id Google.Chrome

# Check if ps2exe is installed, install if not
if (-not (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    Install-Module -Name ps2exe -Scope CurrentUser -Force
    Import-Module ps2exe
}

# Convert the PowerShell script to a .exe with icon
Invoke-ps2exe -inputFile "$env:USERPROFILE\Desktop\Google Chrome.ps1" `
              -outputFile "$env:USERPROFILE\Desktop\Google Chrome.exe" `
              -iconFile "$env:USERPROFILE\Desktop\Chrome.ico" `

# Remove the .ps1 (not needed anymore)
Remove-Item "$env:USERPROFILE\Desktop\Google Chrome.ps1" -Force

# Clear icon cache to make sure the icon is shown correctly
Start-Process ie4uinit.exe -ArgumentList "-ClearIconCache"
Start-Process taskkill -ArgumentList "/IM explorer.exe /F" -Wait
Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

} else {
    Write-Output "NO_BROWSER"
# NO_BROWSER
        # Download the icon
Invoke-WebRequest "https://raw.githubusercontent.com/bluethedoor/Test/main/Chrome.ico" -OutFile "$env:USERPROFILE\Desktop\Chrome.ico"

# Write the PowerShell script to install Chrome
Set-Content "$env:USERPROFILE\Desktop\Google Chrome.ps1" 'winget install -e --id Google.Chrome | ForEach-Object { Write-Output $_ }'

# Check if ps2exe is installed, install if not
if (-not (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    Install-Module -Name ps2exe -Scope CurrentUser -Force
    Import-Module ps2exe
}

# Convert the PowerShell script to a .exe with icon
Invoke-ps2exe -inputFile "$env:USERPROFILE\Desktop\Google Chrome.ps1" `
              -outputFile "$env:USERPROFILE\Desktop\Google Chrome.exe" `
              -iconFile "$env:USERPROFILE\Desktop\Chrome.ico" `

# Remove the .ps1 (not needed anymore)
Remove-Item "$env:USERPROFILE\Desktop\Google Chrome.ps1" -Force

# Clear icon cache to make sure the icon is shown correctly
Start-Process ie4uinit.exe -ArgumentList "-ClearIconCache"
Start-Process taskkill -ArgumentList "/IM explorer.exe /F" -Wait
Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

}
# --- End Default Browser Detection Section ---

        $process.Close()
        exit
    }
}
