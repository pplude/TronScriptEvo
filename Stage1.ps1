####################
##  WINDOW SETUP  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean"

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


# Clean Internet Explorer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing Internet Explorer Cache" -PercentComplete 16
rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351

# Temp File Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Cleanin User Files" -PercentComplete 18
Remove-Item -Path $TempFolders -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Finished Cleaning: $TempFolders `n" 

# Clean System Files
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Cleaning Driver Folders" -PercentComplete 19
Remove-Item -Path $DriverFolders -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Removing Office Installation Cache" -PercentComplete 19
Remove-Item "C:\MSOCache" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Removing Windows Installation Cache" -PercentComplete 19
Remove-Item "C:\Windows\i386" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Emptying Recycle Bin" -PercentComplete 19
Remove-Item "C:\$Recycle.Bin" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "C:\RECYCLER" -Force -Recurse -ErrorAction SilentlyContinue

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing MUI Cache" -PercentComplete 20
reg.exe delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f
Write-Host "Clearing the Windows Update Logs and Built-In Backgrounds"
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
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Clearing Windows Update Cache" -PercentComplete 23
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\WUAUSERV" /ve /t reg_sz /d Service /f 
net stop WUAUSERV 
Remove-Item C:\Windows\SoftwareDistribution\Download -Recurse -ErrorAction SilentlyContinue
net start WUAUSERV 

# Purge oldest VSS copies
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Purging VSS" -PercentComplete 24
net start VSS
vssadmin.exe delete shadows /for=$env:SystemDrive /oldest /quiet


# Reduce System Restore Space
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 1: Temp Clean" -CurrentOperation "Reducing Windows Restore Space" -PercentComplete 24
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v DiskPercent /t REG_DWORD /d 00000007 /f 
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\Cfg" /v DiskPercent /t REG_DWORD /d 00000007 /f 