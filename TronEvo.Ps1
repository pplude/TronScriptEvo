<# 
   REQUIREMENTS:   Administrator access - Local administrator account 
					PowerShell Execution Policy - Unrestricted
					Safe-Mode on the computer (recommended)
                    Windows 10 build 10240 or later (WMF v5)
					
	AUTHOR: 		Based on TRON script batch file by vocatus on /r/TronScript
					Initial port to PowerShell by pplude on /r/TronScriptEvo
	
	VERSION:		Rewrite Version 2.5
						
	USAGE:			Set the Execution Policy, run as Admin

					
	EXIT CODES:		0 - Script ran successfully
                    5 - Acccess is Denied
                    10 - The environment is incorrect.
#>


######################
##  .NET LIBRARIES  ##
######################

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

########################
##  GLOBAL VARIABLES  ##
########################

$ScriptVersion = "2.5.0" # Major.Minor.Errata
$ScriptDate = "2016-03-01" # Commit date for Core.PS1, YYYY-MM-DD
$RunTime = $((Get-Date).ToString("MMdd-hm")) # Time the script is called, MMdd-hm
$WindowsCheck = (Get-WmiObject Win32_OperatingSystem | Select-Object Caption | foreach {$_.Caption} | Select-String -SimpleMatch -Quiet "Windows 10") # Check for Windows 10
$SafeMode = (Get-WmiObject Win32_ComputerSystem | Select-Object BootupState | foreach {$_.BootupState}) # Get the runmode of Windows

$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

#############################
##  WINDOWS VERSION CHECK  ##
#############################

# This will test to see if the user is admin, and terminate the script if it fails the user rights check
If ($WindowsCheck -ne $True)
	{
		[System.Windows.Forms.MessageBox]::Show("TRON:Evo requires Windows 10 to run. Please use the original TRON script at `n `n http://www.reddit.com/r/tronscript", "ERROR") | Out-Null
        Start-Process iexplore.exe http://www.reddit.com/r/tronscript
		[Environment]::Exit(10)
	}

#########################
##  PERMISSIONS CHECK  ##
#########################

# This will test to see if the user is admin, and terminate the script if it fails the user rights check
If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		[System.Windows.Forms.MessageBox]::Show("User is not running as administrator. `n `n Please run this script through an Administrative Powershell.", "ERROR") | Out-Null
		[Environment]::Exit(5)
	}
	
##########################
##  DISCLAIMER SCREENS  ##
##########################


