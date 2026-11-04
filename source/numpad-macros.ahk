#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ================================================================
;  넘패드 매크로
;    NumLock 꺼짐 -> 넘패드가 매크로 버튼
;    NumLock 켜짐 -> 평소처럼 숫자 입력
;
;  같은 키라도 Shift / Ctrl / Alt / Shift+Ctrl 을 누르면 다른 매크로가 나갑니다.
;  매크로는 numpad-macros.txt, 편집기는 NumpadMacroEditor.exe 입니다.
;
;  "프로그램 실행" 매크로는 그 프로그램이 이미 실행 중이면
;  새로 띄우지 않고 기존 창을 맨 앞으로 가져옵니다.
; ================================================================

CONFIG := A_ScriptDir . Chr(92) . "numpad-macros.txt"
DEBUGFLAG := A_ScriptDir . Chr(92) . "debug.on"
DEBUGLOG := A_ScriptDir . Chr(92) . "debug.log"

MACRO := Map()
STAMP := ""
lastNumLock := GetKeyState("NumLock", "T")

EnsureConfig()
LoadConfig()
SetTimer(WatchConfig, 1200)
SetTimer(WatchNumLock, 400)
UpdateTray()

try {
    if (FileExist(DEBUGLOG) && FileGetSize(DEBUGLOG) > 300000)
        FileDelete DEBUGLOG
}

TrayTip("넘패드 매크로 실행 중", "NumLock OFF = 매크로 / ON = 숫자")
A_TrayMenu.Add()
A_TrayMenu.Add("매크로 편집...", (*) => OpenEditor())
A_TrayMenu.Add("진단 로그 켜기/끄기", (*) => ToggleDebug())
A_TrayMenu.Add("설정 다시 읽기", (*) => Reload())
A_TrayMenu.Add()
A_TrayMenu.Add("종료", (*) => ExitApp())

; NumLock 이 꺼져 있고 편집기 창이 앞에 있지 않을 때만 동작합니다.
#HotIf !GetKeyState("NumLock", "T") && !WinActive("ahk_exe NumpadMacroEditor.exe")
NumpadHome::Dispatch("7", "NumpadHome")
+NumpadHome::Dispatch("7+S", "NumpadHome")
^NumpadHome::Dispatch("7+C", "NumpadHome")
!NumpadHome::Dispatch("7+A", "NumpadHome")
^+NumpadHome::Dispatch("7+SC", "NumpadHome")
NumpadUp::Dispatch("8", "NumpadUp")
+NumpadUp::Dispatch("8+S", "NumpadUp")
^NumpadUp::Dispatch("8+C", "NumpadUp")
!NumpadUp::Dispatch("8+A", "NumpadUp")
^+NumpadUp::Dispatch("8+SC", "NumpadUp")
NumpadPgUp::Dispatch("9", "NumpadPgUp")
+NumpadPgUp::Dispatch("9+S", "NumpadPgUp")
^NumpadPgUp::Dispatch("9+C", "NumpadPgUp")
!NumpadPgUp::Dispatch("9+A", "NumpadPgUp")
^+NumpadPgUp::Dispatch("9+SC", "NumpadPgUp")
NumpadLeft::Dispatch("4", "NumpadLeft")
+NumpadLeft::Dispatch("4+S", "NumpadLeft")
^NumpadLeft::Dispatch("4+C", "NumpadLeft")
!NumpadLeft::Dispatch("4+A", "NumpadLeft")
^+NumpadLeft::Dispatch("4+SC", "NumpadLeft")
NumpadClear::Dispatch("5", "NumpadClear")
+NumpadClear::Dispatch("5+S", "NumpadClear")
^NumpadClear::Dispatch("5+C", "NumpadClear")
!NumpadClear::Dispatch("5+A", "NumpadClear")
^+NumpadClear::Dispatch("5+SC", "NumpadClear")
NumpadRight::Dispatch("6", "NumpadRight")
+NumpadRight::Dispatch("6+S", "NumpadRight")
^NumpadRight::Dispatch("6+C", "NumpadRight")
!NumpadRight::Dispatch("6+A", "NumpadRight")
^+NumpadRight::Dispatch("6+SC", "NumpadRight")
NumpadEnd::Dispatch("1", "NumpadEnd")
+NumpadEnd::Dispatch("1+S", "NumpadEnd")
^NumpadEnd::Dispatch("1+C", "NumpadEnd")
!NumpadEnd::Dispatch("1+A", "NumpadEnd")
^+NumpadEnd::Dispatch("1+SC", "NumpadEnd")
NumpadDown::Dispatch("2", "NumpadDown")
+NumpadDown::Dispatch("2+S", "NumpadDown")
^NumpadDown::Dispatch("2+C", "NumpadDown")
!NumpadDown::Dispatch("2+A", "NumpadDown")
^+NumpadDown::Dispatch("2+SC", "NumpadDown")
NumpadPgDn::Dispatch("3", "NumpadPgDn")
+NumpadPgDn::Dispatch("3+S", "NumpadPgDn")
^NumpadPgDn::Dispatch("3+C", "NumpadPgDn")
!NumpadPgDn::Dispatch("3+A", "NumpadPgDn")
^+NumpadPgDn::Dispatch("3+SC", "NumpadPgDn")
NumpadIns::Dispatch("0", "NumpadIns")
+NumpadIns::Dispatch("0+S", "NumpadIns")
^NumpadIns::Dispatch("0+C", "NumpadIns")
!NumpadIns::Dispatch("0+A", "NumpadIns")
^+NumpadIns::Dispatch("0+SC", "NumpadIns")
NumpadDel::Dispatch(".", "NumpadDel")
+NumpadDel::Dispatch(".+S", "NumpadDel")
^NumpadDel::Dispatch(".+C", "NumpadDel")
!NumpadDel::Dispatch(".+A", "NumpadDel")
^+NumpadDel::Dispatch(".+SC", "NumpadDel")
#HotIf

