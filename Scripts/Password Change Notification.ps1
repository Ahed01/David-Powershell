##################################################################################################################
# Please Configure the following variables....
$smtpServer="mail.server.com"
$expireindays = 21
$from = "Company Administrator <support@mycompany.com>"
###################################################################################################################

#Get Users From AD who are enabled
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }

foreach ($user in $users)
{
  $Name = (Get-ADUser $user | foreach { $_.Name})
  $emailaddress = $user.emailaddress
  $passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
  $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
  # Check for Fine Grained Password
  if (($PasswordPol) -ne $null)
  {
    $maxPasswordAge = ($PasswordPol).MaxPasswordAge
  }
  
  else
  {
    $maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
  }
  
  
  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (get-date)
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
  $subject="Your password will expire in $daystoExpire days"
  $body ="
  Dear $name,
  <p> Your Password will expire in $daystoexpire days.<br>
  To change your password on a PC press CTRL ALT Delete and chose Change Password <br>
  <p>Thanks, <br> 
  </P>"
  
  if ($daystoexpire -lt $expireindays)
  {
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High
     
  }  
   
}