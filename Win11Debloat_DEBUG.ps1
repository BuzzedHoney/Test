New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master" | Out-Null

Invoke-RestMethod 'https://raw.githubusercontent.com/bluethedoor/Test/main/FinalAppList' | Set-Content "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master\CustomAppsList"

& ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableDesktopSpotlight -DisableWidgets -ShowHiddenFolders -ShowKnownFileExt -DisableFastStartup -DisableStickyKeys

# Start-Process powershell -ArgumentList "-WindowStyle Minimized -Command & ([scriptblock]::Create((Invoke-RestMethod 'https://debloat.raphi.re/'))) -Custom CMDS"

# -DisableStartRecommended -HideSearchTb
