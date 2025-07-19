Set-MpPreference -DisableRealtimeMonitoring $false

Set-MpPreference -AllowDevRemotePerformanceMode 0

Set-MpPreference -MAPSReporting Advanced

Set-MpPreference -SubmitSamplesConsent 0

Set-MpPreference -EnableControlledFolderAccess Enabled
