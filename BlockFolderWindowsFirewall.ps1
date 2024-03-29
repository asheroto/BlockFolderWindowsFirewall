<#PSScriptInfo

.VERSION 1.0.2

.GUID c7a7f36d-3d4f-4e2e-9bec-336ec8a0eb16

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Windows exe block firewall folder directory recursive

.PROJECTURI https://github.com/asheroto/BlockFolderWindowsFirewall

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Added recurse option.
[Version 0.0.3] - Updated code signing certificate.
[Version 1.0.0] - Major improvements. Added -Version, -Help, -CheckForUpdate. Added inbound/outbound option (will do both if not specified).
[Version 1.0.1] - Added additional line breaks, changed first line to warning, and added PowerShell gallery info to -CheckForUpdate
[Version 1.0.2] - Added UpdateSelf function, fixed CheckForUpdate function.

#>

<#
.SYNOPSIS
    Block all EXEs in a specified folder in Windows Firewall.
.DESCRIPTION
	This script provides functionalities to manage (block/unblock) executables (EXEs) in specified directories via Windows Firewall. The operation can be targeted at individual directories or recursively applied to subdirectories as well.

	By default, both Inbound and Outbound connections will be affected, but the scope can be controlled via the -Inbound or -Outbound switches.

	Here are key switches to guide the script's behavior:
	  -Path to specify the target directory.
	  -Recurse switch will include all subdirectories in the operation.
	  -UnblockInstead switch changes the operation mode from blocking to unblocking.
	  -Inbound switch will only affect Inbound connections.
	  -Outbound switch will only affect Outbound connections.

	Additional utilities include:
	  -Version switch displays the current version of the script.
	  -Help switch brings up the help information for the script usage.
	  -CheckForUpdate switch verifies if the current script version is up-to-date.

	Special care should be taken when using this script due to its potentially broad impact. Blocking EXEs indiscriminately may disrupt applications depending on these executables.

	For detailed examples of usage, refer to the .EXAMPLE section.
.EXAMPLE
    BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder"
    This command will block both inbound and outbound traffic for all EXEs in the specified folder.
.EXAMPLE
	BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse
	This command will block both inbound and outbound traffic for all EXEs in the specified folder and all its subfolders.
.EXAMPLE
	BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Inbound
	This command will block only inbound traffic for all EXEs in the specified folder.
.EXAMPLE
	BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead
	This command will unblock both inbound and outbound traffic for all EXEs in the specified folder.
.EXAMPLE
	BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse -UnblockInstead
	This command will unblock both inbound and outbound traffic for all EXEs in the specified folder and all its subfolders.
.EXAMPLE
	BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Outbound -UnblockInstead
	This command will unblock only outbound traffic for all EXEs in the specified folder.
.PARAMETER Path
    The directory path to target for the operation.
.PARAMETER Recurse
    Include all subdirectories in the operation.
.PARAMETER UnblockInstead
    Change the operation mode from blocking to unblocking.
.PARAMETER Inbound
    Only affect Inbound connections.
.PARAMETER Outbound
    Only affect Outbound connections.
.PARAMETER CheckForUpdate
    Verify if the current script version is up-to-date.
.PARAMETER UpdateSelf
    Updates the script to the latest version on PSGallery.
.PARAMETER Version
    Display the current version of the script.
.PARAMETER Help
    Bring up the help information for the script usage.
.NOTES
    Version      : 1.0.2
    Created by   : asheroto
.LINK
    Project Site: https://github.com/asheroto/BlockFolderWindowsFirewall
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [String]$Path,
    [Switch]$Outbound,
    [Switch]$Inbound,
    [Switch]$Recurse,
    [Switch]$UnblockInstead,
    [switch]$CheckForUpdate,
    [switch]$UpdateSelf,
    [switch]$Version,
    [switch]$Help
)

# Version
$CurrentVersion = '1.0.2'
$RepoOwner = 'asheroto'
$RepoName = 'BlockFolderWindowsFirewall'
$PowerShellGalleryName = 'BlockFolderWindowsFirewall'

# Display version if -Version is specified
if ($Version.IsPresent) {
    $CurrentVersion
    exit 0
}

# Help
if ($Help) {
    Get-Help -Name $MyInvocation.MyCommand.Source -Full
    exit 0
}

