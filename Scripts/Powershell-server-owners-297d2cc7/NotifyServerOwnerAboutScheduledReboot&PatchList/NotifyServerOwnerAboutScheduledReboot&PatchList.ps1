cls 
#region "RàZ" 
 $HTMLHeader  =""
 $HTMLMiddle  ="" 
 $HTMLEnd     =""
 $HTMLmessage =""
 $CurrentSystemHTML =""
 $ListOfAttachments =""
 $body  =""
 $pendingRebootList="0"
#endregion  "RàZ" 

#region "Variables and Arguments"
 $ListOfAttachments = @() 
 $Emailfrom                    = "you.yourfamilyName@contoso.com" 
 $EmailServer                  = "mailGateway.XYZ.ABC.Contoso.com" 
 $path = "C:\windows\Scripts_for_wsus\Reporting\ServerOwners.csv"
 $csv = Import-csv -path $path
 $CurrentMonth = Get-Date -format MMMM
#endregion "Variables and Arguments"

#region "Get Servers requiring reboot" 
 [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null 
 if (!$wsus) { 
              $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();
 } 
 $computerScope = new-object Microsoft.UpdateServices.Administration.ComputerTargetScope; 
 $computerScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::InstalledPendingReboot;
 $updateScope = new-object Microsoft.UpdateServices.Administration.UpdateScope;
 $updateScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::InstalledPendingReboot; 
 $computers = $wsus.GetComputerTargets($computerScope); 
#endregion "Get Servers requiring reboot" 

Write-Host "Servers requiring reboot :"

#region "Loop through the servers requiring reboot list"
 $computers | foreach-object {
                              #region "RàZ"
                               $HTMLHeader  =""
                               $HTMLMiddle  ="" 
                               $HTMLEnd     =""
                               $HTMLmessage =""
                               $HTMLEnd     =""
                               $CurrentSystemHTML =""
                               $ListOfAttachments =""
                               $ListOfPatches=""
                               $body  =""
                               $pendingRebootList =  ""
                               $neededUpdate = ""
                               $pendingRebootList="0"
                              #endregion "RàZ"

                              #region "Assemble the HTML Header and CSS for our Report"
                               $HTMLHeader = @"
                               <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
                               <html><head><title>My Systems Report</title>
                               <style type="text/css">
                               <!--
                               body {
                               font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
                               }
                               #report { width: 835px; }
                               table{ 
                                  border-collapse: collapse;
                                  border: none;
                                  font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
                                  color: black;
                                  margin-bottom: 10px;
                               }
                               table td{
                                  font-size: 12px; 
                                  padding-left: 0px;
                                  padding-right: 20px;
                                  text-align: left;
                               }
                               table th {
                                  font-size: 12px;
                                  font-weight: bold;
                                  padding-left: 0px;
                                  padding-right: 20px;
                                  text-align: left;
                               }
                                  h2{ clear: both; font-size: 130%; }
                                 h3{
                                    clear: both;
                                    font-size: 115%;
                                    margin-left: 20px;
                                    margin-top: 30px;
                               }
                               p{ margin-left: 20px; font-size: 12px; }
                               table.list{ float: left; }
                               table.list td:nth-child(1){
                                  font-weight: bold;
                                  border-right: 1px grey solid;
                                  text-align: right;
                               }
                               table.list td:nth-child(2){ padding-left: 7px; }
                               table tr:nth-child(even) td:nth-child(even){ background: #CCCCCC; }
                               table tr:nth-child(odd) td:nth-child(odd){ background: #F2F2F2; }
                               table tr:nth-child(even) td:nth-child(odd){ background: #DDDDDD; }
                               table tr:nth-child(odd) td:nth-child(even){ background: #E5E5E5; }
                               div.column { width: 320px; float: left; }
                               div.first{ padding-right: 20px; border-right: 1px  grey solid; }
                               div.second{ margin-left: 30px; }
                               table{ margin-left: 20px; }
                               -->
                               </style>
                               </head>
                               <body> 
"@                                    
                              #endregion "Assemble the HTML Header and CSS for our Report"


                              #If current ComputerName in csv == current Server in the for loop 
                              #--> send email to owners ;) 
                             
                              #I'm doing the following to get the short server name or netbios name...  
                              #$_ServerName = $_.FullDomainName.Replace(".fr.frroot.contoso-intl.com","").replace(".contoso.com","").replace(".contosodev.com","").replace(".cognos.com","").replace(".fr.frroot.contoso-intl.com","").replace(".contoso.local","").ToUpper().Trim(); 
                              $_ServerName = $_.FullDomainName.Split('.').ToUpper().Trim() |select -first 1 
                              #for later Html use 
                              write-host  $_ServerName
                              #$pendingRebootList = $pendingRebootList + $_.FullDomainName + "<br>" ;
                              #Show which updates are causing the reboot required for the computer.  Remove the next 5 lines to only generate a list of computers. 
                              $updatesForReboot = $_.GetUpdateInstallationInfoPerUpdate($updateScope);
                              $updatesForReboot | foreach-object { 
                                                                 $neededUpdate = $wsus.GetUpdate($_.UpdateId);
                                                                 "   "+$neededUpdate.Title | write-host;
                                                                  #$pendingRebootList = $pendingRebootList + ">"+ $neededUpdate.Title + "<br>";                                                            
                                                                  #Remove previous lines to only show computers that need updates
                                                                 $ListOfPatches =  $ListOfPatches + "&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;" + $neededUpdate.Title + "<br>"; #for later Html use 
                                                                }
                              #HTML Email Message Body for Servers Requiring reboot
                              $CurrentSystemHTML = @"
                              <div id="report">
                              <font color="#0404B4">
                              Dears,<br><br>
                              as part of the $CurrentMonth Microsoft Windows monthly security patching cycle, <br> new updates were applied on $_ServerName.<br>                                      
                              <br>To complete the installation process, <b> $_ServerName will be restarted - tonight by 11PM</b>.<br>
                              <br>
                              Patch List : <br>
                              $ListOfPatches 
                              <br>  <br>  
                              If you don't agree about the restart time <br> or if you are not the current owner of this server  as mentioned below,  <br> please let us know by replying to this email.
                              <br>  <br>                                             
"@ 
 
                              # Add the current System HTML Report into the final HTML Report body
                              $HTMLMiddle += $CurrentSystemHTML

                             
                              #1 loop through csv file
                              #2 determine Server Owners 
                              #3 complete building the email html body 
                              #4 send the email to owners
                               foreach($line in $csv)
                               { 
                                if ($line.Servername.ToLower().Trim() -eq $_ServerName.ToLower().Trim() )
                                {
                                 $BUOwnerEmail            = $line.BUOwnerEmail.ToLower().Trim()
                                 $TechnicalOwnerEmail     = $line.TechnicalOwnerEmail.ToLower().Trim()
                                 ##################################################################################################
                                 # Actually, as I don't want to specify any Change Management Link so I'm setting it to empty value..
                                 <#$ChangeLink = $line.ChangeLink 
                                 $HTMLEnd = @"
                                 <br>BUOwner : $BUOwnerEmail
                                 <br>TechnicalOwner :  $TechnicalOwnerEmail    
                                 <br>Change Management Ticket link : $ChangeLink
                                 <br><br>Best Regards.<br><table class="list"><tr></tr></table></div></body></html>
"@#> 
                                 ##################################################################################################
                                 $HTMLEnd = @"
                                 <br>BUOwner : $BUOwnerEmail 
                                 <br>TechnicalOwner :  $TechnicalOwnerEmail    
                                 <br><br>Best Regards.<br><table class="list"><tr></tr></table></div></body></html>
"@                                                                        
                                 #Assemble the final report from all our HTML sections
                                 $HTMLmessage = $HTMLHeader + $HTMLMiddle + $HTMLEnd
                                 # Save the report out to a file in the current path
                                 $HTMLmessage | Out-File ((Get-Location).Path + "\Notification_" + $line.Servername.ToUpper().Trim() + "_.html")
                                                                              
                                 ####### proceed to tests using your adress by commenting the BUOwner and TechOwner email lines and uncommenting your line
                                 #$Emailto                  = 'myemailaddresshere@contoso.com'
                                 $Emailto                       = $BUOwnerEmail + "," +  $TechnicalOwnerEmail + "," + "myemailaddress@contoso.com"
                                 $EmailSubject                  = $line.Servername.ToUpper().Trim() + "  - server security patching"
                                 Write-Host   "Emailto     : " $BUOwnerEmail + "   " +  $TechnicalOwnerEmail 
                                 #Write-Host   "Change Link : " $ChangeLink
                                 $HTMLmessage           = $HTMLmessage + "<br><br><br>" + $line.BUOwnerEmail.ToLower().Trim() + "," + $line.TechnicalOwnerEmail.ToLower().Trim()
                                 ##### comment the following if you want to !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                 send-mailmessage    -from $Emailfrom -to $Emailto -subject $EmailSubject -BodyAsHTML -body $HTMLmessage -priority Normal -smtpServer $EmailServer
                                 ##### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                }
                               }
                             } 
#endregion "Loop through the servers requiring reboot list"