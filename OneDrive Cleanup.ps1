Set-MpPreference -EnableControlledFolderAccess Disabled

do {
    Start-Sleep -Milliseconds 100
    $cfaStatus = (Get-MpPreference).EnableControlledFolderAccess
} while ($cfaStatus -ne 0)

Start-Sleep -Seconds 3

$userProfile = [Environment]::GetFolderPath("UserProfile")
$desktop = Join-Path $userProfile "Desktop"

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
    Desktop   = $desktop
}

foreach ($path in $paths.Values) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

$moveableExtensions = @(
    ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp", ".heic", ".avif",
    ".mp4", ".mov", ".avi", ".wmv", ".mkv", ".flv", ".webm",
    ".pdf", ".doc", ".docx", ".txt", ".rtf", ".xlsx", ".xls", ".ppt", ".pptx", ".odt", ".vsdx",
    ".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac", ".wma", ".alac", ".aiff",
    ".lnk", ".exe", ".msi", ".bat"
)

$validDirs = Get-ChildItem -Path $userProfile -Directory -Force | Where-Object {
    $excludedFolders -notcontains $_.Name -and -not ($_.Name.StartsWith('.'))
}

$files = @()
$files += Get-ChildItem -Path $userProfile -File -Force -ErrorAction SilentlyContinue | Where-Object { $moveableExtensions -contains $_.Extension.ToLower() }
foreach ($dir in $validDirs) {
    $files += Get-ChildItem -Path $dir.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $moveableExtensions -contains $_.Extension.ToLower() }
}

$exeFolders = Get-ChildItem -Path $userProfile -Recurse -Directory -Force | Where-Object {
    (Get-ChildItem -Path $_.FullName -Filter *.exe -File -ErrorAction SilentlyContinue).Count -gt 0
}

$folderMoveMode = @{}
foreach ($folder in $exeFolders) {
    $filesInFolder = Get-ChildItem -Path $folder.FullName -File -ErrorAction SilentlyContinue
    $hasNonExe = $filesInFolder | Where-Object { $_.Extension.ToLower() -ne ".exe" } | Measure-Object | Select-Object -ExpandProperty Count
    $folderMoveMode[$folder.FullName] = if ($hasNonExe -gt 0) { "MoveFolder" } else { "MoveFiles" }
}

$movedFolders = @()

function Get-DestFolder($ext) {
    switch ($ext) {
        { $_ -in ".jpg",".jpeg",".png",".bmp",".gif",".tiff",".webp",".heic",".avif" } { return $paths.Pictures }
        { $_ -in ".mp4",".mov",".avi",".wmv",".mkv",".flv",".webm" } { return $paths.Videos }
        { $_ -in ".pdf",".doc",".docx",".txt",".rtf",".xlsx",".xls",".ppt",".pptx",".odt",".vsdx" } { return $paths.Documents }
        { $_ -in ".mp3",".wav",".m4a",".ogg",".flac",".aac",".wma",".alac",".aiff" } { return $paths.Music }
        { $_ -in ".exe",".msi",".bat" } { return $paths.Apps }
        ".lnk" { return $paths.Desktop }
        default { return $null }
    }
}

[int]$filesMoved = 0
$failedFiles = @()

foreach ($file in $files) {
    $folderPath = $file.Directory.FullName
    $ext = $file.Extension.ToLower()
    if ($movedFolders -contains $folderPath) { continue }
    if ($folderMoveMode.ContainsKey($folderPath)) {
        if ($folderMoveMode[$folderPath] -eq "MoveFolder") {
            if (-not $movedFolders.Contains($folderPath)) {
                $destFolder = Join-Path $desktop (Split-Path $folderPath -Leaf)
                $i = 1
                $baseName = Split-Path $folderPath -Leaf
                while (Test-Path $destFolder) {
                    $destFolder = Join-Path $desktop "$baseName ($i)"
                    $i++
                }
                try {
                    Move-Item -Path $folderPath -Destination $destFolder -Force -ErrorAction SilentlyContinue
                    Write-Host "Moved folder '$folderPath' to Desktop"
                    $movedFolders += $folderPath
                } catch {
                    Write-Host "Failed to move folder '$folderPath': $_"
                    $failedFiles += $folderPath
                }
            }
            continue
        }
    }

    $destination = Get-DestFolder $ext
    if ($destination) {
        try {
            $destPath = Join-Path $destination $file.Name
            $i = 1
            while (Test-Path $destPath) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                $destPath = Join-Path $destination "$base ($i)$ext"
                $i++
            }
            Move-Item -Path $file.FullName -Destination $destPath -Force -ErrorAction SilentlyContinue
            $filesMoved++
            Write-Host "Moved $filesMoved file$(if ($filesMoved -ne 1) { 's' })"
        } catch {
            $failedFiles += $file.FullName
            Write-Host "Failed to move '$($file.FullName)'"
        }
    }
}

$totalFiles = ($files | Where-Object { -not ($movedFolders -contains $_.Directory.FullName) }).Count
if ($filesMoved -eq 0 -and $movedFolders.Count -eq 0) {
    Write-Host "No files or folders found to move"
}
elseif ($filesMoved -eq $totalFiles) {
    Write-Host "Successfully transferred OneDrive files to drive"
}
else {
    Write-Host "Successfully transferred $filesMoved/$totalFiles files and moved $($movedFolders.Count) folders"
    Start-Sleep -Seconds 5
    Write-Host "You can find files or folders that failed to transfer in $userProfile"
}

Set-MpPreference -EnableControlledFolderAccess Enabled