function Get-GitHubRelease {
    <#
        .SYNOPSIS
        Fetches the latest release information of a GitHub repository.

        .DESCRIPTION
        This function uses the GitHub API to get information about the latest release of a specified repository, including its version and the date it was published.

        .PARAMETER Owner
        The GitHub username of the repository owner.

        .PARAMETER Repo
        The name of the repository.

        .EXAMPLE
        Get-GitHubRelease -Owner "asheroto" -Repo "winget-install"
        This command retrieves the latest release version and published datetime of the winget-install repository owned by asheroto.
    #>
    [CmdletBinding()]
    param (
        [string]$Owner,
        [string]$Repo
    )
    try {
        $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop

        $latestVersion = $response.tag_name
        $publishedAt = $response.published_at

        # Convert UTC time string to local time
        $UtcDateTime = [DateTime]::Parse($publishedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

        [PSCustomObject]@{
            LatestVersion     = $latestVersion
            PublishedDateTime = $PublishedLocalDateTime
        }
    } catch {
        Write-Error "Unable to check for updates.`nError: $_"
        exit 1
    }
}

function CheckForUpdate {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [version]$CurrentVersion,
        [string]$PowerShellGalleryName
    )

    $Data = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName

    Write-Output ""
    Write-Output ("Repository:       {0,-40}" -f "https://github.com/$RepoOwner/$RepoName")
    Write-Output ("Current Version:  {0,-40}" -f $CurrentVersion)
    Write-Output ("Latest Version:   {0,-40}" -f $Data.LatestVersion)
    Write-Output ("Published at:     {0,-40}" -f $Data.PublishedDateTime)

    if ($Data.LatestVersion -gt $CurrentVersion) {
        Write-Output ("Status:           {0,-40}" -f "A new version is available.")
        Write-Output "`nOptions to update:"
        Write-Output "- Download latest release: https://github.com/$RepoOwner/$RepoName/releases"
        if ($PowerShellGalleryName) {
            Write-Output "- Run: $RepoName -UpdateSelf"
            Write-Output "- Run: Install-Script $PowerShellGalleryName -Force"
        }
    } else {
        Write-Output ("Status:           {0,-40}" -f "Up to date.")
    }
    exit 0
}

function UpdateSelf {
    try {
        # Get PSGallery version of script
        $psGalleryScriptVersion = (Find-Script -Name $PowerShellGalleryName).Version

        # If the current version is less than the PSGallery version, update the script
        if ($CurrentVersion -lt $psGalleryScriptVersion) {
            Write-Output "Updating script to version $psGalleryScriptVersion..."

            # Install NuGet PackageProvider if not already installed
            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                Install-PackageProvider -Name "NuGet" -Force
            }

            # Trust the PSGallery if not already trusted
            $psRepoInstallationPolicy = (Get-PSRepository -Name 'PSGallery').InstallationPolicy
            if ($psRepoInstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted | Out-Null
            }

            # Update the script
            Install-Script $PowerShellGalleryName -Force

            # If PSGallery was not trusted, reset it to its original state
            if ($psRepoInstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name 'PSGallery' -InstallationPolicy $psRepoInstallationPolicy | Out-Null
            }

            Write-Output "Script updated to version $psGalleryScriptVersion."
            exit 0
        } else {
            Write-Output "Script is already up to date."
            exit 0
        }
    } catch {
        Write-Output "An error occurred: $_"
        exit 1
    }
}

function Block-Exe {
    param(
        [String]$FileName,
        [String]$FilePath,
        [Switch]$Inbound,
        [Switch]$Outbound
    )

    If ($Inbound.IsPresent -eq $false -and $Outbound.IsPresent -eq $false) {
        Write-Output "Blocking Inbound and Outbound $FilePath..."
        New-NetFirewallRule -DisplayName "$FileName" -Direction Inbound -Program $FilePath -Action Block | Out-Null
        New-NetFirewallRule -DisplayName "$FileName" -Direction Outbound -Program $FilePath -Action Block | Out-Null
    } elseif ($Inbound.IsPresent) {
        Write-Output "Blocking Inbound $FilePath..."
        New-NetFirewallRule -DisplayName "$FileName" -Direction Inbound -Program $FilePath -Action Block | Out-Null
    } elseif ($Outbound.IsPresent) {
        Write-Output "Blocking Outbound $FilePath..."
        New-NetFirewallRule -DisplayName "$FileName" -Direction Outbound -Program $FilePath -Action Block | Out-Null
    }
}

