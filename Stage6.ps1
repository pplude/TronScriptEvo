####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 6: OPTIMIZE     "
Write-Host "----------------------------"

# Reset the System page file
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize" -CurrentOperation "Resetting Page File" -PercentComplete 80
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
		Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 6: Optimize" -CurrentOperation "Optimizing C:\" -PercentComplete 82
        Optimize-Volume C
	}