####################
##  WINDOW SETUP  ##
####################
Clear-Host
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage : De-Bloat"

##################
##  LOG HEADER  ##
##################

Write-Host "----------------------------"
Write-Host "      STAGE 2: DE-BLOAT     "
Write-Host "----------------------------"

	
####################
##  Apps By GUID  ##
####################
Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing Apps by GUID" -PercentComplete 25
# Start-Process .\AppsGUID.bat | Out-Null
# Start-Process .\Toolbars.bat | Out-Null
# Get-Content .\AppsByName.txt | ForEach-Object { WMIC.EXE product where "name like $_" uninstall /nointeractive }
 
##################
##  Metro Apps  ##
##################

If ($PreserveXAML.IsPresent)
	{
		Write-Host "XAML Apps will not be removed...Moving on"
	}
Else
	{
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing XAML Apps" -PercentComplete 28
		# Script to remove a lot of the pre-loaded 3rd-party Metro "modern app" bloatware
		# Initial creation by /u/kronflux
		# Modified for use with the Tron project by /u/vocatus on reddit.com/r/TronScript
		$ErrorActionPreference = "SilentlyContinue"

		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*06DAC6F6.StumbleUpon*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*134D4F5B.Box*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*26720RandomSaladGamesLLC.HeartsDeluxe*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*26720RandomSaladGamesLLC.SimpleSolitaire*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*4AE8B7C2.Booking.comPartnerEdition*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7906AAC0.TOSHIBACanadaPartners*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7906AAC0.ToshibaCanadaWarrantyService*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*7digitalLtd.7digitalMusicStore*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*9E2F88E3.Twitter*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*A34E4AAB.YogaChef*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AccuWeather.AccuWeatherforWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AcerIncorporated.AcerExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AcerIncorporated.GatewayExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AD2F1837.HP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AdobeSystemsIncorporated.AdobeRevel*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Amazon.com.Amazon*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*AppUp.IntelAppUpCatalogueAppWorldwideEdition*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ASUSCloudCorporation.MobileFileExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*B9ECED6F.ASUSGIFTBOX*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ChaChaSearch.ChaChaPushNotification*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ClearChannelRadioDigital.iHeartRadio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.ac.AcerCrystalEye*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.ac.SocialJogger*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.hs.YouCamforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*CyberLinkCorp.id.PowerDVDforLenovoIdea*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*DailymotionSA.Dailymotion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*DellInc.DellShop*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E046963F.LenovoCompanion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E046963F.LenovoSupport*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.CameraMan*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.DeviceCollaboration*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.LenovoRecommends*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaCameraMan*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaPhoneCompanion*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*E0469640.YogaPicks*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*eBayInc.eBay*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*EncyclopaediaBritannica.EncyclopaediaBritannica*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*esobiIncorporated.newsXpressoMetro*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Evernote.Evernote*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Evernote.Skitch*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*F5080380.ASUSPhotoDirector*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*F5080380.ASUSPowerDirector*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FilmOnLiveTVFree.FilmOnLiveTVFree*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsASUS.FingertappsInstrumentsrecommendedb*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsasus.FingertappsOrganizerrecommendedbyA*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*fingertappsASUS.JigsWarrecommendedbyASUS*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FingertappsInstruments*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FingertappsOrganizer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Flipboard.Flipboard*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*FreshPaint*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GameGeneticsApps.FreeOnlineGamesforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GAMELOFTSA.SharkDash*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*GettingStartedwithWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPConnectedMusic*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPConnectedPhotopoweredbySnapfish*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*HPRegistration*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*JigsWar*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*KindleforWindows8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MAGIX.MusicMakerJam*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*McAfee*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*McAfeeInc.05.McAfeeSecurityAdvisorforASUS*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MobileFileExplorer*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*MusicMakerJam*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*NAVER.LINEwin8*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Netflix*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*PinballFx2*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*PublicationsInternational.iCookbookSE*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*RandomSaladGamesLLC.GinRummyProforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*sMedioforHP.sMedio360*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*sMedioforToshiba.TOSHIBAMediaPlayerbysMedioTrueLin*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*SymantecCorporation.NortonStudio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TelegraphMediaGroupLtd.TheTelegraphforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*toolbar*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TheNewYorkTimes.NYTCrossword*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TripAdvisorLLC.TripAdvisorHotelsFlightsRestaurants*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*TuneIn.TuneInRadio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*UptoElevenDigitalSolution.mysms-Textanywhere*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Weather.TheWeatherChannelforHP*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*Weather.TheWeatherChannelforLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*WildTangentGames*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*YouSendIt.HighTailForLenovo*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*ZinioLLC.Zinio*"}).PackageFullName
		remove-appxpackage $(Get-AppxPackage | where {$_.name -like "*zuukaInc.iStoryTimeLibrary*"}).PackageFullName

		# Active identifiers
		$PackagesToRemove = (
			'Microsoft.3DBuilder',                    # '3DBuilder' app
			'Microsoft.BingFinance',                  # 'Money' app - Financial news
			'Microsoft.BingNews',                     # Generic news app
			'Microsoft.BingSports',                   # 'Sports' app - Sports news
			'Microsoft.BingTranslator',               # 'Translator' app - Bing Translate
			'Microsoft.BingWeather',                  # 'Weather' app
			'Microsoft.CommsPhone',                   # 'Phone' app
			'Microsoft.ConnectivityStore',
			'Windows.ContactSupport',
			'Microsoft.FreshPaint',                   # Canvas painting app
			'Microsoft.Getstarted',                   # 'Get Started' link
			'MicrosoftMahjong',                       # 'Mahjong' game
			'Microsoft.MicrosoftJigsaw',
			'Microsoft.Messaging',                    # 'Messaging' app
			'Microsoft.MicrosoftJackpot',             # 'Jackpot' app
			'Microsoft.MicrosoftOfficeHub',
			'Microsoft.MicrosoftSolitaireCollection', # Solitaire collection
			'Microsoft.Taptiles',                     # imported from stage_2_de-bloat.bat
			'Microsoft.Office.OneNote',               # Onenote app
			'Microsoft.Office.Sway',                  # 'Sway' app
			'Microsoft.People',                       # 'People' app
			'Microsoft.SkypeApp',                     # 'Get Skype' link
			'Microsoft.SkypeWiFi',
			'Microsoft.Studios.Wordament',            # imported from stage_2_de-bloat.bat
			'Microsoft.MicrosoftSudoku',
			'Microsoft.WindowsAlarms',                # 'Alarms and Clock' app
			'microsoft.windowscommunicationsapps',    # 'Calendar and Mail' app
			'Microsoft.Windows.CloudExperienceHost',  # 'Cloud Experience' sigh
			'Microsoft.WindowsFeedback',              # 'Feedback' functionality
			'Microsoft.MovieMoments',                 # imported from stage_2_de-bloat.bat
			'Microsoft.XboxApp',                      # Xbox junk, unfortunately 'Microsoft.XboxGameCallableUI' and 'Microsoft.XboxIdentityProvider' can't be removed
			'Microsoft.ZuneMusic',                    # 'Groove Music' app
			'Microsoft.ZuneVideo',                    # Groove Music
			'king.com.CandyCrushSodaSaga',            # Candy Crush app
			'9E2F88E3.Twitter'                        # Twitter app
		)
	
		# Do the removal
        Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Removing built-in apps" -PercentComplete 30
		Get-AppxProvisionedPackage -Online | Where-Object Name -In $PackagesToRemove | Remove-AppxProvisionedPackage -Online | Out-Null
		Get-AppxPackage –AllUsers | Where-Object Name -In $PackagesToRemove | Remove-AppxPackage | Out-Null

	}

Write-ProgressBar -ProgressBar $TronProgress -Activity "Stage 2: De-Bloat" -CurrentOperation "Running DISM Cleanup" -PercentComplete 34
Dism /Online /Cleanup-Image /StartComponentCleanup /Logpath:"$LogPath\tron_dism.log"