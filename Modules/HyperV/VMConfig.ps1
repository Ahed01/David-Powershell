
  
Function Add-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter(Mandatory = $true)]
        [String]$Key,
        
        [parameter(Mandatory = $true)]
        [String]$Value,
        
        [string]$Server = ".", 
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM = (Get-VM -Name $VM -server $Server)}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Add-KVP  -VM $_ @PSBoundParameters}} 
        if ($VM -is [System.Management.ManagementObject]) {
            $KvpItem = ([wmiclass]"\\$($vm.__server)\root\virtualization:Msvm_KvpExchangeDataItem").createinstance()
            $null=$KvpItem.psobject.properties #Without this the command will fail on Powershell V1 
            $KvpItem.Name = $key 
            $KvpItem.Data = $Value 
            $KvpItem.Source = 0 
            $VSMgtSvc = (Get-WmiObject -computerName $vm.__server -NameSpace  $HyperVNamespace -Class "MsVM_virtualSystemManagementService") 
            if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_KVPSet -f $key,$value))) {
                $result=$VSMgtSvc.AddKvpItems($VM, @($KvpItem.GetText([System.Management.TextFormat]::WmiDtd20)))     
                if     ($result.returnValue -eq 4096){test-wmijob $result.job -wait -Description $lstr_KVP_Waiting -StatusOnly } 
                elseif ($result.returnValue -eq 0)   {$lstr_KVPSetSucess -f $key,$Value,$vm.elementName  } else {write-error ($lstr_KVPSetFailure -f $key,$Value,$vm.elementName,$result )}
            }
        }
   }     
}      



Function Add-VMRASD 
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true)]
        [System.Management.ManagementObject]$VM ,
        [parameter(Mandatory = $true)]
        [System.Management.ManagementObject]$RASD ,
        $PSC, 
        [switch]$force
    )
        if ($psc -eq $null) { $psc = $pscmdlet }
        $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
        if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_CreateHW -f $Rasd.ElementName))) {
            $result = $VSMgtSvc.AddVirtualSystemResources($VM.__Path, @($Rasd.GetText([System.Management.TextFormat]::WmiDtd20)) )
            if ( ($result | Test-wmiResult -wait -JobWaitText ($lstr_CreateHW -f $Rasd.ElementName)`
                                           -SuccessText ($lstr_CreateHWSuccess -f $Rasd.ElementName, $VM.elementname) `
                                           -failText ($lstr_CreateHWFailure -f $Rasd.ElementName, $vm.elementname) ) -eq [returnCode]::ok) {
                                      IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                      [wmi]$Result.NewResources[0] | Add-Member -passthru -name "VMElementName" -MemberType noteproperty -value $($vm.elementName) 
            }
    }
}


Function Add-VMRemoteFXController
{# .ExternalHelp  MAML-vmConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)] 
        $VM,     
        
        [int][validateRange(1,4)]$Monitors = 1, 
        [RemoteFxResoultion]$Resolution=0,
        
        [ValidateNotNullOrEmpty()] 
        $Server = ".",     #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
        if ($VM.count -gt 1 ) {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Add-VMRemoteFXController -VM $_ @PSBoundParameters}}
        if ($VM.__CLASS -eq 'Msvm_ComputerSystem') {
            $RFXRASD=NEW-VMRasd -ResType ([resourcetype]::GraphicsController) -ResSubtype 'Microsoft Synthetic 3D Display Controller' -Server $vm.__Server
            $RFXRASD.MaximumMonitors =  $monitors
            $RFXRASD.MaximumScreenResolution = $Resolution
            add-VmRasd -rasd $RFXRASD -vm $vm -PSC $psc -force:$force
       }
    }     
}


Function Get-VMCPUCount
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%",  
        
        [ValidateNotNullOrEmpty()]
        $Server = "."        #May need to look for VM(s) on Multiple servers
        )
     Process {
         Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
             $v.getRelated("MsVM_ProcessorSettingData") |  Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
         }
     } 
}


