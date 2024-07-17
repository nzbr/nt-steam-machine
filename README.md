# NT Steam Machine

These are scripts to convert a Windows (11) install into something SteamOS Like for use as an HTPC.

This has only been tested on a 11th gen Intel Framework Mainboard

## Installation

1. Install Windows 11
    - I used [Tiny11](https://github.com/ntdevlabs/tiny11builder)
    - Make sure to create a local user without a password
        - If not using Tiny 11, press Shift+F10 during initial setup after the installation and run `oobe\bypassnro` to skip linking a MS account
2. Make sure App Installer is updated to the latest version using the Microsoft Store
3. Download this repo somewhere on the target computer (make sure to include the submodule to get the Bazzite Wallpaper)
    - If you're using Tiny 11, you can use `winget` to install a Browser (`Mozilla.Firefox`) or Git (`Git.Git`)
4. Run `Set-ExecutionPolicy -Scope Process Bypass; .\setup.ps1` in an Admin PowerShell
5. Reboot

If everything went well, after rebooting you should be greeted by a Steam login screen

Steam does not show the Desktop Mode button on Windows. A regular Windows Explorer session will be started if you exit Big Picture Mode. Just enter Big Picture Mode again from Steam to get back (explorer will be killed automatically)
