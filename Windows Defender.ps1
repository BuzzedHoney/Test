Write-Host "Applying Security Tweaks"

Write-Host "Configuring Windows Defender"

Write-Host "Updating Windows Defender"

Update-MpSignature

Write-Host "Enabling Windows Defender"

Set-MpPreference -DisableRealtimeMonitoring $false

Write-Host "Configuring Windows Defender"

Set-MpPreference -PerformanceModeStatus Disabled

Set-MpPreference -MAPSReporting Advanced

Set-MpPreference -SubmitSamplesConsent 0

Set-MpPreference -EnableControlledFolderAccess Enabled

Write-Host "Configuring Firewall"

Write-Host "Enabling Firewall"

Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

Write-Host "Configuring Firewall"

Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -ne 'Public'} | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Public }