Function Get-VMIntegrationComponent
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        
        [ValidateNotNullOrEmpty()]
        $Server="."         #May need to look for VM(s) on Multiple servers
    )
    process {
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') { 
            (Get-vmSettingData -vm $vm -Server $Vm.__server).getRelated()  | Where-Object {$_.allocationUnits -eq "integration Components"}  |
               Add-Member -PassThru -Name "VMElementName" -MemberType NoteProperty -Value  $vm.elementName
        }
    }
} 


Function Get-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        
        [ValidateNotNullOrEmpty()] 
        $Server = "."  #May need to look for VM(s) on Multiple servers
    )
    Process {
         if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
         if ($VM.count -gt 1 ) {$VM | foreach-Object {get-VMKVP -VM $_ -Server $Server} }
         if ($vm.__CLASS -eq 'Msvm_ComputerSystem') { 
             $KVPComponent=(Get-WmiObject -computername $VM.__Server -Namespace $HyperVNamespace -query "select * from Msvm_KvpExchangeComponent where systemName = '$($vm.name)'")
             if ($KVPComponent.GuestIntrinsicExchangeItems  ) {
                 ($KVPComponent.GuestIntrinsicExchangeItems + $KVPComponent.GuestExchangeItems ) | forEach-object `
                     -begin {$KVPObj = New-Object -TypeName System.Object 
                             Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name "VMElementName" -Value $vm.elementName
                     } `
                     -process {([xml]$_).SelectNodes("/INSTANCE/PROPERTY") | ForEach-Object -process {if ($_.name -eq "Name") {$propName=$_.value}; if  ($_.name -eq "Data") {$Propdata=$_.value} } `
                                                                                            -end     {Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name $PropName -Value $PropData}
                     }  `
                     -end {[string[]]$Descriptions=@()
                           if ($KvpObj.ProcessorArchitecture -eq 0)  {$descriptions += "x86" }
                           if ($KvpObj.ProcessorArchitecture -eq 9)  {$descriptions += "x64" }
                           if ($KvpObj.ProductType -eq 1 )           {$descriptions += "Workstation" }
                           if ($KvpObj.ProductType -eq 2 )           {$descriptions += "Domain Controller" }
                           if ($KvpObj.ProductType -eq 3 )           {$descriptions += "Server" } 
                           foreach  ($Key in $LHash_suites.keys) {
                                  if ($KvpObj.suiteMask -band $key)  {$descriptions += $suites.$key}
                           }
                           Add-Member -inputObject $KvpObj -MemberType NoteProperty -Name "Descriptions"  -Value $descriptions
                           $KvpObj
                     } 
             }
         }
    }
}



Function Get-VMMemory
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [ValidateNotNullOrEmpty()]
        $Server = "."
    )
    Process {
         Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
             $v.getRelated("MSVM_MemorySettingData") |  Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
         }
    }     
}


Function Get-VMProcessor
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [ValidateNotNullOrEmpty()]
        $Server = "."         #May need to look for VM(s) on Multiple servers
    )
    process {
        if ($VM -is [String])  {$VM = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 )   {$VM | foreach-Object { Get-VMProcessor -VM $_ -Server $Server} }    
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem')   {
            Get-WmiObject -ComputerName $vm.__server -namespace $HyperVNamespace -Query "associators of {$($vm.__Path)} where resultclass=MSVM_Processor" |
                Add-Member -passthru -name "VMElementName" -MemberType noteproperty -value $($vm.elementName)  } 
    }
}



Function Get-VMRemoteFXController
{# .ExternalHelp  MAML-vmConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM = "%" ,
        
        [ValidateNotNullOrEmpty()] 
        $Server = "."  #May need to look for VM(s) on Multiple servers

    )
    Process {
       get-vmsettingData -vm $vm -server $SERVER | foreach-object { $_.getRelated("Msvm_Synthetic3DDisplayControllerSettingData")  }
  
    }
}


