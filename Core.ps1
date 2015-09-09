<# 
   REQUIREMENTS:   Administrator access - Local administrator account 
					PowerShell Execution Policy - Unrestricted
					Safe-Mode on the computer (recommended)
					
	AUTHOR: 		Based on TRON script batch file by vocatus on /r/TronScript
					Initial port to PowerShell by pplude on /r/TronScriptEvo
	
	VERSION:		Initial Version 0.8.2
						
	USAGE:			Set the Execution Policy, run as Admin, and reboot
	
	NOTES:			BATCH version has command line flags that I am omitting for
					this initial version. That may be implemented at a 
					different time. 
					
					This script relies heavily on WMI. This is done on purpose.
					With Windows 8 and above, if WMI is broken, even attempting
					to fix the system is not worth the time. Use the "Reset this
					PC" if things are truly that bad.
					
	EXIT CODES:		0 - Script ran successfully
					1 - Powershell Error
					4 - Safe mode failure
					5 - Bad EULA
					6 - Bad Admin Rights
#>

######################
##  .NET LIBRARIES  ##
######################

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

########################
##  GLOBAL VARIABLES  ##
########################

$ScriptVersion = "0.8.2" # Major.Minor.Errata
$ScriptDate = "2015-08-28" # Commit date for Core.PS1, YYYY-MM-DD

$EvoRepo = "https://raw.githubusercontent.com/pplude/TronScriptEvo/master" # USE THIS FOR RELEASE VERSION
#$EvoRepo = "https://raw.githubusercontent.com/pplude/TronScriptEvo/WIP" # USE THIS FOR DEV VERSION

$RunTime = $((Get-Date).ToString("MMdd-hm")) # Time the script is called, MMdd-hm
$WindowsVersion = (Get-WmiObject Win32_OperatingSystem | Select-Object Caption | foreach {$_.Caption}) # Returns friendly name
$WindowsNTVersion = ([System.Environment]::OSVersion.Version | Select-Object Major | foreach {$_.Major}) # Returns NTKRNL Major version number
$FreeSpaceLabel=@{Label='Free Space (GB)'; expression={($_.freespace)/1gb};formatstring='n2'} # Needed to get installed Drives
$PreRunFreeSpace = (Get-WmiObject Win32_LogicalDisk | Format-Table Name, $FreeSpaceLabel -AutoSize)	# Prints table of free space
$SafeMode = (Get-WmiObject Win32_ComputerSystem | Select-Object BootupState | foreach {$_.BootupState}) # Get the runmode of Windows

#########################
##  PERMISSIONS CHECK  ##
#########################

# This will test to see if the user is admin, and terminate the script if it fails the user rights check
If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		[System.Windows.Forms.MessageBox]::Show("User is not running as administrator. `n `n Please run this script through an Administrative Powershell.", "ERROR") | Out-Null
		[Environment]::Exit(6)
	}
	
##########################
##  DISCLAIMER SCREENS  ##
##########################

$Host.UI.RawUI.BackgroundColor = ($bkgrnd = 'Red')
$Host.UI.RawUI.WindowTitle = ("TRON:Evo $ScriptVersion ($ScriptDate)")
Clear-Host
Write-Host "
************************** ANNOYING DISCLAIMER **************************
* NOTE: By running Tron you accept COMPLETE responsibility for ANYTHING * 
* that happens. Although the chance of something bad happening due to   * 
* Tron is pretty remote, it's always a possibility, and Tron has ZERO   * 
* WARRANTY for ANY purpose. READ THE INSTRUCTIONS and understand what   * 
* Tron does, because you run it AT YOUR OWN RISK.                       * 
*                                                                       * 
* Tron.PS1 and the supporting code and scripts I've written are free    * 
* and open-source under the MIT License. All 3rd-party tools Tron calls * 
* (MBAM, KVRT, etc) are bound by their respective licenses. It is       * 
* YOUR RESPONSIBILITY to determine if you have the rights to use these  * 
* tools in whatever environment you're in.                              * 
*                                                                       * 
* BOTTOM LINE: there is NO WARRANTY, you are ON YOUR OWN, and anything  * 
* that happens, good or bad, is YOUR RESPONSIBILITY.                    * 
************************************************************************* 

