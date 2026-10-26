#Requires AutoHotkey v2.0
#SingleInstance Force

; ================================================================
;  넘패드 매크로 편집기
;  왼쪽 키패드 모양에서 넘패드 키를 고르고, 그 키에 대해
;  그냥 / Shift / Ctrl / Alt / Shift+Ctrl 다섯 가지 매크로를 지정합니다.
;  저장하면 실행 중인 넘패드 매크로가 1~2초 안에 새로 읽습니다.
; ================================================================

CONFIG := A_ScriptDir . Chr(92) . "numpad-macros.txt"
ORDER := ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", "."]
GRID := [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["0", "."]]
TYPES := ["프로그램 실행", "단축키 전송", "웹사이트 열기", "글자 입력", "사용 안 함"]
TOKENS := ["app", "send", "url", "text", ""]
LAYERS := [["", "그냥"], ["S", "Shift"], ["C", "Ctrl"], ["A", "Alt"], ["SC", "Shift+Ctrl"]]

DATA := Map()
currentKey := "7"
layerCtrls := []
keyButtons := []

LoadData()

g := Gui("+Resize -MaximizeBox", "넘패드 매크로 편집기")
g.SetFont("s10", "Malgun Gothic")
g.MarginX := 16
g.MarginY := 14
g.Add("Text", "x16 y14 w700 cGray", "NumLock 을 끈 상태에서 넘패드가 매크로로 동작합니다. 키를 고르고 보조키 조합별로 매크로를 넣으세요.")

; 키패드 모양 (3열 4행, 마지막 줄은 0 과 . 두 칸)
r := 0
for rowKeys in GRID {
    r += 1
    x := 16
    rowY := 122 + (r - 1) * 39
    for k in rowKeys {
        w := (k = "0") ? 93 : 44
        b := g.Add("Button", Format("x{} y{} w{} h34", x, rowY, w), k)
        b.OnEvent("Click", SelectKey.Bind(k))
        keyButtons.Push({ key: k, btn: b })
        x += w + 5
    }
}

header := g.Add("Text", "x172 y90 w540", "")

y := 122
for lyr in LAYERS {
    g.Add("Text", Format("x172 y{} w64", y + 4), lyr[2])
    cb := g.Add("CheckBox", Format("x238 y{} w56", y + 3), "사용")
    ddl := g.Add("DropDownList", Format("x300 y{} w122", y), TYPES)
    ed := g.Add("Edit", Format("x430 y{} w212", y + 1), "")
    btn := g.Add("Button", Format("x650 y{} w70", y - 1), "찾아보기")
    btn.OnEvent("Click", Browse.Bind(ed))
    layerCtrls.Push({ tok: lyr[1], cb: cb, ddl: ddl, ed: ed })
    y += 34
}

g.Add("Text", Format("x172 y{} w550 cGray", y + 4), "체크한 줄만 동작합니다. 없는 조합은 원래 키 동작이 나갑니다.")
status := g.Add("Text", Format("x172 y{} w550 cGreen", y + 30), "")
saveBtn := g.Add("Button", Format("x172 y{} w110", y + 56), "저장")
saveBtn.OnEvent("Click", Save)
closeBtn := g.Add("Button", Format("x290 y{} w90", y + 56), "닫기")
closeBtn.OnEvent("Click", (*) => g.Destroy())

g.Show(Format("w740 h{}", y + 112))

ShowKey("7")

SelectKey(k, *) {
    CommitCurrent()
    ShowKey(k)
}

ShowKey(k) {
    global currentKey, header, status, layerCtrls, keyButtons, DATA
    currentKey := k
    header.Value := "넘패드 " . k . " 번 키"
    for kb in keyButtons
        kb.btn.Text := (kb.key = k) ? ("▶ " . kb.key) : kb.key
    for row in layerCtrls {
        full := (row.tok = "") ? k : k . "+" . row.tok
        if DATA.Has(full) {
            spec := DATA[full]
            p := InStr(spec, "|")
            if p {
                row.cb.Value := 1
                row.ddl.Value := TypeIndex(SubStr(spec, 1, p - 1))
                row.ed.Value := SubStr(spec, p + 1)
            } else {
                row.cb.Value := 0
                row.ddl.Value := 1
                row.ed.Value := ""
            }
        } else {
            row.cb.Value := 0
            row.ddl.Value := 1
            row.ed.Value := ""
        }
    }
    status.Value := "이 키에 등록된 매크로: " . CountFor(k) . "개"
}

CommitCurrent() {
    global currentKey, layerCtrls, DATA, TOKENS
    if (currentKey = "")
        return
    for row in layerCtrls {
        full := (row.tok = "") ? currentKey : currentKey . "+" . row.tok
        tok := TOKENS[row.ddl.Value]
        val := Trim(row.ed.Value)
        if (row.cb.Value && tok != "" && val != "")
            DATA[full] := tok . "|" . val
        else if DATA.Has(full)
            DATA.Delete(full)
    }
}

CountFor(k) {
    global DATA, LAYERS
    n := 0
    for lyr in LAYERS {
        full := (lyr[1] = "") ? k : k . "+" . lyr[1]
        if DATA.Has(full)
            n += 1
    }
    return n
}

TypeIndex(tok) {
    global TOKENS
    loop TOKENS.Length {
        if (TOKENS[A_Index] = tok)
            return A_Index
    }
    return TOKENS.Length
}

Browse(ctrl, *) {
    f := FileSelect(3, A_ScriptDir, "실행할 프로그램 선택", "프로그램 (*.exe; *.lnk; *.bat; *.cmd)")
    if (f != "")
        ctrl.Value := f
}

Save(*) {
    global CONFIG, DATA, ORDER, LAYERS, status
    CommitCurrent()
    out := ""
    written := Map()
    count := 0
    for k in ORDER {
        for lyr in LAYERS {
            full := (lyr[1] = "") ? k : k . "+" . lyr[1]
            if DATA.Has(full) {
                out .= full . "=" . DATA[full] . Chr(10)
                written[full] := true
                count += 1
            }
        }
    }
    for full, spec in DATA {
        if !written.Has(full) {
            out .= full . "=" . spec . Chr(10)
            count += 1
        }
    }
    try FileDelete CONFIG
    FileAppend(out, CONFIG, "UTF-8")
    status.Value := "저장했습니다 (" . count . "개). 1~2초 안에 매크로에 반영됩니다."
}

LoadData() {
    global CONFIG, DATA
    DATA := Map()
    if !FileExist(CONFIG)
        return
    text := FileRead(CONFIG, "UTF-8")
    for line in StrSplit(text, Chr(10), Chr(13)) {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        eq := InStr(line, "=")
        if !eq
            continue
        DATA[Trim(SubStr(line, 1, eq - 1))] := SubStr(line, eq + 1)
    }
}

