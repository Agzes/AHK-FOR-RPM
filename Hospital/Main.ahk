;              AHK-FOR-RPM
;
; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |      AHK Hospital v2  | by Agzes      |
; |         https://e-z.bio/agzes         |
; \_______________________________________/ 


#SingleInstance Force
#Include !CreateImageButton.ahk 
#Include !WinDarkUI.ahk
#Include !GuiEnchancerKit.ahk
#Include !ScroolBar.ahk
#Include !DarkStyleMsgBox.ahk
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
    'F6',  ; "[UI] Обучение мл. состава",
    'F8',  ; "[UI] Редкое, операции",
    'F9',  ; "[UI] Меню",
    'F10', ; "Перезагрузка",
    '!q',  ; "Приветствие",
    '!t',  ; "Передать таблетку + /med heal",
    '!l',  ; "Продать мед + /med sell",
    '!y',  ; "Ушиб + /med heal",
    '!h',  ; "Нашатырь + /med heal",
    '!i',  ; "Инъекция + /med inject",
    '!m',  ; "Выдача медкарты  + /med givecard",
    '!v',  ; "Выписка из 6 палаты  + /med heal",
    '!o',  ; "Мед.осмотр",
    '!p',  ; "Проф. Пригодность ",
    '!u',  ; "Ножевое",
    '!b',  ; "Пулевое",
    '!n',  ; "Носилки",
    '!k',  ; "Капельница",
    '!d',  ; "Дефибриллятор",
    '!g',  ; "Скрутить, вколоть успокоительный укол",
    '!j',  ; "Успокаивающий укол",
    '!1',  ; "Пластическая операция"
    '!2',  ; "Взятие крови на анализ",
    '!3',  ; "Обработать и зашить рану",
    '!5',  ; "Операция по извлечению пули (БЕЗ ОБСЛЕДОВАНИЯ)
    '!8',  ; "Операция. Закрытый перелом + ренген и гипс
    '!9',  ; "Операция. Открытый перелом + ренген и гипс
    '!6',  ; "Сделать снимок в рентген аппарате",
    '!7',  ; "Вправление сустава. Вывих",
    '',   ; "СЛР"
    '',   ; "ЭКГ"
    '!0',  ; "Наложить гипс", ;! -UI
    '^!1', ; "Лекция интернам [ Фулл лекция ]",
    '^!2', ; "Устав (1/4 часть) [ речь 'Вы готовы... ?'
    '^!3', ; "Устав (2/4 часть) [ 3 Устава рандомно ]",
    '^!4', ; "Устав (3/4 часть) [ 3 Сокращения рандомно
    '^!5', ; "Устав (4/4 часть) [ 'Вы сдали тест...']",
    '^!6', ; "Клятва [ 'Вы готовы?' ]",
    '^!7', ; "Клятва [речь 'Вы дали клятву гиппократу' ]
    '^!8', ; "Поручения для интернов [ Рандом ]",
    '^!9', ; "Практика  (1/2 часть ) [РП, задание] ",
    '^!0', ; "Практика  (2/2 часть ) [ 'Вы сдали...' ]"
    '!c',  ; "/calls",
    '!r',  ; "/pass accept",
    '!e',  ; "/med heal _ 100 (ввод будет там где _ )",
    '!s',  ; "/gps cancel",
]

global G_Binds_Name := [
    "[UI] Основное",
    "[UI] Обучение мл. состава",
    "[UI] Редкое, операции",
    "[UI] Меню",
    "Перезагрузка",
    "Приветствие",
    "Передать таблетку",
    "Продать мед",
    "Ушиб",
    "Нашатырь",
    "Инъекция",
    "Мед.Карта (выдача)",
    "Выписка из 6 палаты",
    "Мед.осмотр",
    "Проф. Пригодность ",
    "Ножевое",
    "Пулевое",
    "Носилки",
    "Капельница",
    "Дефибриллятор",
    "Скрутить + успокоительный укол",
    "Успокаивающий укол",
    "Пластическая операция",
    "Взятие крови на анализ (в пробирку)",
    "Обработать и зашить рану",
    "Операция по извлечению пули",
    "Закрытый перелом",
    "Открытый перелом",
    "Рентген",
    "Вывих",
    "СЛР",
    "ЭКГ",
    "Наложить гипс", ;! -UI
    "Лекция интерну",
    "Устав [1/4 часть] 'Вы готовы... ?' ",
    "Устав [2/4 часть] 3 Устава  ",
    "Устав [3/4 часть] 3 Термин  ",
    "Устав [4/4 часть] 'Вы сдали тест...'",
    "Клятва [ 'Вы готовы?' ]",
    "Клятва [речь 'Вы дали клятву гиппократу' ]",
    "Поручения для интернов [ Рандом ]",
    "Практика (1/2 часть ) [РП, задание] ",
    "Практика (2/2 часть ) [ 'Вы сдали...' ]",
    "/calls",
    "/pass accept",
    "/med heal _ 100",
    "/gps cancel"
]

global G_Binds  := [
    'F4',  ; "[UI] Основное",
    'F6',  ; "[UI] Обучение мл. состава",
    'F8',  ; "[UI] Редкое, операции",
    'F9',  ; "[UI] Меню",
    'F10', ; "Перезагрузка",
    '!q',  ; "Приветствие",
    '!t',  ; "Передать таблетку + /med heal",
    '!l',  ; "Продать мед + /med sell",
    '!y',  ; "Ушиб + /med heal",
    '!h',  ; "Нашатырь + /med heal",
    '!i',  ; "Инъекция + /med inject",
    '!m',  ; "Выдача медкарты  + /med givecard",
    '!v',  ; "Выписка из 6 палаты  + /med heal",
    '!o',  ; "Мед.осмотр",
    '!p',  ; "Проф. Пригодность ",
    '!u',  ; "Ножевое",
    '!b',  ; "Пулевое",
    '!n',  ; "Носилки",
    '!k',  ; "Капельница",
    '!d',  ; "Дефибриллятор",
    '!g',  ; "Скрутить, вколоть успокоительный укол",
    '!j',  ; "Успокаивающий укол",
    '!1',  ; "Пластическая операция"
    '!2',  ; "Взятие крови на анализ",
    '!3',  ; "Обработать и зашить рану",
    '!5',  ; "Операция по извлечению пули (БЕЗ ОБСЛЕДОВАНИЯ)
    '!8',  ; "Операция. Закрытый перелом + ренген и гипс
    '!9',  ; "Операция. Открытый перелом + ренген и гипс
    '!6',  ; "Сделать снимок в рентген аппарате",
    '!7',  ; "Вправление сустава. Вывих",
    '',   ; "СЛР"
    '',   ; "ЭКГ"
    '!0',  ; "Наложить гипс", ;! -UI
    '^!1', ; "Лекция интернам [ Фулл лекция ]",
    '^!2', ; "Устав (1/4 часть) [ речь 'Вы готовы... ?'
    '^!3', ; "Устав (2/4 часть) [ 3 Устава рандомно ]",
    '^!4', ; "Устав (3/4 часть) [ 3 Сокращения рандомно
    '^!5', ; "Устав (4/4 часть) [ 'Вы сдали тест...']",
    '^!6', ; "Клятва [ 'Вы готовы?' ]",
    '^!7', ; "Клятва [речь 'Вы дали клятву гиппократу' ]
    '^!8', ; "Поручения для интернов [ Рандом ]",
    '^!9', ; "Практика  (1/2 часть ) [РП, задание] ",
    '^!0', ; "Практика  (2/2 часть ) [ 'Вы сдали...' ]"
    '!c',  ; "/calls",
    '!r',  ; "/pass accept",
    '!e',  ; "/med heal _ 100 (ввод будет там где _ )",
    '!s',  ; "/gps cancel",
]