function Unblock-Exe {
    param(
        [String]$FilePath,
        [Switch]$Inbound,
        [Switch]$Outbound
    )

    if ($Inbound.IsPresent -eq $false -and $Outbound.IsPresent -eq $false) {
        Write-Output "Unblocking Inbound and Outbound $FilePath..."
        $matchingRules = Get-NetFirewallApplicationFilter | ? { $_.AppPath -eq "$FilePath" } | % { Get-NetFirewallRule $_.InstanceID }
        if ($matchingRules) {
            $matchingRules | Remove-NetFirewallRule
        } else {
            Write-Warning "No matching Inbound and Outbound rules found for $FilePath"
        }
    } elseif ($Inbound.IsPresent) {
        Write-Output "Unblocking Inbound $FilePath..."
        $matchingRules = Get-NetFirewallApplicationFilter | ? { $_.AppPath -eq "$FilePath" } | % { Get-NetFirewallRule $_.InstanceID | ? { $_.Direction -eq "Inbound" } }
        if ($matchingRules) {
            $matchingRules | Remove-NetFirewallRule
        } else {
            Write-Warning "No matching Inbound rules found for $FilePath"
        }
    } elseif ($Outbound.IsPresent) {
        Write-Output "Unblocking Outbound $FilePath..."
        $matchingRules = Get-NetFirewallApplicationFilter | ? { $_.AppPath -eq "$FilePath" } | % { Get-NetFirewallRule $_.InstanceID | ? { $_.Direction -eq "Outbound" } }
        if ($matchingRules) {
            $matchingRules | Remove-NetFirewallRule
        } else {
            Write-Warning "No matching Outbound rules found for $FilePath"
        }
    }
}

# Update the script if -UpdateSelf is specified
if ($UpdateSelf) { UpdateSelf }

# Check for updates if -CheckForUpdate is specified
if ($CheckForUpdate) { CheckForUpdate -RepoOwner $RepoOwner -RepoName $RepoName -CurrentVersion $CurrentVersion -PowerShellGalleryName $PowerShellGalleryName }

# If Path is not set, check if -Version, -Help, or -CheckForUpdate is specified
if ("" -eq $Path) {
    if ($Version.IsPresent -or $Help.IsPresent -or $CheckForUpdate.IsPresent) {
        # Do nothing
    } else {
        Write-Error "-Path is required"
        exit 1
    }
}

# If -Recurse or -UnblockInstead is specified, -Path is required
if ($Recurse.IsPresent -or $UnblockInstead.IsPresent -or $Outbound.IsPresent -or $Inbound.IsPresent) {
    if ("" -eq $Path) {
        Write-Error "-Path is required"
        exit 1
    }
}

# Confirm folder path exists
if (Test-Path -Path $Path -PathType Container) {
    # Update note
    Write-Output "`n$RepoName $CurrentVersion"
    Write-Output "To check for updates, run $RepoName -CheckForUpdate`n"

    # Folder path exists
    Write-Output "Folder exists, continuing...`n"

    # Pause for 10 seconds if the folder is C:\
    If ($Path -eq "C:\") {
        Write-Output "WARNING: You specified C:\ as the path, this will block all EXEs on the C drive. Press CTRL+C to cancel, or wait 10 seconds to continue..."
        Start-Sleep -Seconds 10
    }

    # Determine if we're blocking or unblocking
    if ($UnblockInstead) {
        # Unblocking
        if ($Recurse) {
            # Recursively unblocking
            Write-Output "Recursively unblocking EXEs in $Path..."
            Get-ChildItem -Path $Path -Filter "*.exe" -Recurse | ForEach-Object {
                $FilePath = $_.FullName
                $FileName = Split-Path $FilePath -Leaf
                Unblock-Exe -FilePath $FilePath -FileName $FileName -Inbound:$Inbound.IsPresent -Outbound:$Outbound.IsPresent
            }
        } else {
            # Not recursively unblocking
            Write-Output "Unblocking EXEs in $Path..."
            Get-ChildItem -Path $Path -Filter "*.exe" | ForEach-Object {
                $FilePath = $_.FullName
                $FileName = Split-Path $FilePath -Leaf
                Unblock-Exe -FilePath $FilePath -FileName $FileName -Inbound:$Inbound.IsPresent -Outbound:$Outbound.IsPresent
            }
        }
    } else {
        # Blocking
        if ($Recurse) {
            # Recursively blocking
            Write-Output "Recursively blocking EXEs in $Path..."
            Get-ChildItem -Path $Path -Filter "*.exe" -Recurse | ForEach-Object {
                $FilePath = $_.FullName
                $FileName = Split-Path $FilePath -Leaf
                Block-Exe -FilePath $FilePath -FileName $FileName -Inbound:$Inbound.IsPresent -Outbound:$Outbound.IsPresent
            }
        } else {
            # Not recursively blocking
            Write-Output "Blocking EXEs in $Path..."
            Get-ChildItem -Path $Path -Filter "*.exe" | ForEach-Object {
                $FilePath = $_.FullName
                $FileName = Split-Path $FilePath -Leaf
                Block-Exe -FilePath $FilePath -FileName $FileName -Inbound:$Inbound.IsPresent -Outbound:$Outbound.IsPresent
            }
        }
    }

    Write-Output "Done!"
} else {
    # Folder path does not exist
    Write-Output "Folder does NOT exist, please run script again with a valid path"
}

Write-Output ""