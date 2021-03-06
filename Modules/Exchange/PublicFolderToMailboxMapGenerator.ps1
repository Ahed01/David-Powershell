# .SYNOPSIS
# PublicFolderToMailboxMapGenerator.ps1
#    Generates a CSV file that contains the mapping of public folder branch to mailbox
#
# .DESCRIPTION
#
# Copyright (c) 2011 Microsoft Corporation. All rights reserved.
#
# THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
# OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
param(
    # Mailbox size 
    [Parameter(
	Mandatory=$true,
        HelpMessage = "Size (in Bytes) of any one of the Public folder mailboxes in destination. (E.g. For 1GB enter 1 followed by nine 0's)")]
    [long] $MailboxSize,

    # File to import from
    [Parameter(
        Mandatory=$true,
        HelpMessage = "This is the path to a CSV formatted file that contains the folder names and their sizes.")]
    [ValidateNotNull()]
    [string] $ImportFile,

    # File to export to
    [Parameter(
        Mandatory=$true,
        HelpMessage = "Full path of the output file to be generated. If only filename is specified, then the output file will be generated in the current directory.")]
    [ValidateNotNull()]
    [string] $ExportFile
    )

# Folder Node's member indices
# This is an optimization since creating and storing objects as PSObject types
# is an expensive operation in powershell
# CLASSNAME_MEMBERNAME
$script:FOLDERNODE_PATH = 0;
$script:FOLDERNODE_MAILBOX = 1;
$script:FOLDERNODE_TOTALITEMSIZE = 2;
$script:FOLDERNODE_AGGREGATETOTALITEMSIZE = 3;
$script:FOLDERNODE_PARENT = 4;
$script:FOLDERNODE_CHILDREN = 5;
$script:MAILBOX_NAME = 0;
$script:MAILBOX_UNUSEDSIZE = 1;
$script:MAILBOX_ISINHERITED = 2;

