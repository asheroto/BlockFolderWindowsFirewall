# Block Entire Folder in Windows Firewall

Unfortunately there is no way to *literally* block a folder in Windows Firewall, however, this script will **automate the process of blocking all EXEs inside a specified folder**.

# Installing

You can either download the PS1 script from here, or install using...

```powershell
Install-Script BlockFolderWindowsFirewall
```
This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/BlockFolderWindowsFirewall).
# Usage
|Description|Command|
|--|--|
|Block all EXEs in folder|`BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder"`|
|Block all EXEs in folder & subfolders|`BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse`
|Unblock all EXEs in folder|`BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -UnblockInstead`|
|Unblock all EXEs in folder & subfolders|`BlockFolderWindowsFirewall -Path "C:\Folder\Subfolder" -Recurse -UnblockInstead`|

### Caution!
Be careful when specifying the folder path. If you specify `C:\` as the path, it will block all EXEs on the C drive.

It is recommended that you back up your firewall rules before using. [Here is an article](https://winaero.com/export-and-import-specific-firewall-rule-in-windows-10/) describing several methods.  

# Parameters
  
|Parameter|Required|Description|
|--|--|--|
|`-Path`|Yes|The folder of EXEs to block/unblock.|
|`-Recurse`|No|Scans the folder and subfolders for EXEs.|
|`-UnblockInstead`|No|Unblocks the EXEs in a folder or subfolder.|

# Example

Here's a folder with EXEs in it with path `C:\TestFolderToBlock`

![example folder to block](https://i.imgur.com/iG5O9WD.png)

Let's block EXEs in the folder path `C:\TestFolderToBlock`
 
![enter image description here](https://i.imgur.com/q2ctKys.jpeg)

Now let's unblock the same folder

![enter image description here](https://i.imgur.com/q2ctKys.jpeg)