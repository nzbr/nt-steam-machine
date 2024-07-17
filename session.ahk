#Requires AutoHotkey v2
#SingleInstance Force

SendMode("Input")
SetWorkingDir(A_ScriptDir)

; Windows to ignore when fullscreening
GroupAdd("System", "ahk_exe steamwebhelper.exe")
GroupAdd("System", "ahk_exe explorer.exe")
GroupAdd("System", "ahk_exe taskmgr.exe")
GroupAdd("System", "ahk_exe rustdesk.exe")
GroupAdd("System", "ahk_exe AutoHotkey64.exe")

Run('"C:\Program Files (x86)\Steam\Steam.exe" -steamos -gamepadui')
SteamWin := "ahk_exe steamwebhelper.exe"
WinWait(SteamWin)

SetTimer(Tick, 1000)

BPM := IsSteamFullscreen()

Tick() {
    global SteamWin
    global BPM

    if IsSteamFullscreen() {
        if !BPM {
            StartBPM()
        }
    } else {
        if BPM {
            if WinExist(SteamWin) {
                MinMax := WinGetMinMax(SteamWin)
                if (MinMax == -1) {
                    ; Steam is minimized
                    WinMaximize(SteamWin)
                } else {
                    StartDesktopMode()
                }
            } else {
                StartDesktopMode()
            }
        }
    }

    if BPM {
        ; Full-Screen any focused window (except for the ones in the "System" group)
        if WinExist("A", , "ahk_group System") {
            try {
                WinSetStyle("-0xC00000", "A", , "ahk_group System") ; Hide borders
                WinMaximize("A", , "ahk_group System") ; Maximize
            } catch {
                ; Ignore
            }
        }
    }
}

IsSteamFullscreen() {
    global SteamWin
    if !WinExist(SteamWin) {
        return false
    }

    WinGetPos(&X, &Y, &W, &H, SteamWin)
    return X == 0 && Y == 0 && W == A_ScreenWidth && H == A_ScreenHeight
}

StartBPM() {
    global BPM
    pid := WinGetPID("ahk_class Progman")
    Run('"' A_WinDir '\system32\taskkill.exe" /F /PID ' pid)
    BPM := true
}

StartDesktopMode() {
    global BPM
    Run('C:\Windows\explorer.exe')
    BPM := false
}
