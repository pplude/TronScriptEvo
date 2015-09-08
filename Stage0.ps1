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
$chocoUFlag = $false

Write-Host "Verifing that Chocolatey is installed."
if(Test-Path("C:\ProgramData\chocolatey\choco.exe"))
{
    $chocoinstver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\ProgramData\chocolatey\choco.exe").FileVersion
    Write-Host "Chocolatey $chocoinstver already installed. Checking for updates."
    choco.exe upgrade chocolatey -y | Out-Null
    $chocoupgver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\ProgramData\chocolatey\choco.exe").FileVersion
    if($chocoinstver -eq $chocoupgver)
    {
        Write-Host "Chocolatey is already at the latest version."
    }
    else
    {
        Write-Host "Chocolatey has been upgraded from $chocoinstver to $chocoupgver."
    }
    $chocoUFlag = $true
}
else
{
    Write-Host "Chocolatey not installed, installing."
    Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
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

Write-Host "Downloading Caffeine to prevent sleep"
Invoke-WebRequest "http://www.zhornsoftware.co.uk/caffeine/caffeine.zip" -OutFile $TempPath\Caf.zip
Expand-Archive -Path $TempPath\Caf.zip -DestinationPath $TempPath
Write-Host "Running Caffeine"
$TempPath\caffeine.exe

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
