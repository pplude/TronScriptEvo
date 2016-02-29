####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update"


##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 5: UPDATE      "
Write-Host "----------------------------"

# Allow MSI in Safe Mode
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Fixing MSI for Safe Mode" -PercentComplete 71
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\$SafeMode\MSIServer" /ve /t reg_sz /d Service /f

# Update Apps
If ($SkipPatches.IsPresent)
	{
		Write-Host "Skip Patches Selected...Moving on."
	}
Else
	{
		Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Updating 3rd Party Apps" -PercentComplete 72
		Install-Package 7zip,flashplayerplugin,adobereader,jre8 -Force
	}

# Windows Updates
If ($SkipWinUpdate.IsPresent)
	{
		Write-Host "Skipping Windows Updates"
	}
Else
	{
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "Installing Windows Updates" -PercentComplete 75
		Get-WUInstall -Verbose -AcceptAll -IgnoreRebootRequired
	}
	
# DSIM Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 5: Update" -CurrentOperation "DISM Reset Base" -PercentComplete 78	
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase /Logpath:"$LogPath\tron_dism_base_reset.log"