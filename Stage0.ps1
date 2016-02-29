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

######################
##  PROCESS KILLER  ##
######################
<#
 
##  I want to use this eventually, but will need some troubleshooting  ## 
$SafeProc = @("explorer","TeamViewer","Gui","code")
$Processes = (Get-Process  -IncludeUserName | Where UserName -Match $env:USERNAME | Where {$_.cpu -gt 100} | Select-Object ProcessName | foreach {$_.ProcessName})
$KillProc = (Compare-Object -ReferenceObject $SafeProc -DifferenceObject $Processes | Where {$_.SideIndicator -eq '=>'} | Select-Object InputObject | ForEach-Object {$_.InputObject})

#>

& taskkill.exe /F /FI "USERNAME eq $env:USERNAME" /FI "IMAGENAME ne powershell.exe" /FI "IMAGENAME ne TRON*" /FI "IMAGENAME ne ClassicShellService.exe" /FI "IMAGENAME ne explorer.exe" /FI "IMAGENAME ne dwm.exe" /FI "IMAGENAME ne cmd.exe" /FI "IMAGENAME ne mbam.exe" /FI "IMAGENAME ne teamviewer.exe" /FI "IMAGENAME ne TeamViewer_Service.exe" /FI "IMAGENAME ne Taskmgr.exe" /FI "IMAGENAME ne Teamviewer_Desktop.exe" /FI "IMAGENAME ne MsMpEng.exe" /FI "IMAGENAME ne tv_w32.exe" /FI "IMAGENAME ne LogMeIn.exe" /FI "IMAGENAME ne powershell" /FI "IMAGENAME ne rkill.exe" /FI "IMAGENAME ne rkill64.exe" /FI "IMAGENAME ne rkill.com" /FI "IMAGENAME ne rkill64.com" /FI "IMAGENAME ne conhost.exe" /FI "IMAGENAME ne dashost.exe" /FI "IMAGENAME ne wget.exe" /FI "IMAGENAME ne TechToolbox.exe" /FI "IMAGENAME ne vmtoolsd.exe" /FI "IMAGENAME ne conhost.exe" /FI "IMAGENAME ne gui.exe" /FI "IMAGENAME ne TeamViewer.exe" /FI "IMAGENAME ne ShellExperienceHost.exe" /FI "IMAGENAME ne sihost.exe" /FI "IMAGENAME ne SearchUI.exe" /FI "IMAGENAME ne caffeine.exe" /FI "IMAGENAME ne PowerGUI.exe"

###############
##  FIX WMI  ##
###############
Stop-Service -Force ccmexec -ErrorAction SilentlyContinue
Stop-Service -Force winmgmt
[String[]]$aWMIBinaries=@("unsecapp.exe","wmiadap.exe","wmiapsrv.exe","wmiprvse.exe","scrcons.exe")
foreach ($sWMIPath in @(($ENV:SystemRoot+"\System32\wbem"),($ENV:SystemRoot+"\SysWOW64\wbem"))){
	if(Test-Path -Path $sWMIPath){
		push-Location $sWMIPath
		foreach($sBin in $aWMIBinaries){
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
if([System.Environment]::OSVersion.Version.Major -eq 5) 
{
   foreach ($sWMIPath in @(($ENV:SystemRoot+"\System32\wbem"),($ENV:SystemRoot+"\SysWOW64\wbem"))){
   		if(Test-Path -Path $sWMIPath){
			push-Location $sWMIPath
			Write-Host " Register WMI Managed Objects"
			$aWMIManagedObjects=Get-ChildItem * -Include @("*.mof","*.mfl")
			foreach($sWMIObject in $aWMIManagedObjects){
				$oWMIObject=Get-Item -Path  $sWMIObject
				& mofcomp $oWMIObject.FullName				
			}
			Pop-Location
		}
   }
	# Other Windows Vista, Server 2008 or greater
	Write-Host " Reset Repository"
	WinMgmt.exe /resetrepository | Out-Null
	WinMgmt.exe /salvagerepository | Out-Null
}
Start-Service winmgmt
Start-Service ccmexec -ErrorAction SilentlyContinue

##########################
##  INSTALL PS CMDLETS  ##
##########################

Install-Module PSWindowsUpdate -Force  
Get-PackageProvider -Name Chocolatey -Force

########################
##  GET SMART STATUS  ##
########################

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
Write-Host "Creating a Restore Point, please wait... `n `n"
Enable-ComputerRestore -Drive $env:SYSTEMDRIVE
Checkpoint-Computer -Description "TronEvo"
Write-Host "Created Restore Point."

########################
##  GET SYSTEM STATE  ##
########################

Write-Host "Getting a list of applications."
Get-WmiObject Win32_Product | Select-Object -Property Name | foreach {$_.Name} >> $RawLogPath\ProgsBefore.txt
Write-Host "Getting the User Directory Structure."
Get-ChildItem C:\Users -recurse | select -expand fullname >> $RawLogPath\FilesBefore.txt

############################
##  SET POWER MANAGEMENT  ##
############################

Write-Host "Downloading Caffeine to prevent sleep"
Install-Package Caffeine -Force
Write-Host "Running Caffeine - Please note that this will start in a new window."
Start-Process C:\Chocolatey\bin\caffeine.bat

###############################
##  SYNCHRONIZE SYSTEM CLOCK ##
###############################

Write-Host "Setting the system time" 
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\w32time" /ve /t reg_sz /d Service /f 
sc.exe config w32time start= auto 
net stop w32time 
w32tm /config /syncfromflags:manual /manualpeerlist:"time.nist.gov 3.pool.ntp.org time.windows.com" 
net start w32time 
w32tm /resync /nowait 