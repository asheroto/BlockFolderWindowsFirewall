<#PSScriptInfo

.VERSION 0.0.3

.GUID c7a7f36d-3d4f-4e2e-9bec-336ec8a0eb16

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Windows exe block firewall folder directory recursive

.PROJECTURI https://github.com/asheroto/BlockFolderWindowsFirewall

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Added recurse option.
[Version 0.0.3] - Updated code signing certificate.

#>

<#
.SYNOPSIS
    Block all EXEs in a specified folder in Windows Firewall.
.DESCRIPTION
	This script will block all EXEs in a specified folder in Windows Firewall. Optionally you can specify the -Recurse switch to block all EXEs in a specified folder and all subfolders.

	To unblock all EXEs in a specified folder, use the -UnblockInstead switch. Optionally you can specify the -Recurse switch to unblock all EXEs in a specified folder and all subfolders.

	Be careful when using this script, as it will block all EXEs in a specified folder and all subfolders. This can cause issues with applications that rely on EXEs in the specified folder and subfolders.

	If you specify "C:\" as the path, it will block all EXEs on the C drive. If you specify "C:\Folder" as the path, it will block all EXEs in the "C:\Folder" folder.
.EXAMPLE
    Block all EXEs in a specified folder in Windows Firewall: BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder"
.EXAMPLE
	Block all EXEs in a specified folder and subfolders in Windows Firewall: BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse
.EXAMPLE
	Unblock all EXEs in a specified folder in Windows Firewall: BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead
.EXAMPLE
	Unblock all EXEs in a specified folder and subfolders in Windows Firewall: BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse -UnblockInstead
.NOTES
    Version      : 0.0.3
    Created by   : asheroto
.LINK
    Project Site: https://github.com/asheroto/BlockFolderWindowsFirewall
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)][String]$Path,
	[Switch]$Recurse,
	[Switch]$UnblockInstead
)

# Confirm folder path exists
If (Test-Path -Path $Path -PathType Container) {
	# Folder path exists
	Write-Output ""
	Write-Output "Folder exists, continuing..."
	Write-Output ""

	# Pause for 10 seconds if the folder is C:\
	If ($Path -eq "C:\") {
		Write-Output "WARNING: You specified C:\ as the path, this will block all EXEs on the C drive. Press CTRL+C to cancel, or wait 10 seconds to continue..."
		Start-Sleep -Seconds 10
	}

	# Determine if we're blocking or unblocking
	If ($UnblockInstead) {
		# Unblocking

		# Determine if we're recursively blocking
		if ($Recurse) {
			# Recursively unblocking

			Write-Output "Recursively unblocking EXEs in $Path..."
			Write-Output ""
			Get-ChildItem -Path $Path -Filter "*.exe" -Recurse | ForEach-Object {
				$FilePath = $_.FullName
				Write-Output "Unblocking $FilePath..."
				Get-NetFirewallApplicationFilter | ? { $_.AppPath -eq "$FilePath" } | % { Get-NetFirewallRule $_.InstanceID | Remove-NetFirewallRule }
			}
		} else {
			# Not recursively unblocking

			Write-Output "Unblocking EXEs in $Path..."
			Write-Output ""
			Get-ChildItem -Path $Path -Filter "*.exe" | ForEach-Object {
				$FilePath = $_.FullName
				Write-Output "Unblocking $FilePath..."
				Get-NetFirewallApplicationFilter | ? { $_.AppPath -eq "$FilePath" } | % { Get-NetFirewallRule $_.InstanceID | Remove-NetFirewallRule }
			}
		}
	} else {
		# Blocking

		# Determine if we're recursively blocking
		if ($Recurse) {
			# Recursively blocking
			Write-Output "Recursively blocking EXEs in $Path..."
			Write-Output ""
			Get-ChildItem -Path $Path -Filter "*.exe" -Recurse | ForEach-Object {
				$FileName = $_.Name
				$FilePath = $_.FullName
				Write-Output "Blocking $FilePath..."
				New-NetFirewallRule -DisplayName "Blocked: $FileName" -Direction Outbound -Program $FilePath -Action Block | Out-Null
			}
		} else {
			# Not recursively blocking

			Write-Output "Blocking EXEs in $Path..."
			Write-Output ""
			Get-ChildItem -Path $Path -Filter "*.exe" | ForEach-Object {
				$FileName = $_.Name
				$FilePath = $_.FullName
				Write-Output "Blocking $FilePath..."
				New-NetFirewallRule -DisplayName "Blocked: $FileName" -Direction Outbound -Program $FilePath -Action Block | Out-Null
			}
		}
	}

	Write-Output "Done!"
} else {
	# Folder path does not exist
	Write-Output "Folder does NOT exist, please run script again with a valid path"
}