$EULA= [System.Windows.Forms.MessageBox]::Show("
NOTE: By running Tron you accept COMPLETE responsibility for ANYTHING 
that happens. Although the chance of something bad happening due to    
Tron is pretty remote, it's always a possibility, and Tron has ZERO   
WARRANTY for ANY purpose. READ THE INSTRUCTIONS and understand what    
Tron does, because you run it AT YOUR OWN RISK.  
                     
Tron.PS1 and the supporting code and scripts I've written are free   
and open-source under the MIT License. All 3rd-party tools Tron calls  
(MBAM, KVRT, etc) are bound by their respective licenses. It is       
YOUR RESPONSIBILITY to determine if you have the rights to use these 
tools in whatever environment you're in.             
 
BOTTOM LINE: there is NO WARRANTY, you are ON YOUR OWN, and anything 
that happens, good or bad, is YOUR RESPONSIBILITY. 

Do you wish to continue?                 
" , "ANNOYING DISCLAIMER" , 4)

If ($EULA -ne "Yes")
	{
		[Environment]::Exit(5)
	}

# Check to see if we are running in safe mode
		If ($SafeMode -eq "Normal Boot")
			{
				[System.Windows.Forms.MessageBox]::Show("The system is not in safe mode. Tron functions best in Safe Mode with Networking in order to download Windows and anti-virus updates. `n `n Tron should still run OK, but if you have infections or problems after running, recommend booting to Safe Mode with Networking and re-running.", "WARNING") | Out-Null
			}
	
<# Keeping this here even in Automatic mode, so it quits if we can't download stages #>
If ($SafeMode -eq "Fail-safe boot")
	{
		[System.Windows.Forms.MessageBox]::Show("The system is in Safe Mode without Network support. Tron:Evo does not function in this mode. Please boot into Windows normally or using the Safe Mode with Networking option." , "ERROR") | Out-Null
		[Environment]::Exit(10)
	}
    
###############################
##  TRON INTERNAL LOCATIONS  ##
###############################

$RootPath = "$env:SYSTEMDRIVE\TronEvo"
$PathLocations = @("$RootPath\Logs","$RootPath\TEMP","$RootPath\Backup","$RootPath\RawLogs")
New-Item -ItemType Directory $PathLocations -Force

$LogPath = "$RootPath\Logs"
$TempPath = "$RootPath\TEMP"
$BackupPath = "$RootPath\Backup"
$RawLogPath = "$RootPath\RawLogs"

New-Item -ItemType File -Path "$LogPath\TronEvo-Log-$RunTime.txt" -Force
$LogFile = "$LogPath\TronEvo-Log-$Runtime.txt"

# Write all future output to the log.
Start-Transcript -Path $LogFile -Append
	
##########################
##  INSTALL PS CMDLETS  ##
##########################
Install-Module PSWindowsUpdate -Force  
Install-Module PoshProgressBar -Force
Get-PackageProvider -Name Chocolatey -Force
# Now start the Progress Bar
$TronProgress = New-ProgressBar -MaterialDesign -IsIndeterminate $True -Type Circle -Size Medium -Theme Dark


####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Setting up the Progress Bar" -PercentComplete 1

######################
##  PROCESS KILLER  ##
######################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Killing Rogue Processes" -PercentComplete 2
$SafeProc = @("explorer","TeamViewer","Gui","code","powershell","TRON:Evo","cmd","mbam","MsMpEng","tv_w32","conhost","dashost","gui","caffeine","PowerGUI")
$Processes = (Get-Process  -IncludeUserName | Where UserName -Match $env:USERNAME | Where {$_.cpu -gt 100} | Select-Object ProcessName | foreach {$_.ProcessName})
$KillProc = (Compare-Object -ReferenceObject $SafeProc -DifferenceObject $Processes | Where {$_.SideIndicator -eq '=>'} | Select-Object InputObject | ForEach-Object {$_.InputObject})
Stop-Process -Name $KillProc

###############
##  FIX WMI  ##
###############
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Fixing WMI" -PercentComplete 4
Stop-Service -Force ccmexec -ErrorAction SilentlyContinue
Stop-Service -Force winmgmt
$WMIBinaries=@("unsecapp.exe","wmiadap.exe","wmiapsrv.exe","wmiprvse.exe","scrcons.exe")
foreach ($sWMIPath in @(($ENV:SystemRoot+"\System32\wbem"),($ENV:SystemRoot+"\SysWOW64\wbem"))){
	if(Test-Path -Path $sWMIPath){
		push-Location $sWMIPath
		foreach($sBin in $WMIBinaries){
			if(Test-Path -Path $sBin){
				$oCurrentBin=Get-Item -Path  $sBin
				Write-Host " Register $sBin"
				& $oCurrentBin.FullName /RegServer
			}
			else{
				# Warning only for System32
				if($sWMIPath -eq $ENV:SystemRoot+"\System32\wbem"){
					Write-Warning "File $sBin not found!"
				}
			}
		}
		Pop-Location
	}
}

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Resetting Repository" -PercentComplete 5
Write-Host "Reset Repository"

WinMgmt.exe /resetrepository | Out-Null
WinMgmt.exe /salvagerepository | Out-Null

# Start the services again
Start-Service winmgmt
Start-Service ccmexec -ErrorAction SilentlyContinue

########################
##  GET SMART STATUS  ##
########################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Checking SMART status" -PercentComplete 7

$DriveStat = (Get-WmiObject Win32_DiskDrive | Select-Object Status | foreach {$_.Status})
If (($DriveStat -eq "Error") -or ($DriveStat -eq "Degraded") -or ($DriveStat -eq "Unknown") -or ($DriveStat -eq "PredFail") -or ($DriveStat -eq "Service") -or ($DriveStat -eq "Stressed") -or ($DriveStat -eq "NonRecover"))
	{
		[System.Windows.Forms.MessageBox]::Show("SMART check indicates at least one drive with $DriveStat status. SMART errors can mean a drive is close to failure, be careful running disk-intensive operations like defrag.","WARNING")
		$SkipOptimizeC -eq "True"
	}
	
############################
##  CREATE RESTORE POINT  ##
############################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Creating a Resore Point" -PercentComplete 8
Enable-ComputerRestore -Drive $env:SYSTEMDRIVE
Checkpoint-Computer -Description "TronEvo-$Runtime"


########################
##  GET SYSTEM STATE  ##
########################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Getting a list of installed Applications" -PercentComplete 10
Get-WmiObject Win32_Product | Select-Object -Property Name | foreach {$_.Name} >> $RawLogPath\ProgsBefore.txt

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Getting a list of user files" -PercentComplete 12
Get-ChildItem C:\Users -recurse | select -expand fullname >> $RawLogPath\FilesBefore.txt

############################
##  SET POWER MANAGEMENT  ##
############################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Downliading Caffeine to prevent sleep" -PercentComplete 14
Install-Package Caffeine -Force
Start-Process -NoNewWindow C:\Chocolatey\bin\caffeine.bat 

###############################
##  SYNCHRONIZE SYSTEM CLOCK ##
###############################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Fixing the system time" -PercentComplete 15
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\w32time" /ve /t reg_sz /d Service /f 
sc.exe config w32time start= auto 
Stop-Process w32time 
w32tm /config /syncfromflags:manual /manualpeerlist:"time.nist.gov 3.pool.ntp.org time.windows.com" 
Start-Process w32time 
w32tm /resync /nowait 

####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean"

#################
##  VARIABLES  ##
#################

$TempFolders = @("C:\Windows\Temp\*","$env:TEMP","C:\Windows\Prefetch\*","C:\Users\Users\*\AppData\Local\Temp\*","C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\*","C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*","C:\Users\*\My Documents\*.tmp")
$DriverFolders = @("C\NVIDIA","C\ATI","C\AMD","C\DELL","C\Intel","C\HP")
$UpdateBG = @("C:\Windows\*.log","C:\Windows\*.txt","C:\Windows\*.bmp","C:\Windows\*.tmp","C:\Windows\Web\Wallpaper\*.*","C:\Windows\Web\Wallpaper\Dell")
$FlashCache = @("C:\Users\Users\*\AppData\Roaming\Macromedia\Flash Player\#SharedObjects","C:\Users\Users\*\AppData\Roaming\Macromedia\Flash Player\macromedia.com\support\flashplayer\sys")


# Clean Internet Explorer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing Internet Explorer Cache" -PercentComplete 16
rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351

# Temp File Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Cleanin User Files" -PercentComplete 18
Remove-Item -Path $TempFolders -Force -Recurse -ErrorAction SilentlyContinue

# Clean System Files
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Cleaning Driver Folders" -PercentComplete 19
Remove-Item -Path $DriverFolders -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Removing Office Installation Cache" -PercentComplete 19
Remove-Item "C:\MSOCache" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Removing Windows Installation Cache" -PercentComplete 19
Remove-Item "C:\Windows\i386" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Emptying Recycle Bin" -PercentComplete 19
Remove-Item 'C:\$Recycle.Bin' -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\RECYCLER" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing MUI Cache" -PercentComplete 20
reg.exe delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f
Remove-Item $UpdateBG -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Cleaning Flash Cache" -PercentComplete 20
Remove-Item $FlashCache -Force -Recurse -ErrorAction SilentlyContinue

# Install CCleaner
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Installing/Updating CCleaner" -PercentComplete 21
Install-Package ccleaner -Force

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Running CCleaner" -PercentComplete 20
& 'C:\Program Files\CCleaner\CCleaner.exe' /AUTO

# Clear the Event Logs
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Backing Up Event Logs" -PercentComplete 21
Get-EventLog System >> $BackupPath\EventSystem.txt
Get-EventLog Application >> $BackupPath\EventApplication.txt
Get-EventLog Security >> $BackupPath\EventSecurity.txt

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing Event Logs" -PercentComplete 22
Clear-EventLog System
Clear-EventLog Application
Clear-EventLog Security

# Clear Windows Update Cache
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing Windows Update Cache" -PercentComplete 23
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\WUAUSERV" /ve /t reg_sz /d Service /f 
Stop-Service WUAUSERV 
Remove-Item C:\Windows\SoftwareDistribution\Download -Recurse -ErrorAction SilentlyContinue
Start-Service WUAUSERV 

# Purge oldest VSS copies
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Purging VSS" -PercentComplete 24
net start VSS
vssadmin.exe delete shadows /for=$env:SystemDrive /oldest /quiet


# Reduce System Restore Space
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Reducing Windows Restore Space" -PercentComplete 24
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DiskPercent /t REG_DWORD /d 00000007 /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\Cfg" /v DiskPercent /t REG_DWORD /d 00000007 /f 


####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage : De-Bloat"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 2: DE-BLOAT     "
Write-Host "----------------------------"

	
####################
##  Apps By GUID  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing Apps by GUID" -PercentComplete 25

# Start-Process .\AppsGUID.bat | Out-Null
# Start-Process .\Toolbars.bat | Out-Null
# Get-Content .\AppsByName.txt | ForEach-Object { WMIC.EXE product where "name like $_" uninstall /nointeractive }
 
##################
##  Metro Apps  ##
##################

        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing XAML Apps" -PercentComplete 28
		# Script to remove a lot of the pre-loaded 3rd-party Metro "modern app" bloatware
		# Initial creation by /u/kronflux
		# Modified for use with the Tron project by /u/vocatus on reddit.com/r/TronScript
		$ErrorActionPreference = "SilentlyContinue"

		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*06DAC6F6.StumbleUpon*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*134D4F5B.Box*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*26720RandomSaladGamesLLC.HeartsDeluxe*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*26720RandomSaladGamesLLC.SimpleSolitaire*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*4AE8B7C2.Booking.comPartnerEdition*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7906AAC0.TOSHIBACanadaPartners*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7906AAC0.ToshibaCanadaWarrantyService*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7digitalLtd.7digitalMusicStore*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*9E2F88E3.Twitter*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*A34E4AAB.YogaChef*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AccuWeather.AccuWeatherforWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AcerIncorporated.AcerExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AcerIncorporated.GatewayExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AD2F1837.HP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AdobeSystemsIncorporated.AdobeRevel*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Amazon.com.Amazon*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AppUp.IntelAppUpCatalogueAppWorldwideEdition*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ASUSCloudCorporation.MobileFileExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*B9ECED6F.ASUSGIFTBOX*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ChaChaSearch.ChaChaPushNotification*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ClearChannelRadioDigital.iHeartRadio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.ac.AcerCrystalEye*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.ac.SocialJogger*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.hs.YouCamforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.id.PowerDVDforLenovoIdea*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*DailymotionSA.Dailymotion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*DellInc.DellShop*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E046963F.LenovoCompanion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E046963F.LenovoSupport*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.CameraMan*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.DeviceCollaboration*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.LenovoRecommends*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaCameraMan*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaPhoneCompanion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaPicks*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*eBayInc.eBay*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*EncyclopaediaBritannica.EncyclopaediaBritannica*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*esobiIncorporated.newsXpressoMetro*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Evernote.Evernote*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Evernote.Skitch*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*F5080380.ASUSPhotoDirector*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*F5080380.ASUSPowerDirector*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FilmOnLiveTVFree.FilmOnLiveTVFree*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsASUS.FingertappsInstrumentsrecommendedb*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsasus.FingertappsOrganizerrecommendedbyA*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsASUS.JigsWarrecommendedbyASUS*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FingertappsInstruments*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FingertappsOrganizer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Flipboard.Flipboard*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FreshPaint*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GameGeneticsApps.FreeOnlineGamesforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GAMELOFTSA.SharkDash*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GettingStartedwithWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPConnectedMusic*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPConnectedPhotopoweredbySnapfish*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPRegistration*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*JigsWar*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*KindleforWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MAGIX.MusicMakerJam*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*McAfee*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*McAfeeInc.05.McAfeeSecurityAdvisorforASUS*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MobileFileExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MusicMakerJam*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*NAVER.LINEwin8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Netflix*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*PinballFx2*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*PublicationsInternational.iCookbookSE*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*RandomSaladGamesLLC.GinRummyProforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*sMedioforHP.sMedio360*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*sMedioforToshiba.TOSHIBAMediaPlayerbysMedioTrueLin*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*SymantecCorporation.NortonStudio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TelegraphMediaGroupLtd.TheTelegraphforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*toolbar*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TheNewYorkTimes.NYTCrossword*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TripAdvisorLLC.TripAdvisorHotelsFlightsRestaurants*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TuneIn.TuneInRadio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*UptoElevenDigitalSolution.mysms-Textanywhere*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Weather.TheWeatherChannelforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Weather.TheWeatherChannelforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*WildTangentGames*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*YouSendIt.HighTailForLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ZinioLLC.Zinio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*zuukaInc.iStoryTimeLibrary*"}).PackageFullName

		# Active identifiers
		$PackagesToRemove = (
			'Microsoft.3DBuilder',                    # '3DBuilder' app
			'Microsoft.BingFinance',                  # 'Money' app - Financial news
			'Microsoft.BingNews',                     # Generic news app
			'Microsoft.BingSports',                   # 'Sports' app - Sports news
			'Microsoft.BingTranslator',               # 'Translator' app - Bing Translate
			'Microsoft.BingWeather',                  # 'Weather' app
			'Microsoft.CommsPhone',                   # 'Phone' app
			'Microsoft.ConnectivityStore',
			'Windows.ContactSupport',
			'Microsoft.FreshPaint',                   # Canvas painting app
			'Microsoft.Getstarted',                   # 'Get Started' link
			'MicrosoftMahjong',                       # 'Mahjong' game
			'Microsoft.MicrosoftJigsaw',
			'Microsoft.Messaging',                    # 'Messaging' app
			'Microsoft.MicrosoftJackpot',             # 'Jackpot' app
			'Microsoft.MicrosoftOfficeHub',
			'Microsoft.MicrosoftSolitaireCollection', # Solitaire collection
			'Microsoft.Taptiles',                     # imported from stage_2_de-bloat.bat
			'Microsoft.Office.OneNote',               # Onenote app
			'Microsoft.Office.Sway',                  # 'Sway' app
			'Microsoft.People',                       # 'People' app
			'Microsoft.SkypeApp',                     # 'Get Skype' link
			'Microsoft.SkypeWiFi',
			'Microsoft.Studios.Wordament',            # imported from stage_2_de-bloat.bat
			'Microsoft.MicrosoftSudoku',
			'Microsoft.WindowsAlarms',                # 'Alarms and Clock' app
			'microsoft.windowscommunicationsapps',    # 'Calendar and Mail' app
			'Microsoft.Windows.CloudExperienceHost',  # 'Cloud Experience' sigh
			'Microsoft.WindowsFeedback',              # 'Feedback' functionality
			'Microsoft.MovieMoments',                 # imported from stage_2_de-bloat.bat
			'Microsoft.XboxApp',                      # Xbox junk, unfortunately 'Microsoft.XboxGameCallableUI' and 'Microsoft.XboxIdentityProvider' can't be removed
			'Microsoft.ZuneMusic',                    # 'Groove Music' app
			'Microsoft.ZuneVideo',                    # Groove Music
			'king.com.CandyCrushSodaSaga',            # Candy Crush app
			'9E2F88E3.Twitter'                        # Twitter app
		)
	
		# Do the removal
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing built-in apps" -PercentComplete 30
		Get-AppxProvisionedPackage -Online | Where-Object Name -In $PackagesToRemove | Remove-AppxProvisionedPackage -Online | Out-Null
		Get-AppxPackage -AllUsers | Where-Object Name -In $PackagesToRemove | Remove-AppxPackage | Out-Null


Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Running DISM Cleanup" -PercentComplete 34
Dism /Online /Cleanup-Image /StartComponentCleanup

####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect"

# Run Stinger
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading McAfee Stinger" -PercentComplete 35
Invoke-WebRequest http://downloadcenter.mcafee.com/products/mcafee-avert/Stinger/stinger32.exe -OutFile $TempPath\Stinger.exe
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running Stinger" -PercentComplete 36
& $TempPath\stinger.exe --GO --SILENT --PROGRAM --REPORTPATH="$RawLogPath" --DELETE

# Run TDSS Killer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading Kaspersky TDSS Killer" -PercentComplete 40
Invoke-WebRequest http://media.kaspersky.com/utilities/VirusUtilities/EN/tdsskiller.exe -OutFile $TempPath\TDSS.exe
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running TDSS Killer" -PercentComplete 41
& '$TempPath\TDSS.exe -l $TempPath\tdsskiller.log -silent -tdlfs -dcexact -accepteula -accepteulaksn'
Get-Content $TempPath\tdsskiller.log 
Remove-Item $TempPath\tdsskiller.log

#Rogue Killer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading RogueKiller" -PercentComplete 45
Invoke-WebRequest "http://www.sur-la-toile.com/RogueKiller/RogueKiller.exe" -OutFile "$TempPath\Rogue.exe"
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running RogueKiller - This will open a new window." -PercentComplete 46
Start-Process $TempPath\Rogue.exe

# MalwareBytes
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Installing/Updating MalwareBytes AntiMalware" -PercentComplete 50
Install-Package malwarebytes -Force
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running MalwareBytes" -PercentComplete 51
Start-Process "C:\Program Files (x86)\Malwarebytes Anti-Malware\mbam.exe"


# Kaspersky Virus Removal Tool
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading Kaspersky Virus Removal Tool" -PercentComplete 56
Invoke-WebRequest "http://devbuilds.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe" -OutFile "$TempPath\KVRT.exe"
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running KVRT" -PercentComplete 57
Start-Process $TempPath\KVRT.exe -d "$RawLogPath" -accepteula -adinsilent -silent -processlevel 2 -dontcryptsupportinfo


####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 4: Repair"

# DSIM Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running DISM Cleanup" -PercentComplete 62
Dism /Online /NoRestart /Cleanup-Image /ScanHealth

If ($LASTEXITCODE -ne 0)
	{
		Dism /Online /NoRestart /Cleanup-Image /RestoreHealth
		
	}
	

# SFC scan
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running System File Checker" -PercentComplete 65
SFC.EXE /SCANNOW

# Check Disk
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running CHKDSK" -PercentComplete 70
chkdsk.exe $env:SYSTEMDRIVE
if ($LASTEXITCODE -ne 0)
	{
		fsutil dirty set $env:SYSTEMDRIVE
	}


####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update"


# Allow MSI in Safe Mode
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Fixing MSI for Safe Mode" -PercentComplete 71
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\MSIServer" /ve /t reg_sz /d Service /f

# Update Apps
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Updating 3rd Party Apps" -PercentComplete 72
Install-Package 7zip,flashplayerplugin,adobereader,jre8 -Force


# Windows Updates
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Installing Windows Updates" -PercentComplete 75
Get-WUInstall -Verbose -AcceptAll -IgnoreRebootRequired

	
# DSIM Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "DISM Reset Base" -PercentComplete 78	
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase


####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize"


# Reset the System page file
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize" -CurrentOperation "Resetting Page File" -PercentComplete 80
WMIC.exe computersystem set AutomaticManagedPagefile=True

# Optimize the Volume	
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize" -CurrentOperation "Optimizing C:\" -PercentComplete 82
Optimize-Volume C

####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup"

# Restore power settings
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup" -CurrentOperation "Quitting Caffeine" -PercentComplete 88
Get-Process caffeine | Stop-Process -Force
Uninstall-Package Caffeine

# Remove TRON Temp files
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup" -CurrentOperation "Removing Temp Files" -PercentComplete 90
Remove-Item $RawLogPath -Recurse -Force
Remove-Item $TempPath -Recurse -Force

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup" -CurrentOperation "Complete!" -PercentComplete 100
		Stop-Transcript
		[Environment]::Exit(0)