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
TASKKILL.EXE /IM caffeine.exe #This is more reliable then using the PID

##########################
## UNINSTALL CHOCOLATEY ##
##########################
$chocoDirectory = "C:\ProgramData\chocolatey\" ## Define location for chocolatey

if($chocoUFlag -eq $false) ## Check if Chocolatey should be uninstalled or not.
{
    Write-Host "Verifing that Chocolatey is installed." ## Check for Chocolatey Directory. 
    if(Test-Path($chocoDirectory))
    {
        Write-Host "Chocolatey installed. Uninstalling chocolatey..."
        Get-ChildItem -Path $chocoDirectory -Recurse | Remove-Item -force -recurse -verbose ## Removing Child Items first.
        Remove-Item $chocoDirectory -force -recurse -verbose ## Now Remove the Parent Directory
        Write-Host "Chocolatey uninstalled."
    }
    else
    {
    	Write-Host "Something went wrong or Chocolatey was not found."
    }
}
else
{
    Write-Host "Chocolatey was pre-installed. Skipping removal."
}

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

###########################
##    STAGE 7 COMPLETE   ##
###########################
