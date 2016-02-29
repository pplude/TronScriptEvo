####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 7: Cleanup")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 7: CLEANUP     "
Write-Host "----------------------------"

# Restore power settings
Write-Host "Quitting Caffeine"
Get-Process caffeine | Stop-Process -Force
Uninstall-Package Caffeine

# Remove TRON Temp files
Write-Host "Cleaning TRON:Evo Temp Files"
Remove-Item $RawLogPath -Recurse -Force
Remove-Item $QuarantinePath -Recurse -Force
Remove-Item $TempPath -Recurse -Force

Clear-Host
Write-Host "TRON:Evo is complete. Please reboot the computer. `n `n"

Write-Host "-------------------------------------------------------------------------------
$((Get-Date).ToString("MMdd-hm"))   TRON v$ScriptVersion ($ScriptDate) complete
                         Executed as "$env:USERNAME" on "$env:COMPUTERNAME"
                          Safe Mode: $SafeMode
                          Logfile: $LogFile
-------------------------------------------------------------------------------"