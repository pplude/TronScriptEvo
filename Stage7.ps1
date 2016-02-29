####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 7: CLEANUP     "
Write-Host "----------------------------"

# Restore power settings
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup" -CurrentOperation "Quitting Caffeine" -PercentComplete 88
Get-Process caffeine | Stop-Process -Force
Uninstall-Package Caffeine

# Remove TRON Temp files
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 7: Cleanup" -CurrentOperation "Removing Temp Files" -PercentComplete 90
Remove-Item $RawLogPath -Recurse -Force
Remove-Item $QuarantinePath -Recurse -Force
Remove-Item $TempPath -Recurse -Force