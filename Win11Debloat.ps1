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
