#Requires -RunAsAdministrator
Set-Location -Path $PSScriptRoot


### Setup Steam ###
Write-Host "Searching for Steam..."
$steam = "C:\Program Files (x86)\Steam\steam.exe"
if (Test-Path $steam) {
    Write-Host "Steam found at $steam`n"
}
else {
    Write-Host "Installing Steam..."
    winget install --disable-interactivity --no-upgrade -e `
        Valve.Steam
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install Steam"
        exit 1
    }
}


### Setup AHK ###
Write-Host "Searching for AutoHotkey..."
while ($null -eq $ahk) {
    $ahkCandidates = @(
        "C:\Users\nzbr\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe"
        "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
        "C:\Program Files\AutoHotkey\AutoHotkey64.exe"
    )
    foreach ($candidate in $ahkCandidates) {
        if (Test-Path $candidate) {
            $ahk = $candidate
            break
        }
    }

    if (($null -ne $ahk) -and (Test-Path $ahk)) {
        Write-Host "AutoHotkey found at $ahk`n"
    }
    else {
        Write-Host "Installing AutoHotkey..."
        winget install --disable-interactivity --no-upgrade -e `
            AutoHotkey.AutoHotkey
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install AutoHotkey"
            exit 1
        }
    }
}


### Set the theme ###
Write-Host "Setting up Theme..."
$wallpaperPath = Join-Path -Path $env:USERPROFILE -ChildPath "Pictures\wallpaper.png"
Copy-Item `
    -Path ".\thirdparty\bazzite\system_files\desktop\kinoite\usr\share\wallpapers\ublue.png" `
    -Destination $wallpaperPath `
    -Force

Set-ItemProperty `
    -Path "HKCU:\Control Panel\Desktop" `
    -Name "WallPaper" `
    -Value $wallpaperPath

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "SystemUsesLightTheme" `
    -Value 0

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "AppsUseLightTheme" `
    -Value 0


### Set up lockscreen ###
Write-Host "Setting up Lock Screen..."
Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
    -Name "LockScreenImage" `
    -Value $wallpaperPath

New-Item `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" `
    -Name "PersonalizationCSP" `
    -Force | Out-Null

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" `
    -Name "LockScreenImageStatus" `
    -Value 1

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" `
    -Name "LockScreenImagePath" `
    -Value $wallpaperPath

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" `
    -Name "LockScreenImageUrl" `
    -Value $wallpaperPath

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
    -Name "NoChangingLockScreen" `
    -Value 1

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DisableAcrylicBackgroundOnLogon" `
    -Value 1

# Prevent lock screen after sleep
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0

Set-ItemProperty `
    -Path "HKCU:\Control Panel\Desktop" `
    -Name "DelayLockInterval" `
    -Value 0


### Set up session ###
Write-Host "Setting up Session..."
Copy-Item `
    -Path "session.ahk" `
    -Destination $env:USERPROFILE `
    -Force

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "Shell" `
    -Value "`"$ahk`" `"$env:USERPROFILE\session.ahk`""


### Set up power plan ###
Write-Host "Setting up Power Plan..."
function ChangePowerPlan($setting, $value) {
    powercfg /CHANGE "${setting}-ac" $value
    powercfg /CHANGE "${setting}-dc" $value
}
ChangePowerPlan "monitor-timeout" 10
ChangePowerPlan "standby-timeout" 10
ChangePowerPlan "hibernate-timeout" 30

### Disable Welcome Experience ###
# Gets rid of the "Let's finish setting up your device" screen
# https://winaero.com/disable-lets-finish-setting-up-your-device-screen-in-windows-11/
Write-Host "Disabling Welcome Experience..."
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-310093Enabled" `
    -Value 0

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338389Enabled" `
    -Value 0

Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" `
    -Name "ScoobeSystemSettingEnabled" `
    -Value 0


Write-Host "`nInstallation complete, please reboot"
