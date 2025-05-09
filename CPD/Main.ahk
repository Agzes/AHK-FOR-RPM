;              AHK-FOR-RPM
;
; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |        AHK CPD v2  | by Agzes         |
; |         https://e-z.bio/agzes         |
; \_______________________________________/


#SingleInstance Force
#Include %A_ScriptDir%\..\!Libs\!CreateImageButton.ahk
#Include %A_ScriptDir%\..\!Libs\!WinDarkUI.ahk
#Include %A_ScriptDir%\..\!Libs\!GuiEnchancerKit.ahk
#Include %A_ScriptDir%\..\!Libs\!ScroolBar.ahk
#Include %A_ScriptDir%\..\!Libs\!DarkStyleMsgBox.ahk
#DllLoad "Gdiplus.dll"

global logs := []
LogAdd(Text) {
    logs.Push(Text)
}
LogAdd("[status] Инициализация")

program_version := 2.0
code_version := 1
HotKeyStatus := true
CurrentPage := "SBT01"
Font := "Segoe UI"
FontSize := 11
UserName := "User"
ScrollActive := false
Role := ""
Name := ""
FocusMethod := 1
BeforeEsc := 1
BeforeCheck := 0
BeforeLimit := 0
ShowStatus := 1
UpdateCheck := 1

global R_G_Binds := [
    'F4',  ; "[UI] Основное",
    'F8',  ; "[UI] Меню",
    'F10',  ; "Перезагрузка",
    '!0',  ; "Обыск",
    '!1',  ; "Удостоверение",
    '!2',  ; "[Машина] Посадить преступника",
    '!3',  ; "[Машина] Достать преступника",
    '!4',  ; "[try] Пуля в шину",
    '!5',  ; "Выбить дверь",
    '!6',  ; "Выломать",
    '!7',  ; "Штраф по 1.10 АК",
    '!8',  ; "Преступника в КПЗ",
    '!m',  ; "Зачитать Права",
    '!h',  ; "[`"/me незаметно просунув`"]",
    '!b',  ; "Разминировать",
    '!p',  ; "ПМП при пулевом",
    '!k',  ; "Жгут",
    '!b',  ; "Восстановить дверь",
]

global G_Binds_Name := [
    "[UI] Основное",
    "[UI] Меню",
    "Перезагрузка",
    "Обыск",
    "Удостоверение",
    "[Машина] Посадить преступника",
    "[Машина] Достать преступника",
    "[try] Пуля в шину",
    "Выбить дверь",
    "Выломать",
    "Штраф по 1.10 АК",
    "Преступника в КПЗ",
    "Зачитать Права",
    "[`"/me незаметно просунув`"]",
    "Разминировать",
    "ПМП при пулевом",
    "Жгут",
    "Восстановить дверь",
]

