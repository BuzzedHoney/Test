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
        # ... existing cleanup code remains the same ...

        # --- Simplified Browser Detection ---
        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        $hasDefault = $false
        
        if (Test-Path $regPath) {
            $progId = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProgId
            $hasDefault = ($progId -and $progId -ne "")
        }
        
        if ($hasDefault) {
            Write-Output "BROWSER_FOUND"
        } else {
            Write-Output "NO_BROWSER"
        }
        # --- End Browser Detection ---
        
        $process.Close()
        exit
    }
}
