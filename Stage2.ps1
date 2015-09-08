####################
##  WINDOW SETUP  ##
####################
Clear-Host
$Host.UI.RawUI.WindowTitle = ("TRON:Evo Stage 2: De-Bloat")

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 2: DE-BLOAT     "
Write-Host "----------------------------"

Get-Content -Path ".\AppsByName.txt" | ForEach-Object { $Testing1 = $_
	Write-Host "Checking and Removing $Testing1"
	WMIC.exe product where "caption like '$Testing1'" uninstall /nointeractive }
	
####################
##  Apps By GUID  ##
####################

# Ask Toolbar
 msiexec /x 4F524A2D-5637-006A-76A7-A758B70C0300 /qn /norestart | Out-Null
 msiexec /x 86D4B82A-ABED-442A-BE86-96357B70F4FE /qn /norestart | Out-Null

# Best Buy pc app
 msiexec /x FBBC4667-2521-4E78-B1BD-8706F774549B /qn /norestart | Out-Null

# Bing Bar
 msiexec /x 3365E735-48A6-4194-9988-CE59AC5AE503 /qn /norestart | Out-Null
 msiexec /x C28D96C0-6A90-459E-A077-A6706F4EC0FC /qn /norestart | Out-Null
 msiexec /x 77F8A71E-3515-4832-B8B2-2F1EDBD2E0F1 /qn /norestart | Out-Null

# Bing Desktop
 msiexec /x 7D095455-D971-4D4C-9EFD-9AF6A6584F3A /qn /norestart | Out-Null

# Dell Access
 msiexec /x F839C6BD-E92E-48FA-9CE6-7BFAF94F7096 /qn /norestart | Out-Null

# Dell Backup and Recovery Manager
 msiexec /x 975DFE7C-8E56-45BC-A329-401E6B1F8102 /qn /norestart | Out-Null
 msiexec /x 50B4B603-A4C6-4739-AE96-6C76A0F8A388 /qn /norestart | Out-Null
 msiexec /x 731B0E4D-F4C7-450C-95B0-E1A3176B1C75 /qn /norestart | Out-Null
rd /s /q C:\dell\dbrm

# Dell Client System Update
 msiexec /x 69093D49-3DD1-4FB5-A378-0D4DB4CF86EA /qn /norestart | Out-Null
 msiexec /x 04566294-A6B6-4462-9721-031073EB3694 /qn /norestart | Out-Null
 msiexec /x 2B2B45B1-3CA0-4F8D-BBB3-AC77ED46A0FE /qn /norestart | Out-Null

# Dell Command | Update
 msiexec /x EC542D5D-B608-4145-A8F7-749C02BE6D94 /qn /norestart | Out-Null

# Dell Command | Power
 msiexec /x DDDAF4A7-8B7D-4088-AECC-6F50E594B4F5 /qn /norestart | Out-Null

# Dell ControlPoint
 msiexec /x A9C61491-EF2F-4ED8-8E10-FB33E3C6B55A /qn /norestart | Out-Null

# Dell ControlVault Host Components Installer
 msiexec /x 5A26B7C0-55B1-4DA8-A693-E51380497A5E /qn /norestart | Out-Null

# Dell Datasafe Online
 msiexec /x 7EC66A95-AC2D-4127-940B-0445A526AB2F /qn /norestart | Out-Null

# Dell Dock
 msiexec /x E60B7350-EA5F-41E0-9D6F-E508781E36D2 /qn /norestart | Out-Null

# Dell "Feature Enhancement" Pack
 msiexec /x 992D1CE7-A20F-4AB0-9D9D-AFC3418844DA /qn /norestart | Out-Null

# Dell Getting Started Guide
 msiexec /x 7DB9F1E5-9ACB-410D-A7DC-7A3D023CE045 /qn /norestart | Out-Null

# Dell Power Manager
 msiexec /x CAC1E444-ECC4-4FF8-B328-5E547FD608F8 /qn /norestart | Out-Null

# Dell Support Center
 msiexec /x 0090A87C-3E0E-43D4-AA71-A71B06563A4A /qn /norestart | Out-Null

# Embassy Suite
 msiexec /x 20A4AA32-B3FF-4A0B-853C-ACDDCD6CB344 /qn /norestart | Out-Null

# Epson Customer Participation
 msiexec /x 814FA673-A085-403C-9545-747FC1495069 /qn /norestart | Out-Null

