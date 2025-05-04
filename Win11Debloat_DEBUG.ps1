$directoryPath = "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master"
New-Item -ItemType Directory -Force -Path $directoryPath | Out-Null

[System.IO.File]::WriteAllText("$directoryPath\CustomAppsList", "Clipchamp.Clipchamp
Microsoft.3DBuilder
Microsoft.549981C3F5F10   #Cortana app
Microsoft.BingFinance
Microsoft.BingFoodAndDrink            
Microsoft.BingHealthAndFitness         
Microsoft.BingNews
Microsoft.BingSports
Microsoft.BingTranslator
Microsoft.BingTravel 
Microsoft.BingWeather
Microsoft.Getstarted   # Cannot be uninstalled in Windows 11
Microsoft.Messaging")

Start-Process powershell -ArgumentList "-WindowStyle Minimized -Command & ([scriptblock]::Create((Invoke-RestMethod 'https://debloat.raphi.re/'))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableWidgets -DisableStartRecommended -ShowHiddenFolders -ShowKnownFileExt -HideSearchTb -DisableFastStartup -DisableStickyKeys"
