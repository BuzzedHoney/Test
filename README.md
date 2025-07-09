# Features

###  Everything you actually want from a Windows optimization script

* **Fully automated. No input required.**
* **Applies 20+ privacy & performance tweaks from CTT WinUtil**
* **Deletes 100+ preinstalled & store apps via Win11Debloat**
* **Removes Edge, Outlook, OneDrive and completely**
* **Auto-cleans taskbar, shortcuts, telemetry [("Data Collection")](https://en.wikipedia.org/wiki/Spyware), and useless shit (yes im talking about copilot AI)**

##  Core Features

###  Made for Everyone

Simple, fast, extremely effective. You don’t need to be a nerd to figure out how to use it. Just run it.

###  Fully Transparent

All scripts are plain-text. No binaries. No obfuscation. All fully open-sourced.

###  Doesn't Break Windows

Only disables features that are safe to remove. Core functionality and stability are untouched.

###  Microsoft-Aligned

Uses Microsoft-preferred configuration techniques:

* Group Policy Objects
* PowerShell Cmdlets
* Registry only as fallback

---

##  Full List of Tweaks and Actions

###  CTT WinUtil [(`Tweaks.json`)](https://raw.githubusercontent.com/BuzzedHoney/Test/main/Tweaks.json)

| Tweak                                 | Description                                        |
| ------------------------------------- | -------------------------------------------------- |
| WPFTweaksPowershell7Tele              | Disable Telemetry in PowerShell 7                  |
| WPFTweaksHiber                        | Disable Hibernation                                |
| WPFTweaksDisableExplorerAutoDiscovery | Disable network folder auto-discovery in Explorer  |
| WPFTweaksTele                         | Disable general system telemetry                   |
| WPFTweaksRecallOff                    | Turn off Windows Recall feature                    |
| WPFTweaksDisableBGapps                | Stop background apps from running                  |
| WPFTweaksWifi                         | Disable Wi-Fi auto-connect & known network sharing |
| WPFTweaksDisplay                      | Disable Display content telemetry                  |
| WPFTweaksDVR                          | Disable Xbox Game DVR and background recording     |
| WPFTweaksDisableWpbtExecution         | Disable WPBT execution on boot                     |
| WPFTweaksDeleteTempFiles              | Clean up system temp files                         |
| WPFTweaksDisableLMS1                  | Disable Intel LMS Service                          |
| WPFTweaksConsumerFeatures             | Disable Microsoft consumer experience/promotions   |
| WPFTweaksHome                         | Apply core tweaks tailored for Home edition        |
| WPFTweaksRemoveCopilot                | Remove Copilot completely                          |
| WPFTweaksLoc                          | Disable location tracking                          |
| WPFTweaksAH                           | Adjust animation & accessibility for performance   |
| WPFTweaksServices                     | Disable redundant telemetry-related services       |
| WPFTweaksDisableFSO                   | Disable Feedback & Suggestions Online services     |

---

###  Win11Debloat

Removes **over 100+ preinstalled apps**, including:

* Microsoft built-ins like: Clipchamp, Feedback Hub, Sticky Notes, Maps, Weather, Cortana, Copilot, OneNote, Skype
* Web-junk like: Bing News, Bing Travel, Bing Weather, Bing Finance, Bing Translator
* 3rd-party preinstalls like: TikTok, Netflix, Hulu, Instagram, Facebook, Candy Crush, Duolingo, Prime Video, SpeedTest, Viber, Shazam

Each entry is stripped from the system using clean PowerShell logic that targets both user-installed and provisioned packages.

**Runs the following privacy and UX improvements:**

* `-RemoveAppsCustom` — Removes all custom apps defined in the [list](https://raw.githubusercontent.com/BuzzedHoney/Test/main/CustomAppsList)
* `-DisableTelemetry` — Removes Microsoft spyware
* `-DisableSettings365Ads` — Removes 365 ads from the Settings app
* `-DisableSuggestions` — Disables [suggestions](https://en.wikipedia.org/wiki/Software_bloat) in Start menu and Settings
* `-DisableLockscreenTips` — Turns off lockscreen tips
* `-DisableDesktopSpotlight` — Removes rotating backgrounds and ads on desktop
* `-DisableWidgets` — Disables Windows Widgets completely
* `-DisableFastStartup` — Fast startup doesn't allow your computer to fully turn off after clicking shutdown
* `-DisableStickyKeys` — Disables sticky keys popups
* `-DisableCopilot` — Completely removes Windows Copilot
* `-DisableMouseAcceleration` — Improves gaming and pointer precision
* `-DisableRecall` — Prevents Windows from capturing screen history
* `-DisableBing` — Removes Bing from Start menu search

---

###  Edge, Outlook, and OneDrive Destroyer

The **Edge\&OORemover.ps1** script is the most aggressive, complete removal method for Microsoft bloatware.

####  Edge

* Force-uninstalls Edge using setup.exe with `--force-uninstall`
* Kills EdgeUpdate and EdgeCore
* Deletes services, folders, registry keys, and all shortcuts
* Rebuilds folder structure and applies **deny ACLs** so Microsoft can't reinstall it

####  Outlook

* Terminates all Outlook processes
* Removes UWP & desktop versions
* Deletes app data, registry keys, and start menu/desktop shortcuts
* Erases any trace of Outlook from WindowsApps

####   OneDrive

* Terminates all OneDrive instances
* Uninstalls via `OneDriveSetup.exe`
* Deletes OneDrive folders, start menu shortcuts, and registry keys
* Cleans leftover cloud sync links

It’s a [killshot](https://www.youtube.com/watch?v=FxQTY-W6GIo) for Microsoft’s most persistent shitware.

---

##  Summary

This isn’t a tech showcase. It’s a **no-bullshit debloater that works**:

* Simple for beginners
* Brutal to Microsoft bloat

If you want a clean, fast, private Windows install — this is all you need.