global G_Binds := [
    'F4',  ; "[UI] Основное",
    'F8',  ; "[UI] Меню",
    'F10',  ; "Перезагрузка",
    '!0',  ; "Обыск",
    '!1',  ; "Удостоверение",
    '!2',  ; "[Машина] Посадить преступника",
    '!3',  ; "[Машина] Достать преступника",
    '!4',  ; "[try] Пуля в шину",
    '!5',  ; "Выбить дверь",
    '!6',  ; "Выломать",
    '!7',  ; "Штраф по 1.10 АК",
    '!8',  ; "Преступника в КПЗ",
    '!m',  ; "Зачитать Права",
    '!h',  ; "[`"/me незаметно просунув`"]",
    '!b',  ; "Разминировать",
    '!p',  ; "ПМП при пулевом",
    '!k',  ; "Жгут",
    '!b',  ; "Восстановить дверь",
]

LogAdd("[status] получение файлов конфига")
try {
    LogAdd("[info] получение файлов конфига `"Binds`" ")
    global G_Binds := StrSplit(RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Binds"), A_Space)
    G_Binds.Pop()
    LogAdd("[info] `"Binds`" найдено")
    if R_G_Binds.Size < G_Binds.Size {
        LogAdd("[error] `"Binds`" для старой или новой версии")
        global G_Binds := R_G_Binds
        MsgBox("Ошибка в определении конфига! Конфиг сброшен!")
    }
}
try {
    LogAdd("[info] получение файлов конфига `"UserName`" ")
    global UserName := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "UserName")
    LogAdd("[info] `"UserName`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"Role`" ")
    global Role := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Role")
    LogAdd("[info] `"Role`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"Name`" ")
    global Name := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Name")
    LogAdd("[info] `"Name`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"focus_method`" ")
    global FocusMethod := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "focus_method")
    LogAdd("[info] `"focus_method`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_esc`" ")
    global BeforeEsc := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_esc")
    LogAdd("[info] `"before_esc`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_check`" ")
    global BeforeCheck := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_check")
    LogAdd("[info] `"before_check`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_limit`" ")
    global BeforeLimit := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_limit")
    LogAdd("[info] `"before_limit`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"show_status`" ")
    global ShowStatus := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "show_status")
    LogAdd("[info] `"show_status`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"update_check`" ")
    global UpdateCheck := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "update_check")
    LogAdd("[info] `"update_check`" найдено")
}


SetWindowColor(hwnd, titleText?, titleBackground?, border?)
{
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_CAPTION_COLOR := 35
    static DWMWA_TEXT_COLOR := 36

    if (VerCompare(A_OSVersion, "10.0.22200") < 0)
        return ; MsgBox("This is supported starting with Windows 11 Build 22000.", "OS Version Not Supported.")

    if (border ?? 0)
        DwmSetWindowAttribute(hwnd, DWMWA_BORDER_COLOR, border)

    if (titleBackground ?? 0)
        DwmSetWindowAttribute(hwnd, DWMWA_CAPTION_COLOR, titleBackground)

    if (titleText ?? 0)
        DwmSetWindowAttribute(hwnd, DWMWA_TEXT_COLOR, titleText)

    DwmSetWindowAttribute(hwnd?, dwAttribute?, pvAttribute?) => DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", dwAttribute, "Ptr*", &pvAttribute, "UInt", 4)
}
UseGDIP() {
    Static GdipObject := 0
    If !IsObject(GdipObject) {
        GdipToken := 0
        SI := Buffer(24, 0)
        NumPut("UInt", 1, SI)
        If DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", &GdipToken, "Ptr", SI, "Ptr", 0, "UInt") {
            MsgBox("GDI+ could not be started!`n`nThe program will exit!", A_ThisFunc, 262160)
            ExitApp
        }
        GdipObject := { __Delete: UseGdipShutDown }
    }
    UseGdipShutDown(*) {
        DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GdipToken)
    }
}
GetPageData(Page) {
    if Page == "SBT01" {
        return MainPage
    } else if Page == "SBT02" {
        return BindsPage
    } else if Page == "SBT03" {
        return SettingsPage
    } else if Page == "SBT04" {
        return OtherPage
    }
}
SettingsTabSelect(BtnCtrl, *) {
    global CurrentPage
    global ScrollActive
    OldPageData := GetPageData(CurrentPage)
    OldCurrentPage := CurrentPage
    CurrentPageData := GetPageData(BtnCtrl.Name)
    CurrentPage := BtnCtrl.Name

    for key in OldPageData {
        key.Opt("Hidden")
    }

    for key in CurrentPageData {
        key.Opt("-Hidden")
    }

    if OldCurrentPage == "SBT02" {
        SendMessage(0x115, 6, 0, , SettingsUI.Hwnd)
        STB.Opt("-Hidden")
        STB1.Opt("Hidden")
        RemoveScrollBar(SettingsUI)
        ScrollActive := false
        for item in BindItems {
            t := GuiCtrlFromHwnd(item)
            t.Opt("Hidden")
        }
    }

    if CurrentPage == "SBT02" {
        STB1.Opt("-Hidden")
        STB.Opt("Hidden")
        ShowScrollBar(SettingsUI)
        ScrollActive := true
        for item in BindItems {
            t := GuiCtrlFromHwnd(item)
            t.Opt("-Hidden")
        }
    }
    LogSent("[info] [tab-sys] Окно сменено: " OldCurrentPage " -> " CurrentPage "")
}

LogAdd("[status] Инициализация интерфейса")

ButtonStyles := Map()

ButtonStyles["dark"] := [[0xFF171717, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
[0xFF262626, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
[0xFF2F2F2F, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
[0xFF626262, 0xFF474747, 0xFFFFFFFF, 3, 0xFF474747, 1]]

ButtonStyles["tab"] := [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF626262, 0xFF474747, 0xFFFFFFFF, 3, 0xFF474747, 2]]

ButtonStyles["fake_for_group"] := [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF171717, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["fake_for_hotkey"] := [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["binds"] := [[0xFF191919, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
[0xFF262626, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
[0xFF2F2F2F, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
[0xFF626262, 0xFF474747, 0xFFBEBEBE, 5, 0xFF191919, 2]]

ButtonStyles["reset"] := [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
[0xFFFF4444, 0xFFCC0000, 0xFFFFFFFF, 3, 0xFFCC0000, 2],
[0xFFFF6666, 0xFFFF0000, 0xFFFFFFFF, 3, 0xFFFF0000, 2],
[0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["to_settings"] := [[0xFF171717, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
[0xFF262626, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
[0xFF2F2F2F, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
[0xFF626262, 0xFF474747, 0xFFFFFFFF, 0, 0xFF474747, 1]]

ButtonStyles["secondary"] := [[0xFF6C757D, 0xFF5A6268, 0xFFFFFFFF, 3, 0xFF5A6268, 1],
[0xFF5A6268, 0xFF4E555B, 0xFFFFFFFF, 3, 0xFF4E555B, 1],
[0xFF808B96, 0xFF6C757D, 0xFFFFFFFF, 3, 0xFF6C757D, 1],
[0xFFA0ACB8, 0xFF808B96, 0xFFFFFFFF, 3, 0xFF808B96, 1]]

UseGDIP()
LogAdd("[status] Инициализация GDIP")

SettingsUI := GuiExt("", "AHK | CPD v2 ")
SettingsUI.SetFont("cWhite s" FontSize, Font)
SettingsUI.BackColor := 0x171717
SettingsUI.OnEvent('Size', UpdateScrollBars.Bind(SettingsUI))
CreateImageButton("SetDefGuiColor", 0x171717)

SBT01 := SettingsUI.AddButton("xm+3 y+6 w180 h36 0x100 vSBT01 x6", "  " Chr(0xE10F) "   Главная")
SBT01.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT01, 0, ButtonStyles["tab"]*)

SBT02 := SettingsUI.AddButton("xm+3 y+4 w180 h36 0x100 vSBT02 x6", "  " Chr(0xE138) "   Бинды")
SBT02.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT02, 0, ButtonStyles["tab"]*)

SBT03 := SettingsUI.AddButton("xm+3 y+4 w180 h36 0x100 vSBT03 x6", "  " Chr(0xE115) "   Параметры")
SBT03.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT03, 0, ButtonStyles["tab"]*)

SBT04 := SettingsUI.AddButton("xm+3 y308 w180 h36 0x100 vSBT04 x6", "  " Chr(0xE10C) "   Информация")
SBT04.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT04, 0, ButtonStyles["tab"]*)

GitHubOpen(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM")
}
SBTB02 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB02 x6", Chr(0xE1CF)) ; github
SBTB02.OnEvent("Click", GitHubOpen)
CreateImageButton(SBTB02, 0, ButtonStyles["tab"]*)
ReloadFromUI(Element, *) {
    Reload()
}
SBTB03 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB03 x+6", Chr(0xE117)) ; reload
SBTB03.OnEvent("Click", ReloadFromUI)
CreateImageButton(SBTB03, 0, ButtonStyles["tab"]*)
PlayPause(Element, *) {
    global HotKeyStatus
    if HotKeyStatus {
        HotKeyStatus := false
        SBTB04.Text := Chr(0xE102)
        CreateImageButton(SBTB04, 0, ButtonStyles["tab"]*)
        menu_stopstart.Text := Chr(0xE102)
        CreateImageButton(menu_stopstart, 0, ButtonStyles["binds"]*)
        OnOrOffHotKeys("off")
    } else {
        HotKeyStatus := true
        SBTB04.Text := Chr(0xE103)
        CreateImageButton(SBTB04, 0, ButtonStyles["tab"]*)
        menu_stopstart.Text := Chr(0xE103)
        CreateImageButton(menu_stopstart, 0, ButtonStyles["binds"]*)
        OnOrOffHotKeys("on")
    }
}
SBTB04 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB04 x+6", Chr(0xE103)) ; pause/play
SBTB04.OnEvent("Click", PlayPause)
CreateImageButton(SBTB04, 0, ButtonStyles["tab"]*)

OnOrOffHotKeys(onoroff) {
    SetHotKey(G_Binds[1], onoroff)
    SetHotKey(G_Binds[2], onoroff)
    ; SetHotKey(G_Binds[3], onoroff)
    SetHotKey(G_Binds[4], onoroff)
    SetHotKey(G_Binds[5], onoroff)
    SetHotKey(G_Binds[6], onoroff)
    SetHotKey(G_Binds[7], onoroff)
    SetHotKey(G_Binds[8], onoroff)
    SetHotKey(G_Binds[9], onoroff)
    SetHotKey(G_Binds[10], onoroff)
    SetHotKey(G_Binds[11], onoroff)
    SetHotKey(G_Binds[12], onoroff)
    SetHotKey(G_Binds[13], onoroff)
    SetHotKey(G_Binds[14], onoroff)
    SetHotKey(G_Binds[15], onoroff)
    SetHotKey(G_Binds[16], onoroff)
    SetHotKey(G_Binds[17], onoroff)
    SetHotKey(G_Binds[18], onoroff)
}

AddFixedElement(SBT01)
AddFixedElement(SBT02)
AddFixedElement(SBT03)
AddFixedElement(SBT04)
AddFixedElement(SBTB02)
AddFixedElement(SBTB03)
AddFixedElement(SBTB04)


STB := SettingsUI.AddButton("x192 y6 w442 h338 0x100 vSTB Disabled", "")
CreateImageButton(STB, 0, ButtonStyles["fake_for_group"]*)

STB1 := SettingsUI.AddButton("x192 y6 w431 h534 0x100 vSTB1 Disabled Hidden", "")
CreateImageButton(STB1, 0, ButtonStyles["fake_for_group"]*)


SettingsUI.SetFont("cWhite s" 13, Font)
SMP_GREETINGS := SettingsUI.AddText("x194 y44 w438 h30 +Center", "Привет, " UserName "!")

SettingsUI.SetFont("cGray s" 8, Font)
SMP_VERSION := SettingsUI.AddText("x338 y325", "AHK-FOR-RPM: v2.0" ' I ' "RP: v1.0.0")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)

LogAdder() {
    for i in logs {
        SMP_LOGS.add("", i)
    }
}

SMP_LOGS := SettingsUI.AddListView("x198 y104 w452 h240", [""])
SMP_LOGS.SetRounded(3)
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "                                      AHK_FOR_RPM V2")
SMP_LOGS.add("", "                                             by Agzes")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "                                 ⬇️ пролистать для логов ⬇️")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
LogAdder()

WaitForBind(Options := "T5")
{
    LogSent("[info] [bind-sys] ожидаю привязки...")
    global ih := InputHook(Options)
    if !InStr(Options, "V")
        ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E")
    ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
    ih.Start()
    ih.Wait()
    LogSent("[info] [bind-sys] получено сочетание: " StrReplace(StrReplace(ih.EndMods . ih.EndKey, "<", ""), ">", ""))
    return StrReplace(StrReplace(ih.EndMods . ih.EndKey, "<", ""), ">", "")
}


LogSent(Text) {
    SMP_LOGS.add("", Text)
}
SaveBindCfg() {
    save := ""
    for i in BindHwnd {
        el := GuiCtrlFromHwnd(i)
        save := save HotkeyToBind(el.Text) " "
    }
    RegWrite(save, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Binds")
}
CurrentBindsRecords := ""
BindHotkey(BtnObj) {
    global CurrentBindsRecords
    BtnObj.Text := Chr(0xE15B)
    CreateImageButton(BtnObj, 0, ButtonStyles["fake_for_hotkey"]*)
    CurrentBindsRecords := BtnObj.Hwnd
    tbind := WaitForBind()
    if tbind != "" {
        tt := StrReplace(BtnObj.Name, "EBIND_", "")
        G_Binds[tt] := tbind
        ttt := BindHwnd[tt]
        ttt := GuiCtrlFromHwnd(ttt)
        ttt.Text := BindToHotkey(tbind)
        SaveBindCfg()
    }
    BtnObj.Text := Chr(0xE104)
    CreateImageButton(BtnObj, 0, ButtonStyles["fake_for_hotkey"]*)
    CurrentBindsRecords := ""
}
BindHotkeyButton(BtnObj, *) {
    global CurrentBindsRecords
    if CurrentBindsRecords == "" {
        BindHotkey(BtnObj)
    } else {
        MsgBox("Вы уже что-то вводите...`nПодождите 5 секунд...", "Information")
    }
}
BindHotkeyInput(CtrlElement, *) {
    tt := StrReplace(CtrlElement.Name, "BIND_", "")
    G_Binds[tt] := HotkeyToBind(CtrlElement.Text)
    SaveBindCfg()
}
ImportBinds(Element, *) {
    LogSent("[info] [bind-sys] [import] > start")
    PathToFile := FileSelect("", "CPD_cfg.txt", "Импорт файла конфигурации", "AHK_FOR_RPM Config file (*.txt*)")
    if !FileExist(PathToFile)
        MsgBox("Файл конфигурации не найден!")
    else {
        CfgDatas := FileRead(PathToFile, "UTF-8")
        global G_Binds := StrSplit(CfgDatas, A_Space)
        temp := 0
        for i in G_Binds {
            if i != "" {
                temp += 1
                temp1 := GuiCtrlFromHwnd(BindHwnd[temp])
                temp1.Text := BindToHotkey(i)
            }
        }
        LogSent("[info] [bind-sys] [import] > импортировано")
    }
}
ExportBinds(Element, *) {
    export := ""
    for i in BindHwnd {
        el := GuiCtrlFromHwnd(i)
        export := export HotkeyToBind(el.Text) " "
    }
    PathToFile := FileSelect("S", "CPD_cfg.txt", "Сохранение файла конфигурации", "AHK_FOR_RPM Config file (*.txt*)")
    if PathToFile = "" {

    }
    else {
        FileDelete(PathToFile)
        FileAppend(export, PathToFile)
    }
    if FileExist(PathToFile)
        MsgBox("Файл конфигурации успешно сохранён!")
}
ResetBinds(Element, *) {
    global G_Binds := R_G_Binds
    temp := 0
    for i in G_Binds {
        temp += 1
        temp1 := GuiCtrlFromHwnd(BindHwnd[temp])
        temp1.Text := BindToHotkey(i)
    }
    SaveBindCfg()
}
HotkeyToBind(keys) {
    return StrReplace(StrReplace(StrReplace(StrReplace(keys, "Win + ", "#"), "Ctrl + ", "^"), "Alt + ", "!"), "Shift + ", "+")
}
BindToHotkey(keys) {
    return StrReplace(StrReplace(StrReplace(StrReplace(keys, "+", "Shift + "), "^", "Ctrl + "), "!", "Alt + "), "#", "Win + ")
}
ShowCode(Element, *) {
    Element.Text := BindToHotkey(Element.Text)
}
HideCode(Element, *) {
    Element.Text := HotkeyToBind(Element.Text)
}

