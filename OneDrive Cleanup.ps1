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

$paths.Values | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

$files = @(
    Get-ChildItem -Path $userProfile -Directory -Force | Where-Object {
        $excludedFolders -notcontains $_.Name -and -not ($_.Name.StartsWith('.'))
    }
) + @(
    Get-ChildItem -Path $userProfile -File -Force -ErrorAction SilentlyContinue
) #If you have a better solution for this please let me know because its very slow.

foreach ($folder in $files) {
    Get-ChildItem -Path $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $ext = $_.Extension.ToLowerInvariant()
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
                $destPath = Join-Path $destination $_.Name
                $i = 1
                while (Test-Path $destPath) {
                    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                    $ext = $_.Extension
                    $destPath = Join-Path $destination "$base ($i)$ext"
                    $i++
                }
                Move-Item -Path $_.FullName -Destination $destPath -Force
            } catch {  #If you have a better solution for this please let me know because idk what else to put.
            }
        }
    }
}

Set-MpPreference -EnableControlledFolderAccess Enabled
# This is tied to the CTT WinUtil's OneDrive Tweak which moves items in one drive into the C:\Users\[Username], so I decided to add this to make it auto seperate the files based on their type into desagnated folders.
