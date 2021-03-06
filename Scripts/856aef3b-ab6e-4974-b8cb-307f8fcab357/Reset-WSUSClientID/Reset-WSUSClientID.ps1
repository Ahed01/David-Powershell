$service = "wuauserv" 
$pclist = "C:\wsusPCerrors.txt" 
 
foreach ($computername in gc $PClist) 
{ 
 
$pcservice = $null 
$reg = $null 
$regkey = $null 
$SDpath = $null 
 
if (test-connection $computername -quiet -count 1) 
    { 
    write-host "Processing: "$computername 
 
    $pcservice = gwmi win32_service -computername $computername -filter "name='$service'" 
    $pcservice.stopservice() | out-null; write-host "Stopping $service service." 
 
    do {start-sleep -m 250; $pcservice = gwmi win32_service -computername $computername -filter "name='$service'"} 
    while ($pcservice.state -eq "Running") 
 
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName) 
    $regKey = $reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate", $true) 
    if ($regkey.getvalue("SUSclientid")){$regkey.deletevalue("SUSclientid")} 
    if ($regkey.getvalue("SusClientIdValidation")){$regkey.deletevalue("SusClientIdValidation")} 
    if ($regkey.getvalue("PingID")){$regkey.deletevalue("PingID")} 
    if ($regkey.getvalue("AccountDomainSid")){$regkey.deletevalue("AccountDomainSid")} 
 
    $SDpath = "\\$computername\c$\Windows\SoftwareDistribution.old" 
    if (test-path $SDpath){remove-item $SDpath -force} 
    rename-item -path \\$computername\c$\Windows\SoftwareDistribution -newname $SDpath 
    start-sleep -m 250 
    $pcservice.startservice() | out-null; write-host "Starting $service service." 
 
    cmd /c PsExec.exe \\$computername -d C:\windows\system32\wuauclt.exe /resetauthorization /detectnow 
    } 
else{write-host "Could not contact: " $computername} 
write-host "##################################################" 
} #End foreach $pc