#Requires -RunAsAdministrator

# ==============================================================
# DEFUSAL OS SETUP & BRANDING - VERSION 1.3
# ==============================================================

Add-Type -AssemblyName System.Windows.Forms
$title = "DefusalOS Setup"

# ------------------------------- 
# CONFIGURATION
# ------------------------------- 
$config = @{
    # Branding
    SetDefusalBranding      = $true
    ApplyDefusalWallpaper   = $true
    WallpaperUrl            = "https://github.com/Partvision/Defusal-Toolbox/blob/main/Defusal%20(2).png?raw=true"
    
    # Software & Tools
    InstallUlauncher        = $true
    InstallChrome           = $true
    InstallGit              = $true
    InstallPython           = $true
    RemoveEdge              = $true
    
    # UI & Performance
    Windows10ContextMenu    = $true
    DarkMode                = $true
    DisableTelemetry        = $true
    DisableWebSearch        = $true
    EnableLongPaths         = $true
}

# ------------------------------- 
# HELPER FUNCTIONS
# ------------------------------- 
function Write-Status {
    param([string]$Msg, [string]$Type = "Cyan")
    $color = switch($Type) { "Success" {"Green"} "Warning" {"Yellow"} "Error" {"Red"} Default {"Cyan"} }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Msg" -ForegroundColor $color
}

# ------------------------------- 
# TWEAK LIBRARY
# ------------------------------- 
$TweakLibrary = @{

    SetDefusalBranding = {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        Set-ItemProperty -Path $path -Name "RegisteredOwner" -Value "Partvision"
        Set-ItemProperty -Path $path -Name "RegisteredOrganization" -Value "DefusalOS v1.0"
        
        $oemPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation"
        if (-not (Test-Path $oemPath)) { New-Item $oemPath -Force | Out-Null }
        Set-ItemProperty -Path $oemPath -Name "Manufacturer" -Value "Partvision"
        Set-ItemProperty -Path $oemPath -Name "Model" -Value "DefusalOS Optimized"
    }

    ApplyDefusalWallpaper = {
        $wpPath = "$env:USERPROFILE\DefusalWallpaper.png"
        try {
            Invoke-WebRequest -Uri $config.WallpaperUrl -OutFile $wpPath -TimeoutSec 15
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10"
            
            $code = @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
            Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
            [Wallpaper]::SystemParametersInfo(0x0014, 0, $wpPath, 0x01 -bor 0x02) | Out-Null
        } catch { Write-Status "Wallpaper download failed." "Error" }
    }

    # --- Edge Removal Logic ---
    RemoveEdge = {
        Write-Status "Removing Microsoft Edge..."
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe"
        $setupFile = Get-Item $edgePath -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($setupFile) {
            Start-Process -FilePath $setupFile.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
            Write-Status "Edge uninstaller triggered." "Success"
        } else {
            Write-Status "Edge installer not found (it might already be removed)." "Warning"
        }
    }
}

# ------------------------------- 
# EXECUTION
# ------------------------------- 

# 1. Run Registry & System Tweaks
foreach ($tweak in $TweakLibrary.Keys) {
    if ($config[$tweak]) {
        Write-Status "Applying: $tweak"
        try { & $TweakLibrary[$tweak] } catch { Write-Status "Failed $tweak" "Error" }
    }
}

# 2. Automated Installations
if ($config.InstallGit) {
    Write-Status "Installing Git..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
}

if ($config.InstallUlauncher) {
    Write-Status "Installing Ulauncher via Winget..."
    winget install --id Ulauncher.Ulauncher --accept-package-agreements --silent
}

if ($config.InstallChrome) {
    Write-Status "Installing Google Chrome..."
    $chromeUrl = "https://github.com/Partvision/Apps1/blob/main/ChromeSetup.exe?raw=true"
    $chromePath = "$env:TEMP\ChromeSetup.exe"
    try {
        Invoke-WebRequest -Uri $chromeUrl -OutFile $chromePath
        Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait
        Remove-Item $chromePath -Force
    } catch { Write-Status "Chrome install failed." "Error" }
}

if ($config.InstallPython) {
    Write-Status "Installing Python 3.14.2..."
    $pyUrl = "https://www.python.org/ftp/python/3.14.2/python-3.14.2-amd64.exe"
    $pyPath = "$env:TEMP\python-3.14.2.exe"
    try {
        Invoke-WebRequest -Uri $pyUrl -OutFile $pyPath
        # /quiet installs it silently; PrependPath adds it to system variables
        Start-Process -FilePath $pyPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item $pyPath -Force
        Write-Status "Python installed." "Success"
    } catch { Write-Status "Python install failed." "Error" }
}

# 3. Finalize UI
Write-Status "Restarting Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "`nDefusalOS v1.3 Setup Complete!" -ForegroundColor Green