$script:ROOT = @("`\", $null, 0, 0, $null, @{});

#load hashtable of localized string
Import-LocalizedData -BindingVariable MapGenerator_LocalizedStrings -FileName PublicFolderToMailboxMapGenerator.strings.psd1

# Function that constructs the entire tree based on the folderpath
# As and when it constructs it computes its aggregate folder size that included itself
function LoadFolderHierarchy() 
{
    foreach ($folder in $script:PublicFolders)
    {
        $folderSize = [long]$folder.FolderSize;
        if ($folderSize -gt $MailboxSize)
        {
            Write-Host "[$($(Get-Date).ToString())]" ($MapGenerator_LocalizedStrings.MammothFolder -f $folder, $folderSize, $MailboxSize);
            return $false;
        }

        # Start from root
        $parent = $script:ROOT;
        foreach ($familyMember in $folder.FolderName.Split('\', [System.StringSplitOptions]::RemoveEmptyEntries))
        {
            # Try to locate the appropriate subfolder
            $child = $parent[$script:FOLDERNODE_CHILDREN][$familyMember];
            if ($child -eq $null)
            {
                # Create and add subfolder to parent's children
                $child = @($folder.FolderName, $null, $folderSize, $folderSize, $parent, @{});
                $parent[$script:FOLDERNODE_CHILDREN][$familyMember] = $child;
            }

            # Add child's individual size to parent's aggregate size
            $parent[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE] += $folderSize;
            $parent = $child;
        }
    }

    return $true;
}

# Function that assigns content mailboxes to public folders
# $node: Root node to be assigned to a mailbox
# $mailboxName: If not $null, we will attempt to accomodate folder in this mailbox
function AllocateMailbox()
{
    param ($node, $mailboxName)

    if ($mailboxName -ne $null)
    {
        # Since a mailbox was supplied by the caller, we should first attempt to use it
        if ($node[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE] -le $script:PublicFolderMailboxes[$mailboxName][$script:MAILBOX_UNUSEDSIZE])
        {
            # Node's contents (including branch) can be completely fit into specified mailbox
            # Assign the folder to mailbox and update mailbox's remaining size
            $node[$script:FOLDERNODE_MAILBOX] = $mailboxName;
            $script:PublicFolderMailboxes[$mailboxName][$script:MAILBOX_UNUSEDSIZE] -= $node[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE];
            if ($script:PublicFolderMailboxes[$mailboxName][$script:MAILBOX_ISINHERITED] -eq $false)
            {
                # This mailbox was not parent's content mailbox, but was created by a sibling
                $script:AssignedFolders += New-Object PSObject -Property @{FolderPath = $node[$script:FOLDERNODE_PATH]; TargetMailbox = $node[$script:FOLDERNODE_MAILBOX]};
            }

            return $mailboxName;
        }
    }

    $newMailboxName = "Mailbox" + ($script:NEXT_MAILBOX++);
    $script:PublicFolderMailboxes[$newMailboxName] = @($newMailboxName, $MailboxSize, $false);

    $node[$script:FOLDERNODE_MAILBOX] = $newMailboxName;
    $script:AssignedFolders += New-Object PSObject -Property @{FolderPath = $node[$script:FOLDERNODE_PATH]; TargetMailbox = $node[$script:FOLDERNODE_MAILBOX]};
    if ($node[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE] -le $script:PublicFolderMailboxes[$newMailboxName][$script:MAILBOX_UNUSEDSIZE])
    {
        # Node's contents (including branch) can be completely fit into the newly created mailbox
        # Assign the folder to mailbox and update mailbox's remaining size
        $script:PublicFolderMailboxes[$newMailboxName][$script:MAILBOX_UNUSEDSIZE] -= $node[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE];
        return $newMailboxName;
    }
    else
    {
        # Since node's contents (including branch) could not be fitted into the newly created mailbox,
        # put it's individual contents into the mailbox
        $script:PublicFolderMailboxes[$newMailboxName][$script:MAILBOX_UNUSEDSIZE] -= $node[$script:FOLDERNODE_TOTALITEMSIZE];
    }

    $subFolders = @(@($node[$script:FOLDERNODE_CHILDREN].Values) | Sort-Object @{Expression={$_[$script:FOLDERNODE_AGGREGATETOTALITEMSIZE]}; Ascending=$true});
    $script:PublicFolderMailboxes[$newMailboxName][$script:MAILBOX_ISINHERITED] = $true;
    foreach ($subFolder in $subFolders)
    {
        $newMailboxName = AllocateMailbox $subFolder $newMailboxName;
    }

    return $null;
}

# Function to check if further optimization can be done on the output generated
function TryAccomodateSubFoldersWithParent()
{
    $numAssignedFolders = $script:AssignedFolders.Count;
    for ($index = $numAssignedFolders - 1 ; $index -ge 0 ; $index--)
    {
        $assignedFolder = $script:AssignedFolders[$index];

        # Locate folder's parent
        for ($jindex = $index - 1 ; $jindex -ge 0 ; $jindex--)
        {
            if ($assignedFolder.FolderPath.StartsWith($script:AssignedFolders[$jindex].FolderPath))
            {
                # Found first ancestor
                $ancestor = $script:AssignedFolders[$jindex];
                $usedMailboxSize = $MailboxSize - $script:PublicFolderMailboxes[$assignedFolder.TargetMailbox][$script:MAILBOX_UNUSEDSIZE];
                if ($usedMailboxSize -le $script:PublicFolderMailboxes[$ancestor.TargetMailbox][$script:MAILBOX_UNUSEDSIZE])
                {
					# If the current mailbox can fit into its ancestor mailbox, add the former's contents to ancestor
					# and remove the mailbox assigned to it.Update the ancestor mailbox's size accordingly
                    $script:PublicFolderMailboxes[$assignedFolder.TargetMailbox][$script:MAILBOX_UNUSEDSIZE] = $MailboxSize;
                    $script:PublicFolderMailboxes[$ancestor.TargetMailbox][$script:MAILBOX_UNUSEDSIZE] -= $usedMailboxSize;
                    $assignedFolder.TargetMailbox = $null;
                }

                break;
            }
        }
    }
    
    if ($script:AssignedFolders.Count -gt 1)
    {
        $script:AssignedFolders = $script:AssignedFolders | where {$_.TargetMailbox -ne $null};
    }
}

# Parse the CSV file
Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.ProcessFolder;
$script:PublicFolders = Import-CSV $ImportFile;

# Check if there is atleast one public folder in existence
if (!$script:PublicFolders)
{
    Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.ProcessEmptyFile;
    return;
}

Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.LoadFolderHierarchy;
$loadHierarchy = LoadFolderHierarchy;
if ($loadHierarchy -ne $true)
{
    Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.CannotLoadFolders;
    return;
}

# Contains the list of instantiated public folder maiboxes
# Key: mailbox name, Value: unused mailbox size
$script:PublicFolderMailboxes = @{};
$script:AssignedFolders = @();
$script:NEXT_MAILBOX = 1;

Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.AllocateFolders;
$ignoreReturnValue = AllocateMailbox $script:ROOT $null;

Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.AccomodateFolders;
TryAccomodateSubFoldersWithParent;

Write-Host "[$($(Get-Date).ToString())]" $MapGenerator_LocalizedStrings.ExportFolderMap;
$script:NEXT_MAILBOX = 2;
$previous = $script:AssignedFolders[0];
$previousOriginalMailboxName = $script:AssignedFolders[0].TargetMailbox;
$numAssignedFolders = $script:AssignedFolders.Count;

# Prepare the folder object that is to be finally exported
# During the process, rename the mailbox assigned to it.  
# This is done to prevent any gap in generated mailbox name sequence at the end of the execution of TryAccomodateSubFoldersWithParent function
for ($index = 0 ; $index -lt $numAssignedFolders ; $index++)
{
    $current = $script:AssignedFolders[$index];
    $currentMailboxName = $current.TargetMailbox;
    if ($previousOriginalMailboxName -ne $currentMailboxName)
    {
        $current.TargetMailbox = "Mailbox" + ($script:NEXT_MAILBOX++);
    }
    else
    {
        $current.TargetMailbox = $previous.TargetMailbox;
    }

    $previous = $current;
    $previousOriginalMailboxName = $currentMailboxName;
}

# Export the folder mapping to CSV file
$script:AssignedFolders | Export-CSV -Path $ExportFile -Force -NoTypeInformation -Encoding "Unicode";

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUx8+Ur193aqIoAWUQdXnknW4L
# GFagggpaMIIFIjCCBAqgAwIBAgIQBg4i3l65iHFvsYhyMrxXATANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE0MDcxNzAwMDAwMFoXDTE1MDcy
# MjEyMDAwMFowaTELMAkGA1UEBhMCQ0ExCzAJBgNVBAgTAk9OMREwDwYDVQQHEwhI
# YW1pbHRvbjEcMBoGA1UEChMTRGF2aWQgV2F5bmUgSm9obnNvbjEcMBoGA1UEAxMT
# RGF2aWQgV2F5bmUgSm9obnNvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAN0ZOWCIOEyhtxA/koB0azqKK40Pw3fa8GLif/ZM0cXJWGawkVgxOMbejeJW
# YCqXgEHF2MX/cJY8svCmLlX8M7AdjXYgtAS+C+cEHxrGAMMzj3/9EOu6DjzxIcwL
# l1GKoUwy8X3/GRGk3sBWT5CwKYRJdh9goWy74ltZN+sTKKeDHqpfuvxye6c++PC7
# 86wzm4MwfOIuPE9StFeo/0nKheEukfK9cpthlE5dUHpW0OjmJdX/g0mEdIjm2/Q2
# 50fzQyLQXOuMVIJ4Qk2comMDNRvZZvSPOBwWZ6fAR4tXfZwlpUcLv3wBbIjslhT7
# XasCm73TdBj+ZFDx2tUtpWguP/0CAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBS+FASXsrRle2tLXdkVyoT1Dbw7
# QDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEB
# BHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsG
# AQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEy
# QXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEAbhjcmv+WCZwWCIYQwiEsH94SesBr0cPqWjEtJrBefqU9zFdB
# u5oc/WytxdCkEj5bxkoN9aJmuDAZnHNHBwIYeUz0vNByZRz6HsPzNPxLxThajJTe
# YOHlSTMI/XzBhJ7VzCb3YFhkD5f9gcJ5n+Z94ebd/1SoIvc9iwC3tTf5x2O7aHPN
# iyoWLTV4+PgDntCy/YDj11+uviI9sUUjAajYPEDvoiWinyT+7RlbStlcEuBwqvqT
# nLaiRsK17rjawW87Nkq/jB8rymUR/fzluIpHmPA4P0NazH4v5f62mpMFqdk0osMU
# QJ/qqACQ+2+/eAw7Gr6igNvlsxQpPfxsPNtUkTCCBTAwggQYoAMCAQICEAQJGBtf
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
# Q0ECEAYOIt5euYhxb7GIcjK8VwEwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIEIJHT98j+qyd7X
# QUC4S3CozttwMA0GCSqGSIb3DQEBAQUABIIBAE+iVIZz9hQyaHx8B1xSezDMNTLo
# 5ajRJIEoxn1HB837pmxHy1nmRgUK0v1/H4figU1vcxX5reJtYFgVAwJJLex9vz1X
# ofQQh47+eAlcPRiK1kO6nPFWFheJR/hnojRJt3hy62zFIZEjIp8fHcrg/tx9zZRQ
# pyMUqVJVVSTRnvjpPcDtLJ59GTPF4uhcqbAiSPbcu+rnR7tSVkNrTEammMn27Z2u
# hfA764R2msAhB0oYDcIjAUdKdxI/hCEx6PCuQOXsTSTdqkfrtL6WkE/PxCEDPI8W
# +aoLzQlEoPKKcCOTBgpQzGBg1gN92kTFm7MB5kEpuHZzTo0J5yk8XTKmBhc=
# SIG # End signature block
