####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 0: Prep")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 0: Prep        "
Write-Host "----------------------------"

##########################
##  INSTALL CHOCOLATEY  ##
##########################

Write-Host "Verifing that Chocolatey is installed."
if(Test-Path("C:\ProgramData\chocolatey\choco.exe"))
{
    $chocover = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\ProgramData\chocolatey\choco.exe").FileVersion
    Write-Host "Chocolatey $chocover already installed."
}
else
{
    Write-Host "Chocolatey not installed, installing."
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
	Write-Host "Chocolatey has been installed"
}

#########################
##  ENABLE F8 AT BOOT  ##
#########################


If ($WindowsNTVersion -eq '8')
	{
		bcdedit /set {default} bootmenupolicy legacy
	}

########################
##  GET SMART STATUS  ##
########################

Write-Host (Get-WmiObject Win32_DiskDrive | Select-Object Index,Status,StatusInfo | Format-Table -AutoSize) 
$DriveStat = (Get-WmiObject Win32_DiskDrive | Select-Object Status | foreach {$_.Status})
If (($DriveStat -eq "Error") -or ($DriveStat -eq "Degraded") -or ($DriveStat -eq "Unknown") -or ($DriveStat -eq "PredFail") -or ($DriveStat -eq "Service") -or ($DriveStat -eq "Stressed") -or ($DriveStat -eq "NonRecover"))
	{
		Write-Host "! WARNING! SMART check indicates at least one drive with $DriveStat status
SMART errors can mean a drive is close to failure, be careful
running disk-intensive operations like defrag.

		" 
	}
	
############################
##  CREATE RESTORE POINT  ##
############################
Write-Host "Creating a Restore Point, please wait... `n `n"
Enable-ComputerRestore -Drive $env:SYSTEMDRIVE
Checkpoint-Computer -Description "TronEvo"
Write-Host "Created Restore Point."

########################
##  GET SYSTEM STATE  ##
########################

Write-Host "Getting a list of applications."
Get-WmiObject Win32_Product | Select-Object -Property Name | foreach {$_.Name} >> $RawLogPath\ProgsBefore.txt
Write-Host "Getting the User Directory Structure."
Get-ChildItem C:\Users -recurse | select -expand fullname >> $RawLogPath\FilesBefore.txt

############################
##  SET POWER MANAGEMENT  ##
############################

Write-Host "Disabling Screen Saver."
reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f >> "$LogFile"
Write-Host "Disabling Sleep."
powercfg.exe -S SCHEME_MIN
Write-Host "High-Performance Activated" 

###############################
##  SYNCHRONIZE SYSTEM CLOCK ##
###############################

Write-Host "Setting the system time" 
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\w32time" /ve /t reg_sz /d Service /f 
sc.exe config w32time start= auto 
net stop w32time 
w32tm /config /syncfromflags:manual /manualpeerlist:"time.nist.gov 3.pool.ntp.org time.windows.com" 
net start w32time 
w32tm /resync /nowait 

###########################
##    STAGE 0 COMPLETE   ##
###########################
