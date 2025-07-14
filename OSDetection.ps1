cls 
$osInfo = Get-ComputerInfo
$osVersion = $osInfo.OsName
$osEdition = $osInfo.WindowsEditionId

$editionDisplay = switch ($osEdition) {
    "Professional" { "Pro" }
    "Home"         { "Home" }
    default        { $osEdition }
}

$tweakSupport = switch -Wildcard ("$osVersion $osEdition") {
    "*Windows 11* Professional" { "Full tweak support (Windows 11 Pro)" }
    "*Windows 11* Home"         { "Limited tweak support (Windows 11 Home)" }
    "*Windows 10* Professional" { "Most tweaks will work (Windows 10 Pro)" }
    "*Windows 10* Home"         { "Extremely limited tweak support (Windows 10 Home)" }
    default                     { "Unknown or unsupported Windows edition" }
}

Write-Host "$tweakSupport`n"
