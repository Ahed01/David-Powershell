Function Get-ServiceInfo {

[cmdletbinding()]
Param([string]$Computername=$env:computername)

$services=Get-WmiObject -Class Win32_service -filter "state='Running'" -computername $computername

Write-Host "Found $($services.count) on $computername" -ForegroundColor Green

$services | sort -Property startname,name | Select -property startname,name,startmode,Systemname

} #close function