LogSent("[info] Загрузка конфигуратора биндов")

SBP_LABEL := SettingsUI.AddText("Hidden x194 y13 w420 h20 +Center", Chr(0xE138) " Конфигуратор Биндов")

SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
temp_for_bind_init := 0
BindItems := []
BindHwnd := []
for bind in G_Binds {
    temp_for_bind_init += 1
    t := SettingsUI.AddButton("Hidden x198 y+3 w25 h25 vEBIND_" temp_for_bind_init " ", Chr(0xE104))
    t.OnEvent("Click", BindHotkeyButton)
    CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
    BindItems.Push(t.Hwnd)
    t := SettingsUI.AddButton("Hidden x226 y" t.Y " w116 h25 Disabled")
    CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
    BindItems.Push(t.Hwnd)
    t := SettingsUI.AddEdit("Hidden x226 y" t.Y " w116 h25 vBIND_" temp_for_bind_init " ", "")
    BindHwnd.Push(t.Hwnd)
    BindItems.Push(t.Hwnd)
    t.OnEvent("Change", BindHotkeyInput)
    t.OnEvent("Focus", HideCode)
    t.OnEvent("LoseFocus", ShowCode)
    t.SetRounded(7)
    t.Value := BindToHotkey(bind)
    t := SettingsUI.AddButton("Hidden Left w272 h25 x345 Disabled y" t.Y " vTBIND_" temp_for_bind_init " ", "  " G_Binds_Name[temp_for_bind_init])
    CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
    BindItems.Push(t.Hwnd)
}

