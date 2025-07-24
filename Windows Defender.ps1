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

Write-Host "Security Tweaks Done"

Start-Sleep -Seconds 3

try {
    Write-Host "Blocking Spying Domains"

    Start-Sleep -Seconds 3

    $domains = @(
	"bing.com",
        "oca.telemetry.microsoft.com",
        "oca.microsoft.com",
        "kmwatsonc.events.data.microsoft.com",
        "watson.telemetry.microsoft.com",
        "umwatsonc.events.data.microsoft.com",
        "ceuswatcab01.blob.core.windows.net",
        "ceuswatcab02.blob.core.windows.net",
        "eaus2watcab01.blob.core.windows.net",
        "eaus2watcab02.blob.core.windows.net",
        "weus2watcab01.blob.core.windows.net",
        "weus2watcab02.blob.core.windows.net",
        "co4.telecommand.telemetry.microsoft.com",
        "cs11.wpc.v0cdn.net",
        "cs1137.wpc.gammacdn.net",
        "modern.watson.data.microsoft.com",
        "functional.events.data.microsoft.com",
        "browser.events.data.msn.com",
        "self.events.data.microsoft.com",
        "v10.events.data.microsoft.com",
        "v10c.events.data.microsoft.com",
        "us-v10c.events.data.microsoft.com",
        "eu-v10c.events.data.microsoft.com",
        "v10.vortex-win.data.microsoft.com",
        "vortex-win.data.microsoft.com",
        "telecommand.telemetry.microsoft.com",
        "www.telecommandsvc.microsoft.com",
        "umwatson.events.data.microsoft.com",
        "watsonc.events.data.microsoft.com",
        "eu-watsonc.events.data.microsoft.com",
        "v20.events.data.microsoft.com",
        "settings-win.data.microsoft.com",
        "settings.data.microsoft.com",
        "inference.location.live.net",
        "location-inference-westus.cloudapp.net",
        "maps.windows.com",
        "dev.virtualearth.net",
        "ecn.dev.virtualearth.net",
        "ecn-us.dev.virtualearth.net",
        "weathermapdata.blob.core.windows.net",
        "arc.msn.com",
        "ris.api.iris.microsoft.com",
        "api.msn.com",
        "assets.msn.com",
        "c.msn.com",
        "g.msn.com",
        "ntp.msn.com",
        "srtb.msn.com",
        "www.msn.com",
        "fd.api.iris.microsoft.com",
        "staticview.msn.com",
        "mucp.api.account.microsoft.com",
        "query.prod.cms.rt.microsoft.com",
        "business.bing.com",
        "c.bing.com",
        "th.bing.com",
        "edgeassetservice.azureedge.net",
        "c-ring.msedge.net",
        "fp.msedge.net",
        "I-ring.msedge.net",
        "s-ring.msedge.net",
        "dual-s-ring.msedge.net",
        "creativecdn.com",
        "a-ring-fallback.msedge.net",
        "fp-afd-nocache-ccp.azureedge.net",
        "prod-azurecdn-akamai-iris.azureedge.net",
        "widgetcdn.azureedge.net",
        "widgetservice.azurefd.net",
        "fp-vs.azureedge.net",
        "ln-ring.msedge.net",
        "t-ring.msedge.net",
        "t-ring-fdv2.msedge.net",
        "tse1.mm.bing.net",
        "config.edge.skype.com",
        "evoke-windowsservices-tas.msedge.net",
        "cdn.onenote.net",
        "tile-service.weather.microsoft.com"
    )
    foreach ($domain in $domains) {
        $ruleName = "Block - $domain"
        $ruleExists = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

        if (-not $ruleExists) {
            $resolvedIPs = Resolve-DnsName $domain -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq "A" } | Select-Object -ExpandProperty IPAddress

            if ($resolvedIPs) {
                New-NetFirewallRule -DisplayName $ruleName `
                                    -Direction Outbound `
                                    -Action Block `
                                    -RemoteAddress $resolvedIPs `
                                    -Profile Domain,Private,Public `
                                    -Enabled True `
                                    -Description "Blocked telemetry/tracking domain"
                Write-Host "Blocked: $domain"
            }
            else {
                Write-Host "Could not resolve: $domain" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Rule already exists: $ruleName" -ForegroundColor Cyan
        }
    }
    Write-Host "Privacy Enhanced"
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