# ESC Home Page Plugin
 msiexec /x E738A392-F690-4A9D-808E-7BAF80E0B398 /qn /norestart | Out-Null

# HP Customer Experience Enhancements
 msiexec /x 07FA4960-B038-49EB-891B-9F95930AA544 /qn /norestart | Out-Null

# HP Connected Music
 msiexec /x 8126E380-F9C6-4317-9CEE-9BBDDAB676E5 /qn /norestart | Out-Null

# HP PostScript Converter
 msiexec /x 6E14E6D6-3175-4E1A-B934-CAB5A86367CD /qn /norestart | Out-Null

# HP Registration Service
 msiexec /x D1E8F2D7-7794-4245-B286-87ED86C1893C /qn /norestart | Out-Null

# HP SimplePass
 msiexec /x 314FAD12-F785-4471-BCE8-AB506642B9A1 /qn /norestart | Out-Null

# HP Status Alerts
 msiexec /x 9D1DE902-8058-4555-A16A-FBFAA49587DB /qn /norestart | Out-Null

# HP Support Assistant
 msiexec /x 8C696B4B-6AB1-44BC-9416-96EAC474CABE /qn /norestart | Out-Null

# HP Update
 msiexec /x 912D30CF-F39E-4B31-AD9A-123C6B794EE2 /qn /norestart | Out-Null

# HP Utility Center
 msiexec /x B7B82520-8ECE-4743-BFD7-93B16C64B277 /qn /norestart | Out-Null

# Intel Trusted Connect Client
 msiexec /x 44B72151-611E-429D-9765-9BA093D7E48A /qn /norestart | Out-Null

# Intel Update
 msiexec /x 78091D68-706D-4893-B287-9F1DFB24F7AF /qn /norestart | Out-Null

# Intel Update Manager
 msiexec /x 608E1B9B-A2E8-4A1F-8BAB-874EB0DD25E3 /qn /norestart | Out-Null

# Java Auto Updater
 msiexec /x 4A03706F-666A-4037-7777-5F2748764D10 /qn /norestart | Out-Null
 msiexec /x CCB6114E-9DB9-BD54-5AA0-BC5123329C9D /qn /norestart | Out-Null

# Lenovo Message Center Plus
 msiexec /x 3849486C-FF09-4F5D-B491-3E179D58EE15 /qn /norestart | Out-Null

# Lenovo Metrics Collector SDK
 msiexec /x DDAA788F-52E6-44EA-ADB8-92837B11BF26 /qn /norestart | Out-Null

# Lenovo Patch Utility
 MsiExec /X C6FB6B4A-1378-4CD3-9CD3-42BA69FCBD43 /qn /norestart | Out-Null

# Lenovo Reach
 msiexec /x 3245D8C8-7FE0-4FD4-B04B-2720A333D592 /qn /norestart | Out-Null
 msiexec /x 0B5E0E89-4BCA-4035-BBA1-D1439724B6E2 /qn /norestart | Out-Null

# Lenovo Registration
 msiexec /x 6707C034-ED6B-4B6A-B21F-969B3606FBDE /qn /norestart | Out-Null

# Lenovo SMB Customizations
 msiexec /x AFD7B869-3B70-40C7-8983-769256BA3BD2 /qn /norestart | Out-Null

# Lenovo Solution Center
 msiexec /x 63942F7E-3646-45EC-B8A9-EAC40FEB66DB /qn /norestart | Out-Null
 msiexec /x 13BD494D-9ACD-420B-A291-E145DED92EF6 /qn /norestart | Out-Null
 msiexec /x 4C2B6F96-3AED-4E3F-8DCE-917863D1E6B1 /qn /norestart | Out-Null

# Lenovo System Update
 msiexec /x 25C64847-B900-48AD-A164-1B4F9B774650 /qn /norestart | Out-Null
 msiexec /x 8675339C-128C-44DD-83BF-0A5D6ABD8297 /qn /norestart | Out-Null
 msiexec /x C9335768-C821-DD44-38FB-A0D5A6DB2879 /qn /norestart | Out-Null

# Lenovo User Guide
 msiexec /x 13F59938-C595-479C-B479-F171AB9AF64F /qn /norestart | Out-Null

# Lenovo Warranty Info
 msiexec /x FD4EC278-C1B1-4496-99ED-C0BE1B0AA521 /qn /norestart | Out-Null