LogAdd("[status] получение файлов конфига")
try {
    LogAdd("[info] получение файлов конфига `"Binds`" ")
    global G_Binds := StrSplit(RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Binds"), A_Space)
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
    global UserName := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "UserName")
    LogAdd("[info] `"UserName`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"Role`" ")
    global Role := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Role")
    LogAdd("[info] `"Role`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"Name`" ")
    global Name := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Name")
    LogAdd("[info] `"Name`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"focus_method`" ")
    global FocusMethod := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "focus_method")
    LogAdd("[info] `"focus_method`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_esc`" ")
    global BeforeEsc := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_esc")
    LogAdd("[info] `"before_esc`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_check`" ")
    global BeforeCheck := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_check")
    LogAdd("[info] `"before_check`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"before_limit`" ")
    global BeforeLimit := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_limit")
    LogAdd("[info] `"before_limit`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"show_status`" ")
    global ShowStatus := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "show_status")
    LogAdd("[info] `"show_status`" найдено")
}
try {
    LogAdd("[info] получение файлов конфига `"update_check`" ")
    global UpdateCheck := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "update_check")
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

ButtonStyles["dark"] :=             [[0xFF171717, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
                                     [0xFF262626, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
                                     [0xFF2F2F2F, 0xFF1A1A1A, 0xFFFFFFFF, 3, 0xFF1A1A1A, 1],
                                     [0xFF626262, 0xFF474747, 0xFFFFFFFF, 3, 0xFF474747, 1]]
     
ButtonStyles["tab"] :=              [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF626262, 0xFF474747, 0xFFFFFFFF, 3, 0xFF474747, 2]]

ButtonStyles["fake_for_group"] :=   [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF171717, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["fake_for_hotkey"] :=  [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["binds"] :=            [[0xFF191919, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
                                     [0xFF262626, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
                                     [0xFF2F2F2F, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2],
                                     [0xFF626262, 0xFF474747, 0xFFBEBEBE, 5, 0xFF191919, 2]]
                                     
ButtonStyles["reset"] :=            [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2],
                                     [0xFFFF4444, 0xFFCC0000, 0xFFFFFFFF, 3, 0xFFCC0000, 2],
                                     [0xFFFF6666, 0xFFFF0000, 0xFFFFFFFF, 3, 0xFFFF0000, 2],
                                     [0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ButtonStyles["to_settings"] :=      [[0xFF171717, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
                                     [0xFF262626, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
                                     [0xFF2F2F2F, 0xFF1A1A1A, 0xFFFFFFFF, 0, 0xFF1A1A1A, 1],
                                     [0xFF626262, 0xFF474747, 0xFFFFFFFF, 0, 0xFF474747, 1]]

ButtonStyles["secondary"] :=        [[0xFF6C757D, 0xFF5A6268, 0xFFFFFFFF, 3, 0xFF5A6268, 1], 
                                     [0xFF5A6268, 0xFF4E555B, 0xFFFFFFFF, 3, 0xFF4E555B, 1], 
                                     [0xFF808B96, 0xFF6C757D, 0xFFFFFFFF, 3, 0xFF6C757D, 1], 
                                     [0xFFA0ACB8, 0xFF808B96, 0xFFFFFFFF, 3, 0xFF808B96, 1]] 

UseGDIP()
LogAdd("[status] Инициализация GDIP")

SettingsUI := GuiExt("", "AHK | Hospital v2 ")
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

SBT04 := SettingsUI.AddButton("xm+3 y308 w180 h36 0x100 vSBT04 x6","  " Chr(0xE10C) "   Информация")
SBT04.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT04, 0, ButtonStyles["tab"]*)

GitHubOpen(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM")
}
SBTB02 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB02 x6",  Chr(0xE1CF) ) ; github
SBTB02.OnEvent("Click", GitHubOpen)
CreateImageButton(SBTB02, 0, ButtonStyles["tab"]*)
ReloadFromUI(Element, *) {
    Reload()
}
SBTB03 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB03 x+6", Chr(0xE117) ) ; reload
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
SBTB04 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB04 x+6", Chr(0xE103) ) ; pause/play
SBTB04.OnEvent("Click", PlayPause)
CreateImageButton(SBTB04, 0, ButtonStyles["tab"]*)

OnOrOffHotKeys(onoroff) {
    SetHotKey(G_Binds[1], onoroff)
    SetHotKey(G_Binds[2], onoroff)
    SetHotKey(G_Binds[3], onoroff)
    ; SetHotKey(G_Binds[4], onoroff)
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
    SetHotKey(G_Binds[19], onoroff)
    SetHotKey(G_Binds[20], onoroff)
    SetHotKey(G_Binds[21], onoroff)
    SetHotKey(G_Binds[22], onoroff)
    SetHotKey(G_Binds[23], onoroff)
    SetHotKey(G_Binds[24], onoroff)
    SetHotKey(G_Binds[25], onoroff)
    SetHotKey(G_Binds[26], onoroff)
    SetHotKey(G_Binds[27], onoroff)
    SetHotKey(G_Binds[28], onoroff)
    SetHotKey(G_Binds[29], onoroff)
    SetHotKey(G_Binds[30], onoroff)
    SetHotKey(G_Binds[31], onoroff)
    SetHotKey(G_Binds[32], onoroff)
    SetHotKey(G_Binds[34], onoroff)
    SetHotKey(G_Binds[35], onoroff)
    SetHotKey(G_Binds[36], onoroff)
    SetHotKey(G_Binds[37], onoroff)
    SetHotKey(G_Binds[38], onoroff)
    SetHotKey(G_Binds[39], onoroff)
    SetHotKey(G_Binds[40], onoroff)
    SetHotKey(G_Binds[41], onoroff)
    SetHotKey(G_Binds[42], onoroff)
    SetHotKey(G_Binds[43], onoroff)
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

STB1 := SettingsUI.AddButton("x192 y6 w431 h1349 0x100 vSTB1 Disabled Hidden", "")
CreateImageButton(STB1, 0, ButtonStyles["fake_for_group"]*)


SettingsUI.SetFont("cWhite s" 13, Font)
SMP_GREETINGS := SettingsUI.AddText("x194 y44 w438 h30 +Center", "Привет, " UserName "!")

SettingsUI.SetFont("cGray s" 8, Font)
SMP_VERSION := SettingsUI.AddText("x338 y325", "AHK-FOR-RPM: v2.0" ' I ' "RP: v2.0.0")
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
    return StrReplace(StrReplace( ih.EndMods . ih.EndKey  , "<", ""), ">", "")
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
    RegWrite(save, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Binds")
}

CurrentBindsRecords := ""
BindHotkey(BtnObj){
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
    PathToFile := FileSelect("", "Hospital_cfg.txt", "Импорт файла конфигурации", "AHK_FOR_RPM Config file (*.txt*)")
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
    PathToFile := FileSelect("S", "Hospital_cfg.txt", "Сохранение файла конфигурации", "AHK_FOR_RPM Config file (*.txt*)")
    if PathToFile = ""{

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
    t := SettingsUI.AddButton("Hidden x198 y+3 w25 h25 vEBIND_" temp_for_bind_init " ",  Chr(0xE104))
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

SBP_Export := SettingsUI.AddButton("Hidden x359 h30 w155 y" SBP_Import.Y , Chr(0xE11C) "  Экспорт")
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
SSP_P2_UIMETHOD_BG := SettingsUI.AddButton("Hidden x420 y70 Disabled w203 h25 Left", "  ᐁ I "  UiMethodList[FocusMethod])
CreateImageButton(SSP_P2_UIMETHOD_BG, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P2_UIMETHOD := SettingsUI.AddDropDownList("Hidden x420 y70 w203 +0x4000000", UiMethodList)
SSP_P2_UIMETHOD.OnEvent("Change", DropDownListWorker )
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
        whr.Open("GET", "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/Hospital/version", true)
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
        RegWrite(SSP_P1_NAME.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Name")
        RegWrite(SSP_P1_ROLE.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Role")
        RegWrite(SSP_P1_USERNAME.Text, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "UserName")
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
        RegWrite(SSP_P2_UIMETHOD.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "focus_method")
        RegWrite(SSP_P2_ESCNEED.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_esc")
        RegWrite(SSP_P2_CHECKNEED.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_check")
        RegWrite(SSP_P2_LIMIT.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "before_limit")
        RegWrite(SSP_P2_STATUS.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "show_status")
        RegWrite(SSP_P2_UPDATE.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "update_check")
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
SettingsPage := [SSP_LABEL, SSP_PANEL_1, SSP_PANEL_2, SSP_PANEL_3, SSP_P1_NAME, SSP_P1_NAME_BG, SSP_P1_NAME_LABEL, SSP_P1_ROLE, SSP_P1_ROLE_BG, SSP_P1_ROLE_LABEL, SSP_P1_SAVEBUTTON, SSP_P1_USERNAME, SSP_P1_USERNAME_BG, SSP_P1_USERNAME_LABEL, SSP_P2_BEFORERP_LABEL, SSP_P2_CHECKNEED, SSP_P2_CHECKNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_ESCNEED, SSP_P2_ESCNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_LIMIT, SSP_P2_LIMIT_HELP, SSP_P2_LIMIT_TEXT, SSP_P2_STATUS, SSP_P2_STATUS_HELP, SSP_P2_STATUS_TEXT, SSP_P2_UIMETHOD, SSP_P2_UIMETHOD_BG, SSP_P2_UIMETHOD_LABEL, SSP_P2_UPDATE,SSP_P2_UPDATE_HELP, SSP_P2_UPDATE_TEXT, SSP_P3_BUTTON, SSP_P3_DESC, SSP_P3_STATS, SSP_P2_ESCNEED_TEXT, SSP_P2_OTHER]
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
    if WinExist("AHK | Hospital v2") {
        temp := true
    }
    MainBindUI.Hide()
    EducBindUI.Hide()
    RareBindUI.Hide()
    PMPBindUI.Hide()
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
greetings(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("Здравствуйте, чем я могу вам помочь? {ENTER}")
    Return
}
give_pill(Element?, *)
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
    SetMStatusBar(4)
    if ShowStatus
        ShowStatusBar()
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee осмотрел пациента, выявил проблему и приступил искать лекарство или таблетку в своей аптечке {Enter}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300)  ;
    SendInput(temp2 " {Enter}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee найдя нужное лекарство, достаёт и передает пациенту напротив, затем закрывает аптечку {Enter}")
    SetNStatusBar(3)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SetNStatusBar(4)
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
sell_pill(Element?, *)
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
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    list2 := ["красную аптечку", "аптечку с красным крестом", "аптечку"]
    temp3 := list2[r1]
    temp4 := "/mee открыв " . temp3 . " и найдя нужное лекарство передаёт человеку напротив, затем подписывает листок c датой выдачи и данными врача который его выдал"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput(temp2 " {Enter}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput(temp4 " {Enter}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med sell")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
bruise(Element?, *)
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
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput(temp2 " {Enter}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee открыв свою аптечку ищет и достаёт мазь, затем одевает на свои руки перчатки и осматривает место ушиба пациента {Enter}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee открыв крышку тюбика мази, и выдавив на перчатку немного мази начинает намазывать место ушиба пострадавшему, после этого берет бинт распаковав из пачки, забинтовывает место ушиба пациента {Enter}")
    SetNStatusBar(3)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
ammonia(Element?,*)
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
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee открывает аптечку и достает нашатырный спирт вместе с ваткой, затем открывает крышку банки и немного смочив ватку подносит её перед носом человека без сознания, ожидая когда он придет в себя {Enter}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee закрывает крышку банки и убирает нашатырь обратно в аптечку, продолжая наблюдать за состоянием пациента {ENTER}")
    SetNStatusBar(2)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/med heal  100")
    SetNStatusBar(3)
    Sleep(100) ;
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
inject(Element?, *)
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
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput(temp2 " {Enter}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee достает из аптечки шприц, спиртовую салфетку и бинт, протирает место для укола спиртовой салфеткой и начинает делать укол аккуратно вводя иглу в мышечную ткань{ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Инъекция была сделана{ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee прикладывая ватку на место укола вытаскивает иглу, убирает ватку и заклеивает место прокола кусочком пластыря {ENTER}")
    SetNStatusBar(4)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(100)
    SendInput("/med inject")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
med_card(Element?, *)
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
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee взяв паспорт из рук гражданина и держа его в руках, сверяет данные и проверяет фотографию {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee берёт чистую и незаполненную медкарту из аптечки и начинает заполнять по паспортным данным {ENTER}")
    SetNStatusBar(2)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/todo Заполнив мед. карту, ставит штамп и расписывается, а затем передает посетителю вместе с паспортом : проверяйте. {ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/n Смотреть свою медкарту командой /med card , там можно узнать о зависимостях, есть ли у вас переломы, ушибы, отравление и тд   {ENTER}")
    SetNStatusBar(4)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med givecard ")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
extract(Element?, *)
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
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee осмотрел пациента убедился что он в порядке, берёт незаполненную справку из сумки на плече и записывает данные человека на него, затем убирает справку в сумку {ENTER}")
    SetNStatusBar(1)
    Sleep(100) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SetNStatusBar(2)
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
medical_examination(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(7)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee сняв стетоскоп со своей шеи и приподняв рубашку человеку напротив, начинает прослушивать дыхание{ENTER}")
    SetNStatusBar(1)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee обойдя со спины продолжает прослушивать дыхание{ENTER}")
    SetNStatusBar(2)
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Опустив рубашку пациенту и повесив обратно стетоскоп себе на шею : Дыхание чистое.{ENTER}")
    SetNStatusBar(3)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do На плече висит медицинская сумка{ENTER}")
    SetNStatusBar(4)
    Sleep(4000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee достав тонометр из медицинской сумки и надев манжет на руку пациента выше локтя,  начинает накачивать воздух в манжет, измеряет давление смотря на манометр{ENTER}")
    SetNStatusBar(5)
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Измерив давление, снимая манжет с руки пациента : Давление в норме.{ENTER}")
    SetNStatusBar(6)
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Подписывает справку, передав человеку напротив : Вы прошли мед.осмотр, вы здоровы.{ENTER}")
    SetNStatusBar(7)
    Sleep(250)
    HideStatusBar()
    Return
}
prof_suitability(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(7)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee снимает стетоскоп со своей шеи, начинает проверять дыхание, затем берёт тонометр и измеряет давление {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/todo Убирая все на свое место : Дыхание и давление у вас в норме. {ENTER}")
    SetNStatusBar(2)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/mee достаёт из кармана халата фонарик и начинает поочерёдно светить в глаза, смотря на реакцию зрачка {ENTER}")
    SetNStatusBar(3)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/todo Выключив фонарик, возвращая его в карман медицинского халата : Всё в порядке. {ENTER}")
    SetNStatusBar(4)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/mee достав отоскоп из медицинской сумки, держит ухо пациента слегка натянутым, прислонив отоскоп в каждое ухо по очереди, осматривает слуховой аппарат {ENTER}")
    SetNStatusBar(5)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/todo Закончив осмотр слухового аппарата и спрятав отоскоп в медицинскую сумку : Слуховой аппарат в норме. {ENTER}")
    SetNStatusBar(6)
    Sleep(3000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/todo Выписывает справку, после чего передаёт человеку напротив : Вы здоровы и прошли осмотр на проф.пригодность. {ENTER}")
    SetNStatusBar(7)
    Sleep(250)
    HideStatusBar()
    Return
}

MainBindUI := GuiExt("", "AHK | Hospital v2 ")
MainBindUI.SetFont("cWhite s" FontSize - 1, Font)
MainBindUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

MainBindUI.AddText("w250 x5 +Center", "\^o^/")

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Приветствие")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", greetings)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Передать таблетку")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", give_pill)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Продать мед")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", sell_pill)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Ушиб")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", bruise)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Нашатырь")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", ammonia)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Инъекция")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", inject)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Мед. Карта")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", med_card)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Выписка из 6 палаты")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", extract)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Мед. Осмотр")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", medical_examination)

t := MainBindUI.AddButton("w250 h30 y+5 x5", "Проф. Пригодность")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", prof_suitability)



SetWindowAttribute(MainBindUI)
SetWindowColor(MainBindUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
mainbindsy := t.y + 35
; MainBindUI.Show("w260 h" mainbindsy)





knife(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(21)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me готовит операционную для извлечения ножа, раскладывая необходимые инструменты на стерильном столе {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}")
    SetNStatusBar(2)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}")
    SetNStatusBar(3)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}")
    SetNStatusBar(4)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me вводит местную анестезию вокруг раны {ENTER}")
    SetNStatusBar(5)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}")
    SetNStatusBar(6)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}")
    SetNStatusBar(7)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me делает аккуратный разрез вокруг ножевой раны, чтобы минимизировать повреждения при извлечении {ENTER}")
    SetNStatusBar(8)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Кожа вокруг раны обработана, разрез сделан для облегчения извлечения ножа {ENTER}")
    SetNStatusBar(9)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me осторожно захватывает нож за рукоятку и начинает аккуратно вытаскивать его {ENTER}")
    SetNStatusBar(10)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me извлекает нож, держа его за рукоятку, и кладет в металлический лоток {ENTER}")
    SetNStatusBar(11)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Нож успешно извлечен, рана открыта для обработки {ENTER}")
    SetNStatusBar(12)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов и тампонов {ENTER}")
    SetNStatusBar(13)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me проверяет, не повреждены ли внутренние органы или крупные сосуды, используя специальные инструменты {ENTER}")
    SetNStatusBar(14)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Внутренние органы и сосуды не повреждены, хирург продолжает обработку раны {ENTER}")
    SetNStatusBar(15)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me накладывает несколько швов, чтобы закрыть разрез и восстановить целостность тканей {ENTER}")
    SetNStatusBar(16)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Швы аккуратно наложены, рана закрыта {ENTER}")
    SetNStatusBar(17)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}")
    SetNStatusBar(18)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}")
    SetNStatusBar(19)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}")
    SetNStatusBar(20)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}")
    SetNStatusBar(21)
    Sleep(250)
    HideStatusBar()
    Return
}
peluvoe(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(20)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/me готовит операционную для извлечения пули, раскладывая необходимые инструменты на стерильном столе {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}")
    SetNStatusBar(2)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}")
    SetNStatusBar(3)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}")
    SetNStatusBar(4)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me вводит местную анестезию вокруг раны {ENTER}")
    SetNStatusBar(5)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}")
    SetNStatusBar(6)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}")
    SetNStatusBar(7)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me делает аккуратный разрез вокруг раны, чтобы расширить доступ к пуле {ENTER}")
    SetNStatusBar(8)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Рана слегка расширена, открывая доступ к пуле {ENTER}")
    SetNStatusBar(9)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me осторожно использует пинцет для захвата и извлечения пули {ENTER}")
    SetNStatusBar(10)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me извлекает пулю, держа её пинцетом, и помещает в металлический лоток {ENTER}")
    SetNStatusBar(11)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Пуля успешно извлечена, рана готова к обработке {ENTER}")
    SetNStatusBar(12)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов {ENTER}")
    SetNStatusBar(13)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me накладывает несколько швов, чтобы закрыть разрез {ENTER}")
    SetNStatusBar(14)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Швы аккуратно наложены, рана закрыта {ENTER}")
    SetNStatusBar(15)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}")
    SetNStatusBar(16)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}")
    SetNStatusBar(17)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}")
    SetNStatusBar(18)
    Sleep(4000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}")
    SetNStatusBar(19)
    Sleep(250)
    HideStatusBar()
    Return
}
stretcher(Element?, *)
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
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee осмотрел пострадавшего и убедившись что его можно перевозить, затем аккуратно укладывает его на носилки {ENTER}")
    SetNStatusBar(1)
    Sleep(300) ;
    SendInput("{t}")
    Sleep(100)
    SendInput("/do Пострадавший лежит на носилках {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
dropper(Element?, *)
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
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee ставит стойку для капельницы около кровати, проверяя устойчивая ли стойка для капельницы {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв нужный флакон лекарства, вставляет в стойку флакон лекарства {ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв жгут ставит его чуть выше изгиба руки пациенту, протирает место для укола спиртовой салфеткой и начинает вводить катетер в набухшую вену, одновременно снимая жгут{ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee берёт пластырь, отмотав 3 см отрывает кусок и закрепляет катетер пригладив пластырь к коже руки пациента{ENTER}")
    SetNStatusBar(4)
    Sleep(250)
    HideStatusBar()
    Return
}
defibrillator(Element?, *)
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
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee достает дефибриллятор и ставит рядом с пациентом на твердую и устойчивую поверхность{ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee оголив торс от одежды пациента берёт гель из своей аптечки, открыв крышку геля наносит его на правую ключицу, а также на левый бок под грудь{ENTER}")
    SetNStatusBar(2)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Взяв электроды кладет их на намазанные места гелем : Разряд! {ENTER}")
    SetNStatusBar(3)
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Подаётся напряжение, тело человека резко дернулось{ENTER}")
    SetNStatusBar(4)
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/try Пациент реанимирован?{ENTER}")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
twist(Element?, *)
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
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee резким движением взяв руку неадекватного пациента и скрутил за его спину повалив его прижав к поверхности, подставил свое колено к спине пациента зажимая его {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Пациенту трудно двигаться {ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee достает свободной рукой из кармана халата шприц с успокаивающим средством, снимая колпачок своими зубами и приспустив воздух вкалывает его в плечо пациента и убирает пустой шприц обратно в карман {ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do На пациента начинает действовать лекарство и он слабеет, успокаивается {ENTER}")
    SetNStatusBar(4)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee поднимает пациента придерживая его руку за спиной {ENTER}")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
calm(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee засунув руку в карман и нащупав шприц с успокаивающим, незаметно достает его и приоткрывает колпачок приспускает воздух из шприца слегка нажав, вкалывает в плечо пациента и приспускает медленно лекарство придерживая пациента {ENTER}")
    Return
}
plast_operation(Element?, *) {
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(13)
    if ShowStatus
        ShowStatusBar()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/me проверяет записи в мед.карте пациента, убеждаясь, что все необходимые анализы и согласия на операцию оформлены {ENTER}")
    SetNStatusBar(1)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me моет руки, надевает стерильные перчатки, затем проверяет готовность инструментов и материалов, после дезинфицирует операционное поле {ENTER}")
    SetNStatusBar(2)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Операционное поле дезинфицировано, все инструменты и материалы подготовлены {ENTER}")
    SetNStatusBar(3)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me размечает разметку на коже пациента, учитывая запланированную форму и размер {ENTER}")
    SetNStatusBar(4)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me готовит препараты для наркоза и проверяет оборудование для анестезии {ENTER}")
    SetNStatusBar(5)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Подготовительные работы завершены, пациент готов к операции {ENTER}")
    SetNStatusBar(6)
    Sleep(1000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("/me вводит анестезиологический препарат, ожидая пока пациент полностью уснёт под действием наркоза {ENTER}")
    SetNStatusBar(7)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me делает аккуратный разрез в области под грудью, следуя заранее разработанной разметки {ENTER}")
    SetNStatusBar(8)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me аккуратно проводит установку имплантов, заранее их стерилизовав, следя за симметрией и правильным положением {ENTER}")
    SetNStatusBar(9)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Импланты установлены, симметрия правильная, положение ровное {ENTER}")
    SetNStatusBar(10)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me накладывает швы на операционные разрезы {ENTER}")
    SetNStatusBar(11)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me проводит финальную дезинфекцию и накладывает стерильную повязку {ENTER}")
    SetNStatusBar(12)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Операция завершена, пациент постепенно выходит из наркоза {ENTER}")
    SetNStatusBar(13)
    Sleep(250)
    HideStatusBar()
}
blood(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(8)
    if ShowStatus
        ShowStatusBar()
    ErrorLevel := SendMessage(0x20, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee одевает перчатки и достаёт из медицинской сумки жгут{ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/todo Наложив жгут на середину плеча : Сжимайте и разжимайте кулак{ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Вена расширилась {ENTER}")
    SetNStatusBar(3)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Взяв иглу и распечатав из пачки, вводит её в вену пациента : Разжимайте кулак.{ENTER}")
    SetNStatusBar(4)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee подставив пробирку к игле и снимает жгут с руки пациента, набирает кровь медленно стекающую в пробирку{ENTER}")
    SetNStatusBar(5)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Необходимое количество крови набрано {ENTER}")
    SetNStatusBar(6)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/todo Извлекая иглу из вены и прикладывает чистую салфетку к руке пациента : Согните руку в суставе{ENTER}")
    SetNStatusBar(7)
    Sleep(2000) ;
    SendInput("{t}")
    Sleep(2000)
    SendInput("/todo Выкидывает использованную иглу в урну : Ожидайте анализов.{ENTER}")
    SetNStatusBar(8)
    Sleep(250)
    HideStatusBar()
    Return
}
wound(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(9)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee надевает стерильные перчатки и начинает осматривать рану у пациента{ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв шприц, распечатывает его из новой упаковки, затем берет ампулу, надламывает верхушку и сняв колпачок с иглы шприца набирает лекарство {ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee протерев спиртовой салфеткой место укола, вводит в мышечную ткань иглу, начинает медленно вводить лекарство{ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(4000)
    SendInput("/do Укол сделан{ENTER}")
    SetNStatusBar(4)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee вытаскивает иглу и выкидывает шприц в мусорку{ENTER}")
    SetNStatusBar(5)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв антисептик начинает обрабатывать рану, затем берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану{ENTER}")
    SetNStatusBar(6) 
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(4000)
    SendInput("/do Рана зашита{ENTER}")
    SetNStatusBar(7)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee отложив иглу с пинцетом, берет бинт начинает перебинтовывать рану{ENTER}")
    SetNStatusBar(8)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Рана перебинтована{ENTER}")
    SetNStatusBar(9)
    Sleep(250)
    HideStatusBar()
    Return
}
bullet(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(11)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee подготавливает инструменты и надевает стерильные перчатки {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв шприц с обезболивающим выпустив воздух из иглы начинает делать укол в районе огнестрела протерев место укола салфеткой {ENTER}")
    SetNStatusBar(2)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee сделав укол, выкидывает шприц в мусорку {ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee берёт скальпель начинает делать надрез {ENTER}")
    SetNStatusBar(4)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee отложив скальпель берет разжим и щипцы, начинает извлекать пулю разжав щипцами ткань {ENTER}")
    SetNStatusBar(5)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee вытащив пулю кладет ее на поднос {ENTER}")
    SetNStatusBar(6)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee обрабатывает рану спреем, подтирает капли вокруг раны стерильной салфеткой {ENTER}")
    SetNStatusBar(7)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану {ENTER}")
    SetNStatusBar(8) 
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв бинты начинает забинтовывать {ENTER}")
    SetNStatusBar(9)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/do Рана зашита. Бинты наложены {ENTER}")
    SetNStatusBar(10) 
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/todo Передавая пулю пациенту : Держите на память. {ENTER}")
    SetNStatusBar(11)
    Sleep(250)
    HideStatusBar()
    Return
}
close_fracture(Element?, *) 
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
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/todo Включив рентген и сняв снимки смотрит на них, затем ставит диагноз с дальнейшим исправлением : У вас закрытый перелом. {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee взяв шприц с обезболивающим и салфетку, протерев место укола, выпустив воздух из иглы, начинает делать укол в районе перелома, приложив после на пару секунд салфетку на место укола, затем принимается вправлять кость {ENTER}")
    SetNStatusBar(2)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/do Кость вправлена{ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee подготавливает гипсовый бинт, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома, подождав пару минут, проверяет подсыхание гипса, затем берёт бинт и начинает накладывать поверх гипса{ENTER}")
    SetNStatusBar(4)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/med heal  100")
    SetNStatusBar(5)
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
open_fracture(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(9)
    if ShowStatus
        ShowStatusBar()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/todo Включив рентген, смотрит на монитор и ставит диагноз с дальнейшим исправлением : У вас открытый перелом. {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee подготовив операционный стол и пациента, раскладывает нужные инструменты перед собой и одевает стерильные перчатки {ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee ставит катетер, присоединяет трубку с анестезией пациенту, ожидает когда на пациента подействует наркоз {ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee взяв антисептик, начинает обрабатывать рану, затем проводит манипуляции с восстановлением костной ткани {ENTER}")
    SetNStatusBar(4)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет, держа иглу, зашивает рану, после чего взяв бинты, начинает забинтовывать поврежденную конечность пациента {ENTER}")
    SetNStatusBar(5)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee начинает подготавливать гипсовый бинт, налив воды в тару, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома {ENTER}")
    SetNStatusBar(6)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/mee действие лекарства заканчивается и пока пациент приходит в себя, проверяет подсыхание гипса, затем берёт бинт и начинает обматывать гипс {ENTER}")
    SetNStatusBar(7)
    Sleep(4000) ;
    SendInput("{t}")
    Sleep(2000) ;
    SendInput("/mee закрепляет конец бинта и снимает катетер с уже закончившим наркозом, затем накладывает повязку {ENTER}")
    SetNStatusBar(8)
    Sleep(100) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SetNStatusBar(9)
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(250)
    HideStatusBar()
    Return
}
rengen(Element?, *)
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
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee включает рентген и нажимает кнопку пуска{ENTER}")
    SetNStatusBar(1)
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500)
    SendInput("/do Рентген аппарат включён, идет сканирование{ENTER}")
    SetNStatusBar(2)
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500)
    SendInput("/mee распечатывает снимок и взяв его из принтера поднеся к свету рассматривает снимок, ставит диагноз{ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
dislocation(Element?, *)
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
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee одевает перчатки, подготавливает салфетки и ампулу с обезболивающим, надломив ампулу и взяв шприц вскрытый из новой пачки, набирает обезболивающее из ампулы{ENTER}")
    SetNStatusBar(1)
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500)
    SendInput("/mee держа шприц с обезболивающим выпустив воздух из иглы начинает делать укол протерев место укола салфеткой{ENTER}")
    SetNStatusBar(2)
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500)
    SendInput("/mee взяв конечность пациента начинает потихоньку натягивать на себя и вправляет сустав в нужную сторону{ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
slrt(Element?, *) {
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(9)
    if ShowStatus
        ShowStatusBar()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee осматривает пострадавшего, замечая остановку дыхания и отсутствия пульса приложив пальцы к шее лежащего {ENTER}")
    SetNStatusBar(1)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee открывает аптечку и достает стерильные перчатки, начинает одевать на свои руки {ENTER}")
    SetNStatusBar(2)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв фонарик из аптечки и приоткрыв рот потерпевшему осматривает ротовую полость на инородные предметы {ENTER}")
    SetNStatusBar(3)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee выключает фонарик и убирает обратно в аптечку, прихватив из аптечки ручной ИВЛ положив рядом{ENTER}")
    SetNStatusBar(4)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee поставив ладони на вытянутых руках, строго вертикально на груди пострадавшего начинает проводить технику непрямого массажа сердца{ENTER}")
    SetNStatusBar(5)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee поочередно надавливая на грудь, после возвращения в исходное положение 30 надавливаний {ENTER}")
    SetNStatusBar(6)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв ручной ИВЛ лежащий рядом, прикладывает маску на рот пострадавшего, тем самым приготовив для искусственного дыхания {ENTER}")
    SetNStatusBar(7)
    Sleep(4000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee придерживая маску начинает сжимать мешок рукой запуская воздух в легкие пострадавшего {ENTER}")
    SetNStatusBar(8)
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee контролируя пульс на сонной артерии и реакцию зрачков на свет приоткрывая веко пострадавшему продолжает делать массаж сердца до появления слабого пульса {ENTER}")
    SetNStatusBar(9)
    Sleep(250)
    HideStatusBar()
    Return
}
ekgg(Element?, *) {
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    SetMStatusBar(2)
    if ShowStatus
        ShowStatusBar()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/mee подготовив пациента, оголив ему грудь от одежды, включает аппарат ЭКГ, затем взяв гель начинает наносить на грудь пациенту и устанавливает присоски {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee распечатывает данные, одной рукой берет край распечатки и изучает сердцебиение {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}

RareBindUI := GuiExt("", "AHK | Hospital v2 ")
RareBindUI.SetFont("cWhite s" FontSize - 1, Font)
RareBindUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

t := RareBindUI.AddButton("w123 h30 y+5 x5", "Ножевое")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", knife)

t := RareBindUI.AddButton("w123 h30 y" t.Y " x133", "Пулевое")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", peluvoe)

t := RareBindUI.AddButton("w123 h30 y+5 x5", "Носилки")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", stretcher)

t := RareBindUI.AddButton("w123 h30 y" t.Y " x133", "Капельница")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", dropper)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Дефибриллятор")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", defibrillator)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Скрутить + успокаивающий укол")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", twist)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Успокаивающий укол")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", calm)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Пластическая операция")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", plast_operation)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Взятие крови на анализ (в пробирку)")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", blood)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Обработать и зашить рану")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", wound)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Операция по извлечению пули")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", bullet)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Закрытый перелом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", close_fracture)

t := RareBindUI.AddButton("w250 h30 y+5 x5", "Открытый перелом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", open_fracture)

t := RareBindUI.AddButton("w123 h30 y+5 x5", "Рентген")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", rengen)

t := RareBindUI.AddButton("w123 h30 y" t.Y " x133", "Вывих")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", dislocation)

t := RareBindUI.AddButton("w123 h30 y+5 x5", "СЛР")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", slrt)

t := RareBindUI.AddButton("w123 h30 y" t.Y " x133", "ЭКГ")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", ekgg)




SetWindowAttribute(RareBindUI)
SetWindowColor(RareBindUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
rarebindy := t.y + 35
; RareBindUI.Show("w260 h" rarebindy)




lecture(Element?, *)
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
    SendInput("Гиппократ – великий древнегреческий врач и философ, вошедший в историю как “отец медицины”. Его медицинские трактаты оказали огромное влияние на медицинскую науку и практику. В биографии Гиппократа есть немало ярких и  трагических моментов, которые  {ENTER}")
    SetNStatusBar(1)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("способствовали развитию его дарования. Гиппократ был первым врачом, отвергшим теорию о том, что болезни на человека насылают боги. Благодаря ему медицина была выделена в отдельную науку. По мнению великого врача, болезнь является следствием влияния  {ENTER}")
    SetNStatusBar(2)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("характера человека, его питания, привычек, а также природных факторов. Гиппократ принадлежал к Косской школе врачей. Ее представители стремились отыскать первопричину патологии.  {ENTER}")
    SetNStatusBar(3)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("Для этого за больными организовывалось наблюдение. Врачи создавали специальный режим, способствующий самоизлечению. В это время был “рожден” один из важнейших принципов великого врача – “Не навреди”.  {ENTER}")
    SetNStatusBar(4)
    Sleep(800) ;
    SendInput("{е}")
    Sleep(800) ;
    SendInput("Вы прослушали лекцию.  {ENTER}")
    SetNStatusBar(5)
    Sleep(250)
    HideStatusBar()
    Return
}
regulation1(Element?, *)
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
    SendInput("Вы готовы сдать тест по уставу?  {ENTER}")
    Return
}
regulation2(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    list := ["3.5", "2.12", "3.7", "2.18", "2.19", "1.2", "2.7", "1.4", "2.9", "2.4", "1.3", "2.16", "2.17", "3.3", "2.13", "3.6", "2.5", "2.8", "4.2", "4.1", "2.10", "2.15", "1.1", "2.2", "2.20", "2.6", "3.6.1", "2.11", "3.1", "3.9", "2.14", "3.8", "4.0", "2.3", "2.1", "3.2", "3.4"]
    Loop
    {
        r1 := Random(1, 37)
        r2 := Random(1, 37)
        r3 := Random(1, 37)
    } Until (r1 != r2) && (r1 != r3) && (r2 != r3)
    item1 := list[r1]
    item2 := list[r2]
    item3 := list[r3]
    sentence := "Сначала устав, " . item1 . ", " . item2 . " и " . item3 . "."
    SendInput("{е}")
    Sleep(100) ;
    SendInput(sentence " {ENTER}")
}
regulation3(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    list := ["ГКБ", "НРС", "СЛР", "МЗ", "ПМП", "СПИД", "АИК", "ЧМТ", "ИМ", "ДС", "НИВЛ", "ЭКГ", "УЗИ", "ВИЧ", "ТТЖ", "ОЧМТ", "МРТ", "ЛФК", "МП", "КТГ", "ИВЛ", "ЖКТ", "СМП", "ПП"]
    Loop
    {
        r1 := Random(1, 24)
        r2 := Random(1, 24)
        r3 := Random(1, 24)
    } Until (r1 != r2) && (r1 != r3) && (r2 != r3)
    item1 := list[r1]
    item2 := list[r2]
    item3 := list[r3]
    sentence := "Теперь расшифровки, " . item1 . ", " . item2 . " и " . item3 . "."
    SendInput("{е}")
    Sleep(100) ;
    SendInput(sentence " {ENTER}")
}
regulation4(Element?, *)
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
    SendInput("Вы сдали тест на Устав и термины Больницы. {ENTER}")
    Return
}
oath_start(Element?, *)
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
    SendInput("Вы готовы дать клятву Гиппократа? {ENTER}")
    Return
}
oath(Element?, *)
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
    SendInput("Вы дали клятву Гиппократа. {ENTER}")
    Return
}
assingments(Element?, *)
{
    hide_ui()
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }
    list := ["разложи медикаменты по ящикам в архиве", "помой стенки лифта", "протри листики деревьев на 1 этаже", "поменяй постельное белье на кроватях в 6 палате", "покорми рыбок на -1 этаже", "поправь одеяла и подушку в 6 палате", "протри раковины в туалете", "подмети дорожку у входа в больницу", "заправь кровати в палате номер 6", "полей цветы в горшках в холле", "помой стойку регистратуры", "протри пыль на полках регистратуры", "помой полы в архиве", "поправь стулья в зале собраний", "пребири и поправь папки в архиве", "помой окна на 1 этаже", "поправь книги на полках в комнате отдыха", "помой полы на 1 этаже", "помой пол в лифте"]
    Loop
    {
        r1 := Random(1, 19)
        r2 := Random(1, 19)
        r3 := Random(1, 19)
    } Until (r1 != r2) && (r1 != r3) && (r2 != r3)
    item1 := list[r1]
    item2 := list[r2]
    item3 := list[r3]
    sentence := "Интерн, " . item1 . ", " . item2 . " и " . item3 . "."
    SendInput("{е}")
    Sleep(100) ;
    SendInput(sentence " {ENTER}")
}
practice(Element?, *)
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
    Sleep(100) ;
    SendInput("/do Манекен лежит в шкафу {ENTER}")
    SetNStatusBar(1)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/me достал манекен из шкафа и затем положил на кушетку  {ENTER}")
    SetNStatusBar(2)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("У него закрытый перелом, приступай.  {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
practice2(Element?, *)
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
    SendInput("Вы сдали практику на парамедика. {ENTER}")
    Return
}


EducBindUI := GuiExt("", "AHK | Hospital v2 ")
EducBindUI.SetFont("cWhite s" FontSize - 1, Font)
EducBindUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

EducBindUI.AddText("w250 x5 +Center", "\(ᵔ•ᵔ)/")

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Лекция интерну")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", lecture)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Устав [1/4] | `"Вы готовы?`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", regulation1)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Устав [3/4] | `"3 устава`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", regulation2)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Устав [3/4] | `"3 термина`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", regulation3)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Устав [4/4] | `"Вы сдали.`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", regulation4)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Клятва [1/2] | `"Вы готовы?`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", oath_start)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Клятва [2/2] | `"Вы дали...`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", oath)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Поручения | 3 поручения (авто)")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", assingments)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Практика [1/2] | Отыгровки")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", practice)

t := EducBindUI.AddButton("w250 h30 y+5 x5", "Практика [2/2] | `"Вы сдали`"")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", practice2)

SetWindowAttribute(EducBindUI)
SetWindowColor(EducBindUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
educbindy := t.y + 35
; EducBindUI.Show("w260 h" educbindy)



open_settings_ui(Element? , *) {
    SettingsUI.Show("h350 w640")
}
open_pmp_window(Element?, *) {
    pmpbindy := t.Y + 35
    PMPBindUI.Show("w260 h" pmpbindy)
}


MenuUI := GuiExt("", "AHK | Hospital v2 ")
MenuUI.SetFont("cWhite s" FontSize - 1, Font)
MenuUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

MenuUI.AddText("w250 x5 +Center", "(. ❛ ᴗ ❛.)")

t := MenuUI.AddButton("w250 h30 y+5 x5", "открыть меню")
CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
t.OnEvent("Click", open_settings_ui)

t := MenuUI.AddButton("w250 h30 y+5 x5", "пмп")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", open_pmp_window)

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





pmp1_(Element?, *)
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
    Sleep(100) ;
    SendInput("/todo Внимательно осматривая пациента и обнаруживая вывих в области сустава : У вас вывих сустава, сейчас вам помогу. {ENTER}")
    SetNStatusBar(1)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee надевает перчатки, выдавливает небольшое кол-во Лидокаина на ватный диск и начинает промазывать им нужное место для купирования боли {ENTER}")
    SetNStatusBar(2)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee аккуратно устанавливает поврежденный сустав в нормальное положение, применяя мягкий тягостойкий бандаж {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp2_(Element?, *)
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
    SendInput("/mee быстро берет из аптечки шину, бинты и накладывает ее с двух боковых сторон от конечности, дабы иммобилизовать ее, после чего обматывает бинтами {ENTER}")
    Return
}
pmp3_(Element?, *)
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
    SendInput("/mee открывает аптечку и достает от туда жгут, после чего накладывает его на место выше места кровотечения, после же берет из аптечки шину, бинты и накладывает ее в места, где не выступают кости и обматывает бинтами {ENTER}")
    Return
}
pmp15_(Element?, *)
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
    Sleep(100) ;
    SendInput("/mee ставит и открывает аптечку рядом с собой, осматривает ранение пострадавшего, разрывает чуть одежду в районе огнестрела, ставит жгут, взяв из аптечки антисептик, обрабатывает свои руки и одевает перчатки {ENTER}")
    SetNStatusBar(1)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee распечатывает из пачки антисептическую салфетку, взяв шприц с обезболивающим и выпустив воздух из иглы протирает салфеткой место укола и вводит иглу с обезболивающим в районе огнестрела {ENTER}")
    SetNStatusBar(2)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(4000) ;
    SendInput("/mee осматривает рану на наличие пули и глубины раны, берет из аптечки запечатанную салфетку гемостатик, открывает ее и начинает делать тампонаду раны, останавливая кровотечение, затем берет бинт из аптечки и начинает накладывать тугую повязку {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp17_(Element?, *)
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
    SendInput("/mee быстра надев перчатки и маску достал из аптечки все нужное для укола и резким, а также точным движением ввел шприц в мышечную ткань пациента, рядом с местом ранения и надавил на конец шприца для введения препарата внутрь человека {ENTER}")
    SetNStatusBar(1)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee взяв ватку смочил ее антисептическим веществом и прошелся им по краю раны, для обработки ранения {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp18_(Element?, *)
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
    SendInput("/mee быстра надев перчатки и маску достал из аптечки слабый раствор антисептика и прошелся им по месту ранения, а после бинтами замотал рану в несколько слоев {ENTER}")
    Sleep(100) ;
    Return
}
pmp25_(Element?, *)
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
    SendInput("/me пальцем надавливает на место кровотечения, после другой рукой берет жгут и накладывает его выше ранения, помечая время, после берет стерильную марлевую повязку и тампонирует ее, если есть возможность сжать конечность пациенту, то делает это {ENTER}")
    Sleep(100) ;
    Return
}
pmp39_(Element?, *)
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
    Sleep(100) ;
    SendInput("/mee достает из кармана халата фонарик, включает его и проверяет глазное яблоко на чувствительность к свету {ENTER}")
    SetNStatusBar(1)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/try Пациент реагирует на свет фонарика? {ENTER}")
    SetNStatusBar(2)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/mee достал из аптечки нашатырный спирт и ватку, промочил небольшим кол-вом спирта ватку и принялся водить перед носом пациента {ENTER}")
    SetNStatusBar(3)
    Sleep(1000) ;
    SendInput("{е}")
    Sleep(1000) ;
    SendInput("/mee подложил под голову пациента небольшую подушку {ENTER}")
    SetNStatusBar(4)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp40_(Element?, *)
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
    Sleep(100) ;
    SendInput("/mee поставил мед.аптечку на землю, открыл ее и достал от туда Нитроглицерин, после же передал пациенту {ENTER}")
    SetNStatusBar(1)
    Sleep(100) ;
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Возьмите эту таблетку под язык {ENTER}")
    SetNStatusBar(2)
    Sleep(100) ;
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/do Через несколько минут таблетка подействовала и расширила артерии и снизила давление пациенту {ENTER}")
    SetNStatusBar(3)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp41_(Element?, *)
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
    SendInput("/mee рассмотрел крепление ремня или галстука и помог пациенту ослабить их натяжение {ENTER}")
    SetNStatusBar(1)
    Sleep(100) ;
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/do После действий мед.работника к пациенту пошел поток свежего воздуха {ENTER}")
    SetNStatusBar(2)
    Sleep(250)
    HideStatusBar()
    Return
}
pmp44_(Element?, *)
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
    Sleep(100) ;
    SendInput("/mee присев к пациенту поставив аптечку рядом поворачивает его на правый бок взявшись за левую руку и левую ногу согнув при этом на 90 градусов и подкладывает его руку ему под голову, проверяет стопор колена и правильного положения пациента {ENTER}")
    SetNStatusBar(1)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee открыв аптечку берет стерильные перчатки и одевает на свои руки, опрашивает прохожих и фиксирует с их слов время начала приступа {ENTER}")
    SetNStatusBar(2)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/mee достает из аптечки шприц с лекарством, сняв колпачок с иглы и приспустив штаны человеку сделала укол в ягодичную мышцу {ENTER}")
    SetNStatusBar(3)
    Sleep(700) ;
    SendInput("{е}")
    Sleep(700) ;
    SendInput("/do Ожидает прохождения эпилептического шока, наблюдает состояние здоровья пациента {ENTER}")
    SetNStatusBar(4)
    Sleep(250)
    HideStatusBar()
    Return
}



PMPBindUI := GuiExt("", "AHK | Hospital v2 ")
PMPBindUI.SetFont("cWhite s" FontSize - 1, Font)
PMPBindUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

PMPBindUI.AddText("w250 x5 +Center", "пмп")

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Вывих")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp1_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Закрытый перелом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp2_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Открытый перелом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp3_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Пулевое ранение")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp15_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Ножевое с ножом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp17_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Ножевое без ножом")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp18_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Кровотечение: Артериальное")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp25_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Сотрясение мозга: проверка")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp39_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Сердечный приступ")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp40_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Сердечный приступ (рубашка, ремень)")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp41_)

t := PMPBindUI.AddButton("w250 h30 y+5 x5", "Эпилепсия")
CreateImageButton(t, 0, ButtonStyles["binds"]*)
t.OnEvent("Click", pmp44_)

SetWindowAttribute(PMPBindUI)
SetWindowColor(PMPBindUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
pmpbindy := t.Y + 35
; PMPBindUI.Show("w260 h" pmpbindy)


MainBindUIopen(Element?, *){
    MainBindUI.Show("w260 h" mainbindsy)
}
EducBindUIopen(Element?, *) {
    EducBindUI.Show("w260 h" educbindy)
}
RareBindUIopen(Element?, *) {
    RareBindUI.Show("w260 h" rarebindy)
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
SetHotKey(G_Binds[2], EducBindUIopen)
SetHotKey(G_Binds[3], RareBindUIopen)
SetHotKey(G_Binds[4], MenuUIopen)
SetHotKey(G_Binds[5], ReloadFromUI)

SetHotKey(G_Binds[6], greetings)
SetHotKey(G_Binds[7], give_pill)
SetHotKey(G_Binds[8], sell_pill)
SetHotKey(G_Binds[9], bruise)
SetHotKey(G_Binds[10], ammonia)
SetHotKey(G_Binds[11], inject)
SetHotKey(G_Binds[12], med_card)
SetHotKey(G_Binds[13], extract)
SetHotKey(G_Binds[14], medical_examination)
SetHotKey(G_Binds[15], prof_suitability)
SetHotKey(G_Binds[16], knife)
SetHotKey(G_Binds[17], peluvoe)
SetHotKey(G_Binds[18], stretcher)
SetHotKey(G_Binds[19], dropper)
SetHotKey(G_Binds[20], defibrillator)
SetHotKey(G_Binds[21], twist)
SetHotKey(G_Binds[22], calm)
SetHotKey(G_Binds[23], plast_operation)
SetHotKey(G_Binds[24], blood)
SetHotKey(G_Binds[25], wound)
SetHotKey(G_Binds[26], bullet)
SetHotKey(G_Binds[27], close_fracture)
SetHotKey(G_Binds[28], open_fracture)
SetHotKey(G_Binds[29], rengen)
SetHotKey(G_Binds[30], dislocation)
SetHotKey(G_Binds[31], slrt)
SetHotKey(G_Binds[32], ekgg)
SetHotKey(G_Binds[34], lecture)
SetHotKey(G_Binds[35], regulation1)
SetHotKey(G_Binds[36], regulation2)
SetHotKey(G_Binds[37], regulation3)
SetHotKey(G_Binds[38], regulation4)
SetHotKey(G_Binds[39], oath_start)
SetHotKey(G_Binds[40], oath)
SetHotKey(G_Binds[41], assingments)
SetHotKey(G_Binds[42], practice)
SetHotKey(G_Binds[43], practice2)


if BeforeLimit {
    A_HotkeyInterval := 1000
    A_MaxHotkeysPerInterval := 1
}

if (VerCompare(A_OSVersion, "10.0.22200") < 0) {
    LogSent("[WinCheck] [Info] Версия Windows ниже 10.0.22200: -ColorWindow")
    LogSent("[WinCheck] [Info] Вы можете игнорировать ошибку -> ColorWindow")
}


; made with ❤️  by Agzes!