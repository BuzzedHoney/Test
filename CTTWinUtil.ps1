$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = '-NoProfile -Command "iex \"& { $(irm christitus.com/win) } -Config https://raw.githubusercontent.com/bluethedoor/Test/main/Tweaks.json -Run\""'
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
            # Close WinUtil windows
            $apps = Get-Process | Where-Object { $_.MainWindowTitle }
            foreach ($app in $apps) {
                if ($app.MainWindowTitle -like "*WinUtil*") {
                    Stop-Process -Id $app.Id -Force
                }
            }

            # Prepare folder for temp files
            New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat" | Out-Null

            Invoke-RestMethod 'https://raw.githubusercontent.com/bluethedoor/Test/main/CustomAppsList.txt' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\CustomAppsList"

            # Run debloat script
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

            # Check if default browser is set
            $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
            $hasDefault = $false

            if (Test-Path $regPath) {
                $progId = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProgId
                $hasDefault = ($progId -and $progId -ne "")
            }

            if ($hasDefault) {
                Write-Output "NO_BROWSER"

                Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber -Confirm:$false

$iconUrl = "https://raw.githubusercontent.com/bluethedoor/Test/main/Firefox.ico"
$iconPath = "$env:TEMP\Firefox.ico"
Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath -UseBasicParsing

$scriptPath = "$env:TEMP\InstallFirefox.ps1"
@'
$proc = Start-Process "winget" -ArgumentList "install -e --id Mozilla.Firefox" -WindowStyle Minimized -PassThru
$proc.WaitForExit()
'@ | Set-Content -Path $scriptPath -Encoding UTF8

$exeOutput = "$env:USERPROFILE\Desktop\Firefox.exe"
Invoke-ps2exe -inputFile $scriptPath -outputFile $exeOutput -iconFile $iconPath -noConsole -noOutput

Remove-Item $scriptPath, $iconPath -Force
Uninstall-Module -Name ps2exe -Force -Confirm:$false

# Removed the following lines that hide file extensions again:
# Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1
# Stop-Process -Name explorer -Force
# Start-Process explorer.exe

            }

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
