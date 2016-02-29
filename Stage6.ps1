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

# Optimize the Volume
<# The Optimize-Volume cmdlet optimizes a volume, performing such tasks on supported volumes and system SKUs as
    defragmentation, trim, slab consolidation, and storage tier processing.

     If no parameter is specified, then the default operation will be performed per the drive type as follows.

    -- HDD, Fixed VHD, Storage Space. -Analyze -Defrag.
    -- Tiered Storage Space. -TierOptimize.
    -- SSD with TRIM support. -Retrim.
    -- Storage Space (Thinly provisioned), SAN Virtual Disk (Thinly provisioned), Dynamic VHD, Differencing VHD.
    -Analyze -SlabConsolidate -Retrim.
    -- SSD without TRIM support, Removable FAT, Unknown. No operation. #>
	
If ($SkipOptimizeC.IsPresent)
	{
		Write-Host "Skipping Optimization of Drive C:\ ... Moving on."
	}
Else
	{
		Optimize-Volume C
	}