Dispatch(full, nav) {
    global MACRO
    if !MACRO.Has(full) {
        Log("nomap", full . " -> " . nav)
        Send("{Blind}" . nav)
        return
    }
    m := MACRO[full]
    try {
        if (m.type = "app") {
            LaunchOrActivate(m.value, full)
        } else if (m.type = "send" && LooksLikeProgram(m.value)) {
            LaunchOrActivate(m.value, full)
        } else if (m.type = "url") {
            Run m.value
            Log("url", full . " = " . m.value)
        } else if (m.type = "send") {
            Send m.value
            Log("send", full . " = " . m.value)
        } else if (m.type = "text") {
            SendText m.value
            Log("text", full . " = " . m.value)
        } else {
            Log("unknown-type", full . " type=" . m.type)
        }
    } catch as e {
        Log("ERROR", full . " = " . m.value . " :: " . e.Message)
        TrayTip("실행하지 못했습니다: " . e.Message, "넘패드 매크로", 2)
        ShowTip("매크로 실패: " . e.Message, 3000)
    }
}

; 이미 실행 중이면 그 창을 앞으로 가져오고, 없으면 새로 실행합니다.
LaunchOrActivate(target, full) {
    if ActivateRunning(target, full)
        return
    Run target
    Log("run", full . " = " . target)
}

ActivateRunning(target, full) {
    SplitPath target, , , &ext, &name
    if (ext != "exe")
        return false
    exe := name . ".exe"
    if !ProcessExist(exe)
        return false

    found := false
    for id in WinGetList("ahk_exe " . exe) {
        cls := WinGetClass("ahk_id " . id)
        if (cls = "Shell_TrayWnd" || cls = "Shell_SecondaryTrayWnd" || cls = "Progman" || cls = "WorkerW")
            continue
        if (WinGetTitle("ahk_id " . id) = "")
            continue
        found := true
        try {
            if (WinGetMinMax("ahk_id " . id) = -1)
                WinRestore("ahk_id " . id)
            WinActivate("ahk_id " . id)
        }
        if WinActive("ahk_id " . id) {
            Log("activate", full . " = " . exe)
            return true
        }
    }

    if (found) {
        ; 창은 있는데 앞으로 못 올림 (관리자 권한 등)
        Log("activate-failed", full . " = " . exe)
        ShowTip(exe . " 창을 앞으로 가져오지 못했습니다 (권한)", 2000)
    } else {
        ; 실행 중이지만 창이 없음 (트레이 상주 등)
        Log("running-no-window", full . " = " . exe)
        ShowTip(exe . " 는 이미 실행 중입니다 (창 없음)", 1800)
    }
    return true
}

LooksLikeProgram(v) {
    if !FileExist(v)
        return false
    SplitPath v, , , &ext
    return (ext = "exe" || ext = "bat" || ext = "cmd" || ext = "lnk")
}

