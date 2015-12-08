####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 1: TempClean")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "     STAGE 1: TEMP CLEAN    "
Write-Host "----------------------------"

#################
##  VARIABLES  ##
#################

$TempFolders = @("C:\Windows\Temp\*","$env:TEMP","C:\Windows\Prefetch\*","C:\Users\Users\*\AppData\Local\Temp\*","C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\*","C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*","C:\Users\*\My Documents\*.tmp")
$DriverFolders = @("C\NVIDIA","C\ATI","C\AMD","C\DELL","C\Intel","C\HP")
$UpdateBG = @("C:\Windows\*.log","C:\Windows\*.txt","C:\Windows\*.bmp","C:\Windows\*.tmp","C:\Windows\Web\Wallpaper\*.*","C:\Windows\Web\Wallpaper\Dell")
$FlashCache = @("C:\Users\Users\*\AppData\Roaming\Macromedia\Flash Player\#SharedObjects","C:\Users\Users\*\AppData\Roaming\Macromedia\Flash Player\macromedia.com\support\flashplayer\sys")

Clear-Host
Write-Host "STAGE 1: Temporary Files Cleanup `n `n `n" 

# Clean Internet Explorer
Write-Host "Cleaning Internet Explorer" 
rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351

# Temp File Cleanup
Write-Host "Cleaning User Files `n"
Remove-Item -Path $TempFolders -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Finished Cleaning: $TempFolders `n" 

# Clean System Files
Write-Host "Cleaning System Files"
Write-Host "Removing Driver Temp Files"
Remove-Item -Path $DriverFolders -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Removing Office Installation Cache"
Remove-Item "C:\MSOCache" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Removing the Windows installation cache"
Remove-Item "C:\Windows\i386" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Emptying Recycle Bin"
Remove-Item "C:\$Recycle.Bin" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\RECYCLER" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Clearing the MUI Cache"
reg.exe delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f
Write-Host "Clearing the Windows Update Logs and Built-In Backgrounds"
Remove-Item $UpdateBG -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Remove Flash Cache"
Remove-Item $FlashCache -Force -Recurse -ErrorAction SilentlyContinue

# Install CCleaner
Write-Host "Installing/Updating CCleaner"
choco.exe upgrade ccleaner -y | Out-Null
Write-Host "Running CCleaner"
& 'C:\Program Files (x86)\CCleaner\CCleaner.exe' /AUTO

# Install Bleachbit
Write-Host "Installing/Updating BleachBit"
choco.exe upgrade bleachbit -y | Out-Null
Write-Host "Running BleachBit"
& 'C:\Program Files (x86)\BleachBit\bleachbit_console.exe' --preset -c

# Clear the Event Logs
Write-Host "Backing up Event Logs"
Get-EventLog System >> $BackupPath\EventSystem.txt
Get-EventLog Application >> $BackupPath\EventApplication.txt
Get-EventLog Security >> $BackupPath\EventSecurity.txt
Write-Host "Done backing up, clearing"

If ($PreserveEventLog.IsPresent)
	{
		Write-Host "Preserving Event Logs"
	}
Else
	{
		Clear-EventLog System
		Clear-EventLog Application
		Clear-EventLog Security
	}

# Clear Windows Update Cache
Write-Host "Clearing the Windows Update Cache"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\WUAUSERV" /ve /t reg_sz /d Service /f 
net stop WUAUSERV 
Remove-Item C:\Windows\SoftwareDistribution\Download -Recurse -ErrorAction SilentlyContinue
net start WUAUSERV 

# Purge oldest VSS copies
net start VSS
vssadmin.exe delete shadows /for=$env:SystemDrive /oldest /quiet
Write-Host "Old VSS Purged" 

# Reduce System Restore Space
Write-Host "Reducing System Restore to max of 7% of disk"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DiskPercent /t REG_DWORD /d 00000007 /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\Cfg" /v DiskPercent /t REG_DWORD /d 00000007 /f 

########################
##  STAGE 1 COMPLETE  ##
########################
