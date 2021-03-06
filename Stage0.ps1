####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 0: Prep")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "       STAGE 0: Prep        "
Write-Host "----------------------------"

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Setting up the Progress Bar" -PercentComplete 1

######################
##  PROCESS KILLER  ##
######################

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Killing Rogue Processes" -PercentComplete 2
$SafeProc = @("explorer","TeamViewer","Gui","code","powershell","TRON:Evo","cmd","mbam","MsMpEng","tv_w32","conhost","dashost","gui","caffeine","PowerGUI")
$Processes = (Get-Process  -IncludeUserName | Where UserName -Match $env:USERNAME | Where {$_.cpu -gt 100} | Select-Object ProcessName | foreach {$_.ProcessName})
$KillProc = (Compare-Object -ReferenceObject $SafeProc -DifferenceObject $Processes | Where {$_.SideIndicator -eq '=>'} | Select-Object InputObject | ForEach-Object {$_.InputObject})
Stop-Process -Name $KillProc

###############
##  FIX WMI  ##
###############
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Fixing WMI" -PercentComplete 4
Stop-Service -Force ccmexec -ErrorAction SilentlyContinue
Stop-Service -Force winmgmt
$WMIBinaries=@("unsecapp.exe","wmiadap.exe","wmiapsrv.exe","wmiprvse.exe","scrcons.exe")
foreach ($sWMIPath in @(($ENV:SystemRoot+"\System32\wbem"),($ENV:SystemRoot+"\SysWOW64\wbem"))){
	if(Test-Path -Path $sWMIPath){
		push-Location $sWMIPath
		foreach($sBin in $WMIBinaries){
			if(Test-Path -Path $sBin){
				$oCurrentBin=Get-Item -Path  $sBin
				Write-Host " Register $sBin"
				& $oCurrentBin.FullName /RegServer
			}
			else{
				# Warning only for System32
				if($sWMIPath -eq $ENV:SystemRoot+"\System32\wbem"){
					Write-Warning "File $sBin not found!"
				}
			}
		}
		Pop-Location
	}
}
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Resetting Repository" -PercentComplete 5
Write-Host "Reset Repository"
WinMgmt.exe /resetrepository | Out-Null
WinMgmt.exe /salvagerepository | Out-Null

Start-Service winmgmt
Start-Service ccmexec -ErrorAction SilentlyContinue

########################
##  GET SMART STATUS  ##
########################

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Checking SMART status" -PercentComplete 7
Write-Host (Get-WmiObject Win32_DiskDrive | Select-Object Index,Status,StatusInfo | Format-Table -AutoSize) 
$DriveStat = (Get-WmiObject Win32_DiskDrive | Select-Object Status | foreach {$_.Status})
If (($DriveStat -eq "Error") -or ($DriveStat -eq "Degraded") -or ($DriveStat -eq "Unknown") -or ($DriveStat -eq "PredFail") -or ($DriveStat -eq "Service") -or ($DriveStat -eq "Stressed") -or ($DriveStat -eq "NonRecover"))
	{
		[System.Windows.Forms.MessageBox]::Show("SMART check indicates at least one drive with $DriveStat status. SMART errors can mean a drive is close to failure, be careful running disk-intensive operations like defrag.","WARNING")
		$SkipOptimizeC -eq "True"
	}
	
############################
##  CREATE RESTORE POINT  ##
############################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Creating a Resore Point" -PercentComplete 8
Write-Host "Creating a Restore Point, please wait... `n `n"
Enable-ComputerRestore -Drive $env:SYSTEMDRIVE
Checkpoint-Computer -Description "TronEvo"
Write-Host "Created Restore Point."

########################
##  GET SYSTEM STATE  ##
########################

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Getting a list of installed Applications" -PercentComplete 10
Get-WmiObject Win32_Product | Select-Object -Property Name | foreach {$_.Name} >> $RawLogPath\ProgsBefore.txt
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Getting a list of user files" -PercentComplete 12
Get-ChildItem C:\Users -recurse | select -expand fullname >> $RawLogPath\FilesBefore.txt

############################
##  SET POWER MANAGEMENT  ##
############################

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Downliading Caffeine to prevent sleep" -PercentComplete 14
Install-Package Caffeine -Force
Write-Host "Running Caffeine - Please note that this will start in a new window."
Start-Process C:\Chocolatey\bin\caffeine.bat

###############################
##  SYNCHRONIZE SYSTEM CLOCK ##
###############################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 0: Prep" -CurrentOperation "Fixing the system time" -PercentComplete 15
Write-Host "Setting the system time" 
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\w32time" /ve /t reg_sz /d Service /f 
sc.exe config w32time start= auto 
net stop w32time 
w32tm /config /syncfromflags:manual /manualpeerlist:"time.nist.gov 3.pool.ntp.org time.windows.com" 
net start w32time 
w32tm /resync /nowait 