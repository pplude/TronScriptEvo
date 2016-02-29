####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 3: DISINFECT    "
Write-Host "----------------------------"

# Run Stinger
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading McAfee Stinger" -PercentComplete 35
Invoke-WebRequest http://downloadcenter.mcafee.com/products/mcafee-avert/Stinger/stinger32.exe -OutFile $TempPath\Stinger.exe
Write-Host "Stinger does not write to Tron...need to make a raw log"
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running Stinger" -PercentComplete 36
& $TempPath\stinger.exe --GO --SILENT --PROGRAM --REPORTPATH="$RawLogPath" --DELETE

# Run TDSS Killer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading Kaspersky TDSS Killer" -PercentComplete 40
Invoke-WebRequest http://media.kaspersky.com/utilities/VirusUtilities/EN/tdsskiller.exe -OutFile $TempPath\TDSS.exe
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running TDSS Killer" -PercentComplete 41
& '$TempPath\TDSS.exe -l $TempPath\tdsskiller.log -silent -tdlfs -dcexact -accepteula -accepteulaksn'
Get-Content $TempPath\tdsskiller.log 
Remove-Item $TempPath\tdsskiller.log

#Rogue Killer
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading RogueKiller" -PercentComplete 45
Invoke-WebRequest "http://www.sur-la-toile.com/RogueKiller/RogueKiller.exe" -OutFile "$TempPath\Rogue.exe"
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running RogueKiller - This will open a new window." -PercentComplete 46
Start-Process $TempPath\Rogue.exe

# MalwareBytes
If ($SkipMBAM.IsPresent)
	{
		Write-Host "Skip Malwarebytes Selected...Moving on"
	}
Else
	{
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Installing/Updating MalwareBytes AntiMalware" -PercentComplete 50
		Install-Package malwarebytes -Force
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running MalwareBytes" -PercentComplete 51
		Start-Process "C:\Program Files (x86)\Malwarebytes Anti-Malware\mbam.exe"
		Write-Host "You MUST click SCAN in the window! `n `n"
	}

# Kaspersky Virus Removal Tool
If ($SkipKaspersky.IsPresent)
	{
		Write-Host "Skip Kaspersky Selected...Moving on"
	}
Else
	{
		Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Downloading Kaspersky Virus Removal Tool" -PercentComplete 56
		Invoke-WebRequest "http://devbuilds.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe" -OutFile "$TempPath\KVRT.exe"
		Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 3: Disinfect" -CurrentOperation "Running KVRT" -PercentComplete 57
		Start-Process $TempPath\KVRT.exe -d "$RawLogPath" -accepteula -adinsilent -silent -processlevel 2 -dontcryptsupportinfo
	}