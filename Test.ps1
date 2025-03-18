$shell = New-Object -ComObject Shell.Application
$shell.MinimizeAll()

$directoryPath = "$env:LOCALAPPDATA\Temp\Win11Debloat\Win11Debloat-master"
New-Item -ItemType Directory -Force -Path $directoryPath | Out-Null

Set-Content -Path "$directoryPath\CustomAppsList" -Value "
Microsoft.Edge
Microsoft.Copilot
Microsoft.549981C3F5F10
Microsoft.BingFinance
Microsoft.BingFoodAndDrink
Microsoft.BingHealthAndFitness
Microsoft.BingNews
Microsoft.BingSearch
Microsoft.BingSports
Microsoft.BingTranslator
Microsoft.BingTravel
Microsoft.BingWeather
Microsoft.GetHelp
Microsoft.Getstarted
Microsoft.Messaging
Microsoft.Microsoft3DViewer
Microsoft.MicrosoftJournal
Microsoft.MicrosoftOfficeHub
Microsoft.MicrosoftPowerBIForWindows
Microsoft.MicrosoftSolitaireCollection
Microsoft.MicrosoftStickyNotes
Microsoft.MixedReality.Portal
Microsoft.MSPaint
Microsoft.NetworkSpeedTest
Microsoft.3DBuilder
Microsoft.News
Microsoft.Get
Microsoft.Office.OneNote
Microsoft.Office.Sway
Microsoft.OneConnect
Microsoft.OneDrive
Microsoft.OutlookForWindows
Microsoft.Paint
Microsoft.People
Microsoft.PowerAutomateDesktop
Microsoft.Print3D
Microsoft.RemoteDesktop
Microsoft.ScreenSketch
Microsoft.SkypeApp
Microsoft.Todos
Microsoft.Whiteboard
Microsoft.Windows.DevHome
Microsoft.WindowsAlarms
Microsoft.windowscommunicationsapps
Microsoft.WindowsFeedbackHub
Microsoft.WindowsMaps
Microsoft.WindowsNotepad
Microsoft.WindowsSoundRecorder
Microsoft.XboxApp
MicrosoftWindows.CrossDevice
Microsoft.YourPhone
MicrosoftCorporationII.MicrosoftFamily
MicrosoftCorporationII.QuickAssist
MicrosoftWindows.Client.WebExperience
MicrosoftTeams
MSTeams
Netflix
NYTCrossword
OneCalendar
PandoraMediaInc
PhototasticCollage
PicsArt-PhotoStudio
Plex
PolarrPhotoEditorAcademicEdition
Royal Revolt
Shazam
Sidia.LiveWallpaper
SlingTV
Spotify
TikTok
TuneInRadio
Twitter
Viber
WinZipUniversal
Wunderlist
XING
ACGMediaPlayer
ActiproSoftwareLLC
AdobeSystemsIncorporated.AdobePhotoshopExpress
Amazon.com.Amazon
AmazonVideo.PrimeVideo
Asphalt8Airborne
AutodeskSketchBook
CaesarsSlotsFreeCasino
Clipchamp.Clipchamp
COOKINGFEVER
CyberLinkMediaSuiteEssentials
Disney
DisneyMagicKingdoms
DrawboardPDF
Duolingo-LearnLanguagesforFree
EclipseManager
Facebook
FarmVille2CountryEscape
fitbit
Flipboard
HiddenCity
HULULLC.HULUPLUS
iHeartRadio
Instagram
king.com.BubbleWitch3Saga
king.com.CandyCrushSaga
king.com.CandyCrushSodaSaga
LinkedInforWindows
MarchofEmpires"

Start-Process powershell -ArgumentList "-WindowStyle Minimized -Command & ([scriptblock]::Create((Invoke-RestMethod 'https://debloat.raphi.re/'))) -Silent -RemoveAppsCustom -DisableTelemetry -DisableSuggestions -DisableLockscreenTips -DisableWidgets -DisableStartRecommended -ShowHiddenFolders -ShowKnownFileExt -HideSearchTb"

iex "& { $(irm christitus.com/win) } -Config https://raw.githubusercontent.com/bluethedoor/Test/refs/heads/main/Tweaks.json -Run"
