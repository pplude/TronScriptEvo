<# 
	PURPOSE: 		The purpose of this script is to create an easy to use 
					cleaner for various system issues that are commonly \
					encountered. This script will use both Windows built-in 
					tools and various third party cleaners to disinfect a 
					Windows machine running Vista or later.
				
	REQUIREMENTS:
					Administrator access - Local administrator account 
					PowerShell Execution Policy - Unrestricted
					Safe-Mode on the computer (reccomended)
					
	AUTHOR: 		Based on TRON script batch file by vocatus on /r/TronScript
					Initial port to PowerShell by pplude on /r/TronScriptEvo
	
	VERSION:		Initial Version 0.1
						Convert core of TRON to PowerShell
						
	USAGE:			Set the Execution Policy, run as Admin, and reboot
	
	NOTES:			BATCH version has command line flags that I am omitting for
					this initial version. That may be implemented at a 
					different time. Also, eventually, TRON will be a collection
					of scripts and not one monolithic system as it was before.
					This will be to reduce the amount of downloads needed for a
					specific job and to omit tools that may already be present
					on the computer.
					
					This script relies heavily on WMI. This is done on purpose.
					With Windows 8 and above, if WMI is broken, even attempting
					to fix the system is not worth the time. Use the "Reset this
					PC" if things are truly that bad.
					
	EXIT CODES:		0 - Script ran successfully
					1 - Powershell Error
					5 - Bad EULA
					6 - Bad Admin Rights
					
	ERRATA:
					Script is **NOT** Reboot-tolerant
					RKILL is not in this version - if chocolatey does not supply
						it, it isn't needed. Besides, vanilla TRON has been
						struggling with issues with this component for several
						versions now, better to avoid that hassle.
					ProcessKiller is the same as above.
					We assume WMI is working. If it is broken, with Win NT 6+,
						there are more pressing issues that should require a 
						nuke from orbit.
#>

	#####################
	##  BASE VARIABLES  #
	#####################
	
$ScriptVersion = '0.0.1'
$ScriptDate = '2015-08-07'

# We need to make some assumptions here
$SSD = "False"
$RAID = "False"

	##################
	##  ADMIN CHECK  #
	##################