SBP_Import := SettingsUI.AddButton("Hidden x198 h30 w155 y+10 ", Chr(0xE118) "  Импорт")
CreateImageButton(SBP_Import, 0, ButtonStyles["fake_for_hotkey"]*)
SBP_Import.OnEvent("Click", ImportBinds)

SBP_Export := SettingsUI.AddButton("Hidden x359 h30 w155 y" SBP_Import.Y, Chr(0xE11C) "  Экспорт")
CreateImageButton(SBP_Export, 0, ButtonStyles["fake_for_hotkey"]*)
SBP_Export.OnEvent("Click", ExportBinds)

SBP_Reset := SettingsUI.AddButton("Hidden x520 h30 w97 y" SBP_Import.Y, Chr(0xE149) " Сброс")
CreateImageButton(SBP_Reset, 0, ButtonStyles["reset"]*)
SBP_Reset.OnEvent("Click", ResetBinds)

LogSent("[info] Запуск ScrollBar")
OnMessage(WM_VSCROLL, OnScroll)

SSP_LABEL := SettingsUI.AddText("Hidden x194 y13 w437 h20 +Center", Chr(0xE115) " Параметры/Настройки")

SSP_PANEL_1 := SettingsUI.AddButton("Hidden x198 y+5 w213 h200 0x100 Disabled", "")
CreateImageButton(SSP_PANEL_1, 0, ButtonStyles["fake_for_group"]*)

SSP_PANEL_2 := SettingsUI.AddButton("Hidden x415 y" SSP_PANEL_1.Y " w213 h200 0x100 Disabled", "")
CreateImageButton(SSP_PANEL_2, 0, ButtonStyles["fake_for_group"]*)

SSP_PANEL_3 := SettingsUI.AddButton("Hidden x198 y+3 w430 h97 0x100 Disabled", "")
CreateImageButton(SSP_PANEL_3, 0, ButtonStyles["fake_for_group"]*)

