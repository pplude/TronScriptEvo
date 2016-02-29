# TronScript:Evolution
Welcome to TRON Script: Evolution. This is an attempt to update TRON Script to PowerShell. We are targeting Windows 8 as an initial deployment target. The core script at this time is working, but produces several errors. Please let me know what they are or open an issue so I can squash some bugs please!

I'm Using Dell PowerGUI to develop the script. This will eventually allow me to sign the script and "compile" an executable file for distribution. For best results when editing, please use the same editor. Also opens and auto-completes in PowerShell ISE for v2 or later.

# Usage:

 1. Set the Powershell execution policy to **UNRESTRICTED**
 2. Download only **Core.ps1**
 3. Run Core.ps1 in an administrative Powershell instance

### Optional flags (can be combined):
 - `-Automatic`               *Automatic mode (no welcome screen or prompts)*
 - `-PreserveXAML`            *Preserve OEM Metro apps (don't remove them)*
 - `-Shutdown`                *Power off after running (overrides -Reboot)*
 - `-Reboot`                  *Reboot automatically (auto-reboot 30 seconds after completion)*
 - `-SkipAV`                  *Skip anti-virus scans (MBAM, KVRT, Sophos)*
 - `-SkipDebloat`             *Skip de-bloat (OEM bloatware removal)*
 - `-SkipOptimizeC`           *Skip defrag (force Tron to ALWAYS skip Stage 5 defrag)*
 - `-PreserveEventLog`        *Skip Event Log clearing* 
 - `-SkipKaspersky`           *Skip Kaspersky Virus Rescue Tool (KVRT) scan*
 - `-SkipMalwareBytes`        *Skip Malwarebytes Anti-Malware (MBAM) installation*
 - `-SkipPatches`             *Skip patches (do not patch 7-Zip, Java Runtime, Adobe Flash or Reader)*
 - `-SkipPermissionsReset`    *Skip settings reset (don't set to "Let Windows manage the page file")*
 - `-SkipSophos`              *Skip Sophos Anti-Virus (SAV) scan*
 - `-SkipWinUpdate`           *Skip Windows Updates (do not attempt to run Windows Update)*

 
### Stages:
*Stage0 | Prep*: 
 1. Install Chocolatey; Download and Install Chocolatey - Used for installation of various softwares
 2. Kill all unneeded Processes
 3. Get SMART Status; Get various details of Physical Drive from S.M.A.R.T.
 4. Create Restore Point
 5. Get System State; Builds a list of applications/software installed on the machine as well as a directory structure of the Users folder.
 6. Run Caffeiene; Prevents the computer from entering a sleep state.
 7. Sync System Clock; Sets the OS Clock to the correct time using official windows NTP.

*Stage1 | Temp Clean*:
 1. Clean Internet Exploer; History, Cache, ect.
 2. Clear Junk Files; Clear Temp Drivers, Flash Cache, Recycle Bin, ect.
 3. CCLeaner; Run CCleaner in Auto mode
 4. Bleachbit; Various thorough temp cleaning
 5. Clear Event Logs; Removes Event logs 
 6. Clear Win Update Cache; Clears Cached files from Windows Update to free up space.
 7. Purge Oldest VSS Copies; Removes old Volume Shadowing files to free up space.
 8. Reduce System Restore Space; Reduces used space to 7% by System Restore.

*Stage2 | De-Bloat*:
 1. Remove Apps By GUID; Removes Installed software VIA MSIEXEC based on known GUIDs.
 2. Cleanup METRO Apps

*Stage3 | Disinfect*:
 1. Run McAfee Stinger; scans for specific malware.
 2. TDSSKiller; Kaspersky TDSSKiller, scans and removes specific malware.
 3. RogueKiller; Scans and removes Malware using RogueKiller(GUI) Version)
 4. Malwarebytes; Manual malware scan with Malwarebytes if installed.
 5. Kaspersky Virus Removal Tool; Scan and remove malware with KVRT.
 
`6. Sophos Virus Removal Tool; Scan and Remove Malware *DISABLED*`

*Stage4 | Repair*:
 1. DISM Cleanup; Cleans up the WinSxS folder and Repair component store corruption
 2. Reset File-System Permissions
 3. Security database Repair; Using secedit to compare against recommended template confirugation
 4. SFC Scan; Using System File Checker to repair missing or corrupted system files.
 5. Check Disk; Checks disk with chkdsk.exe and forces fix on reboot if errors are found.

*Stage5 | Updates*:
 1. Allow MSI in Safe-Mode; Allows MSI to be installed while in safe-mode.
 2. Chocolatey upgrade; Upgrade various software using Chocolatey `7zip flashplayerplugin adobereader jre8`
 3. Windows Updates; Perform windows updates
 4. Reset Windows Datastore; Using DISM

*Stage6 | Optimize*:
 1. Reset Page-File; Resets Page-File to be handled by OS.
 2. Optimize-Volume; Optimize-Volume cmdlet optimizes a volume, performing such tasks on supported volumes and system SKUs as defragmentation, trim, slab consolidation, and storage tier processing.

*Stage7 | Cleanup*:
 1. Restore Power Settings; Quit Caffeiene.
 2. Uninstall Chocolatey; Uninstalls Chocolatey if it was installed from TronScriptEvo.
 3. Remove TronScriptEvo specific Files.
 
# Errata
* There is no RKill, I don't have a good reposiorty for it
* This is NOT reboot safe. Do not restart in the middle or you will have to stop again