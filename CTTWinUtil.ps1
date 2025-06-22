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

                # Install NuGet & ps2exe if missing
                if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
                }
                Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber -Confirm:$false

                # Download icon for exe
                $iconUrl = "https://raw.githubusercontent.com/bluethedoor/Test/main/Chrome.ico"
                $iconPath = "$env:TEMP\Chrome.ico"
                Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath -UseBasicParsing

                # Create inline script content for the exe
               $inlineScript = @'
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "winget"
$psi.Arguments = "install -e --id Google.Chrome"
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $false
$psi.WindowStyle = "Minimized"

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi
$process.Start() | Out-Null

while (-not $process.HasExited) {
    while (-not $process.StandardOutput.EndOfStream) {
        Write-Output $process.StandardOutput.ReadLine()
    }
    while (-not $process.StandardError.EndOfStream) {
        Write-Output $process.StandardError.ReadLine()
    }
    Start-Sleep -Milliseconds 100
}

while (-not $process.StandardOutput.EndOfStream) {
    Write-Output $process.StandardOutput.ReadLine()
}
while (-not $process.StandardError.EndOfStream) {
    Write-Output $process.StandardError.ReadLine()
}

Write-Output "Browser_Install"
'@


                # Save to temp script file for ps2exe input
                $scriptPath = "$env:TEMP\InstallBrowserInline.ps1"
                $inlineScript | Set-Content -Path $scriptPath -Encoding UTF8

                # Output exe path
                $exeOutput = "$env:USERPROFILE\Desktop\Google Chrome.exe"

                # Compile the inline script into exe
                Invoke-ps2exe -inputFile $scriptPath -outputFile $exeOutput -iconFile $iconPath -noConsole -noOutput

                # Remove temp script and icon files
                Remove-Item $scriptPath, $iconPath -Force

                Uninstall-Module -Name ps2exe -Force -Confirm:$false

                # Adjust Explorer settings to hide extensions and restart explorer
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1
                Stop-Process -Name explorer -Force
                Start-Process explorer.exe
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
