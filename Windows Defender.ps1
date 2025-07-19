Write-Host "Applying Security Tweaks"

Set-MpPreference -DisableRealtimeMonitoring $false

Set-MpPreference -PerformanceModeStatus Disabled

Set-MpPreference -MAPSReporting Advanced

Set-MpPreference -SubmitSamplesConsent 0

Set-MpPreference -EnableControlledFolderAccess Enabled