Function Get-VMSerialPort
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
     param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%", 
        
        [Alias("PortNo")]
        $PortNumber ,
        
        [ValidateNotNullOrEmpty()]
        $Server = "."       #May need to look for VM(s) on Multiple servers
    )
    process {Foreach ($v in (Get-vmSettingData -vm $vm -server $server) ) {
                 $v.getRelated("MSVM_ResourceAllocationSettingData") | 
                   Where-Object {($_.ResourceSubType -eq "Microsoft Serial Port") -and ($_.Caption -like "*$PortNumber")}  |
                      Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($v.elementName) 
                } 
   }
}


Function Get-VMSettingData
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%", 
        
        [ValidateNotNullOrEmpty()]        
        $Server = "."
    )
    process {
        if ($VM -is [String])  { $vm = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 )   { $VM | ForEach-object { Get-VMSettingData -VM $_ -Server $Server} }
        if ($vm.__Class -eq "Msvm_VirtualSystemSettingData") { $VM }
        if ($vm.__Class -eq "Msvm_ComputerSystem")           {
            Get-WmiObject -ComputerName $vm.__server -namespace $HyperVNamespace -Query "associators of {$($vm.__Path)} where resultclass=MSVM_VirtualSystemSettingData" |
                 where-object {$_.instanceID -eq "Microsoft:$($vm.name)"} | Add-Member -passthru -name "VMElementName" -MemberType noteproperty   -value $($vm.elementName)                                                                
        }
    }
}


Function New-VMRASD
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [int]$ResType,   # The integers here are defined in the enum resourcetype.
                         # Needed as [int] below, and never passed as strings. 
        
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [string]$ResSubType, 
        
        [ValidateNotNullOrEmpty()]
        [string]$Server = "."  #Only create resource allocation settings data objects on one server
    )
    
    $ac = ((Get-WmiObject -ComputerName $Server -Namespace $HyperVNamespace `
        -Query "SELECT * FROM MSVM_AllocationCapabilities WHERE ResourceType = $ResType AND ResourceSubType = '$ResSubType'").__Path).Replace("\", "\\")
    
    New-Object System.Management.ManagementObject((Get-WmiObject -ComputerName $Server -Namespace $HyperVNamespace `
        -Query "SELECT * FROM MSVM_SettingsDefineCapabilities WHERE ValueRange=0 AND GroupComponent = '$ac'").PartComponent)
}

Function Remove-VMKVP
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM="%", 
        
        [parameter(Mandatory = $true)]
        [String]$Key,
        
        [ValidateNotNullOrEmpty()]    
        $Server = ".",        #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM = (Get-VM -Name $VM -server $Server)}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Remove-VMKVP  -VM $_ @PSBoundParameters}} 
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            $KvpItem = ([wmiclass]"\\$($VM.__Server)\root\virtualization:Msvm_KvpExchangeDataItem").createinstance()
            $null=$KvpItem.psobject.properties #Without this the command will fail on Powershell V1 
            $KvpItem.Name = $key 
            $KvpItem.Data = ""
            $KvpItem.Source = 0
            $VSMgtSvc = (Get-WmiObject -computerName $vm.__server -NameSpace  $HyperVNamespace -Class "MsVM_virtualSystemManagementService") 
            if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstrRemove  -f $key ))) {
               $result=$VSMgtSvc.RemoveKvpItems($VM, @($KvpItem.GetText([System.Management.TextFormat]::WmiDtd20)) )   
               if     ($result.returnValue -eq 4096){test-wmijob $Result.job -wait -Description $lstr_KVP_Waiting -StatusOnly } 
               elseif ($result.returnValue -eq 0)   {$lstr_KVPRemoveSucess -f $key,$vm.elementName} else {$lstr_KVPRemoveFailure -f $key,$vm.elementName,$result}
            }   
       }
    }   
}




