####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 4: Repair"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 4: REPAIR      "
Write-Host "----------------------------"

# DSIM Cleanup
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running DISM Cleanup" -PercentComplete 62
Dism /Online /NoRestart /Cleanup-Image /ScanHealth /Logpath#"$LogPath\tron_dism.log"

If ($LASTEXITCODE -ne 0)
	{
		Dism /Online /NoRestart /Cleanup-Image /RestoreHealth /Logpath#"$LogPath\tron_dism.log"
		
	}
	

# SFC scan
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running System File Checker" -PercentComplete 65
SFC.EXE /SCANNOW

# Check Disk
Write-ProgressBar -ProgressBar $TronProgress -Activity  "Stage 4: Repair" -CurrentOperation "Running CHKDSK" -PercentComplete 70
chkdsk.exe $env:SYSTEMDRIVE
if ($LASTEXITCODE -ne 0)
	{
		Write-Host "Errors Found, fixing on next reboot"
		fsutil dirty set $env:SYSTEMDRIVE
	}