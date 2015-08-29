####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 6: Optimize")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 6: OPTIMIZE     "
Write-Host "----------------------------"

# Reset the System page file
Write-Host "Resetting page file settings to Windows defaults..."
WMIC.exe computersystem set AutomaticManagedPagefile=True

# Detect if you are running an SSD Drive
If ((Get-PhysicalDisk | Select-Object MediaType | foreach {$_.MediaType} | Select-String -Pattern 'SSD' -SimpleMatch -Quiet) -eq "True")
	{
		$SSD = "True"
	}
	
# Detect if you are running RAID
If ((Get-PhysicalDisk | Select-Object MediaType | foreach {$_.MediaType} | Select-String -Pattern 'RAID' -SimpleMatch -Quiet) -eq "True")
	{
		$RAID = "True"
	}	

# Check for Defrag
If (($SSD -eq "True") -or ($RAID -eq "True"))
	{
		Write-Host "Skipping Defrag"
	}
Else 
	{
		Write-Host "Updating/Installing Defraggler"
		choco.exe upgrade defraggler -y
		Write-Host "Defragging Drive"
		& 'C:\Program Files\Defraggler\df.exe' $env:SYSTEMDRIVE /MinPercent 5
	}

###########################
##    STAGE 6 COMPLETE   ##
###########################
