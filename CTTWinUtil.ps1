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

        # --- Browser Detection Section ---
$browserPatterns = @(
    "chrome", "firefox", "msedge", "opera", "opera_gx", "brave", "zenbrowser", "librewolf",
    "tor", "mullvadbrowser", "vivaldi", "yandex", "chromium", "mozilla"
)

$hasDefault = $false
$regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
if (Test-Path $regPath) {
    $progId = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProgId
    if ($progId -and $progId -ne "") { $hasDefault = $true }
}

$found = $false
if (-not $hasDefault) {
    $appPaths = Get-ChildItem 'HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths' -ErrorAction SilentlyContinue
    foreach ($item in $appPaths) {
        foreach ($pattern in $browserPatterns) {
            if ($item.PSChildName -imatch $pattern) { $found = $true }
        }
    }
    $uninstallKeys = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($key in $uninstallKeys) {
        Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | ForEach-Object {
            $displayName = $_.DisplayName
            if ($displayName) {
                foreach ($pattern in $browserPatterns) {
                    if ($displayName -imatch $pattern) { $found = $true }
                }
            }
        }
    }
}

if ($hasDefault -or $found) {
    Write-Output "BROWSER_FOUND"
} else {
    Write-Output "NO_BROWSER"
}
# --- End Browser Detection Section ---

        
        $process.Close()
        exit
    }
}
