Set-MpPreference -EnableControlledFolderAccess Disabled

do {
    Start-Sleep -Milliseconds 100
    $cfaStatus = (Get-MpPreference).EnableControlledFolderAccess
} while ($cfaStatus -ne 0)

Start-Sleep -Seconds 3

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

foreach ($path in $paths.Values) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

# Define all moveable file extensions
$moveableExtensions = @(
    ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp", ".heic", ".avif",
    ".mp4", ".mov", ".avi", ".wmv", ".mkv", ".flv", ".webm",
    ".pdf", ".doc", ".docx", ".txt", ".rtf", ".xlsx", ".xls", ".ppt", ".pptx", ".odt", ".vsdx",
    ".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac", ".wma", ".alac", ".aiff",
    ".exe", ".msi", ".bat"
)

# Gather files with only moveable extensions
$files = @()
$files += Get-ChildItem -Path $userProfile -File -Force -ErrorAction SilentlyContinue | Where-Object { $moveableExtensions -contains $_.Extension.ToLower() }

$validDirs = Get-ChildItem -Path $userProfile -Directory -Force | Where-Object {
    $excludedFolders -notcontains $_.Name -and -not ($_.Name.StartsWith('.'))
}

foreach ($dir in $validDirs) {
    $files += Get-ChildItem -Path $dir.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $moveableExtensions -contains $_.Extension.ToLower() }
}

[int]$filesMoved = 0
$failedFiles = @()

foreach ($file in $files) {
    $ext = $file.Extension.ToLowerInvariant()
    $destination = $null

    if ($ext -in @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp", ".heic", ".avif")) {
        $destination = $paths.Pictures
    }
    elseif ($ext -in @(".mp4", ".mov", ".avi", ".wmv", ".mkv", ".flv", ".webm")) {
        $destination = $paths.Videos
    }
    elseif ($ext -in @(".pdf", ".doc", ".docx", ".txt", ".rtf", ".xlsx", ".xls", ".ppt", ".pptx", ".odt", ".vsdx")) {
        $destination = $paths.Documents
    }
    elseif ($ext -in @(".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac", ".wma", ".alac", ".aiff")) {
        $destination = $paths.Music
    }
    elseif ($ext -in @(".exe", ".msi", ".bat")) {
        $destination = $paths.Apps
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
            $filesMoved++
            Write-Host "Moved $filesMoved file$(if ($filesMoved -ne 1) { 's' })"
        } catch {
            $failedFiles += $file.Name
            Write-Host "Failed to move '$($file.Name)'"
        }
    }
}

$totalFiles = $files.Count

if ($filesMoved -eq 0) {
    Write-Host "No files found to move"
}
elseif ($filesMoved -eq $totalFiles) {
    Write-Host "Successfully transferred OneDrive files to drive"
}
else {
    Write-Host "Successfully transferred $filesMoved/$totalFiles OneDrive files to drive"
    Start-Sleep -Seconds 5
    Write-Host "You can find files that failed to transfer in $userProfile"
}

Set-MpPreference -EnableControlledFolderAccess Enabled
