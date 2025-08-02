Set-MpPreference -EnableControlledFolderAccess Disabled

do {
    Start-Sleep -Milliseconds 100
    $cfaStatus = (Get-MpPreference).EnableControlledFolderAccess
} while ($cfaStatus -ne 0)

Start-Sleep 3

$userProfile = [Environment]::GetFolderPath("UserProfile")

$excludedFolders = @(
    "AppData", "Desktop", "Documents", "Downloads", "Music",
    "Pictures", "Videos", "Favorites", "Links", "Saved Games",
    "Searches", "Contacts", "3D Objects", "source"
)

$paths = @{
    Pictures  = Join-Path $userProfile "Pictures"
    Videos    = Join-Path $userProfile "Videos"
    Documents = Join-Path $userProfile "Documents"
    Music     = Join-Path $userProfile "Music"
    Apps      = Join-Path $userProfile "Downloads"
}

$files = @()

$files += Get-ChildItem -Path $userProfile -File -Force -ErrorAction SilentlyContinue

$validDirs = Get-ChildItem -Path $userProfile -Directory -Force | Where-Object {
    $excludedFolders -notcontains $_.Name -and -not ($_.Name.StartsWith('.'))
}

foreach ($dir in $validDirs) {
    try {
        $files += Get-ChildItem -Path $dir.FullName -Recurse -File -Force -ErrorAction Stop
    } catch {
    }
}

foreach ($file in $files) {
    $ext = $file.Extension.ToLowerInvariant()
    $destination = $null

    switch ($ext) {
        { $_ -in ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp", ".heic", ".avif" } { $destination = $paths.Pictures; break }
        { $_ -in ".mp4", ".mov", ".avi", ".wmv", ".mkv", ".flv", ".webm" } { $destination = $paths.Videos; break }
        { $_ -in ".pdf", ".doc", ".docx", ".txt", ".rtf", ".xlsx", ".xls", ".ppt", ".pptx", ".odt", ".vsdx" } { $destination = $paths.Documents; break }
        { $_ -in ".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac", ".wma", ".alac", ".aiff" } { $destination = $paths.Music; break }
        { $_ -in ".exe", ".msi", ".bat" } { $destination = $paths.Apps; break }
    }

    if ($destination) {
        try {
            $destPath = Join-Path $destination $file.Name
            $i = 1
            while (Test-Path $destPath) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $ext = $file.Extension
                $destPath = Join-Path $destination "$base ($i)$ext"
                $i++
            }
            Move-Item -Path $file.FullName -Destination $destPath -Force
        } catch {
            Write-Host "Failed to sort files into directed folders"
        }
    }
}

Set-MpPreference -EnableControlledFolderAccess Enabled