# Microsoft Search Enhancement Pack
 msiexec /x 4CBA3D4C-8F51-4D60-B27E-F6B641C571E7 /qn /norestart | Out-Null

# Office 2013 C2R Suite
 msiexec /x 90150000-0138-0409-0000-0000000FF1CE /qn /norestart | Out-Null

# Roxio File Backup
 msiexec /x 60B2315F-680F-4EB3-B8DD-CCDC86A7CCAB /qn /norestart | Out-Null

# Roxio BackOnTrack
 msiexec /x 5A06423A-210C-49FB-950E-CB0EB8C5CEC7 /qn /norestart | Out-Null

# Skype Click 2 Call
 msiexec /x 6D1221A9-17BF-4EC0-81F2-27D30EC30701 /qn /norestart | Out-Null

# Toshiba ReelTime
 msiexec /x 24811C12-F4A9-4D0F-8494-A7B8FE46123C /qn /norestart | Out-Null

# Toshiba Book Place
 msiexec /x 92C7DC44-DAD3-49FE-B89B-F92C6BA9A331 /qn /norestart | Out-Null

# Toshiba Value Added Package
 msiexec /x 066CFFF8-12BF-4390-A673-75F95EFF188E /qn /norestart | Out-Null

# Toshiba Wireless LAN Indicator
 msiexec /x CDADE9BC-612C-42B8-B929-5C6A823E7FF9 /qn /norestart | Out-Null

# Toshiba Bulletin Board
 msiexec /x C14518AF-1A0F-4D39-8011-69BAA01CD380  /qn /norestart | Out-Null

# Trend Micro Trial
 msiexec /x BED0B8A2-2986-49F8-90D6-FA008D37A3D2 /qn /norestart | Out-Null

# Trend Micro Worry-Free Business Security Trial
 msiexec /x 0A07E717-BB5D-4B99-840B-6C5DED52B277 /qn /norestart | Out-Null

# WildTangent GUIDs. Thanks to /u/mnbitcoin
 msiexec /x 23170F69-40C1-2702-0938-000001000000 /qn /norestart | Out-Null
 msiexec /x EE691BD9-2B2C-6BFB-6389-ABAF5AD2A4A1 /qn /norestart | Out-Null
 msiexec /x 6E3610B2-430D-4EB0-81E3-2B57E8B9DE8D /qn /norestart | Out-Null
 msiexec /x 9E9EF3EC-22BC-445C-A883-D8DB2908698D /qn /norestart | Out-Null

# \/ "Delicious Emilys Childhood Memories Premium Edition"....wtf
 msiexec /x FC0ADA4D-8FA5-4452-8AFF-F0A0BAC97EF7 /qn /norestart | Out-Null
 msiexec /x 6F340107-F9AA-47C6-B54C-C3A19F11553F /qn /norestart | Out-Null
 msiexec /x DD7C5FC1-DCA5-487A-AF23-658B1C00243F /qn /norestart | Out-Null
 msiexec /x 0F929651-F516-4956-90F2-FFBD2CD5D30E /qn /norestart | Out-Null
 msiexec /x 89C7E0A7-4D9D-4DCC-8834-A9A2B92D7EBB /qn /norestart | Out-Null
 msiexec /x 9B56B031-A6C0-4BB7-8F61-938548C1B759 /qn /norestart | Out-Null
 msiexec /x 0C0F368E-17C4-4F28-9F1B-B1DA1D96CF7A /qn /norestart | Out-Null
 msiexec /x 36AC0D1D-9715-4F13-B6A4-86F1D35FB4DF /qn /norestart | Out-Null
 msiexec /x 03D562B5-C4E2-4846-A920-33178788BE00 /qn /norestart | Out-Null

# Windows Live Toolbar
 msiexec /x 995F1E2E-F542-4310-8E1D-9926F5A279B3 /qn /norestart | Out-Null
 
##################
##  Metro Apps  ##
##################

reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\%SAFEBOOT_OPTION%\AppXSVC" /ve /t reg_sz /d Service /f
net start AppXSVC
<# Will need to fix this, please do not use
Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online 2>&1 | Out-Null
Get-AppxPackage -AllUsers | Remove-AppxPackage 2>&1 | Out-Null #>

Dism /Online /Cleanup-Image /StartComponentCleanup /Logpath:"$LogPath\tron_dism.log"

###########################
##    STAGE 2 COMPLETE   ##
###########################