# The function here uses .NET calls to get the security level of the user.
function Test-IsAdmin 
	{
		([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
	}

# This will test to see if the user is admin, and terminate the script if it fails the user rights check
if (!(Test-IsAdmin))
	{
		Write-Host "User is not running as administrator. `n `n Please run this script through an Administrative Powershell. `n"
		Write-Host "Press any key to continue..."
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
		[Environment]::Exit(6)
	}


	#################
	##  LOCATIONS  ##
	#################
	
# Root Path that everything will run from
$RootPath = "$env:SystemDrive\TronEvo"

# Set the path that logs will be stored in, create the folder if it does not exist.
$LogPath = "$RootPath\Logs"
	If ((Test-Path $LogPath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $LogPath -Force
		}

# Create The Logfile (If we are running more than once a minute, there are issues)
$RunTime = $((Get-Date).ToString("MMdd-hm"))
New-Item -ItemType File -Path "$LogPath\TronEvo-Log-$RunTime.txt" -Force
$LogFile = "$LogPath\TronEvo-Log-$Runtime.txt"
Write-Host "-------------------------------------------------------------------------------
$RunTime TRONevo $ScriptVersion ($ScriptDate)
                          Executing as $env:USERNAME on $env:HOSTNAME
                          Logfile: $Logfile
                          Safe Mode: $SafeMode
                          Free space before Tron run: $PreRunFreeSpace MB
-------------------------------------------------------------------------------


" >> $LogFile

#Create the TEMP directory for TRON, delete at end of file!
$TempPath = "$RootPath\TEMP"
	If ((Test-Path $TempPath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $TempPath -Force
		}
		
#Create the Qarintine Path
$QuarantinePath = "$RootPath\quarantine"
	If ((Test-Path $QuarantinePath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $QuarantinePath -Force
		}
		
#Create the Backup Path
$BackupPath = "$RootPath\backup"
	If ((Test-Path $BackupPath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $BackupPath -Force
		}
		
#Create the Raw Logs Path, for logs that can't be saved to TXT
$RawLogPath = "$RootPath\raw_logs"
	If ((Test-Path $RawLogPath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $RawLogPath -Force
		}
		
#Create the Summary Logs Path, for logs that can't be saved to TXT
$SummaryLogPath = "$RootPath\rsummary"
	If ((Test-Path $SummaryLogPath) -ne "True")
		{
			 New-Item -ItemType Directory -Path $SummaryLogPath -Force
		}
		
###############################################################################
###                  NOW FOR THE FUN PART! THE SCRIPTING!!                  ###
############           DO *NOT* EDIT BELOW THIS SECTION!           ############
###############################################################################

	#####################
	## PREP AND CHECKS ##
	#####################

# Get the Windows Version and pipe it to a string
$WindowsVersion = (Get-WmiObject Win32_OperatingSystem | Select-Object Caption | foreach {$_.Caption})
$WindowsNTVersion = ([System.Environment]::OSVersion.Version | Select-Object Major | foreach {$_.Major})

# Detect if you are running an SSD Drive
If ((Get-PhysicalDisk | Select-Object MediaType | foreach {$_.MediaType} | Select-String -Pattern 'SSD' -SimpleMatch -Quiet) -eq "True")
	{
		$SSD = "True"
	}
	
# Detect if you are running RAID
If ((Get-PhysicalDisk | Select-Object MediaType | foreach {$_.MediaType} | Select-String -Pattern 'RAID' -SimpleMatch -Quiet) -eq "True")
	{
		$RAID = "True"
	}	
	
# Get Free Space (in GB) pre-run
$FreeSpaceLabel=@{Label='Free Space (GB)'; expression={($_.freespace)/1gb};formatstring='n2'}
$PreRunFreeSpace = (Get-WmiObject Win32_LogicalDisk | Format-Table Name, $FreeSpaceLabel -AutoSize)

# Now to set the annoying disclaimer screen
$Host.UI.RawUI.BackgroundColor = ($bkgrnd = 'Red')
$Host.UI.RawUI.WindowTitle = ("TRON:Evo $ScriptVersion ($ScriptDate)")
Clear-Host
Write-Host "************************** ANNOYING DISCLAIMER **************************
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
	
# Check to see if we are running in safe mode
$SafeMode = (Get-WmiObject Win32_ComputerSystem | Select-Object BootupState | foreach {$_.BootupState})
If ($SafeMode -eq "Normal Boot")
	{
		Write-Host "WARNING

The system is not in safe mode. Tron functions best
in Safe Mode with Networking in order to download
Windows and anti-virus updates.
		
Tron should still run OK, but if you have infections
or problems after running, recommend booting to
Safe Mode with Networking and re-running.

"
		Write-Host "Press any key to continue..."
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
		Clear-Host
	}
	
If ($SafeMode -eq "Fail-safe boot")
	{
		Write-Host "WARNING

The system is in Safe Mode without Network support.
Tron functions best in Safe Mode with Networking in
order to download Windows and anti-virus updates.
		
Tron will still function, but rebooting to Safe Mode
with Networking is recommended.

"
		Write-Host "Press any key to continue..."
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
		Clear-Host
	}
	
	######################
	##  WELCOME SCREEN  ##
	######################

Write-Host "**********************  TRON v$ScriptVersion ($ScriptDate)  *********************
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
*                                                                     *
* \resources\stage_8_manual_tools contains additional manual tools    *
***********************************************************************"

# Install Chocolatey. This will let us install/update programs as we need to.
# NOTE - NOT MY CODE, will rewrite later
Write-Host "Verify Chocolatey is installed."
if(Test-Path("C:\ProgramData\chocolatey\choco.exe"))
{
    $chocover = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\ProgramData\chocolatey\choco.exe").FileVersion
    Write-Host "Chocolatey $chocover already installed."
}
else
{
    Write-Host "Chocolatey not installed, installing."
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Re-enable F8 bootup options in Windows 8 (DOes not apply to Win10
If ($WindowsNTVersion -eq '8')
	{
		bcdedit /set {default} bootmenupolicy legacy
	}
	
Clear-Host
Write-Host "CURRENT SETTINGS: `n" #Adding a blank line after
Write-Host "Log Location: $LogPath" >> $LogFile
Write-Host "SSD Found: $SSD" >> $LogFile
Write-Host "Boot Mode: $SafeMode" >> $LogFile

# Get the Hard Drive SMART status -- Warn if there is an issue
Write-Host (Get-WmiObject Win32_DiskDrive | Select-Object Index,Status,StatusInfo | Format-Table -AutoSize) >> $LogFile
$DriveStat = (Get-WmiObject Win32_DiskDrive | Select-Object Status | foreach {$_.Status})
If (($DriveStat -eq "Error") -or ($DriveStat -eq "Degraded") -or ($DriveStat -eq "Unknown") -or ($DriveStat -eq "PredFail") -or ($DriveStat -eq "Service") -or ($DriveStat -eq "Stressed") -or ($DriveStat -eq "NonRecover"))
	{
		Write-Host "! WARNING! SMART check indicates at least one drive with $DriveStat status
SMART errors can mean a drive is close to failure, be careful
running disk-intensive operations like defrag.

		" >> $LogFile
	}
	
# Create A Restore point
Write-Host "Creating a Restore Point, please wait... `n `n"
Enable-ComputerRestore
Checkpoint-Computer -Description "TronEvo"

# Get system state
Write-Host "Getting a list of applications."
Get-WmiObject Win32_Product | Select-Object -Property Name | foreach {$_.Name} >> $RawLogPath\ProgsBefore.txt
Write-Host "Getting the User Directory Structure."
Get-ChildItem C:\Users -recurse | select -expand fullname >> $RawLogPath\FilesBefore.txt

# Disable sleep/screensaver
Write-Host "Disabling Screen Saver."
reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f >> "$LogFile"
Write-Host "Disabling Sleep."
powercfg.exe -S SCHEME_MIN
Write-Host "High-Performance Activated" >> $LogFile

# Set the System Clock ( I want a more PowerShell-y way to do this)
Write-Host "Setting the system time" >> $LogFile
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\w32time" /ve /t reg_sz /d Service /f >> $LogFile
sc.exe config w32time start= auto >> $LogFile
net stop w32time >> $LogFile
w32tm /config /syncfromflags:manual /manualpeerlist:"time.nist.gov 3.pool.ntp.org time.windows.com" >> $LogFile
net start w32time >> $LogFile
w32tm /resync /nowait >> $LogFile

# Run Stinger
Write-Host "Downloading McAfee Stinger"
Invoke-WebRequest http://downloadcenter.mcafee.com/products/mcafee-avert/Stinger/stinger32.exe -OutFile $TempPath\Stinger.exe
Write-Host "Stinger does not write to Tron...need to make a raw log"
Write-Host "Starting Stinger"
Start-Process $TempPath\stinger.exe --GO --SILENT --PROGRAM --REPORTPATH="$RawLogPath" --DELETE

# Run TDSS Killer
Write-Host "Downloading Kaspersky TDSS Killer"
Invoke-WebRequest http://media.kaspersky.com/utilities/VirusUtilities/EN/tdsskiller.exe -OutFile $TempPath\TDSS.exe
Write-Host "Starting TDSS Killer"
$TempPath\TDSS.exe -l $TempPath\tdsskiller.log -silent -tdlfs -dcexact -accepteula -accepteulaksn
Get-Content $TempPath\tdsskiller.log >> $LogFile
Remove-Item $TempPath\tdsskiller.log

# Purge oldest VSS copies
net start VSS
vssadmin.exe delete shadows /for=$env:SystemDrive /oldest /quiet
Write-Host "Old VSS Purged" >> $LogFile

# Reduce System Restore Space
Write-Host "Reducing System Restore to max of 7% of disk"
reg.exe add "\\%COMPUTERNAME%\HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DiskPercent /t REG_DWORD /d 00000007 /f>> $LogFile
reg.exe add "\\%COMPUTERNAME%\HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\Cfg" /v DiskPercent /t REG_DWORD /d 00000007 /f>> $LogFile

###########################
##    STAGE 0 COMPLETE   ##
###########################

## NOW WE NEED TO BOOTSTRAP STAGE 1 ##

# Start-Process .\Stage1.PS1