Write-Output ""
# SIG # Begin signature block
# MIIpMAYJKoZIhvcNAQcCoIIpITCCKR0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCp9R4dWkTshzxu
# hsCuAt6SbFDDFKcKl1cnhgj62ott86CCDh8wggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggdnMIIFT6ADAgECAhAN0Uk2zX4f3m8X7HdlwxBNMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMzE3MDAwMDAwWhcNMjQwMzE2
# MjM1OTU5WjBvMQswCQYDVQQGEwJVUzERMA8GA1UECBMIT2tsYWhvbWExETAPBgNV
# BAcTCE11c2tvZ2VlMRwwGgYDVQQKExNBc2hlciBTb2x1dGlvbnMgSW5jMRwwGgYD
# VQQDExNBc2hlciBTb2x1dGlvbnMgSW5jMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEA081RwO7808Fuab0RP0L2gthlZB8fiiGUBpnqJhsD1Bzpk+45B2LA
# qmrUp+nZIXNwr5me/55enGI9CkhaxmZoFhBxoM1u5lODNp8GaAYzIEi0IJldzZ9y
# PAQMfhTkHRiOwKBqTGO3h/gSZtaZ+8F+ltCmlXvv2vpqFpt5JL+uJm9SRIN5WLiP
# QM/isjYR+eIcaZxQeHLfbnemNcaT4cXOMChUsmG6WsoHZO1o76dCN+owz23koLy2
# Y1R3N2PMQj3kj8Bnlph6ffNnitKhXuwj3NkWwPSSQvYhcBuTcCOxpXpUjWlQNuTt
# llTHp9leKMq11raPkSaLe2qVX4eBc6HPtBT+7XagpaA409d7fmYTOLKmE0BCEdgb
# YZzYmKSyjrAgWlU9SYxurhFgHuQFD0CsBW1aXl6IEjn26cVx+hmj2KCOFELAdh1r
# 9UTNt37a/o/TYCp/mQ22/oa/224is1dpNj7RAHnNaix5n8RKKHufEh85lVjS/cBn
# 7z3cCKejyfBaUGK10SUwZKJiJ51DKkRkdh4A5cL85wKkQcFnRpfT/T+KTOEYRFT/
# vz3uK9bMLwuBj+gkP3WnlVXf67IY3FfZaQUDNdtwur4UTGrDQOn8Xl2rEy7L9VlJ
# UOCjX93WfW0B1Q4IxSdF6vIJw1m44HpIU4jxnqTBEo6BVVRCtdmp/x0CAwEAAaOC
# AgMwggH/MB8GA1UdIwQYMBaAFGg34Ou2O/hfEYb7/mF7CIhl9E5CMB0GA1UdDgQW
# BBTH3/U7rGshoJKjtOAVqNAEWJ/PBDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwgbUGA1UdHwSBrTCBqjBToFGgT4ZNaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hB
# Mzg0MjAyMUNBMS5jcmwwU6BRoE+GTWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEu
# Y3JsMD4GA1UdIAQ3MDUwMwYGZ4EMAQQBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEEgYcwgYQwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggrBgEFBQcwAoZQaHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25p
# bmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0TBAIwADANBgkqhkiG9w0B
# AQsFAAOCAgEAQtDUmTp7UG2w4A4WaT6BoMLBLqzm09S64nFfuIUFjWk3KTCStpwR
# 3KzwG78CpYb7I0G6T7O2Emv+u0WgKVaWPbLFlnrjXXB+68DxR+CFWh6UDioz/9wo
# +eD/V2eKilAc2WSEIC8NzXT3C4yEtxUmnebK7Ysxy4qLlb4Sxk9NspS+Lg3jKBxb
# ExduQWHi1ytqw9NCghzK1Y2h5/AHwSYfwz7AyRerN3gTwzmmgTaWYEHVCL0NQddO
# 1lkSz6LPq2/JWHns7I0tNPCT5nZYva1v34EZvP9+P+SUDBH8bfrm6HlTd+Z6qNW5
# ACsALaCCAsZRQ6i7UZfjolD/lADn65f46XfnNMIo8PPpagFBIvxg03DGDJQu4QnY
# AyZhtrLDxc8VLtGZP8QVBf9JVcjVD8FxMMobDnuDq0YZ1h3ydRo1dqOzWVDipp0i
# oPd0UbL7EcZr6QcM72LWFvAACyVcIiXlh5jY+JehqaZMlS9aw4WQT0gpvBOaOJqb
# vGoAbtyHRFIkFbJG/Wxkpr+VkU1JvilXCh8g0OsXwvJk4dK4GeBVa7VLlq95fLiK
# zL54EZDTY1W+YfKYUseiptRlu5XBUn15C9rTpqDZhHFz6exyLfYcJzdxJJdArjio
# UKKR9ZhLfxm1bmFMb8NPWOKH/ZI6vR0jNgwalk3nTx63ZnVAOJLH+BkxghpnMIIa
# YwIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFB
# MD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5
# NiBTSEEzODQgMjAyMSBDQTECEA3RSTbNfh/ebxfsd2XDEE0wDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# gdUKKJQDnt/4nx/Dkpd+dDwIwj8r3h0k/6zhi/9m9yIwDQYJKoZIhvcNAQEBBQAE
# ggIAK2l4NJIx864RF3gu1hbwmXWdkmBDSluOG2DEqUX+eotonVZOkgUFkOooxiX8
# mqD7JPHpUa0Oc+F+W69yxU2v2hk51zJzR99iQDqiVxMTXype8oqyEx56fTJyQ2b4
# 3ZUElfuXso/87vIdRunD9BKLWkGMQ/rH77g/s+OvMGxLctrwjrpX2jTlZ8Gj02gI
# 4ZnuO00/qVxrt4JMEDBjM4Nh539RjNnDc7BoL0wb7Lwzlg9il+KHugFl+tFVB64m
# Tn9uE4iys+nhgdANdiye1Bj3iRNajaqgYd1SktvaFjznFzQwnVTpjLvu22KtubRx
# Z7A8GcNxKVCc16RaOchEIUegWw0Q6JCw1qQWoNLG5+zbi/QUyOVX0VkIwq3YRTZa
# i/iZwS6JtF1vjHHKWdnjoQ7Sv5OSdJU3056fZphlNWPuZ8ftAq9/sZ/jgkUuA2Hz
# Kr43mDKGknpPndhSW/OPTJq70yGfshYZMuAPTPOpADvJb1Zvo4cmI+l4eHhXJovm
# 3xU+pv0qk/v9tGAjft/Qt+FLoSYlVg6bwk56kmek87QCgGTe9gv9f27OlhKx2AAD
# YiGqZwdAltO+bOgW7B+8mwvcjlfhsw69Yxrn+IDlALlYH72zxxapcB/b3y1TgL24
# SkBYsZADE4bF2GHDb+bpdT4DLwMgADvbVzfr+nSFHJBih5yhghc9MIIXOQYKKwYB
# BAGCNwMDATGCFykwghclBgkqhkiG9w0BBwKgghcWMIIXEgIBAzEPMA0GCWCGSAFl
# AwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEBBglghkgBhv1sBwEwMTANBglg
# hkgBZQMEAgEFAAQgQCAhF68ZAp8hwfXxE1Ist96NnLbIYm92WVi3GXXEhtACEAPa
# KVMUZf/d3PJdIh8HQS0YDzIwMjMwNTE5MDE0MTI4WqCCEwcwggbAMIIEqKADAgEC
# AhAMTWlyS5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1
# c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIx
# MDAwMDAwWhcNMzMxMTIxMjM1OTU5WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMI
# RGlnaUNlcnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26Ho
# FIV0MxomrNAcVR4eNm28klUMYfSdCXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6
# Va8z7GGK6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hp
# DIjG8b7gL307scpTjUCDHufLckkoHkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/t
# jdRNlYRo44DLannR0hCRRinrPibytIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqia
# nJVHhoV5PgxeZowaCiS+nKrSnLb3T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhM
# kRCWfk3h3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/
# NurlfDHn88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M5
# 0GT6Vs/g9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTA
# WOXlLimQprdhZPrZIGwYUWC6poEPCSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs
# 4Xu5zGcTB5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkD
# Tvpd6kVzHIR+187i1Dp3AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYD
# VR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxq
# II+eyG8wHQYDVR0OBBYEFGKK3tBh/I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEw
# T6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGD
# MIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYB
# BQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQEL
# BQADggIBAFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklR
# LHiIY1UJRjkA/GnUypsp+6M/wMkAmxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qY
# QitQ/Bu1nggwCfrkLdcJiXn5CeaIzn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A
# ++T/350Qp+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br
# /5iyJpU4GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMf
# hgFknADC6Vp0dQ094XmIvxwBl8kZI4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJ
# y8P7mxNfarXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrT
# mJBFYDOA4CPe+AOk9kVH5c64A0JH6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKo
# T5u92ByaUcQvmvZfpyeXupYuhVfAYOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls
# 9Oie1FqYyJ+/jbsYXEP10Cro4mLueATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB
# 0j862uXl9uab3H4szP8XTE0AotjWAQ64i+7m4HJViSwnGWH2dwGMMIIGrjCCBJag
# AwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIw
# MzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCw
# zIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFz
# sbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ
# 7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7
# QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/teP
# c5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCY
# OjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9K
# oRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6
# dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM
# 1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbC
# dLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbEC
# AwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1N
# hS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9P
# MA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcB
# AQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggr
# BgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7Zv
# mKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI
# 2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/ty
# dBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVP
# ulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmB
# o1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc
# 6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3c
# HXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0d
# KNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZP
# J/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLe
# Mt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDy
# Divl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n
# 79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoX
# DTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNl
# cnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQw
# H/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6
# dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXG
# XuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXn
# Mcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy
# 19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFY
# F/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+Skjqe
# PdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFg
# qrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJR
# R3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7Gr
# hotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2
# MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9P
# MB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIB
# hjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0Eu
# Y3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV
# 5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8t
# tzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKh
# SLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO
# 7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WY
# IsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3
# AamfV6peKOK5lDGCA3YwggNyAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQDE1pckuU+jwqSj0pB4A9WjAN
# BglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJ
# KoZIhvcNAQkFMQ8XDTIzMDUxOTAxNDEyOFowKwYLKoZIhvcNAQkQAgwxHDAaMBgw
# FgQU84ciTYYzgpI1qZS8vY+W6f4cfHMwLwYJKoZIhvcNAQkEMSIEIEM7H1wk884C
# aSzoK2i8c6DCn1Z1EiaqVTeqK2Tswf/XMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIE
# IMf04b4yKIkgq+ImOr4axPxP5ngcLWTQTIB1V6Ajtbb6MA0GCSqGSIb3DQEBAQUA
# BIICAA8qbsw2B5hkkxDnA+4gIG4fYIZL7nYIl10dT4A7hjpEyy8Js/WxxcLRWkct
# YeXb/SIA8Zkm9puKyvOiNxQIAQcCtjEmcUOG0kc15jZoau5NyuMVa/91K96YgUwv
# Wxi5OjQsAX1E8T56l54cB600yqsLkpKle8iKM7BmKE5bzLmE56rw9S63Lw3XG68a
# pXyqu1pV4BDvF5xQsGqEa+UqSsNlNS3xMwkVlp+iZ4JTtAkZYYwIbY00A/HgTF79
# aX4f88m17L+RwaOP6XHFYxndo5+pzIKWXThlYsZZH1iDiFXzZqucdKsQMhzdwqCu
# ebCfaBZ+RnibUOUQHXtnHFW8dAeuDm8OFM7MhYrm4nfuzI4d2jcIlWZL5xYe+fcQ
# ajHxBbjhAK54BXsvgb8O9dHXxYaDxRCU9aqgiKtcIiJPaVyWhAtdkXD+WDo9citn
# iuN/L84AyZHW5n9TdmcEggpUGO8IzAoC4okVHT8PAfOhZsJoDwjePpFAffrfhW+U
# N8foCDLJjs3lHHzRe+IGRB07dubBQswoi75UIYRh+LJ22V7ZsKeYFZKK/x55DRXk
# DJ4bPgGX2DETqaVbQ2DKk+0i8jZgkXRW48jrpM1WeyembuDBUy4xk7RLHhXBqILm
# JItVdrMQ3zf4Hj8mPyFiFr9737TdE5S5yJ0uuXlu3TG/M+dx
# SIG # End signature block
