####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 5: Update")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 5: UPDATE      "
Write-Host "----------------------------"

# Allow MSI in Safe Mode
Write-Host "Alowing MSI in safe mode"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\MSIServer" /ve /t reg_sz /d Service /f

# Chocolatey to the rescue - Update Apps
Write-Host "Updating Apps"
choco.exe upgrade 7zip flashplayerplugin adobereader jre8 -y

# Windows Updates
if(-Not $skipReg)
	{
		Write-Host "Running Windows Update"
		wuauclt /detectnow /updatenow
	}
Write-Host "Fixing the Windows Update datastore"
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase /Logpath:"$LogPath\tron_dism_base_reset.log"

###########################
##    STAGE 5 COMPLETE   ##
###########################