Function Remove-VMRASD
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true)]
        $RASD ,
        
        $VM ,   # VM is discovered in the funtion, may be passed for backwards comapatibility
        $PSC, 
        [switch]$Force
    )
    if ($psc -eq $null) { $psc = $pscmdlet }
    $HWLabel  = $Rasd.elementName
    $VM  = Get-VM $rasd 
    $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
    if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_RemoveHW -f $HWlabel))) {
         $result=$VSMgtSvc.RemoveVirtualSystemResources($VM.__Path, @( $Rasd.__Path )) 
         if     ( $result.returnValue -eq [returnCode]::OK)         {  IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                                                       [returncode]::ok
                                                                       write-verbose ($lstr_RemoveHWSuccess -f $Hwlabel, $vm.elementname)
         }  
         elseif ( $result.returnValue -eq [returnCode]::JobStarted) {
             $job = Test-WMIJob -Wait -Job $result.job
             if     ($job.jobstate -eq [JobState]::completed )      { IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                                                      [returncode]::ok
                                                                      write-verbose ($lstr_RemoveHWSuccess -f $Hwlabel, $vm.elementname)
             }  
             else                                                   { write-error   ($lstr_RemoveHWFailure -f $Hwlabel, $vm.elementname , $job.ErrorDescription ) }    
         }
         else                                                       { write-error   ($lstr_RemoveHWFailure -f $Hwlabel, $vm.elementname , [resultCode]$Result.returnValue) }
    }
}


Function Remove-VMRemoteFXController
{# .ExternalHelp  MAML-vmConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)] 
        $VM, 
        
        [ValidateNotNullOrEmpty()]  
        $Server=".",                    #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet}  ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
        if ($VM.count -gt 1 ) {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Remove-RemoteFXController -VM $_  @PSBoundParameters}}
        $controller= (Get-VMRemoteFXController -vm $vm )
        if ($Controller -is [System.Management.ManagementObject]) {
	        remove-VMRasd -VM $vm -rasd $controller -PSC $psc -force:$force
        }
    }	
}

Function Set-VMCPUCount
{# .ExternalHelp  MAML-VMConfig.XML
   [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM,     
        
        [ValidateRange(1,4)]
        $CPUCount ,         
        $Limit, 
        $Reservation,
        $Weight,
        
        [ValidateNotNullOrEmpty()]
        $Server = ".",       #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($psc -eq $null) { $psc = $pscmdlet ;  $PSBoundParameters.add("psc",$psc) }
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -server $server) }
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMCPUCount -VM $_  @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            $procsSettingData=Get-VMCpuCount $VM 
            if ((($reservation -gt 0 -and $reservation -lt 100)) -or (($limit -gt 0) -and ($limit -lt 100))) {write-warning $LStr_CPUScalesWarning}
            if ($CPUCount    -ne $null) {$procsSettingData.VirtualQuantity=$CPUCount}
            if ($Reservation -ne $null) {$procsSettingData.Reservation = $Reservation}
            if ($Limit       -ne $null) {$procsSettingData.Limit = $Limit}
            if ($Weight      -ne $null) {$procsSettingData.weight = $Weight}
            Set-VMRASD -vm  $vm -rasd $procsSettingData -psc $psc             
        }
    }
 
}


Function Set-VMIntegrationComponent
{# .ExternalHelp  MAML-VMConfig.XML
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(ValueFromPipeline = $true)]
        $VM="%",
        [String[]]$ComponentName="*",
        [vmstate]$State,
        
        [ValidateNotNullOrEmpty()]
        $Server=".",      #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
            foreach ($c in $componentName)  {(get-vmSettingData -vm $vm -server $server) | foreach-object {$_.getRelated() |          #get-wmiobject  -computername $vm.__SERVER -namespace $HyperVNamespace  -Query "associators of {$vmsd}" | 
                                              where-object {($_.allocationUnits -eq "integration Components") -and ($_.elementName -like "$c*")} | 
                                                  foreach-object {If (-not $state) {$_.enabledState = ($_.enabledState -bxor 1)} 
                                                                  else             {$_.enabledState = [int]$state}
                                                                  Set-VMRASD  -rasd $_ -PSC $psc -force:$force                                             
                                                  }                  
                                        }
        }
   }
} 


