# KJ_KeypadMacro

NumLock 이 꺼져 있을 때 넘패드(키패드)를 매크로 버튼으로 쓰는 Windows 도구입니다.
NumLock 을 켜면 평소처럼 숫자가 입력됩니다.

같은 키라도 **Shift / Ctrl / Alt / Shift+Ctrl** 을 함께 누르면 다른 매크로가 실행됩니다.

- 실행: `NumpadMacros.exe` (트레이 상주)
- 편집기: `NumpadMacroEditor.exe`
- 설정: `numpad-macros.txt` (편집기가 자동으로 읽고 씁니다)

## 동작

NumLock **꺼짐** 상태에서 넘패드 키가 매크로로 동작합니다.
해당 보조키 조합에 매크로가 없으면 원래 키 동작(Home, Left, Ctrl+Left 등)이 그대로 나갑니다.

프로그램 실행 매크로는 대상 프로그램이 이미 실행 중이면 새로 띄우지 않고 그 창을 맨 앞으로 가져옵니다. 최소화돼 있으면 복원합니다. 실행 파일 이름으로 판단하므로, 같은 이름의 다른 프로그램이 떠 있으면 그 창이 올라올 수 있습니다.

## 편집기

왼쪽 키패드 모양(7 8 9 / 4 5 6 / 1 2 3 / 0 .)에서 키를 고르고, 오른쪽에서 조합별로
"사용" 을 체크한 뒤 종류와 값을 넣고 저장합니다. 저장하면 실행 중인 매크로가 1~2초 안에 반영합니다.

종류는 네 가지입니다.

| 종류 | 값 예시 | 의미 |
| --- | --- | --- |
| 프로그램 실행 | `notepad.exe` | 프로그램 실행 |
| 단축키 전송 | `^!s` | Ctrl+Alt+S (`^`=Ctrl, `!`=Alt, `+`=Shift, `#`=Win) |
| 웹사이트 열기 | `https://github.com` | 기본 브라우저로 열기 |
| 글자 입력 | `안녕하세요` | 글자를 그대로 입력 |

## 설정 파일 형식

```
7=app|notepad.exe
7+S=send|^!t
7+SC=url|https://github.com
```

키 이름 뒤의 접미사가 보조키 조합입니다: `+S` Shift, `+C` Ctrl, `+A` Alt, `+SC` Shift+Ctrl.
접미사가 없으면 보조키 없는 기본 매크로입니다.

## 자동 실행

시작프로그램 폴더(`shell:startup`)에 `NumpadMacros.exe` 바로가기를 두면 로그인할 때 자동으로 켜집니다.

## 빌드

`source` 폴더의 스크립트를 [AutoHotkey v2](https://www.autohotkey.com/) 와 Ahk2Exe 로 컴파일합니다.

```
Ahk2Exe.exe /in source\numpad-macros.ahk /out NumpadMacros.exe /base "<AutoHotkey 설치 경로>\v2\AutoHotkey64.exe" /silent
Ahk2Exe.exe /in source\numpad-macro-editor.ahk /out NumpadMacroEditor.exe /base "<AutoHotkey 설치 경로>\v2\AutoHotkey64.exe" /silent
```

## 참고

- Win 키 조합은 윈도우 단축키를 위해 건드리지 않습니다.
- 관리자 권한으로 실행 중인 창에서는 매크로가 동작하지 않습니다.


## 진단

트레이 아이콘 우클릭 메뉴에 다음 항목이 있습니다.

- 진단 로그 켜기/끄기 : 켜면 같은 폴더의 debug.log 에 키 입력, 매크로 종류, NumLock 상태, 매크로를 누른 시점의 앞 창을 기록합니다.
- 설정 다시 읽기 : 설정 파일을 즉시 다시 읽습니다.

NumLock 상태가 바뀌면 화면 위쪽에 현재 모드가 잠깐 표시되고, 트레이 아이콘 설명에도 반영됩니다.

## 런처 프로그램

대상이 런처여서 실제 프로그램을 다른 이름으로 띄우는 경우(예: Manager.exe 가 Server.exe 를 실행),
실행 후 같은 폴더에서 이름 앞부분이 같은 프로세스를 찾아 launch-map.txt 에 기억합니다.
다음부터는 그 프로세스가 떠 있으면 새로 실행하지 않고 창을 앞으로 올립니다 (창이 없으면 안내만 표시).
기억된 목록은 launch-map.txt 에서 직접 고칠 수 있습니다.
