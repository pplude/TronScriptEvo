# TronScript:Evolution
Welcome to TRON Script: Evolution. This is an attempt to update TRON Script to PowerShell. We are targeting Windows 8 as an initial deployment target. The core script at this time is working, but produces several errors. Please let me know what they are or open an issue so I can squash some bugs please!

I'm Using Dell PowerGUI to develop the script. This will eventually allow me to sign the script and "compile" an executable file for distribution. For best results when editing, please use the same editor. Also opens and auto-completes in PowerShell ISE for v2 or later.

# Usage:

 1. Set the Powershell execution policy to **UNRESTRICTED**
 2. Download only **Core.ps1**
 3. Run Core.ps1 in an administrative Powershell instance

# Errata
* There is no RKill, I don't have a good reposiorty for it
* Same thing with ProcessKiller, I hope to have these fixed soon!
* This is NOT reboot safe. Do not restart in the middle or you will have to stop again
* WMIC is no longer a reliable way to uninstall software. I will work on something new where I can, this may need to move to an outside utility.
* The Log is wonky, but it works, and is not as verbose as it used to be