Function Set-VMMemory
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $VM, 
        
        [Alias("MemoryInBytes")]
        [long]$Memory = 0 , 
        [long]$limit            = $memory , 
        [long]$Weight           = 1000 ,
        [ValidateRange(5,2000)]
        [long]$BufferPercentage = 20 ,
        
        [Switch]$Dynamic ,
        
        $Server = ".",       #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) { $VM = Get-VM -Name $VM -Server $Server}
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMMemory -VM $_ @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
	       $SettingData  = Get-VMMemory -VM $VM
           if ($memory -eq 0)           {$memory  = $SettingData.VirtualQuantity   }
           if ($limit  -eq  0)          {$limit   = $SettingData.Limit }
           # The API takes the amount of memory in MB, in multiples of 2MB. 
           # Assume that anything less than 2097152 is in aready MB (we aren't assigning 2TB to the VM). If user enters "1024MB" or 0.5GB divide by 1MB  
           
           if (-not ($memory % 2mb))  {$memory /= 1mb}
           if (-not ($Limit  % 2mb))  {$Limit  /= 1mb}
           
           if ($dynamic)  {  $settingData.DynamicMemoryEnabled = $True 
                               $settingData.TargetMemoryBuffer = $BufferPercentage 
                                           $settingData.Weight = $weight
                                            $SettingData.Limit = $limit
                                      $SettingData.Reservation = $SettingData.VirtualQuantity = $memory } 
           else {$SettingData.Limit = $SettingData.Reservation = $SettingData.VirtualQuantity = $Memory 
                             $settingData.DynamicMemoryEnabled = $false}
           Set-VMRASD -vm  $vm -rasd $SettingData -psc $psc  
        }
    }
}


Function Set-VMRASD 
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [System.Management.ManagementObject]$VM , #VM no longer needed but kept for compatibility
        [parameter(Mandatory = $true)]
        $RASD ,
        $PSC, 
        [switch]$Force
    )
        if ($psc -eq $null) { $psc = $pscmdlet }
        $VSMgtSvc = Get-WmiObject -ComputerName $rasd.__Server -Namespace $HyperVNamespace -Class "MSVM_VirtualSystemManagementService"
        $VM  = Get-VM $rasd 
        if ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), ($lstr_ModifyHW   -f $Rasd.ElementName))) {
             if ( ($VSMgtSvc.ModifyVirtualSystemResources($VM.__Path, @($Rasd.GetText([System.Management.TextFormat]::WmiDtd20)) ) |
                     Test-wmiResult -wait  -JobWaitText ($lstr_ModifyHW -f $Rasd.ElementName)`
                                    -SuccessText ($lstr_ModifyHWSuccess -f $Rasd.ElementName, $VM.elementname) `
                                    -failText    ($lstr_ModifyHWFailure -f $Rasd.ElementName, $vm.elementname) ) -eq [returnCode]::ok) { 
                                    IF ((Get-Module FailoverClusters) -and (Get-vmclusterGroup $VM)) {Sync-VMClusterConfig $vm | out-null }
                                    $rasd.get() ;  $rasd
             }                       
        }
}
    

Function Set-VMRemoteFXController
{# .ExternalHelp  MAML-vmConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [parameter(ParameterSetName="Path" , Mandatory = $true, ValueFromPipeline = $true , position=0)]
        $VM,
        
        [int][validateRange(1,4)]$Monitors , 
        [RemoteFxResoultion]$Resolution ,
        
        
        [parameter(ParameterSetName="Controller")]
        $RFxRASD,
        
        [parameter(ParameterSetName="Path")][ValidateNotNullOrEmpty()] 
        $Server = ".",     #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($pscmdlet.ParameterSetName -eq "Path") {
            if ($VM -is [String]) {$VM=(Get-VM -Name $VM -Server $Server) }
            if ($VM.count -gt 1 ) {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMRemoteFXController -VM $_ @PSBoundParameters}}
            if ($VM.__CLASS -eq 'Msvm_ComputerSystem') {  
                $RFXRASD=Get-VMRemoteFXController $VM
                if ($RFXRASD -eq $null) {Add-VMRemoteFXController @PSboundParameters }
            }    
        }    
        if ($RFXRASD.count -gt 1 ) {[Void]$PSBoundParameters.Remove("RFXRASD") ; $RFXRASD | ForEach-object {Set-VMRemoteFXController -RFXRASD $_ @PSBoundParameters}}
        if ($RFXRASD.__CLASS -eq 'Msvm_Synthetic3DDisplayControllerSettingData') { 
     
                        if ($Monitors)   { $RFXRASD.MaximumMonitors         = $Monitors   }
                        if ($Resolution) { $RFXRASD.MaximumScreenResolution = $Resolution }
                        Set-VmRasd -rasd   $RFXRASD -PSC $psc -force:$force
        }
    }
}            


