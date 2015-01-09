﻿#------------------------------------------------------------------------
# Source File Information (DO NOT MODIFY)
# Source ID: 73e81dac-2fd5-4679-98af-575cf70d7413
# Source File: Toolmaking\Toolmaking.pfproj
#------------------------------------------------------------------------
#========================================================================
# Code Generated By: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.0.3
# Generated On: 6/8/2012 2:28 PM
# Generated By: Administrator
#========================================================================


#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
[void][Reflection.Assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
[void][Reflection.Assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
#endregion Import Assemblies

#Define a Param block to use custom parameters in the project
#Param ($CustomParameter)

function Main {
	Param ([String]$Commandline)
	#Note: This function starts the application
	#Note: $Commandline contains the complete argument string passed to the packager
	#Note: $Args contains the parsed arguments passed to the packager (Type: System.Array) 
	#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
	#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
	#TODO: Initialize and add Function calls to forms
	
	if((Call-MainForm_pff) -eq "OK")
	{
		
	}
	
	$global:ExitCode = 0 #Set the exit code for the Packager
}








#region Call-MainForm_pff
function Call-MainForm_pff
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$MainForm = New-Object 'System.Windows.Forms.Form'
	$OKButton = New-Object 'System.Windows.Forms.Button'
	$EventLogName = New-Object 'System.Windows.Forms.ComboBox'
	$ComputerName = New-Object 'System.Windows.Forms.TextBox'
	$labelEnterComputerName = New-Object 'System.Windows.Forms.Label'
	$labelSelectEventLog = New-Object 'System.Windows.Forms.Label'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$OnLoadFormEvent={
	#TODO: Initialize Form Controls here
	
	}
	
	
	
	
	#region Control Helper Functions
	function Load-ComboBox 
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ComboBox.
	
		.DESCRIPTION
			Use this function to dynamically load items into the ComboBox control.
	
		.PARAMETER  ComboBox
			The ComboBox control you want to add items to.
	
		.PARAMETER  Items
			The object or objects you wish to load into the ComboBox's Items collection.
	
		.PARAMETER  DisplayMember
			Indicates the property to display for the items in this control.
		
		.PARAMETER  Append
			Adds the item(s) to the ComboBox without clearing the Items collection.
		
		.EXAMPLE
			Load-ComboBox $combobox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Load-ComboBox $combobox1 "Red" -Append
			Load-ComboBox $combobox1 "White" -Append
			Load-ComboBox $combobox1 "Blue" -Append
		
		.EXAMPLE
			Load-ComboBox $combobox1 (Get-Process) "ProcessName"
	#>
		Param (
			[ValidateNotNull()]
			[Parameter(Mandatory=$true)]
			[System.Windows.Forms.ComboBox]$ComboBox,
			[ValidateNotNull()]
			[Parameter(Mandatory=$true)]
			$Items,
		    [Parameter(Mandatory=$false)]
			[string]$DisplayMember,
			[switch]$Append
		)
		
		if(-not $Append)
		{
			$ComboBox.Items.Clear()	
		}
		
		if($Items -is [Object[]])
		{
			$ComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [Array])
		{
			$ComboBox.BeginUpdate()
			foreach($obj in $Items)
			{
				$ComboBox.Items.Add($obj)	
			}
			$ComboBox.EndUpdate()
		}
		else
		{
			$ComboBox.Items.Add($Items)	
		}
	
		$ComboBox.DisplayMember = $DisplayMember	
	}#endregion
	
	$OKButton_Click={
		if ($EventLogName.Visible) {
			# retrieve event log
			if ($EventLogName.SelectedIndex -gt -1) {
				$global_events = Get-EventLog -ComputerName $ComputerName.Text `
				                        -LogName $EventLogName.SelectedItem
				#$entries | Out-GridView
				$global_logname = $EventLogName.SelectedItem
				Call-Results_pff
			}
		} else {
			# populate event log list
			$logs = Get-EventLog -ComputerName $ComputerName.Text `
			                     -List |
				    Select-Object -ExpandProperty Log
			Load-ComboBox -ComboBox $EventLogName `
			              -Items $logs
			$EventLogName.Visible = $true
			$labelSelectEventLog.Visible = $true
		}
	}
		# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$MainForm.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
		$script:MainForm_EventLogName = $EventLogName.Text
		$script:MainForm_ComputerName = $ComputerName.Text
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$OKButton.remove_Click($OKButton_Click)
			$MainForm.remove_Load($OnLoadFormEvent)
			$MainForm.remove_Load($Form_StateCorrection_Load)
			$MainForm.remove_Closing($Form_StoreValues_Closing)
			$MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# MainForm
	#
	$MainForm.Controls.Add($OKButton)
	$MainForm.Controls.Add($EventLogName)
	$MainForm.Controls.Add($ComputerName)
	$MainForm.Controls.Add($labelEnterComputerName)
	$MainForm.Controls.Add($labelSelectEventLog)
	$MainForm.ClientSize = '282, 129'
	$MainForm.FormBorderStyle = 'FixedDialog'
	$MainForm.MaximizeBox = $False
	$MainForm.MinimizeBox = $False
	$MainForm.Name = "MainForm"
	$MainForm.StartPosition = 'CenterScreen'
	$MainForm.Text = "Toolmaking Demo"
	$MainForm.add_Load($OnLoadFormEvent)
	#
	# OKButton
	#
	$OKButton.Location = '190, 94'
	$OKButton.Name = "OKButton"
	$OKButton.Size = '75, 23'
	$OKButton.TabIndex = 4
	$OKButton.Text = "OK"
	$OKButton.UseVisualStyleBackColor = $True
	$OKButton.add_Click($OKButton_Click)
	#
	# EventLogName
	#
	$EventLogName.DropDownStyle = 'DropDownList'
	$EventLogName.FormattingEnabled = $True
	$EventLogName.Location = '13, 67'
	$EventLogName.Name = "EventLogName"
	$EventLogName.Size = '252, 21'
	$EventLogName.TabIndex = 2
	$EventLogName.Visible = $False
	#
	# ComputerName
	#
	$ComputerName.Location = '12, 23'
	$ComputerName.Name = "ComputerName"
	$ComputerName.Size = '253, 20'
	$ComputerName.TabIndex = 1
	#
	# labelEnterComputerName
	#
	$labelEnterComputerName.Location = '13, 9'
	$labelEnterComputerName.Name = "labelEnterComputerName"
	$labelEnterComputerName.Size = '127, 21'
	$labelEnterComputerName.TabIndex = 0
	$labelEnterComputerName.Text = "Enter computer name:"
	#
	# labelSelectEventLog
	#
	$labelSelectEventLog.Location = '13, 53'
	$labelSelectEventLog.Name = "labelSelectEventLog"
	$labelSelectEventLog.Size = '100, 18'
	$labelSelectEventLog.TabIndex = 3
	$labelSelectEventLog.Text = "Select Event Log:"
	$labelSelectEventLog.Visible = $False
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $MainForm.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$MainForm.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$MainForm.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$MainForm.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $MainForm.ShowDialog()

}
#endregion

#region Call-Global_ps1
	#--------------------------------------------
	# Declare Global Variables and Functions here
	#--------------------------------------------
	$global_events = @()
	$global_logname = ''
	
	#Sample function that provides the location of the script
	function Get-ScriptDirectory
	{ 
		if($hostinvocation -ne $null)
		{
			Split-Path $hostinvocation.MyCommand.path
		}
		else
		{
			Split-Path $script:MyInvocation.MyCommand.Path
		}
	}
	
	#Sample variable that provides the location of the script
	[string]$ScriptDirectory = Get-ScriptDirectory
	
	
	
#endregion

#region Call-Results_pff
function Call-Results_pff
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$Results = New-Object 'System.Windows.Forms.Form'
	$OKButton2 = New-Object 'System.Windows.Forms.Button'
	$EventCountLabel = New-Object 'System.Windows.Forms.Label'
	$LogNameLabel = New-Object 'System.Windows.Forms.Label'
	$ComputerNameLabel = New-Object 'System.Windows.Forms.Label'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	
	function OnApplicationLoad {
		#Note: This function is not called in Projects
		#Note: This function runs before the form is created
		#Note: To get the script directory in the Packager use: Split-Path $hostinvocation.MyCommand.path
		#Note: To get the console output in the Packager (Windows Mode) use: $ConsoleOutput (Type: System.Collections.ArrayList)
		#Important: Form controls cannot be accessed in this function
		#TODO: Add snapins and custom code to validate the application load
		
		return $true #return true for success or false for failure
	}
	
	
	function OnApplicationExit {
		#Note: This function is not called in Projects
		#Note: This function runs after the form is closed
		#TODO: Add custom code to clean up and unload snapins when the application exits
		
		$script:ExitCode = 0 #Set the exit code for the Packager
	}
	
	$Results_Load={
		#TODO: Initialize Form Controls here
		$ComputerNameLabel.Text = $global_events[0].machinename
		$LogNameLabel.Text = $global_logname
		$EventCountLabel.Text = $global_events | measure | select -ExpandProperty count
	}
	
	$OKButton2_Click={
		#TODO: Place custom script here
		$Results.Close()
	}
		# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$Results.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$OKButton2.remove_Click($OKButton2_Click)
			$Results.remove_Load($Results_Load)
			$Results.remove_Load($Form_StateCorrection_Load)
			$Results.remove_Closing($Form_StoreValues_Closing)
			$Results.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# Results
	#
	$Results.Controls.Add($OKButton2)
	$Results.Controls.Add($EventCountLabel)
	$Results.Controls.Add($LogNameLabel)
	$Results.Controls.Add($ComputerNameLabel)
	$Results.ClientSize = '284, 166'
	$Results.ControlBox = $False
	$Results.FormBorderStyle = 'FixedDialog'
	$Results.Name = "Results"
	$Results.Text = "Results"
	$Results.add_Load($Results_Load)
	#
	# OKButton2
	#
	$OKButton2.Location = '13, 130'
	$OKButton2.Name = "OKButton2"
	$OKButton2.Size = '259, 23'
	$OKButton2.TabIndex = 3
	$OKButton2.Text = "OK"
	$OKButton2.UseVisualStyleBackColor = $True
	$OKButton2.add_Click($OKButton2_Click)
	#
	# EventCountLabel
	#
	$EventCountLabel.Location = '13, 89'
	$EventCountLabel.Name = "EventCountLabel"
	$EventCountLabel.Size = '259, 27'
	$EventCountLabel.TabIndex = 2
	$EventCountLabel.Text = "label3"
	$EventCountLabel.TextAlign = 'MiddleCenter'
	#
	# LogNameLabel
	#
	$LogNameLabel.Location = '12, 46'
	$LogNameLabel.Name = "LogNameLabel"
	$LogNameLabel.Size = '260, 23'
	$LogNameLabel.TabIndex = 1
	$LogNameLabel.Text = "label2"
	$LogNameLabel.TextAlign = 'MiddleCenter'
	#
	# ComputerNameLabel
	#
	$ComputerNameLabel.Location = '12, 9'
	$ComputerNameLabel.Name = "ComputerNameLabel"
	$ComputerNameLabel.Size = '260, 23'
	$ComputerNameLabel.TabIndex = 0
	$ComputerNameLabel.Text = "label1"
	$ComputerNameLabel.TextAlign = 'MiddleCenter'
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $Results.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$Results.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$Results.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$Results.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $Results.ShowDialog()

}
#endregion

#Start the application
Main ($CommandLine)

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdHOpGeM9y5tk8zqBKtdQKh9t
# 82+gggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFB1EroBaOCyNkrpk
# fcVgVT5tMhYxMA0GCSqGSIb3DQEBAQUABIIBADT9H2c9UHlql/6Mxq3Y7uQZyQcZ
# ujTs1oMyeFaOP6JjSPzYclRm8qn2o+1erRg2b9lA9KC3uRQHzBfCPCC2O4INEgII
# bFQTyeqAaNJEsEvRkiTaEjAvyGfhH2HTOcOshMgFOQm42qHBc9ytXMtx2svp6WvB
# wieDyKXwJZv6I9q4ByrmZSxETrvoQ++0aO4GFpR8gCe0FJpK1NmSwqfi9iZztoc5
# TrYtxX3xdSwLlYrL5MfV/lYq/6BRPNa/GCIKcnAX0VWUmcmP2BjJOgThYLiJOyor
# KLcpun3KZ7v4FOCAJUQSkbCiJwaYo9X7vLxqXfPKveOWpSj1IyoP7YGCr14=
# SIG # End signature block