Type I AGREE (all caps) to accept this and go to the main menu, or 
press CTRL+C to cancel. `n `n `n"

$EULA = Read-Host
If ($EULA -ne "I AGREE")
	{
		[Environment]::Exit(5)
	}
	
# Set the screen back to normal
$Host.UI.RawUI.BackgroundColor = ($bkgrnd = 'Black')
Clear-Host
	
<# At this point we are assuming that the EULA has been accepted. If it has not
	nothing below this line should run. The rest of this section will determine
	if the script can run, and will boot the user out of TRON:Evo if they are in
	Safe Mode without Networking. Tron:Evo relies on downloads from the internet
	and will not work without an internet connection! #>	
	
# Check to see if we are running in safe mode

If ($SafeMode -eq "Normal Boot")
	{
		[System.Windows.Forms.MessageBox]::Show("The system is not in safe mode. Tron functions best in Safe Mode with Networking in order to download Windows and anti-virus updates. `n `n Tron should still run OK, but if you have infections or problems after running, recommend booting to Safe Mode with Networking and re-running.", "WARNING") | Out-Null
	}
	
If ($SafeMode -eq "Fail-safe boot")
	{
		[System.Windows.Forms.MessageBox]::Show("The system is in Safe Mode without Network support. Tron:Evo does not function in this mode. Please boot into Windows normally or using the Safe Mode with Networking option." , "ERROR") | Out-Null
		[Environment]::Exit(4)
	}
	
###############################
##  TRON INTERNAL LOCATIONS  ##
###############################

$RootPath = "$env:SYSTEMDRIVE\TronEvo"
$PathLocations = @("$RootPath\Logs","$RootPath\TEMP","$RootPath\Quarantine","$RootPath\Backup","$RootPath\RawLogs","$RootPath\Summary")
New-Item -ItemType Directory $PathLocations -Force

$LogPath = "$RootPath\Logs"
$TempPath = "$RootPath\TEMP"
$QuarantinePath = "$RootPath\Quarantine"
$BackupPath = "$RootPath\Backup"
$RawLogPath = "$RootPath\RawLogs"
$SummaryLogPath = "$RootPath\Summary"

######################
##  WELCOME SCREEN  ##
######################

Clear-Host
Write-Host "
**********************  TRON v$ScriptVersion ($ScriptDate)  *********************
* Script to automate a series of cleanup/disinfection tools           *
* Author: pplude on reddit.com/r/TronScriptEvo                        *
*                                                                     *
* Stage:        Tools:                                                *
*  0 Prep:      Create SysRestore point/Rkill/ProcessKiller/Stinger/  *
*               TDSSKiller/registry backup/clean oldest VSS set       *
*  1 TempClean: TempFileClean/BleachBit/CCleaner/IE & EvtLogs clean   *
*  2 De-bloat:  Remove OEM bloatware, remove Metro bloatware          *
*  3 Disinfect: RogueKiller/Sophos/KVRT/MBAM/DISM repair              *
*  4 Repair:    RegPerms reset/Fileperms reset/chkdsk/SFC scan        *
*  5 Patch:     Update 7-Zip/Java/Flash/Windows, reset DISM base      *
*  6 Optimize:  defrag $env:SYSTEMDRIVE (mechanical only, SSDs skipped)             *
*  7 Wrap-up:   collect misc logs, send email report (if requested)   *
*********************************************************************** `r`n`r`n"

####################
##  LOG CREATION  ##
####################

New-Item -ItemType File -Path "$LogPath\TronEvo-Log-$RunTime.txt" -Force
$LogFile = "$LogPath\TronEvo-Log-$Runtime.txt"

Write-Output "
-------------------------------------------------------------------------------
$RunTime TRON:evo $ScriptVersion ($ScriptDate)
                          Executing as $env:USERNAME on $env:COMPUTERNAME
                          Logfile: $Logfile
                          Run Mode: $SafeMode
-------------------------------------------------------------------------------


" >> $LogFile

# Write all future output to the log.
Start-Transcript -Path $LogFile -Append

#####################
##  BOOT TRON:EVO  ##
#####################

Write-Host "`r`n`r`nDownloading Tron:Evo Stages" # Need a few blank lines to separate everything
Write-Host "---------------------------"
Write-Host "Downloading Stage 0 - Prep"
Invoke-WebRequest "$EvoRepo/Stage0.ps1" -OutFile .\Stage0.ps1
Write-Host "Downloading Stage 1 - Temp Clean"
Invoke-WebRequest "$EvoRepo/Stage1.ps1" -OutFile .\Stage1.ps1
Write-Host "Downloading Stage 2 - Debloat"
Invoke-WebRequest "$EvoRepo/Stage2.ps1" -OutFile .\Stage2.ps1
Write-Host "Downloading Stage 3 - Disinfect"
Invoke-WebRequest "$EvoRepo/Stage3.ps1" -OutFile .\Stage3.ps1
Write-Host "Downloading Stage 4 - Repair"
Invoke-WebRequest "$EvoRepo/Stage4.ps1" -OutFile .\Stage4.ps1
Write-Host "Downloading Stage 5 - Patch"
Invoke-WebRequest "$EvoRepo/Stage5.ps1" -OutFile .\Stage5.ps1
Write-Host "Downloading Stage 6 - Optomize"
Invoke-WebRequest "$EvoRepo/Stage6.ps1" -OutFile .\Stage6.ps1
Write-Host "Downloading Stage 7 - Cleanup"
Invoke-WebRequest "$EvoRepo/Stage7.ps1" -OutFile .\Stage7.ps1
Write-Host "Downloading Junkware List"
Invoke-WebRequest "$EvoRepo/AppsByName.txt" -OutFile .\AppsByName.txt
Write-Host "Downloaded All Tron:Evo Components"

######################
##  RUN COMPONENTS  ##
######################

.\Stage0.ps1 | Out-Null
.\Stage1.ps1 | Out-Null
.\Stage2.ps1 | Out-Null
.\Stage3.ps1 | Out-Null
.\Stage4.ps1 | Out-Null
.\Stage5.ps1 | Out-Null
.\Stage6.ps1 | Out-Null
.\Stage7.ps1 | Out-Null

##################################
##  REMOVE ALL TRON SUBSCRIPTS  ##
##################################

Remove-Item .\Stage0.ps1 -Force
Remove-Item .\Stage1.ps1 -Force
Remove-Item .\Stage2.ps1 -Force
Remove-Item .\Stage3.ps1 -Force
Remove-Item .\Stage4.ps1 -Force
Remove-Item .\Stage5.ps1 -Force
Remove-Item .\Stage6.ps1 -Force
Remove-Item .\Stage7.ps1 -Force
Remove-Item .\AppsByName.txt -Force