Function Set-VMSerialPort
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $VM, 
        
        [Alias("PortNo")][ValidateNotNullOrEmpty()][ValidateRange(1,2)]
        [int]$PortNumber = 1, 
        

        [String]$Connection,   #need to allow empty string
        
        [ValidateNotNullOrEmpty()]
        $Server = ".",         #May need to look for VM(s) on Multiple servers
        $PSC, 
        [switch]$Force
    )
    process {
        if ($psc -eq $null)  {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) { $VM = Get-VM -Name $VM -Server $Server }
        if ($VM.count -gt 1 ) {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Set-VMSerialPort -VM $_  @PSBoundParameters}}
        if ($vm.__CLASS -eq 'Msvm_ComputerSystem') {
            write-debug "Connecting serial port $portNumber to $connection"   
            $comPortRASD = Get-VMSerialPort -VM $VM -PortNumber $PortNumber      
            $comPortRASD.Connection = $Connection
            Set-VMRASD -vm $vm -rasd $ComPortRASD -psc $psc
        }
    }
}

Function Sync-VMClusterConfig 
{# .ExternalHelp  MAML-VMConfig.XML
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(ValueFromPipeLine = $true)]
        $VM="%",
        
        [ValidateNotNullOrEmpty()]
        $Server = ".",
        $PSC,
        [switch]$Force
    )
    process {
        if (-not (get-command -Name Move-ClusterVirtualMachineRole -ErrorAction "SilentlyContinue")) {Write-warning $lstr_noCluster ; return}
        if ($psc -eq $null)   {$psc = $pscmdlet} ; if (-not $PSBoundParameters.psc) {$PSBoundParameters.add("psc",$psc)}
        if ($VM -is [String]) {$VM=(Get-VM -Name $VM -server $server) }
        if ($VM.count -gt 1 )  {[Void]$PSBoundParameters.Remove("VM") ;  $VM | ForEach-object {Move-VM -VM $_  @PSBoundParameters}}
        if (($vm.__CLASS -eq 'Msvm_ComputerSystem') -and ($force -or $psc.shouldProcess(($lStr_VirtualMachineName -f $vm.elementName ), $lstr_syncConfig))) {
            Write-Progress -Activity $lstr_syncConfig -Status $vm.ElementName 
            Get-vmClusterGroup -vm $vm | Get-ClusterResource | where-object {($_.resourceType -like "Virtual Machine Configuration")}  | Update-ClusterVirtualMachineConfiguration
            Write-Progress -Activity $lstr_syncConfig -Status $vm.ElementName  -Completed
        }
    }
 }
 

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1C7cGYrKPXlAm179Yz+wWj9n
# G4+gggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE0MDcxNzAwMDAwMFoXDTE1MDcy
# MjEyMDAwMFowaTELMAkGA1UEBhMCQ0ExCzAJBgNVBAgTAk9OMREwDwYDVQQHEwhI
# YW1pbHRvbjEcMBoGA1UEChMTRGF2aWQgV2F5bmUgSm9obnNvbjEcMBoGA1UEAxMT
# RGF2aWQgV2F5bmUgSm9obnNvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAM3+T+61MoGxUHnoK0b2GgO17e0sW8ugwAH966Z1JIzQvXFa707SZvTJgmra
# ZsCn9fU+i9KhC0nUpA4hAv/b1MCeqGq1O0f3ffiwsxhTG3Z4J8mEl5eSdcRgeb+1
# jaKI3oHkbX+zxqOLSaRSQPn3XygMAfrcD/QI4vsx8o2lTUsPJEy2c0z57e1VzWlq
# KHqo18lVxDq/YF+fKCAJL57zjXSBPPmb/sNj8VgoxXS6EUAC5c3tb+CJfNP2U9vV
# oy5YeUP9bNwq2aXkW0+xZIipbJonZwN+bIsbgCC5eb2aqapBgJrgds8cw8WKiZvy
# Zx2qT7hy9HT+LUOI0l0K0w31dF8CAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBTnMIKoGnZIswBx8nuJckJGsFDU
# lDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEB
# BHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsG
# AQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEy
# QXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEAVlkBmOEKRw2O66aloy9tNoQNIWz3AduGBfnf9gvyRFvSuKm0
# Zq3A6lRej8FPxC5Kbwswxtl2L/pjyrlYzUs+XuYe9Ua9YMIdhbyjUol4Z46jhOrO
# TDl18txaoNpGE9JXo8SLZHibwz97H3+paRm16aygM5R3uQ0xSQ1NFqDJ53YRvOqT
# 60/tF9E8zNx4hOH1lw1CDPu0K3nL2PusLUVzCpwNunQzGoZfVtlnV2x4EgXyZ9G1
# x4odcYZwKpkWPKA4bWAG+Img5+dgGEOqoUHh4jm2IKijm1jz7BRcJUMAwa2Qcbc2
# ttQbSj/7xZXL470VG3WjLWNWkRaRQAkzOajhpTCCBTAwggQYoAMCAQICEAQJGBtf
# 1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIG
# A1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTEzMTAyMjEyMDAw
# MFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/DhGvZ3cH0wsxSRnP0PtFmbE620T1
# f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2qvCchqXYJawOeSg6funRZ9PG+ykn
# x9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrskacLCUvIUZ4qJRdQtoaPpiCwgla4c
# SocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/6XzLkqHlOzEcz+ryCuRXu0q16XTm
# K/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE94zRICUj6whkPlKWwfIPEvTFjg/B
# ougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8np+mM6n9Gd8lk9ECAwEAAaOCAc0w
# ggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsME8GA1UdIARIMEYwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQsFAAOCAQEA
# PuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh134LYP3DPQ/Er4v97yrfIFU3sOH2
# 0ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63XX0R58zYUBor3nEZOXP+QsRsHDpEV
# +7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPAJRHinBRHoXpoaK+bp1wgXNlxsQyP
# u6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC/i9yfhzXSUWW6Fkd6fp0ZGuy62ZD
# 2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG/AeB+ova+YJJ92JuoVP6EpQYhS6S
# kepobEQysmah5xikmmRR7zGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
# Q0ECEALqUCMY8xpTBaBPvax53DkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPXPynz7ybcuY94w
# BVF0OVxC6iVjMA0GCSqGSIb3DQEBAQUABIIBAAHytICF0Ks92HDyHmxyfYkRhfQF
# LhO3y+hAc49OCYFJHKbQXttnVshDllgnhfIeduqM5+dRw0uDGgf7fZEORBA9zGUp
# 9iW+BIhiz39GamINY32dneMKWreBa5k/cvNKkeH10tcmFY3/0nQqdVm+/AheMfK0
# rNMkpshpRbJMvA8I6akoYxakb6tvwd8RQxS/3an9QhWak50FKeqRa1pZe7E1HVBc
# PyCM039XlEUnGgSD6Z7aGWl/fy1+RMdEi16wJfAimtkk9GB1c7SUBWRCEUlsYCnc
# IK5E294bUfRgmP0XWLMMTmiSH74NtSXyekE/v2tP2gb36NjkjzEiUFMW2dU=
# SIG # End signature block
