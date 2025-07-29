Set-MpPreference -EnableControlledFolderAccess Disabled
$usersPath = "C:\Users"
$validUsers = Get-ChildItem $usersPath -Directory | Where-Object {
    $_.Name -ne "Public" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" -and $_.Name -ne "All Users" -and $_.Name -ne "Administrator"
}

foreach ($user in $validUsers) {
    $userProfile = $user.FullName

    $paths = @{
        Pictures = Join-Path $userProfile "Pictures"
        Videos   = Join-Path $userProfile "Videos"
        Documents = Join-Path $userProfile "Documents"
        Apps     = Join-Path $userProfile "Desktop\OneDrive Backup Apps"
    }

    # Ensure destination folders exist
    foreach ($folder in $paths.Values) {
        if (-not (Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
        }
    }

    # Classify files by extension and move them
    Get-ChildItem -Path $userProfile -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $ext = $_.Extension.ToLowerInvariant()
        $destination = $null

        switch ($ext) {
            # Images
            { $_ -in ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp", ".heic", ".avif" } { $destination = $paths.Pictures; break }
            # Videos
            { $_ -in ".mp4", ".mov", ".avi", ".wmv", ".mkv", ".flv", ".webm" } { $destination = $paths.Videos; break }
            # Docs
            { $_ -in ".pdf", ".doc", ".docx", ".txt", ".rtf", ".xlsx", ".xls", ".ppt", ".pptx", ".odt", ".vsdx" } { $destination = $paths.Documents; break }
            # Apps and installers
            { $_ -in ".exe", ".msi", ".bat", ".cmd" } { $destination = $paths.Apps; break }
        }

        if ($destination) {
            try {
                Move-Item -Path $_.FullName -Destination (Join-Path $destination $_.Name) -Force -ErrorAction Stop
                Write-Host "Moved $($_.Name) to $destination"
            } catch {
                Write-Host "Failed to move $($_.Name): $_"
            }
        }
    }
}
Set-MpPreference -EnableControlledFolderAccess Enabled
