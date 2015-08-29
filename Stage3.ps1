####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 3: Disinfect")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 3: DISINFECT    "
Write-Host "----------------------------"

# Run Stinger
Write-Host "Downloading McAfee Stinger"
Invoke-WebRequest http://downloadcenter.mcafee.com/products/mcafee-avert/Stinger/stinger32.exe -OutFile $TempPath\Stinger.exe
Write-Host "Stinger does not write to Tron...need to make a raw log"
Write-Host "Starting Stinger"
& $TempPath\stinger.exe --GO --SILENT --PROGRAM --REPORTPATH="$RawLogPath" --DELETE

# Run TDSS Killer
Write-Host "Downloading Kaspersky TDSS Killer"
Invoke-WebRequest http://media.kaspersky.com/utilities/VirusUtilities/EN/tdsskiller.exe -OutFile $TempPath\TDSS.exe
Write-Host "Starting TDSS Killer"
& '$TempPath\TDSS.exe -l $TempPath\tdsskiller.log -silent -tdlfs -dcexact -accepteula -accepteulaksn'
Get-Content $TempPath\tdsskiller.log 
Remove-Item $TempPath\tdsskiller.log

#Rogue Killer
Write-Host "Downloading RogueKiller"
Invoke-WebRequest "http://www.sur-la-toile.com/RogueKiller/RogueKiller.exe" -OutFile "$TempPath\Rogue.exe"
Write-Host "Running RogueKiller - This will open a new Window"
Start-Process $TempPath\Rogue.exe

# MalwareBytes
Write-Host "Updating Malwarebytes"
choco.exe upgrade malwarebytes -y
Write-Host "Running Malwarebytes - This will open a new Window"
Start-Process "C:\Program Files (x86)\Malwarebytes Anti-Malware\mbam.exe"
Write-Host "You MUST click SCAN in the window! `n `n"

# Kaspersky Virus Removal Tool
Write-Host "Downloading Kaspersky Virus Removal Tool"
Invoke-WebRequest "http://devbuilds.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe" -OutFile "$TempPath\KVRT.exe"
Write-Host "Running Kaspersky Virus Removal Tool"
& $TempPath\KVRT.exe -d "$RawLogPath" -accepteula -adinsilent -silent -processlevel 2 -dontcryptsupportinfo

# Sophos Virus Removal Tool
<# DISABLING -- THIS NEEDS INSTALLATION ??
Write-Host "Downloading Sophos Virus Removal Tool"
Invoke-WebRequest "http://downloads.sophos.com/tools/withides/Sophos%20Virus%20Removal%20Tool.exe" -OutFile "$TempPath\Sophos.exe"
Write-Host "Running Sohpos Virus Removal Tool `n `n"
& $TempPath\Sophos.exe -yes
#>

###########################
##    STAGE 3 COMPLETE   ##
###########################