; ---------- 진단 로그 ----------

IsDebug() {
    global DEBUGFLAG
    return FileExist(DEBUGFLAG) ? true : false
}

Log(tag, detail) {
    global DEBUGLOG
    if !IsDebug()
        return
    fg := ""
    try fg := WinGetProcessName("A") . " | " . WinGetTitle("A")
    line := FormatTime(A_Now, "MM-dd HH:mm:ss") . " | " . tag . " | " . detail
        . " | nl=" . GetKeyState("NumLock", "T") . " | fg=" . fg
    try FileAppend(line . Chr(10), DEBUGLOG, "UTF-8")
}

ToggleDebug() {
    global DEBUGFLAG
    if FileExist(DEBUGFLAG) {
        try FileDelete DEBUGFLAG
        ShowTip("진단 로그 꺼짐", 1500)
    } else {
        FileAppend("", DEBUGFLAG, "UTF-8")
        ShowTip("진단 로그 켜짐 (debug.log)", 2000)
        Log("info", "diagnostic logging started")
    }
}

; ---------- 상태 표시 ----------

WatchNumLock() {
    global lastNumLock
    st := GetKeyState("NumLock", "T")
    if (st = lastNumLock)
        return
    lastNumLock := st
    UpdateTray()
    if (st = 0)
        ShowTip("넘패드: 매크로 모드", 1600)
    else
        ShowTip("넘패드: 숫자 입력 모드 (매크로 꺼짐)", 1600)
}

UpdateTray() {
    on := !GetKeyState("NumLock", "T")
    A_IconTip := on ? "넘패드 매크로 - 사용 중 (NumLock 꺼짐)" : "넘패드 매크로 - 대기 (NumLock 켜짐)"
}

ShowTip(text, ms := 1500) {
    ToolTip(text, A_ScreenWidth // 2 - 220, 60)
    SetTimer(HideTip, -ms)
}

HideTip() {
    ToolTip()
}

; ---------- 설정 ----------

LoadConfig() {
    global CONFIG, MACRO, STAMP
    MACRO := Map()
    if !FileExist(CONFIG) {
        STAMP := ""
        return
    }
    text := FileRead(CONFIG, "UTF-8")
    for line in StrSplit(text, Chr(10), Chr(13)) {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        eq := InStr(line, "=")
        if !eq
            continue
        key := Trim(SubStr(line, 1, eq - 1))
        rest := SubStr(line, eq + 1)
        bar := InStr(rest, "|")
        if !bar
            continue
        MACRO[key] := { type: SubStr(rest, 1, bar - 1), value: SubStr(rest, bar + 1) }
    }
    STAMP := CurStamp()
}

WatchConfig() {
    global CONFIG, STAMP
    if !FileExist(CONFIG)
        return
    if (CurStamp() != STAMP) {
        LoadConfig()
        TrayTip("매크로 설정을 새로 읽었습니다", "넘패드 매크로", 1)
    }
}

CurStamp() {
    global CONFIG
    return FileGetTime(CONFIG, "M") . FileGetSize(CONFIG)
}

OpenEditor() {
    q := Chr(34)
    editorExe := A_ScriptDir . Chr(92) . "NumpadMacroEditor.exe"
    if FileExist(editorExe) {
        Run(q . editorExe . q)
        return
    }
    src := A_ScriptDir . Chr(92) . "source" . Chr(92) . "numpad-macro-editor.ahk"
    if FileExist(src) {
        Run(q . A_AhkPath . q . " " . q . src . q)
        return
    }
    MsgBox("편집기 파일을 찾을 수 없습니다." . Chr(10) . editorExe)
}

EnsureConfig() {
    global CONFIG
    if FileExist(CONFIG)
        return
    defaults := [
        "7=app|notepad.exe"
        , "8=app|calc.exe"
        , "9=app|explorer.exe"
        , "4=send|#d"
        , "5=url|https://www.google.com"
        , "6=url|https://www.naver.com"
        , "1=text|안녕하세요"
        , "2=send|{Volume_Up}"
        , "3=send|{Volume_Down}"
        , "0=send|^c"
        , ".=url|https://mail.google.com"
    ]
    txt := ""
    for line in defaults
        txt .= line . Chr(10)
    FileAppend(txt, CONFIG, "UTF-8")
}

