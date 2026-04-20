[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/BlockFolderWindowsFirewall?label=PowerShell%20Gallery%20downloads)](https://www.powershellgallery.com/packages/BlockFolderWindowsFirewall)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/BlockFolderWindowsFirewall/total?label=release%20downloads)](https://github.com/asheroto/BlockFolderWindowsFirewall/releases)
[![Release](https://img.shields.io/github/v/release/asheroto/BlockFolderWindowsFirewall)](https://github.com/asheroto/BlockFolderWindowsFirewall/releases)
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/BlockFolderWindowsFirewall)](https://github.com/asheroto/BlockFolderWindowsFirewall/releases)

[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40px"></a>

# Block, Allow, or Unblock Entire Folder in Windows Firewall

This script provides functionalities to manage (block/allow/unblock) executables (EXEs) in specified directories via Windows Firewall. The operation can be targeted at individual directories or recursively applied to subdirectories as well.

By default, both Inbound and Outbound connections will be affected, but the scope can be controlled via the -Inbound or -Outbound switches.

Special care should be taken when using this script due to its potentially broad impact. Blocking or allowing EXEs indiscriminately may disrupt applications depending on these executables.

# Installing

You can either download the PS1 script from here, or install using...

```powershell
Install-Script BlockFolderWindowsFirewall -Force
```

Answer **Yes** to any prompts. `-Force` is optional, but it will force the script to update if it is outdated.

This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/BlockFolderWindowsFirewall).

# Usage

```powershell
BlockFolderWindowsFirewall [-Path <String>] [-Outbound] [-Inbound] [-Recurse] [-UnblockInstead] [-Allow] [-Version] [-Help] [-CheckForUpdate]
```

# Parameters

| Parameter         | Required | Description                                                                    |
| ----------------- | -------- | ------------------------------------------------------------------------------ |
| `-Path`           | Yes      | The folder of EXEs to block/allow/unblock.                                     |
| `-Recurse`        | No       | Scans the folder and subfolders for EXEs.                                      |
| `-UnblockInstead` | No       | Removes existing Block rules for the EXEs in a folder or subfolder.            |
| `-Allow`          | No       | Creates Allow rules instead of Block rules. Cannot be used with -UnblockInstead. |
| `-Inbound`        | No       | Only affects inbound connections for the EXEs in a folder or subfolder.        |
| `-Outbound`       | No       | Only affects outbound connections for the EXEs in a folder or subfolder.       |
| `-CheckForUpdate` | No       | Checks if there is an update available for the script.                         |
| `-UpdateSelf`     | No       | Updates the script to the latest version.                                      |
| `-Help`           | No       | Displays the help message.                                                     |
| `-Version`        | No       | Shows the current version of the script.                                       |

# Examples

| Description                                                          | Command                                                                            |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Block all EXEs in a specified folder                                 | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder"`                           |
| Block all EXEs in a specified folder and its subfolders              | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse`                  |
| Block only the inbound connections for EXEs in a specified folder    | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Inbound`                  |
| Block only the outbound connections for EXEs in a specified folder   | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Outbound`                 |
| Unblock all EXEs in a specified folder                               | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead`           |
| Unblock all EXEs in a specified folder and its subfolders            | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse -UnblockInstead`  |
| Unblock only the inbound connections for EXEs in a specified folder  | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead -Inbound`  |
| Unblock only the outbound connections for EXEs in a specified folder | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead -Outbound` |
| Allow all EXEs in a specified folder                                 | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Allow`                    |
| Allow all EXEs in a specified folder and its subfolders              | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Allow -Recurse`           |
| Allow only the inbound connections for EXEs in a specified folder    | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Allow -Inbound`           |
| Allow only the outbound connections for EXEs in a specified folder   | `BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Allow -Outbound`          |
| Display help for the script                                          | `BlockFolderWindowsFirewall -Help`                                                 |
| Check the current version of the script                              | `BlockFolderWindowsFirewall -Version`                                              |
| Check if there is an update available for the script                 | `BlockFolderWindowsFirewall -CheckForUpdate`                                       |

# Screenshot

![Screenshot](https://github.com/asheroto/BlockFolderWindowsFirewall/assets/49938263/439d99ed-0ad1-4f75-87bc-11d385185567)