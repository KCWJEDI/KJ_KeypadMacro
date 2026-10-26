#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ================================================================
;  넘패드 매크로
;    NumLock 꺼짐 -> 넘패드가 매크로 버튼
;    NumLock 켜짐 -> 평소처럼 숫자 입력
;
;  같은 키라도 Shift / Ctrl / Alt / Shift+Ctrl 을 누르면 다른 매크로가 나갑니다.
;  매크로 내용은 numpad-macros.txt 에 저장되고, 편집기는 NumpadMacroEditor.exe 입니다.
; ================================================================

CONFIG := A_ScriptDir . Chr(92) . "numpad-macros.txt"
MACRO := Map()
STAMP := ""

EnsureConfig()
LoadConfig()
SetTimer(WatchConfig, 1200)

TrayTip("넘패드 매크로 실행 중", "NumLock OFF = 매크로 / ON = 숫자")
A_TrayMenu.Add()
A_TrayMenu.Add("매크로 편집...", (*) => OpenEditor())
A_TrayMenu.Add("설정 다시 읽기", (*) => Reload())
A_TrayMenu.Add()
A_TrayMenu.Add("종료", (*) => ExitApp())

; NumLock 이 꺼져 있고 편집기 창이 앞에 있지 않을 때만 동작합니다.
; 보조키 조합마다 따로 등록하므로, 매크로를 넣지 않은 조합은 원래 키 동작이 그대로 나갑니다.
#HotIf !GetKeyState("NumLock", "T") && !WinActive("넘패드 매크로 편집기")
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

; 매크로가 있으면 실행하고, 없으면 원래 키 동작(Home, Left 등)을 그대로 보냅니다.
Dispatch(full, nav) {
    global MACRO
    if !MACRO.Has(full) {
        Send("{Blind}" . nav)
        return
    }
    m := MACRO[full]
    try {
        if (m.type = "app")
            Run m.value
        else if (m.type = "url")
            Run m.value
        else if (m.type = "send")
            Send m.value
        else if (m.type = "text")
            SendText m.value
    } catch as e {
        TrayTip("실행하지 못했습니다: " . m.value, "넘패드 매크로", 2)
    }
}

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

