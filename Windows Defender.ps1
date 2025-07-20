Write-Host "Applying Windows Defender Tweaks"

Update-MpSignature

Set-MpPreference -DisableRealtimeMonitoring $false

Set-MpPreference -PerformanceModeStatus Disabled

Set-MpPreference -MAPSReporting Advanced

Set-MpPreference -SubmitSamplesConsent 0

Set-MpPreference -EnableControlledFolderAccess Enabled

Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -ne 'Public'} | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Public }

