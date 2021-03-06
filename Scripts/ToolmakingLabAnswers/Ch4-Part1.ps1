
#Chapter 4 Lab Answer

Function Get-ServiceStartMode {

Param(
[string]$Computername='localhost',
[string]$StartMode='Auto',
[string]$State='Running'
)

$filter="Startmode='$Startmode' AND state='$State'"

Get-CimInstance -ClassName Win32_Service -ComputerName $Computername -Filter $filter

}

#testing
Get-ServiceStartMode
Get-ServiceStartMode -Start 'Auto' -State 'Stopped'
Get-ServiceStartMode -StartMode 'Disabled' -Computername 'SERVER01'