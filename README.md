# DefusalOS Setup & Optimization

This script transforms a standard Windows installation into **DefusalOS**, a debloated and optimized environment for performance and privacy.

## Quick Start
To run the setup, open **PowerShell as Administrator** and paste the following command:
PowerShell -ExecutionPolicy Bypass -File "PATH-TO-YOUR-SETUP.ps1

What's Included?
Branding & UI
Winver Branding: Sets "Partvision" and "DefusalOS v1.0" in the About Windows dialog.
Wallpaper: Applies the official DefusalOS background (Auto-Fill for all resolutions).
Context Menu: Restores the classic Windows 10 right-click menu.
Dark Mode: Enables system-wide Dark Theme and adds "End Task" to the taskbar.

System Optimization
Edge Removal: Forcefully uninstalls Microsoft Edge from the system.
Telemetry: Disables Windows tracking, data collection, and Bing web search.
Performance: Enables Win32 Long Paths and optimizes background services.

🖥️ Software Suite
Chocolatey: Installed as the primary package manager.
Flow Launcher: The modern productivity launcher (Alt + Space).
Google Chrome: Clean, automated installation via Partvision repository.
Git: Latest version for version control.
Python 3.14.2: Pre-configured with System PATH variables.

⚠️ Important Notes
Explorer Restart: Your screen will flicker and the taskbar will disappear briefly at the end of the script; this is normal as registry changes are being applied.
Internet Required: The script must have an active connection to download the wallpaper and software packages.
BETA: This is a BETA release. It is recommended to run this on a fresh installation or a virtual machine (vboxuser).
Developed by Partvision
