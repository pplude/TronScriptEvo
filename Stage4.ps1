####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 4: Repair")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 4: REPAIR      "
Write-Host "----------------------------"

# DSIM Cleanup
Dism /Online /NoRestart /Cleanup-Image /ScanHealth /Logpath#"$LogPath\tron_dism.log"

If ($LASTEXITCODE -ne 0)
	{
		Dism /Online /NoRestart /Cleanup-Image /RestoreHealth /Logpath#"$LogPath\tron_dism.log"
		
	}
	

## Security database repair
secedit /configure /cfg C:\Windows\repair\secsetup.inf /db secsetup.sdb /verbose >> "$RawLogPath\secedit_filesystem_reset.log"

# SFC scan
Write-Host "Fixing SFC"
sfc.exe /scannow

# Check Disk
chkdsk.exe $env:SYSTEMDRIVE
if ($LASTEXITCODE -ne 0)
	{
		Write-Host "Errors Found, fixing on next reboot"
		fsutil dirty set $env:SYSTEMDRIVE
	}