SSP_P1_USERNAME_LABEL := SettingsUI.AddText("Hidden x203 y50", Chr(0xE13D) " НикНейм ↴")
SSP_P1_USERNAME_BG := SettingsUI.AddButton("Hidden x203 y70 Disabled w203 h25", "")
CreateImageButton(SSP_P1_USERNAME_BG, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P1_USERNAME := SettingsUI.AddEdit("Hidden x203 y70 w203", UserName)
SSP_P1_USERNAME.SetRounded(3)

SSP_P1_NAME_LABEL := SettingsUI.AddText("Hidden x203 y97", Chr(0xE136) " РП Имя Фамилия ↴")
SSP_P1_NAME_BG := SettingsUI.AddButton("Hidden x203 y117 Disabled w203 h25", "")
CreateImageButton(SSP_P1_NAME_BG, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P1_NAME := SettingsUI.AddEdit("Hidden x203 y117 w203", Name)
SSP_P1_NAME.SetRounded(3)

SSP_P1_ROLE_LABEL := SettingsUI.AddText("Hidden x203 y144", Chr(0xE181) " Должность ↴")
SSP_P1_ROLE_BG := SettingsUI.AddButton("Hidden x203 y164 Disabled w203 h25", "")
CreateImageButton(SSP_P1_ROLE_BG, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P1_ROLE := SettingsUI.AddEdit("Hidden x203 y164 w203", Role)
SSP_P1_ROLE.SetRounded(3)

SSP_P1_SAVEBUTTON := SettingsUI.AddButton("Hidden x203 y200 w203 h33 Center", Chr(0xe222) " Сохранить")
SSP_P1_SAVEBUTTON.OnEvent("click", SaveSettingsForUSERDATA)
CreateImageButton(SSP_P1_SAVEBUTTON, 0, ButtonStyles["fake_for_hotkey"]*)


UiMethodList := ["WinActivate [`"Minecarft`"] (" Chr(0xE113) ")", "WinActivate [`"javaw.exe`"] (" Chr(0xE113) ")", "MouseClick (Old)"]
SSP_P2_UIMETHOD_LABEL := SettingsUI.AddText("Hidden x420 y50", Chr(0xE12A) " Метод фокусировки на игре ↴")
SSP_P2_UIMETHOD_BG := SettingsUI.AddButton("Hidden x420 y70 Disabled w203 h25 Left", "  ᐁ I " UiMethodList[FocusMethod])
CreateImageButton(SSP_P2_UIMETHOD_BG, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_UIMETHOD := SettingsUI.AddDropDownList("Hidden x420 y70 w203 +0x4000000", UiMethodList)
SSP_P2_UIMETHOD.OnEvent("Change", DropDownListWorker)
SSP_P2_UIMETHOD.Text := UiMethodList[FocusMethod]


ShowInformationESC(Element, *) {
    MsgBox "Нажимать ESC`n`nИспользуется для предотвращений`n начала отыгровок на меню игры`n`nПо умолчанию -> ВКЛ"
}
ShowInformationCHECK(Element, *) {
    MsgBox "Проверять открытую игру`n`nПеред началом отыгровок`n проверяет запущена ли игра`n`nПо умолчанию -> ВЫКЛ"
}
ShowInformationLIMIT(Element, *) {
    MsgBox "Ограничить hotkey`n`nОграничивает максимальное кол-во одновременных hotkey`n включите если hotkey запускается дважды`n`nПо умолчанию -> ВЫКЛ"
}
ShowInformationSTATUS(Element, *) {
    MsgBox "Показывать статус`n`nПоказывает статус выполнения отыгровок`n сверху экрана показывается прогресс выполнения отыгровок`n`nПо умолчанию -> ВКЛ"
}
ShowInformationUPDATE(Element, *) {
    MsgBox "Авто-проверка обновлений`n`nАвтоматически проверяет уведомления`n при запуске проверяет обновления`n`nПо умолчанию -> ВКЛ"
}
CheckForUpdate(Element?, *) {
    SSP_P3_STATS.Text := Chr(0xE117)
    SSP_P3_DESC.Text := "проверка обновлений"
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/CPD/version", true)
        whr.Send()
        whr.WaitForResponse()
        fileContent := Trim(whr.ResponseText)
        numberFromServer := Integer(RegExReplace(fileContent, "[^\d]"))
        if numberFromServer <= code_version {
            SSP_P3_STATS.Text := Chr(0xE10B)
            SSP_P3_DESC.Text := "у вас последняя версия"
            SMP_LOGS.Add("", "[Info] [CheckForUpdate] -> latest ver. install")
        } else if numberFromServer > code_version {
            SSP_P3_STATS.Text := Chr(0xE149)
            SSP_P3_DESC.Text := "доступно обновление"
            MsgBox("Доступно обновление! Загрузите на: `nhttps://github.com/Agzes/AHK-FOR-RPM")
            SMP_LOGS.Add("", "[Info] [CheckForUpdate] -> update found")
        }
    } catch Error as e {
        SSP_P3_STATS.Text := Chr(0xE171)
        SSP_P3_DESC.Text := "ошибка проверки"
        SMP_LOGS.Add("", "[Err] [CheckForUpdate] -> [-]")
    }
}
SaveSettingsForUSERDATA(Element, *) {
    try {
        RegWrite(SSP_P1_NAME.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Name")
        RegWrite(SSP_P1_ROLE.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "Role")
        RegWrite(SSP_P1_USERNAME.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "UserName")
        MsgBox("Данные успешно сохранены!`nПерезапустите для применения")
    } catch Error as e {
        MsgBox("Ошибка при сохранении!")
    }
}
DropDownListWorker(Element, *) {
    SSP_P2_UIMETHOD_BG.Text := "  ᐁ I " UiMethodList[Element.Value]
    CreateImageButton(SSP_P2_UIMETHOD_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    SaveSettingsForDATA(Element)
}
SaveSettingsForDATA(Element, *) {
    try {
        RegWrite(SSP_P2_UIMETHOD.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "focus_method")
        RegWrite(SSP_P2_ESCNEED.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_esc")
        RegWrite(SSP_P2_CHECKNEED.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_check")
        RegWrite(SSP_P2_LIMIT.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "before_limit")
        RegWrite(SSP_P2_STATUS.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "show_status")
        RegWrite(SSP_P2_UPDATE.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_CPD_v2", "update_check")
        MsgBox("Данные успешно сохранены!`nПерезапустите для применения")
    } catch Error as e {
        MsgBox("Ошибка при сохранении!")
    }
}

SSP_P2_BEFORERP_LABEL := SettingsUI.AddText("Hidden x420 y97", Chr(0xE102) " Перед отыгровками ↴")

SGW := SysGet(SM_CXMENUCHECK := 71)
SGH := SysGet(SM_CYMENUCHECK := 72)
SSP_P2_ESCNEED := SettingsUI.AddCheckBox("Hidden x420 y117 Checked h" SGH " w" SGW)
SSP_P2_ESCNEED_TEXT := SettingsUI.AddText("Hidden x434 y115 0x200 h" SGH, " Нажимать ESC")
SSP_P2_ESCNEED_HELP := SettingsUI.AddButton("Hidden x600 y117 h17 w17", "?")
SSP_P2_ESCNEED_HELP.OnEvent("Click", ShowInformationESC)
CreateImageButton(SSP_P2_ESCNEED_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_ESCNEED.OnEvent("Click", SaveSettingsForDATA)
SSP_P2_ESCNEED.Value := BeforeEsc

SGW2 := SysGet(SM_CXMENUCHECK := 71)
SGH2 := SysGet(SM_CYMENUCHECK := 72)
SSP_P2_CHECKNEED := SettingsUI.AddCheckBox("Hidden x420 y137 h" SGH2 " w" SGW2)
SSP_P2_CHECKNEED_TEXT := SettingsUI.AddText("Hidden x434 y135 0x200 h" SGH2, " Проверять открытую игру")
SSP_P2_CHECKNEED_HELP := SettingsUI.AddButton("Hidden x600 y137 h17 w17", "?")
SSP_P2_CHECKNEED_HELP.OnEvent("Click", ShowInformationCHECK)
CreateImageButton(SSP_P2_CHECKNEED_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_CHECKNEED.OnEvent("Click", SaveSettingsForDATA)
SSP_P2_CHECKNEED.Value := BeforeCheck

SGW3 := SysGet(SM_CXMENUCHECK := 71)
SGH3 := SysGet(SM_CYMENUCHECK := 72)
SSP_P2_LIMIT := SettingsUI.AddCheckBox("Hidden x420 y157 h" SGH3 " w" SGW3)
SSP_P2_LIMIT_TEXT := SettingsUI.AddText("Hidden x434 y155 0x200 h" SGH3, " Ограничить hotkey")
SSP_P2_LIMIT_HELP := SettingsUI.AddButton("Hidden x600 y157 h17 w17", "?")
SSP_P2_LIMIT_HELP.OnEvent("Click", ShowInformationLIMIT)
CreateImageButton(SSP_P2_LIMIT_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_LIMIT.OnEvent("Click", SaveSettingsForDATA)
SSP_P2_LIMIT.Value := BeforeLimit

SSP_P2_OTHER := SettingsUI.AddText("Hidden x420 y177", Chr(0xE14C) " Прочее ↴")

SGW4 := SysGet(SM_CXMENUCHECK := 71)
SGH4 := SysGet(SM_CYMENUCHECK := 72)
SSP_P2_STATUS := SettingsUI.AddCheckBox("Hidden x420 y197 Checked h" SGH4 " w" SGW4)
SSP_P2_STATUS_TEXT := SettingsUI.AddText("Hidden x434 y195 0x200 h" SGH4, " Показывать статус рп")
SSP_P2_STATUS_HELP := SettingsUI.AddButton("Hidden x600 y197 h17 w17", "?")
SSP_P2_STATUS_HELP.OnEvent("Click", ShowInformationSTATUS)
CreateImageButton(SSP_P2_STATUS_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_STATUS.OnEvent("Click", SaveSettingsForDATA)
SSP_P2_STATUS.Value := ShowStatus

SGW5 := SysGet(SM_CXMENUCHECK := 71)
SGH5 := SysGet(SM_CYMENUCHECK := 72)
SSP_P2_UPDATE := SettingsUI.AddCheckBox("Hidden x420 y217 Checked h" SGH4 " w" SGW4)
SSP_P2_UPDATE_TEXT := SettingsUI.AddText("Hidden x434 y215 0x200 h" SGH4, " Авто-проверка обновлений")
SSP_P2_UPDATE_HELP := SettingsUI.AddButton("Hidden x600 y217 h17 w17", "?")
SSP_P2_UPDATE_HELP.OnEvent("Click", ShowInformationUPDATE)
CreateImageButton(SSP_P2_UPDATE_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_UPDATE.OnEvent("Click", SaveSettingsForDATA)
SSP_P2_UPDATE.Value := UpdateCheck

SettingsUI.SetFont("cWhite s" FontSize + 3, Font)
SSP_P3_STATS := SettingsUI.AddText("Hidden x287 y266", Chr(0xE10C) "")
SettingsUI.SetFont("cWhite s" FontSize - 3, Font)
SSP_P3_DESC := SettingsUI.AddText("Hidden x231 y290 w130 Center", "\(ᵔ•ᵔ)/")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
SSP_P3_BUTTON := SettingsUI.AddButton("Hidden x430 y275", "Проверить обновления")
SSP_P3_BUTTON.OnEvent("Click", CheckForUpdate)
CreateImageButton(SSP_P3_BUTTON, 0, ButtonStyles["fake_for_hotkey"]*)


ToDev(Element, *) {
    Run("https://e-z.bio/agzes")
}
ToMessage(Element, *) {
    Run("https://discord.com/users/695827097024856124")
}
ToGitHub(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM")
}

SettingsUI.SetFont("cWhite s" FontSize + 8, Font)
SOP_LABEL := SettingsUI.AddText("Hidden x203 y114 w200 h30 ", "AHK-FOR-RPM")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
SOP_LABEL2 := SettingsUI.AddText("Hidden x203 y144 w200 h30 ", "V2 by Agzes")


SOP_DEV := SettingsUI.AddButton("Hidden x198 h30 w155 y308 ", Chr(0xE13D) "  Разработчик")
CreateImageButton(SOP_DEV, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_DEV.OnEvent("Click", ToDev)

SOP_CONTACT := SettingsUI.AddButton("Hidden x359 h30 w155 y308 ", Chr(0xE136) "  Связаться")
CreateImageButton(SOP_CONTACT, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_CONTACT.OnEvent("Click", ToMessage)

SOP_GITHUB := SettingsUI.AddButton("Hidden x520 h30 w107 y308 ", Chr(0xE136) "  GitHub")
CreateImageButton(SOP_GITHUB, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_GITHUB.OnEvent("Click", ToGitHub)

LogSent("[status] Интерфейс инициализирован")

isScrollBarActive() {
    if WinActive(SettingsUI) {
        if ScrollActive {
            return true
        }
    }
    return false
}

LogSent("[info] запускаю дополнительные скрипты интерфейса")
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 50
#HotIf isScrollBarActive()
WheelUp::
WheelDown:: {
    Loop 10 {
        SendMessage WM_VSCROLL, A_ThisHotkey ~= 'Up' ? SB_LINEUP : SB_LINEDOWN, , , SettingsUI
    }
}

LogSent("[info] конфигурирую данные интерфейса")
MainPage := [SMP_GREETINGS, SMP_VERSION, SMP_LOGS]
BindsPage := [SBP_LABEL, SBP_Import, SBP_Export, SBP_Reset]
SettingsPage := [SSP_LABEL, SSP_PANEL_1, SSP_PANEL_2, SSP_PANEL_3, SSP_P1_NAME, SSP_P1_NAME_BG, SSP_P1_NAME_LABEL, SSP_P1_ROLE, SSP_P1_ROLE_BG, SSP_P1_ROLE_LABEL, SSP_P1_SAVEBUTTON, SSP_P1_USERNAME, SSP_P1_USERNAME_BG, SSP_P1_USERNAME_LABEL, SSP_P2_BEFORERP_LABEL, SSP_P2_CHECKNEED, SSP_P2_CHECKNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_ESCNEED, SSP_P2_ESCNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_LIMIT, SSP_P2_LIMIT_HELP, SSP_P2_LIMIT_TEXT, SSP_P2_STATUS, SSP_P2_STATUS_HELP, SSP_P2_STATUS_TEXT, SSP_P2_UIMETHOD, SSP_P2_UIMETHOD_BG, SSP_P2_UIMETHOD_LABEL, SSP_P2_UPDATE, SSP_P2_UPDATE_HELP, SSP_P2_UPDATE_TEXT, SSP_P3_BUTTON, SSP_P3_DESC, SSP_P3_STATS, SSP_P2_ESCNEED_TEXT, SSP_P2_OTHER]
OtherPage := [SOP_CONTACT, SOP_DEV, SOP_GITHUB, SOP_LABEL, SOP_LABEL2]

LogSent("[info] применяю атрибуты и тему для окна")
SetWindowAttribute(SettingsUI)
SetWindowTheme(SettingsUI)
SetWindowColor(SettingsUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
LogSent("[info] показываю интерфейс")
SettingsUI.Show("h350 w640")
RemoveScrollBar(SettingsUI)

if UpdateCheck
    CheckForUpdate()

; STATUS BAR
global SBMaximum := 0
global SBMaximumForOne := 0
global CurrentProgress := 0

StatusUI := GuiExt("+AlwaysOnTop -Caption", "AHK | Status")
StatusUI.BackColor := "0"
WinSetTransColor(0, StatusUI.Hwnd)
ProgressBar := StatusUI.AddProgress("w300 h32 x0 y0 Background171717 c636363")
ProgressBar.Value := 0
ProgressBar.SetRounded(6)

ShowStatusBar(Element?, *) {
    StatusUI.Show("w300 h32 NA")
    Sleep(100)
    screenWidth := A_ScreenWidth
    x := (screenWidth - StatusUI.W) / 2
    StatusUI.Move(x, 2)
}

SetMStatusBar(MaxSteps?, *) {
    global SBMaximum := MaxSteps
    global SBMaximumForOne := 100 / MaxSteps
    global CurrentProgress := 0
    ProgressBar.Value := 0
}

SetNStatusBar(Step?, *) {
    global CurrentProgress
    if !SBMaximum
        return

    targetProgress := SBMaximumForOne * Step

    loop {
        if CurrentProgress < targetProgress {
            global CurrentProgress += 1
        } else if CurrentProgress > targetProgress {
            break
        } else {
            break
        }

        ProgressBar.Value := CurrentProgress
        Sleep(5)
    }
}

HideStatusBar(Element?, *) {
    StatusUI.Hide()
    global SBMaximum := 0
    global SBMaximumForOne := 0
    global CurrentProgress := 0
    ProgressBar.Value := 0
}

; {RP ELEMENTS}

hide_ui(Element?, *) {
    temp := false
    if WinExist("AHK | CPD v2") {
        temp := true
    }
    MainBindUI.Hide()
    MenuUI.Hide()
    Sleep(100)
    if FocusMethod = 1 {
        if WinExist("Minecraft") {
            WinShow("Minecraft")
            WinActivate("Minecraft")
        }
    } else if FocusMethod = 2 {
        if WinExist("ahk_exe javaw.exe") {
            WinShow("ahk_exe javaw.exe")
            WinActivate("ahk_exe javaw.exe")
        }
    } else {
        MouseClick("Left")
    }
    Sleep(100)
    if BeforeEsc and !temp {
        SendInput("{Esc}")
    }
}


rummage(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(5)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/do Белые перчатки для обыска в левом кармане штанов {ENTER}")
    SetNStatusBar(1)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("/me потянувшись рукой в левый карман штанов достал из него перчатки для обыска, после чего надев их, начал осматривать подозреваемого {ENTER}")
    SetNStatusBar(2)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("/me повернув подозреваемого к себе лицом, открыл его рот и осмотрел на запрещенные вещества, после чего закрыл его, повернул лицом к стене {ENTER}")
    SetNStatusBar(3)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("/me ощупывает плечи, торс, руки, пах и ноги подозреваемого {ENTER}")
    SetNStatusBar(4)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("/me закончив обыск снимает, сворачивает перчатки и убирает их в карман {ENTER}")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
document(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(5)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Здравия желаю, я Сотрудник `"CPD`" " Name ", надеюсь на сотрудничество с вашей стороны. {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/do В кармане штанов удостоверение `"CPD`", со всей интересующей информацией {ENTER} ")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me достал удостоверение из кармана своих штанов, открыл и показал гражданину некоторое время в открытом виде {ENTER}")
    SetNStatusBar(3)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/do Информация в удостоверении: " Name ", значок CPD, роспись сотрудника {ENTER} ")
    SetNStatusBar(4)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me после доказательства информации, захлопнул документ, перекинул его во вторую руку и положил обратно в карман {ENTER}")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
car_in(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me открыв дверь автомобиля, сажает преступника в автомобиль и захлопывает дверь {ENTER}")
    Sleep(150) ;
    Return
}
car_out(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me открывая дверь автомобиля, вытаскивает преступника из автомобиля и захлопывает дверь {ENTER}")
    Sleep(150) ;
    Return
}
in_tire(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(2)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me достал из за спины автомат, снял с предохранителя, открыл окно, высунулся из него, прицелился в колесо впереди едущего транспортного средства {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(150) ;
    SendInput("/try выстрелив, пуля пробила колесо? {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
crash_door(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me осмотрел дверь, встал левым боком к двери и встал на опорную правую ногу, сделал резкий боковой удар левой ногой в область дверной ручки {ENTER}")
    Sleep(150) ;
    Return
}
lom_door(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(3)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me протянул руку к боковой части бронежилета, затем достал лом и молоток из карманов бронежилета {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me подставил лом между дверным полотном и рамой. После чего начал вбивать лом силовыми ударами молотка {ENTER}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me резкими движениями вернул молоток и лом на свои места и закрепил их {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
fine(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(4)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/do КПК закреплен на поясе {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me снял КПК с пояса, включил его, начал вводить данные {ENTER}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me введя данные, выписал штраф и отправил оповещение на электронную почту, затем выключил КПК и закрепил его на поясе {ENTER}")
    SetNStatusBar(3)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/police card")
    SetNStatusBar(4)
    Sleep(250)
    HideStatusBar()
    Return
}
kpz(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(2)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(600) ;
    SendInput("/me достает ключ от кпз и разгрузки бронежилета, вставляет его в дверь и прокручивает до упора, берется за ручку двери и открывает её {ENTER}")
    SetNStatusBar(1)
    Sleep(600) ;
    SendInput("{е}")
    Sleep(600) ;
    SendInput("/me заталкивает преступника в камеру и захлопывает дверь, прокручивает ключ в обратную сторону, высовывает его из замка и убирает в разгрузку бронежилета {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
rights(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(2)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(500) ;
    SendInput("Вы имеете право хранить молчание, всё что вы скажете будет использовано против вас, вы имеете право на один телефонный звонок, протяженностью 1 минута. Также вы имеете право на адвоката, в случае его необходимости мы осуществим вызов {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("Вы понимаете свои права? {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
unnoticed(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me незаметно просунув {ENTER}")
    Sleep(150) ;
    Return
}
defuse(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(10)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/me снял сапёрский набор с бронежилета, положил его перед собой и открыл {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/me достал из чемодана отвёртку и сосуд с жидким азотом. {ENTER}")
    SetNStatusBar(2)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/do Перед парнем находится взрывное устройство {ENTER}")
    SetNStatusBar(3)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/me открутил болты с крышки устройства, аккуратно снял крышку с таймером {ENTER}")
    SetNStatusBar(4)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/me положил отвёртку в чемодан, внимательно осмотрел содержимое детонатора {ENTER}")
    SetNStatusBar(5)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/do Детонатор состоит из взрывного вещества и большого количества разноцветных проводов {ENTER}")
    SetNStatusBar(6)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/me достал из набора кусачки, перекусил ими красный провод {ENTER}")
    SetNStatusBar(7)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/do Таймер бомбы остановился, взрывное вещество отключено от детонатора {ENTER}")
    SetNStatusBar(8)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/do Бомба обезврежена {ENTER}")
    SetNStatusBar(9)
    Sleep(1250) ;
    SendInput("{е}")
    Sleep(1250) ;
    SendInput("/me убрал кусачки в чемодан, открыл сосуд, залил азот в сосуд {ENTER}")
    SetNStatusBar(10)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(3)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(300) ;
    SendInput("/mee ставит и открывает аптечку рядом с собой, осматривает ранение пострадавшего, разрывает чуть одежду в районе огнестрела, ставит жгут, взяв из аптечки антисептик, обрабатывает свои руки и одевает перчатки {ENTER}")
    SetNStatusBar(1)
    Sleep(600) ;
    SendInput("{е}")
    Sleep(600) ;
    SendInput("/mee распечатывает из пачки антисептическую салфетку, взяв шприц с обезболивающим и выпустив воздух из иглы протирает салфеткой место укола и вводит иглу с обезболивающим в районе огнестрела {ENTER}")
    SetNStatusBar(2)
    Sleep(600) ;
    SendInput("{е}")
    Sleep(600) ;
    SendInput("/mee осматривает рану на наличие пули и глубины раны, берет из аптечки запечатанную салфетку гемостатик, открывает ее и начинает делать тампонаду раны, останавливая кровотечение, затем берет бинт из аптечки и начинает накладывать тугую повязку {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp2(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/mee открыв аптечку достает жгут и накладывает выше места повреждения, после чего пишет записку и смотрит время наложение жгута и прикрепляет к жгуту, обработав рану перекисью, накладывает временную повязку {ENTER}")
    Sleep(150) ;
    Return
}
door(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(2)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(500) ;
    SendInput("/do Выбитый деревянный предмет и петли с болтами лежат на полу. {ENTER}")
    SetNStatusBar(1)
    Sleep(500) ;
    SendInput("{е}")
    Sleep(500) ;
    SendInput("/mee подняв деревянный предмет подобрал с пола вылетевшие петли и болты, после чего достал из сумки дрель и прикрутил одну сторону петли обратно к двери а другую обратно к коробке {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}


MainBindUI := GuiExt("", "AHK | CPD v2 ")
MainBindUI.SetFont("cWhite s" FontSize - 1, Font)
MainBindUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

t := MainBindUI.AddButton("w123 h30 y+5 x5", "Обыскать")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", rummage)

t := MainBindUI.AddButton("w123 h30 y" t.Y " x133", "Удостоверение")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", document)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Преступника в машину")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", car_in)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Преступника из машины")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", car_out)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Выстрел в шину")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", in_tire)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Выбить дверь")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", crash_door)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Выломать")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", lom_door)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Штраф по 1.10 АК")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", fine)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Преступника в КПЗ")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", kpz)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Зачитать Права")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", rights)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "[`"/me незаметно просунув`"]")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", unnoticed)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Разминировать")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", defuse)

t := MainBindUI.AddButton("w123 h30 y+5 x5", "пулевое")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp)

t := MainBindUI.AddButton("w123 h30 y" t.Y " x133", "жгут")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp2)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Восстановить дверь")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", door)


SetWindowAttribute(MainBindUI)
SetWindowColor(MainBindUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
mainbinduiy := t.y + 35
; RareBindUI.Show("w260 h" rarebindy)


open_settings_ui(Element?, *) {
    SettingsUI.Show("h350 w640")
}


MenuUI := GuiExt("", "AHK | CPD v2 ")
MenuUI.SetFont("cWhite s" FontSize - 1, Font)
MenuUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

MenuUI.AddText("w250 x5 +Center", "(. ❛ ᴗ ❛.)")

t := MenuUI.AddButton("w250 h30 y+5 x5", "открыть меню")
CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
t.OnEvent("Click", open_settings_ui)

menu_restart := MenuUI.AddButton("w250 h30 y+5 x5", Chr(0xE117))
CreateImageButton(menu_restart, 0, ButtonStyles["binds"]*)
menu_restart.OnEvent("Click", ReloadFromUI)

menu_stopstart := MenuUI.AddButton("w250 h30 y+5 x5", Chr(0xE103))
CreateImageButton(menu_stopstart, 0, ButtonStyles["binds"]*)
menu_stopstart.OnEvent("Click", PlayPause)

SetWindowAttribute(MenuUI)
SetWindowColor(MenuUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
mainbindy := menu_stopstart.Y + 35
; MenuUI.Show("w260 h" mainbindy)


MainBindUIopen(Element?, *) {
    MainBindUI.Show("w260 h" mainbinduiy)
}
MenuUIopen(Element?, *) {
    MenuUI.Show("w260 h" mainbindy)
}

SetHotKey(key, function) {
    if key != "" {
        HotKey(key, function)
    }
}

SetHotKey(G_Binds[1], MainBindUIopen)
SetHotKey(G_Binds[2], MenuUIopen)
SetHotKey(G_Binds[3], ReloadFromUI)

SetHotKey(G_Binds[4], rummage)
SetHotKey(G_Binds[5], document)
SetHotKey(G_Binds[6], car_in)
SetHotKey(G_Binds[7], car_out)
SetHotKey(G_Binds[8], in_tire)
SetHotKey(G_Binds[9], crash_door)
SetHotKey(G_Binds[10], lom_door)
SetHotKey(G_Binds[11], fine)
SetHotKey(G_Binds[12], kpz)
SetHotKey(G_Binds[13], rights)
SetHotKey(G_Binds[14], unnoticed)
SetHotKey(G_Binds[15], defuse)
SetHotKey(G_Binds[16], pmp)
SetHotKey(G_Binds[17], pmp2)
SetHotKey(G_Binds[18], door)

if BeforeLimit {
    A_HotkeyInterval := 1000
    A_MaxHotkeysPerInterval := 1
}

if (VerCompare(A_OSVersion, "10.0.22200") < 0) {
    LogSent("[WinCheck] [Info] Версия Windows ниже 10.0.22200: -ColorWindow")
    LogSent("[WinCheck] [Info] Вы можете игнорировать ошибку -> ColorWindow")
}


; made with ❤️  by Agzes!