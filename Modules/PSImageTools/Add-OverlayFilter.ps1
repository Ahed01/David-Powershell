#requires -version 2.0
function Add-OverlayFilter {    
    <#
    .Synopsis
    Creates a filter for overlaying images.

    .Description
    The Add-OverlayFilter function adds a Stamp filter of an image to a filter collection.
    The stamp filter lets you layer the specified image over another images.
    Add-OverlayFilter creates a new filter collection if none exists. 

    An image filter is Windows Image Acquisition (WIA) concept.
    Each filter represents a change to an image. 
    Add-OverlayFilter does not overlay images; it only creates a filter. 
    To overlay the image use the Set-ImageFilter function, which applies the filters.

    The Image parameter of Add-OverlayFilter is required. You cannot create a stamp (overlay) filter that is not specific to an image. 

    .Parameter Image
    Mandatory. Creates a stamp filter of the specified image.
    This parameter is required. Enter an image object, such as one returned by the Get-Image function.
    The image that is used in the filter is placed over other images when you apply the filter.

    .Parameter Filter
    Enter a filter collection (a Wia.ImageProcess COM object).
    You can also pipe a filter collection to Add-OverlayFilter.
    Each filter in the collection represents one change to an image.
    This parameter is optional. If you do not submit a filter collection, Add-OverlayFilter creates one for you.

    .Parameter Left
    The horizontal location within the image where the overlay is added. 
    The default value is zero (0). Enter a value in pixels from the left edge of the image.

    .Parameter Top
    The vertical location within the image where the overlay is added. 
    The default value is zero (0). Enter a value in pixels from the top edge of the image.

    .Parameter Passthru
    Returns an object that represents the stamp filter. 
    By default, this function does not generate output.

    .Notes
    Add-OverlayFilter uses the Wia.ImageProcess object.

    .Example
    Add-OverlayFilter –image (get-image .\Colors.jpg) –left 10 –top 10 –passthru

    .Example
    $i = get-image .\Colors.jpg
    $ol = Add-OverlayFilter –image $i –top 42 –passthru

    .Example
    C:\PS> $i = get-image .\Colors.jpg
    C:\PS> $of = Add-OverlayFilter –image $i –top 20 –left 20 –passthru
    C:\PS> ($of.filters | select properties).properties |  format-table –property Name, Value –auto

    Name       Value          
    ----       -----          
    ImageFile  System.__ComObject
    Left       20
    Top        20
    FrameIndex 0     


    .Example
    $layer = Get-Image .\Prism.jpg
    $photo = Get-Image .\Photo01.jpg            
    $NewImage = $photo | Set-ImageFilter -filter (Add-OverLayFilter -Image $layer -Left 10 -Top 10 -passThru) -passThru                    
    $NewImage.SaveFile(".\Photo01_Edited.jpg")

    .Link
    Get-Image

    .Link
    Set-ImageFilter

    .Link
    Image Manipulation in PowerShell:
    http://blogs.msdn.com/powershell/archive/2009/03/31/image-manipulation-in-powershell.aspx

    .Link
    "ImageProcess object" in MSDN
    http://msdn.microsoft.com/en-us/library/ms630507(VS.85).aspx

    .Link
    "Filter Object" in MSDN 
    http://msdn.microsoft.com/en-us/library/ms630501(VS.85).aspx

    .Link
    "How to Use Filters" in MSDN
    http://msdn.microsoft.com/en-us/library/ms630819(VS.85).aspx
    #>

    param(
    [Parameter(ValueFromPipeline=$true)]
    [__ComObject]
    $filter,
    
    [__ComObject]
    $image,
        
    [Double]$left,
    [Double]$top,
    
    [switch]$passThru                      
    )
    
    process {
        if (-not $filter) {
            $filter = New-Object -ComObject Wia.ImageProcess
        } 
        $index = $filter.Filters.Count + 1
        if (-not $filter.Apply) { return }
        $stamp = $filter.FilterInfos.Item("Stamp").FilterId                    
        $filter.Filters.Add($stamp)
        $filter.Filters.Item($index).Properties.Item("ImageFile") = $image.PSObject.BaseObject
        $filter.Filters.Item($index).Properties.Item("Left") = $left
        $filter.Filters.Item($index).Properties.Item("Top") = $top
        if ($passthru) { return $filter }         
    }
}
 

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6hZxpMo9bkPz4au9Ps7vuIU4
# 1s6gggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFArAYaOTkGyr38oz
# D7eoEQFsg4GXMA0GCSqGSIb3DQEBAQUABIIBAC52FYAJFsa7SJ8BrLAUgJagbdC7
# WTtcjDA52IekQlGCoNbG+1wTde8Z1TLpracAxjKGrMfdvR4beNi2Lxygrmgy0VK4
# 1sHteX9Od7/7ayJysPZ432QD8fGwjJ/4tgIFxpRljV7NaAGkIIML4PKBnL/GETgJ
# mwEiEsRT583wsnXwG0u5orFY2ie1spZA/oXwtq4t38nbHi9cdQU0yBj7eOmOZLpW
# f9zDj8BbUcwzTal3ua1DGBODLN+/wdjcWTuoESmaEUCi0drJTXDR9r+yaOf9cdnV
# CvMh1NmZSMqQYqxyJcktH8nAZNa1PpKRu4i9V6DE2NJg0Nl3jhGoPk+XgeY=
# SIG # End signature block
