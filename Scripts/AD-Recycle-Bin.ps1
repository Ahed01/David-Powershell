﻿' Script:    Create_Restore.vbs 
' Purpose:  This script will graphically create a Powershell script based on user input, the powershell script can be run to restore deleted AD Objects 
' Author:   Paperclips     
' Email:    magiconion_M@hotmail.com 
' Date:     Feb 2011 
' Comments: Creating a ps1 script to restore deleted AD objects 
' Notes:     
'            - The recycling feature must be enabled on teh DC that this is run on - At present only available in 2008 R2 
 
Dim objFSO, objFolder, objFile, objWMI, objItem, GUID, x, ShellMessage 
 
' ---------------------------------------------------Set the folder and file name------------------------------------------------------------------- 
strComputer = "." 
strFileName1 = "Commit_Restore.ps1" 
strFileName2 = "Query_Del_Obj.ps1" 
strFolder1 = ".\" 
strPath1 = strFolder1 & strFileName1 
strPath2 = strFolder1 & strFileName2 
 
' ----------------------------------------------------Create the File System Object----------------------------------------------------------------- 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
 
'----------------------------------------------------Check that the strFolder2 folder exists-------------------------------------------------------- 
If objFSO.FolderExists(strFolder1) Then 
Set objFolder = objFSO.GetFolder(strFolder1) 
Else 
Set objFolder = objFSO.CreateFolder(strFolder1) 
End If 
 
If objFSO.FileExists(strFolder1 & strFileName2) Then 
Set objFolder = objFSO.GetFolder(strFolder1) 
Else 
Set objFile = objFSO.CreateTextFile(strFolder1 & strFileName2) 
End If  
 
'----------------------------------------------------Generate the Query.ps1 Script and run Query Script and Open report-------------------------------- 
set objFile = nothing 
set objFolder = nothing 
Set strFileOpen2 = objFSO.CreateTextFile(strPath2, True) 
 
'---------------------generate Script--------------------------------- 
strFileOpen2.WriteLine("import-module activedirectory") 
strFileOpen2.WriteLine("Get-AdObject -filter 'isdeleted -eq $True -and name -ne ""Deleted Objects""' -includeDeletedObjects -property * |Format-List samAccountName,DistinguishedName,LastKnownParent,ObjectGUID,ObjectClass > Deleted_Obj.txt") 
strFileOpen2.Close 
 
'---------------------Run Script that was generated------------------- 
Set objShell = CreateObject("Wscript.Shell") 
objShell.Run("powershell.exe -WindowStyle minimized -noprofile .\Query_Del_Obj.ps1") 
WScript.Sleep(3000) 
 
'------------Open report that was generated by running script--------- 
ShellMessage = MsgBox("Please wait while the report is genereated" & VbNewLine & "The report will open automatically in a text file when the process completes",0,"Please wait") 
WScript.Sleep(7000)  
objShell.Run("notepad.exe .\Deleted_Obj.txt") 
 
'-----------------------------------------------------Check that the strFolder1 folder exists-------------------------------------------------------- 
If objFSO.FolderExists(strFolder1) Then 
Set objFolder = objFSO.GetFolder(strFolder1) 
Else 
Set objFolder = objFSO.CreateFolder(strFolder1) 
End If 
 
If objFSO.FileExists(strFolder1 & strFileName1) Then 
Set objFolder = objFSO.GetFolder(strFolder1) 
Else 
Set objFile = objFSO.CreateTextFile(strFolder1 & strFileName1) 
End If  
' -----Cleanup----- 
 
set objFile = nothing 
set objFolder = nothing 
' -----------------------------------------------------Write the information to the file------------------------------------------------------------ 
 
Set strFileOpen1 = objFSO.CreateTextFile(strPath1, True) 
' -----------------------------------------------------Create script based ojn this Criteria----------------------------------------------------------- 
 
x = MsgBox("Do you want to create the powershell script for restoring Deleted AD Objects?" & VbNewLine & "Please note that you will need the GUID" & VbnewLine & "Also note that any objects deleted prior to 180 days ago, will not be recoverable!" & VbnewLine & "" & VbnewLine & "IMPORTANT: Always restore Parent OU's first (This is because if any child objects exist under an OU, The OU must exist)",4,"Confirmation") 
  
If x = vbyes Then 
    strFileOpen1.WriteLine("import-module activedirectory") 
        Do While x = vbyes 
        Call Criteria 
        x = MsgBox("Would you like to add another GUID",4,"Confirmation") 
    Loop 
End if     
 
strFileOpen1.Close 
'---------------------Run Script that was generated------------------- 
Set objShell = CreateObject("Wscript.Shell") 
 
y = MsgBox("Do you want to commit the script for restoring Deleted AD Objects? " & VbNewLine & "The GUID's entered will be restored",4,"Confirmation") 
  
If y = vbyes Then 
    objShell.Run("powershell.exe -WindowStyle minimized -noprofile .\Commit_Restore.ps1") 
    WScript.Sleep(3000) 
    ShellMessage = MsgBox("The objects have now been restored.",0,"Finished") 
End if     
 
On Error goTo 0 
Function Criteria() 
    GUID = InputBox("Please Enter the GUID you would like to restore", "Input Criteria") 
    strFileOpen1.WriteLine("restore-ADObject -identity " &GUID) 
End Function
# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfn0NQCXVLXpNUt+5csdVW59H
# u2GgggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFF3yVXSbt2cHv8Lp
# YFTBl19uh0aeMA0GCSqGSIb3DQEBAQUABIIBAG/8uUkfJplVDM2LvatWfAwgMzGC
# 3yRam5Wll4BppaSY1f7dNThoG01nHd1kBBH8xFungaBlJcwNOzXnzcSOVt3noAZC
# 6NyIUIVCKpLSsFhxce8G0I6fE8Hxhwsqlque96Dy4EnGyPlDOecm4+SMC6q1xpyd
# 55wB+P8VPI/T+4ukXoZcmQqDs74kuLvgWWz1Th/961ZqzxJlNJQsywVygamR7OEF
# DqfXaecDl5UvalcVzaMf/hHi3Gm3posP7zM5/VK2MUMsRWvGXafSdfqM8Ha9VxXW
# NNreR6S24z9Xxy/cpSyzy8yyi5QPGLkQuChXYs2oY/s6D6Bu72Nj2H5dRpU=
# SIG # End signature block
