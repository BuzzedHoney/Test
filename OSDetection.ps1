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
    "*Windows 11* Professional" { "w111p" } 
    "*Windows 11* Home"         { "w11h" } 
    "*Windows 10* Professional" { "w10p" } 
    "*Windows 10* Home"         { "w10h" } 
    default                     { "d" } 
}

Write-Host "$tweakSupport`n"
