; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |              AHK-FOR-RPM              |
; |           AFR v2  | by Agzes          |
; |         https://e-z.bio/agzes         |
; \_______________________________________/

Init() ; AFR v.2.2 

; /  AFR VERSION 2.2 | CONFIG (test cfg (for run) )

; Переменные
AHK_version := "1.0" ; Версия АХК
code_version := 1 ; Кодовая версия (Для работы авто-обновлений)
Font := "Segoe UI" ; Шрифт программы (не рекомендуется к изменению)
FontSize := 11 ; Размер шрифта (для корректного отображения собственного шрифта)
ConfigPath := "HKEY_CURRENT_USER\Software\Author\AFR\Custom" ; Основной путь для настроек
RevName := "Hospital" ; Название ревизии (Организация)
BindsBGHeight := 400 ; Высота фона в Конфигураторе биндов

; Конфиг отыгровок/биндов/окон и прочего
global GBinds := Map()
global GBinds_cfg := Map()
global GBindsAction_cfg := Map()

; i["Name"] := [Bind, Description]
InitGBinds(i) {
    i["ForceStop"] := ['Insert', "[ForceStop] - Остановка отыгровок"]
    i["UI_Main"] := ['F4', "[UI] Основное"]
    i["UI_Menu"] := ['F9', "[UI] Меню"]
    i["Restart"] := ['F10', "Перезагрузка"]
    i["Greetings"] := ['!q', "Приветствие"]
    i["ID"] := ['!f', "Удостоверение"]
}

; i["Name"] := [Value]
InitGBindsCfg(i) {
    i["Global_Bool"] := true
    i["Global_Number"] := 111
}

; RpSetUIGen(RpSetUI, "Тип [CheckBox/Input]", "Название", "НазваниеПараметра", "Описание")
InitGBindsCfgUI() {
    RpSetUIGen(RpSetUI, "CheckBox", "Галочка", "Global_Bool", "Описание галочки")
    RpSetUIGen(RpSetUI, "Input", "Текст (число)", "Global_Number", "Описание текста")
}

; i["НазОтыгровки"] := ["НазваниеБинда", "Тип [RPAction/Func]", "[["Chat", "...", S100, S300]] {если тип - RPAction} или function {если тип - Func}"]
InitRPActions(i) {
    i["Greetings"] := ["Greetings", "Func", greetings]
    i["ID"] := ["ID", "RPAction", ["Chat", "...", S100, S300]]
}

GBindsSortedArrayForSet := ["ForceStop", "UI_Main", "UI_Menu", "Restart", "Greetings", "ID"] ; Отсортированный список для конфигуратора биндов
GBindsSortedArray := ["Greetings", "ID"] ; Список для биндов

; ["Тип окна [Custom]", "НазваниеОкна", "Label в окне", "НазваниеБинда", ["Элементы"...]]
GWindows := [
    ["Custom", "Main", "\^o^/", "UI_Main", ["Greetings", "ID"]],
]

; ["Тип [AFR/SYS]", "Название Настройки [Menu, ForceStop / Restart]", "НазваниеБинда"]
G_AFRSettings := [
    ["AFR", "Menu", "UI_Menu"],
    ["AFR", "ForceStop", "ForceStop"],
    ["SYS", "Restart", "Restart"],
]

greetings(Element?, *) {
    gt := "Здравствуйте, чем я могу вам помочь? {ENTER}"

    RPAction([
        ["Chat", gt, S100, S100]
    ])
}

; \ AFR VERSION 2.2 | CONFIG

; <--------------->
;       LIBS 
; <--------------->

#Include %A_ScriptDir%\..\!Libs\!CreateImageButton.ahk
#Include %A_ScriptDir%\..\!Libs\!WinDarkUI.ahk
#Include %A_ScriptDir%\..\!Libs\!GuiEnchancerKit.ahk
#Include %A_ScriptDir%\..\!Libs\!ScroolBar.ahk
#Include %A_ScriptDir%\..\!Libs\!DarkStyleMsgBox.ahk
#Include %A_ScriptDir%\..\!Libs\!JXON.ahk 

; AFR v.2.2 CODE PART (Не изменяйте для корректной работы конфига) 
{

global logs := []
#Requires AutoHotkey v2.0 
#SingleInstance Force
#DllLoad "Gdiplus.dll"

LogAdd("[status] Инициализация")

ButtonStyles := Map()
ButtonStyles["tab"] := [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF626262, 0xFF474747, 0xFFFFFFFF, 3, 0xFF474747, 2]]
ButtonStyles["fake_for_group"] := [[0xFF171717, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF171717, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]
ButtonStyles["fake_for_hotkey"] := [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF262626, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF2F2F2F, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]
ButtonStyles["binds"] := [[0xFF191919, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2], [0xFF262626, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2], [0xFF2F2F2F, 0xFF181818, 0xFFBEBEBE, 5, 0xFF191919, 2], [0xFF626262, 0xFF474747, 0xFFBEBEBE, 5, 0xFF191919, 2]]
ButtonStyles["reset"] := [[0xFF1b1b1b, 0xFF202020, 0xFFFFFFFF, 3, 0xFF202020, 2], [0xFFFF4444, 0xFFCC0000, 0xFFFFFFFF, 3, 0xFFCC0000, 2], [0xFFFF6666, 0xFFFF0000, 0xFFFFFFFF, 3, 0xFFFF0000, 2], [0xFF1b1b1b, 0xFF474747, 0xFFFFFFFF, 3, 0xFF202020, 2]]

ForceStopRP := False
IsOldItemIsInput := False
ScrollActive := false 
CurrentBindsRecords := "" 
CurrentPage := "SBT01"
HotKeyStatus := true 
AFR_Version := "2.2"
global G_BindsFunc := Map()
global G_WindowData := Map()
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 50
global SBMaximum := 0
global SBMaximumForOne := 0
global CurrentProgress := 0
InitGBinds(GBinds)
InitGBindsCfg(GBinds_cfg)
global G_Binds := GBinds
global G_Binds_cfg := GBinds_cfg
InitRPActions(GBindsAction_cfg)
try {
    global G_Binds
    LogAdd("[info] получение файлов конфига `"Binds`" ")
    T_Temp := RegRead(ConfigPath, "Binds")
    T_Data := Jxon_Load(&T_Temp)
    LogAdd("[info] `"Binds`" найдено")
    for key, value in T_Data {
        G_Binds[key] := value
    }
    LogAdd("[info] `"Binds`" загружено")
}
try {
    global G_Binds_cfg
    LogAdd("[info] получение файлов конфига `"BindsCFG`" ")
    T_Temp := RegRead(ConfigPath, "BindsCFG")
    T_Data := Jxon_Load(&T_Temp)
    LogAdd("[info] `"BindsCFG`" найдено")
    for key, value in T_Data {
        G_Binds_cfg[key] := value
    }
    LogAdd("[info] `"BindsCFG`" загружено")
}
global FocusMethod := LoadConfig("focus_method", 1)
global BeforeEsc := LoadConfig("before_esc", 1)
global BeforeCheck := LoadConfig("before_check", 0)
global BeforeLimit := LoadConfig("before_limit", 0)
global ShowStatus := LoadConfig("show_status", 1)
global UpdateCheck := LoadConfig("update_check", 1)
InitBeforeCFGInit() {
    global S100 := LoadConfig("S100", 100)
    global S250 := LoadConfig("S250", 250)
    global S300 := LoadConfig("S300", 300)
    global S500 := LoadConfig("S500", 500)
    global S700 := LoadConfig("S700", 700)
    global S800 := LoadConfig("S800", 800)
    global S1000 := LoadConfig("S1000", 1000)
    global S2000 := LoadConfig("S2000", 2000)
    global S3000 := LoadConfig("S3000", 3000)
    global S4000 := LoadConfig("S4000", 4000)
}
Init() {
    InitBeforeCFGInit()
    global UserName := LoadConfig("UserName", "User")
    global Role := LoadConfig("Role", "")
    global Name := LoadConfig("Name", "")
}
StatusUI := GuiExt("+AlwaysOnTop -Caption", "AHK | Status")
StatusUI.BackColor := "0"
WinSetTransColor(0, StatusUI.Hwnd)
ProgressBar := StatusUI.AddProgress("w300 h32 x0 y0 Background171717 c019C9A")
ProgressBar.Value := 0
ProgressBar.SetRounded(6)
InitFuncAndHotKeyForAFR() {
    for i in GBindsAction_cfg {
        FName := GBindsAction_cfg[i][1]
        FType := GBindsAction_cfg[i][2]
        FData := GBindsAction_cfg[i][3]

        if (FType == "Func") {
            G_BindsFunc[FName] := [FData]
        } else if (FType == "RPAction") {
            G_BindsFunc[FName] := [CreateRPActionFunction(FData)]
        }
    }
}
CreateRPActionFunction(DataToUse) {
    return (Element?, *) => RPAction(DataToUse)
}
InitWindowForAFR() {
    for i in GWindows {
        WType := i[1]
        WName := i[2]
        WEmoj := i[3]
        WBind := i[4]
        WElem := i[5]

        ui := AutoCreateUI(WEmoj)
        for i in WElem { 
            AutoAddButton(ui, G_Binds[GBindsAction_cfg[i][1]][2], G_BindsFunc[GBindsAction_cfg[i][1]][1], "full")
            
        }
        uiy := AutoInitUI(ui)

        G_WindowData[WName] := [ui, uiy]

        try { 
            SetHotKey(G_Binds[WBind][1], CreateWindowFunction(WName))
        }  catch {
            MsgBox("Кажется произошла ошибка :( `n Не удалось назначить бинд для открытия окна!")
        }
    }
}
CreateWindowFunction(WName) {
    return (Element?, *) => G_WindowData[WName][1].Show("w260 h" G_WindowData[WName][2])
}
InitBindsForAFR() {
    for i in G_AFRSettings {
        SType := i[1]
        SNeed := i[2]
        SBind := i[3]
        
        if (SType == "AFR") {
            if (SNeed == "Menu") {
                SetHotKey(G_Binds[SBind][1], open_settings_ui)
            } else if (SNeed == "ForceStop") {
                SetHotKey(G_Binds[SBind][1], ForceStop)
            }
        } else if (SType == "SYS") {
            if (SNeed == "Restart") {
                SetHotKey(G_Binds[SBind][1], ReloadFromUI)
            }
        }
    }
    for i in GBindsSortedArray {
        try {
            TName := i
            TBind := G_Binds[TName][1]
            TActi := G_BindsFunc[TName][1]
            SetHotKey(TBind, TActi)
        }  catch {
            LogSent("Note | Бинд: " i  " не имеет действие ")
        }
    }
}
lastRandom := 0
RandomNew(min, max) {
    global lastRandom := Random(min,max)
    return lastRandom
}
RandomLast() {
    return lastRandom
}
SaveBindsCFG() {
    RegWrite(Jxon_Dump(G_Binds_cfg), "REG_SZ", ConfigPath, "BindsCFG")
}
LogAdd(Text) {
    logs.Push(Text)
}
LoadConfig(configName, basic) {
    try {
        LogAdd("[info] получение файлов конфига `" " configName " `" ")
        local value := RegRead(ConfigPath, configName)
        LogAdd("[info] `" " configName " `" найдено")
        return value
    } 
    return basic
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
    } else if Page == "SBT05" {
        return AutoChatPage
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
SaveBindCfg() {
    RegWrite(Jxon_Dump(G_Binds), "REG_SZ", ConfigPath, "Binds")
}
BindHotkey(BtnObj) {
    global CurrentBindsRecords
    BtnObj.Text := Chr(0xE15B)
    CreateImageButton(BtnObj, 0, ButtonStyles["fake_for_hotkey"]*)
    CurrentBindsRecords := BtnObj.Hwnd
    tbind := WaitForBind()
    if tbind != "" {
        tt := StrReplace(BtnObj.Name, "EBIND_", "")
        G_Binds[GBindsSortedArrayForSet[tt]][1] := tbind
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
    G_Binds[GBindsSortedArrayForSet[StrReplace(CtrlElement.Name, "BIND_", "")]][1] := HotkeyToBind(CtrlElement.Text)
    SaveBindCfg()
}
UpdateBindsInConfigurator(Element?, *){
    for i, x in GBindsSortedArrayForSet {
        temp1 := GuiCtrlFromHwnd(BindHwnd[i])
        temp2 := G_Binds[x][1]
        temp1.Text := BindToHotkey(temp2)
    }
}
ImportBinds(Element, *) {
    LogSent("[info] [bind-sys] [import] > start")
    PathToFile := FileSelect("", RevName "_cfg.json", "Импорт файла конфигурации", "AHK_FOR_RPM Config file (*.json*)")
    if !FileExist(PathToFile)
        MsgBox("Файл конфигурации не найден!")
    else {
        CfgDatas := FileRead(PathToFile, "UTF-8")
        global G_Binds := Jxon_Load(&CfgDatas)
        UpdateBindsInConfigurator()
        SaveBindCfg()
        LogSent("[info] [bind-sys] [import] > импортировано")
        MsgBox("Файл конфигурации загружен!`nПерезапустите программу для применения")
    }
}
ExportBinds(Element, *) {
    export := Jxon_Dump(G_Binds, 0)
    PathToFile := FileSelect("S", RevName "_cfg.json", "Сохранение файла конфигурации", "AHK_FOR_RPM Config file (*.json*)")
    if PathToFile != "" {
        if FileExist(PathToFile) {
            Result := MsgBox("Файл уже существует! `nПерезаписать? (это удалит его содержимое)", "Warning" , "YesNo")
            if Result = "Yes"
            {
                FileDelete(PathToFile)
                FileAppend(export, PathToFile, "UTF-8")
                MsgBox("Файл был экспортирован")
            }
            else
                MsgBox("Файл не был изменён.")
        } else {
            FileAppend(export, PathToFile)
            MsgBox("Файл был экспортирован")
        }
    }
}
ResetBinds(Element, *) {
    InitGbinds(G_Binds)
    SaveBindCfg()
    UpdateBindsInConfigurator()
}
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
        whr.Open("GET", "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/" RevName "/version", true)
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
            UpdateUI.Show("w260 h " UpdateUIy)
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
        RegWrite(SSP_P1_NAME.Text, "REG_SZ", ConfigPath, "Name")
        RegWrite(SSP_P1_ROLE.Text, "REG_SZ", ConfigPath, "Role")
        RegWrite(SSP_P1_USERNAME.Text, "REG_SZ", ConfigPath, "UserName")
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
        RegWrite(SSP_P2_UIMETHOD.Value, "REG_SZ", ConfigPath, "focus_method")
        RegWrite(SSP_P2_ESCNEED.Value, "REG_SZ", ConfigPath, "before_esc")
        RegWrite(SSP_P2_CHECKNEED.Value, "REG_SZ", ConfigPath, "before_check")
        RegWrite(SSP_P2_LIMIT.Value, "REG_SZ", ConfigPath, "before_limit")
        RegWrite(SSP_P2_STATUS.Value, "REG_SZ", ConfigPath, "show_status")
        RegWrite(SSP_P2_UPDATE.Value, "REG_SZ", ConfigPath, "update_check")
        MsgBox("Данные успешно сохранены!`nПерезапустите для применения")
    } catch Error as e {
        MsgBox("Ошибка при сохранении!")
    }
}
S100_Warning(Element, *) {
    MsgBox("Это поле не рекомендуется к изменению!`nИспользуется в: Первых отыгровках, Кд перед командой`nПо умолчанию -> 100")
}
S250_Warning(Element, *) {
    MsgBox("Это поле не рекомендуется к изменению!`nИспользуется в: Кд перед удалением окна Статуса (после всех отыгровок)`nПо умолчанию -> 250")
}
S300_Warning(Element, *) {
    MsgBox("Используется в: Мелких отыгровок`nПо умолчанию -> 300")
}
S500_Warning(Element, *) {
    MsgBox("Используется в: Мелких отыгровок`nПо умолчанию -> 500")
}
S700_Warning(Element, *) {
    MsgBox("Используется в: Коротких отыгровок с большим количетсвом фраз`nПо умолчанию -> 700")
}
S800_Warning(Element, *) {
    MsgBox("Используется в: Коротких отыгровок с большим количетсвом фраз`nПо умолчанию -> 800")
}
S1000_Warning(Element, *) {
    MsgBox("Используется во: Многих отыгровок`nПо умолчанию -> 1000")
}
S2000_Warning(Element, *) {
    MsgBox("Используется в: Средних отыгровок`nПо умолчанию -> 2000")
}
S3000_Warning(Element, *) {
    MsgBox("Используется в: Больших отыгровок`nПо умолчанию -> 3000")
}
S4000_Warning(Element, *) {
    MsgBox("Используется в: Больших отыгровок`nПо умолчанию -> 4000")
}
x100MultiplierClick(Element, *) {
    MultiplierClick(1)
}
x125MultiplierClick(Element, *) {
    MultiplierClick(1.25)
}
x150MultiplierClick(Element, *) {
    MultiplierClick(1.5)
}
x175MultiplierClick(Element, *) {
    MultiplierClick(1.75)
}
x200MultiplierClick(Element, *) {
    MultiplierClick(2)
}
MultiplierClick(multiplier) {
    global S100, S250, S300, S700, S1000, S2000, S3000, S4000

    S300 := Round(300 * multiplier)
    S500 := Round(500 * multiplier)
    S700 := Round(700 * multiplier)
    S800 := Round(800 * multiplier)
    S1000 := Round(1000 * multiplier)
    S2000 := Round(2000 * multiplier)
    S3000 := Round(3000 * multiplier)
    S4000 := Round(4000 * multiplier)

    S300_Input.Text := S300
    S500_Input.Text := S500
    S700_Input.Text := S700
    S800_Input.Text := S800
    S1000_Input.Text := S1000
    S2000_Input.Text := S2000
    S3000_Input.Text := S3000
    S4000_Input.Text := S4000

}
SaveTimeSettings(Element, *) {
    global S100, S250, S300, S500, S700, S800, S1000, S2000, S3000, S4000

    S100 := S100_Input.Text
    S250 := S250_Input.Text
    S300 := S300_Input.Text
    S500 := S500_Input.Text
    S700 := S700_Input.Text
    S800 := S800_Input.Text
    S1000 := S1000_Input.Text
    S2000 := S2000_Input.Text
    S3000 := S3000_Input.Text
    S4000 := S4000_Input.Text

    LogSent("[SaveTimeSettings] -> Попытка сохранения")
    try {
        RegWrite(S100, "REG_SZ", ConfigPath, "S100")
        RegWrite(S250, "REG_SZ", ConfigPath, "S250")
        RegWrite(S300, "REG_SZ", ConfigPath, "S300")
        RegWrite(S500, "REG_SZ", ConfigPath, "S500")
        RegWrite(S700, "REG_SZ", ConfigPath, "S700")
        RegWrite(S800, "REG_SZ", ConfigPath, "S800")
        RegWrite(S1000, "REG_SZ", ConfigPath, "S1000")
        RegWrite(S2000, "REG_SZ", ConfigPath, "S2000")
        RegWrite(S3000, "REG_SZ", ConfigPath, "S3000")
        RegWrite(S4000, "REG_SZ", ConfigPath, "S4000")
        MsgBox("Настройки времени сохранены!`nПерезапустите для применения")
        LogSent("[SaveTimeSettings] -> Сохранено")
    } catch Error as e {
        MsgBox("Ошибка при сохранении настроек!")
        LogSent("[SaveTimeSettings] -> Error")
    }
}
ShowStatusBar(Element?, *) {
    if ShowStatus {
        StatusUI.Show("w300 h32 NA")
        Sleep(S100)
        screenWidth := A_ScreenWidth
        x := (screenWidth - StatusUI.W) / 2
        StatusUI.Move(x, 2)
    }
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
GitHubOpen(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM")
}
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
ReloadFromUI(Element, *) {
    Reload()
}
OnOrOffHotKeys(onoroff) {
    for i, x in GBindsSortedArrayForSet {
        SetHotKey(G_Binds[x][1], onoroff)
    }
    SetHotKey(G_Binds["UI_Menu"][1], "on")
}
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
SleepTimeMenu(Element, *) {
    TimeSetUI.Show("w260 h454")
}
RPSettings(Element, *) {
    RpSetUI.Show("w260 h450")
}
ToDev(Element, *) {
    Run("https://e-z.bio/agzes")
}
ToMessage(Element, *) {
    Run("https://discord.com/users/695827097024856124")
}
ToGitHub(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM")
}
isScrollBarActive() {
    if WinActive(SettingsUI) {
        if ScrollActive {
            return true
        }
    }
    return false
}
SetHotKey(key, function) {
    if key != "" {
        HotKey(key, function)
    }
}
OnCloseMenu(Element?, *) {
    TrayTip("`nДля полного закрытия: `nПКМ по иконке в трей -> кнопка `"Exit`"", "Программа свёрнута в трей")
    SettingsUI.OnEvent("Close", OnCloseMenu, 0)
}
RpSetUIGen(Ui, Type, Label, Value, Desc) {
    global IsOldItemIsInput
    ts(Element?, *) {
        G_Binds_cfg[Value] := Element.Value
        SaveBindsCFG()
    }
    tf(Element?, *) {
        MsgBox(Desc)
    }
    if Type == "CheckBox" {
        if IsOldItemIsInput {
            t := 12
            IsOldItemIsInput := False
        } else
            t := 10
        t := ui.AddButton("w250 h29 y+" t " x5 Disabled",)
        CreateImageButton(t, 0, ButtonStyles["fake_for_group"]*)
        t := ui.AddText("x30 y" t.Y + 5, Label)
        t1 := SysGet(SM_CXMENUCHECK := 71)
        t2 := SysGet(SM_CYMENUCHECK := 72)
        t := ui.AddCheckBox("x13 y" t.Y + 2 " Checked h" t1 " w" t2)
        t.value := G_Binds_cfg[Value]
        t.OnEvent("Click", ts)
        t := Ui.AddButton("x232 y" t.Y - 1 " h17 w17", "?")
        t.OnEvent("Click", tf)
        CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)

    } else if Type == "Input" {
        if IsOldItemIsInput {
            t := 12
            IsOldItemIsInput := False
        } else
            t := 10
        t := ui.AddButton("w250 h54 y+" t  " x5 Disabled",)
        CreateImageButton(t, 0, ButtonStyles["fake_for_group"]*)
        t := ui.AddText("x13 y" t.Y + 5, Label)
        t1 := SysGet(SM_CXMENUCHECK := 71)
        t2 := SysGet(SM_CYMENUCHECK := 72)
        t := Ui.AddButton("x232 y" t.Y  " h17 w17", "?")
        t.OnEvent("Click", tf)
        CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
        t := ui.AddButton("x10 y" t.Y + 21 " h23 w239 Disabled",)
        CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
        t := Ui.AddEdit("x10 y" t.Y + 0 " h20 w239", G_Binds_cfg[Value])
        t.OnEvent("Change", ts)
        t.SetRounded(3)

        IsOldItemIsInput := True
    } 

}
LogAdd("[status] Инициализация интерфейса")
LogAdd("[status] Инициализация GDIP")
UseGDIP()
SettingsUI := GuiExt("", "!AHK | " RevName " v2 ")
SettingsUI.SetFont("cWhite s" FontSize, Font)
SettingsUI.BackColor := 0x171717
SettingsUI.OnEvent('Size', UpdateScrollBars.Bind(SettingsUI))
CreateImageButton("SetDefGuiColor", 0x171717)
SBT01 := SettingsUI.AddButton("xm+3 y+6 w180 h36 0x100 vSBT01 x6", "  " Chr(0xE10F) "   Главная")
SBT01.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT01, 0, ButtonStyles["tab"]*)
AddFixedElement(SBT01)
SBT02 := SettingsUI.AddButton("xm+3 y+4 w180 h36 0x100 vSBT02 x6", "  " Chr(0xE138) "   Бинды")
SBT02.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT02, 0, ButtonStyles["tab"]*)
AddFixedElement(SBT02)
SBT03 := SettingsUI.AddButton("xm+3 y+4 w180 h36 0x100 vSBT03 x6", "  " Chr(0xE115) "   Параметры")
SBT03.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT03, 0, ButtonStyles["tab"]*)
AddFixedElement(SBT03)
SBT05 := SettingsUI.AddButton("xm+3 y+4 w180 h36 0x100 vSBT05 x6", "  " Chr(0xE122) "   AutoChat*")
SBT05.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT05, 0, ButtonStyles["tab"]*)
AddFixedElement(SBT05)
SBT04 := SettingsUI.AddButton("xm+3 y308 w180 h36 0x100 vSBT04 x6", "  " Chr(0xE10C) "   Информация")
SBT04.OnEvent("Click", SettingsTabSelect)
CreateImageButton(SBT04, 0, ButtonStyles["tab"]*)
AddFixedElement(SBT04)
SBTB02 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB02 x6", Chr(0xE1CF)) ; github
SBTB02.OnEvent("Click", GitHubOpen)
CreateImageButton(SBTB02, 0, ButtonStyles["tab"]*)
AddFixedElement(SBTB02)
SBTB03 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB03 x+6", Chr(0xE117)) ; reload
SBTB03.OnEvent("Click", ReloadFromUI)
CreateImageButton(SBTB03, 0, ButtonStyles["tab"]*)
AddFixedElement(SBTB03)
SBTB04 := SettingsUI.AddButton("xm+3 y268 w56 h36 0x100 Center vSBTB04 x+6", Chr(0xE103)) ; pause/play
SBTB04.OnEvent("Click", PlayPause)
CreateImageButton(SBTB04, 0, ButtonStyles["tab"]*)
AddFixedElement(SBTB04)
STB := SettingsUI.AddButton("x192 y6 w442 h338 0x100 vSTB Disabled", "")
CreateImageButton(STB, 0, ButtonStyles["fake_for_group"]*)
STB1 := SettingsUI.AddButton("x192 y6 w431 h" BindsBGHeight " 0x100 vSTB1 Disabled Hidden", "") ; Binds background
CreateImageButton(STB1, 0, ButtonStyles["fake_for_group"]*)
SettingsUI.SetFont("cWhite s" 13, Font)
SMP_GREETINGS := SettingsUI.AddText("x194 y44 w438 h30 +Center", "Привет, " UserName "!")
SettingsUI.SetFont("cGray s" 8, Font)
SMP_VERSION := SettingsUI.AddText("x338 y325", "AHK-FOR-RPM: v" AFR_Version ' I ' "RP: v" AHK_version)
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
SMP_LOGS := SettingsUI.AddListView("x198 y104 w452 h240", [""])
SMP_LOGS.SetRounded(3)
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "                                      AHK_FOR_RPM V2")
SMP_LOGS.add("", "                                             by Agzes")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "                             вы можете закрывать это окно")
SMP_LOGS.add("", "                              (программа свернётся в трей)")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "                                 ⬇️ пролистать для логов ⬇️")
SMP_LOGS.add("", "")
SMP_LOGS.add("", "")
for i in logs {
    SMP_LOGS.add("", i)
}
LogSent("[info] Загрузка конфигуратора биндов")
SBP_LABEL := SettingsUI.AddText("Hidden x194 y13 w420 h20 +Center", Chr(0xE138) " Конфигуратор Биндов")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
BindItems := []
BindHwnd := []
for i, x in GBindsSortedArrayForSet {
    if G_Binds.Has(x)
        T_B_Data := G_Binds[x]
    else
        G_Binds.DeleteProp(x)
    t := SettingsUI.AddButton("Hidden x198 y+3 w25 h25 vEBIND_" i " ", Chr(0xE104))
    t.OnEvent("Click", BindHotkeyButton)
    CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
    BindItems.Push(t.Hwnd)
    t := SettingsUI.AddButton("Hidden x226 y" t.Y " w116 h25 Disabled")
    CreateImageButton(t, 0, ButtonStyles["fake_for_hotkey"]*)
    BindItems.Push(t.Hwnd)
    t := SettingsUI.AddEdit("Hidden x226 y" t.Y " w116 h25 vBIND_" i " ", "")
    BindHwnd.Push(t.Hwnd)
    BindItems.Push(t.Hwnd)
    t.OnEvent("Change", BindHotkeyInput)
    t.OnEvent("Focus", HideCode)
    t.OnEvent("LoseFocus", ShowCode)
    t.SetRounded(7)
    t.Value := BindToHotkey(T_B_Data[1])
    t := SettingsUI.AddButton("Hidden Left w272 h25 x345 Disabled y" t.Y " vTBIND_" i " ", "  " T_B_Data[2])
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
SSP_P3_STATS := SettingsUI.AddText("Hidden x287 y255", Chr(0xE10C) "")
SettingsUI.SetFont("cWhite s" FontSize - 3, Font)
SSP_P3_DESC := SettingsUI.AddText("Hidden x231 y278 w130 Center", "\(ᵔ•ᵔ)/")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
SSP_P3_BUTTON := SettingsUI.AddButton("Hidden x216 y295", "Проверить обновления")
SSP_P3_BUTTON.OnEvent("Click", CheckForUpdate)
CreateImageButton(SSP_P3_BUTTON, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P4_BUTTON := SettingsUI.AddButton("Hidden x436 y258 w170", Chr(0xE115) " задержка")
SSP_P4_BUTTON.OnEvent("Click", SleepTimeMenu)
CreateImageButton(SSP_P4_BUTTON, 0, ButtonStyles["fake_for_hotkey"]*)
SSP_P5_BUTTON := SettingsUI.AddButton("Hidden x436 y293 w170", Chr(0xE115) " отыгровки")
SSP_P5_BUTTON.OnEvent("Click", RPSettings)
CreateImageButton(SSP_P5_BUTTON, 0, ButtonStyles["fake_for_hotkey"]*)
TimeSetUI := GuiExt("", "!AHK | " RevName " v2 ")
TimeSetUI.SetFont("cWhite s" FontSize - 1, Font)
TimeSetUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)
TimeSetUI.AddText("w250 x5 +Center", "(╯▽╰)")
TimeSetUI.SetFont("cWhite s" FontSize - 2, Font)
S100_250_Label := TimeSetUI.AddText("x5 y+5", "[!] S100-250 ↴")
TimeSetUI.SetFont("cWhite s" FontSize - 1, Font)
S100_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S100_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S100_Input := TimeSetUI.AddEdit("x5 y" S100_BG.Y " w220", S100)
S100_Input.SetRounded(3)
S100_Help := TimeSetUI.AddButton("x230 y" S100_BG.Y " h25 w25", "?")
S100_Help.OnEvent("Click", S100_Warning)
CreateImageButton(S100_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S250_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S250_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S250_Input := TimeSetUI.AddEdit("x5 y" S250_BG.Y " w220", S250)
S250_Input.SetRounded(3)
S250_Help := TimeSetUI.AddButton("x230 y" S250_BG.Y " h25 w25", "?")
S250_Help.OnEvent("Click", S250_Warning)
CreateImageButton(S250_Help, 0, ButtonStyles["fake_for_hotkey"]*)
TimeSetUI.SetFont("cWhite s" FontSize - 2, Font)
S300_800_Label := TimeSetUI.AddText("x5 y+5", "S300-800 ↴")
TimeSetUI.SetFont("cWhite s" FontSize - 1, Font)
S300_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S300_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S300_Input := TimeSetUI.AddEdit("x5 y" S300_BG.Y " w220", S300)
S300_Input.SetRounded(3)
S300_Help := TimeSetUI.AddButton("x230 y" S300_BG.Y " h25 w25", "?")
S300_Help.OnEvent("Click", S300_Warning)
CreateImageButton(S300_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S500_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S500_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S500_Input := TimeSetUI.AddEdit("x5 y" S500_BG.Y " w220", S500)
S500_Input.SetRounded(3)
S500_Help := TimeSetUI.AddButton("x230 y" S500_BG.Y " h25 w25", "?")
S500_Help.OnEvent("Click", S500_Warning)
CreateImageButton(S500_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S700_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S700_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S700_Input := TimeSetUI.AddEdit("x5 y" S700_BG.Y " w220", S700)
S700_Input.SetRounded(3)
S700_Help := TimeSetUI.AddButton("x230 y" S700_BG.Y " h25 w25", "?")
S700_Help.OnEvent("Click", S700_Warning)
CreateImageButton(S700_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S800_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S800_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S800_Input := TimeSetUI.AddEdit("x5 y" S800_BG.Y " w220", S800)
S800_Input.SetRounded(3)
S800_Help := TimeSetUI.AddButton("x230 y" S800_BG.Y " h25 w25", "?")
S800_Help.OnEvent("Click", S800_Warning)
CreateImageButton(S800_Help, 0, ButtonStyles["fake_for_hotkey"]*)
TimeSetUI.SetFont("cWhite s" FontSize - 2, Font)
S1000_4000_Label := TimeSetUI.AddText("x5 y+5", "S1000-4000 ↴")
TimeSetUI.SetFont("cWhite s" FontSize - 1, Font)
S1000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S1000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S1000_Input := TimeSetUI.AddEdit("x5 y" S1000_BG.Y " w220", S1000)
S1000_Input.SetRounded(3)
S1000_Help := TimeSetUI.AddButton("x230 y" S1000_BG.Y " h25 w25", "?")
S1000_Help.OnEvent("Click", S1000_Warning)
CreateImageButton(S1000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S2000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S2000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S2000_Input := TimeSetUI.AddEdit("x5 y" S2000_BG.Y " w220", S2000)
S2000_Input.SetRounded(3)
S2000_Help := TimeSetUI.AddButton("x230 y" S2000_BG.Y " h25 w25", "?")
S2000_Help.OnEvent("Click", S2000_Warning)
CreateImageButton(S2000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S3000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S3000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S3000_Input := TimeSetUI.AddEdit("x5 y" S3000_BG.Y " w220", S3000)
S3000_Input.SetRounded(3)
S3000_Help := TimeSetUI.AddButton("x230 y" S3000_BG.Y " h25 w25", "?")
S3000_Help.OnEvent("Click", S3000_Warning)
CreateImageButton(S3000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
S4000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
CreateImageButton(S4000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
S4000_Input := TimeSetUI.AddEdit("x5 y" S4000_BG.Y " w220", S4000)
S4000_Input.SetRounded(3)
S4000_Help := TimeSetUI.AddButton("x230 y" S4000_BG.Y " h25 w25", "?")
S4000_Help.OnEvent("Click", S4000_Warning)
CreateImageButton(S4000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
TimeSetUI.SetFont("cWhite s" FontSize - 1, Font)
x1_Button := TimeSetUI.AddButton("x5 y+5 w50 h25", "x1")
x1_Button.OnEvent("Click", x100MultiplierClick)
CreateImageButton(x1_Button, 0, ButtonStyles["fake_for_hotkey"]*)
x125_Button := TimeSetUI.AddButton("x+5 y" x1_Button.y " w45 h25", "x1.25")
x125_Button.OnEvent("Click", x125MultiplierClick)
CreateImageButton(x125_Button, 0, ButtonStyles["fake_for_hotkey"]*)
x15_Button := TimeSetUI.AddButton("x+5 y" x1_Button.y " w45 h25", "x1.5")
x15_Button.OnEvent("Click", x150MultiplierClick)
CreateImageButton(x15_Button, 0, ButtonStyles["fake_for_hotkey"]*)
x175_Button := TimeSetUI.AddButton("x+5 y" x1_Button.y " w45 h25", "x1.75")
x175_Button.OnEvent("Click", x175MultiplierClick)
CreateImageButton(x175_Button, 0, ButtonStyles["fake_for_hotkey"]*)
x2_Button := TimeSetUI.AddButton("x+5 y" x1_Button.y " w45 h25", "x2")
x2_Button.OnEvent("Click", x200MultiplierClick)
CreateImageButton(x2_Button, 0, ButtonStyles["fake_for_hotkey"]*)
SaveButton := TimeSetUI.AddButton("x5 y+5 w250 h30", "Сохранить настройки")
SaveButton.OnEvent("Click", SaveTimeSettings)
CreateImageButton(SaveButton, 0, ButtonStyles["fake_for_hotkey"]*)
SetWindowAttribute(TimeSetUI)
SetWindowTheme(TimeSetUI)
SetWindowColor(TimeSetUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)

RpSetUI := GuiExt("", "!AHK | " RevName " v2 ")
RpSetUI.SetFont("cWhite s" FontSize - 1, Font)
RpSetUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

RpSetUI.AddText("w250 x5 +Center", "( °o° )")
RpSetUI.AddText("w250 x5 +Center", "настройки сохраняются автоматически")
InitGBindsCfgUI()

SetWindowTheme(RpSetUI)
SetWindowAttribute(RpSetUI)
SetWindowColor(RpSetUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)

ToCredits(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM/blob/main/CREDITS.md")
}

SettingsUI.SetFont("cWhite s" FontSize + 8, Font)
SOP_LABEL := SettingsUI.AddText("Hidden x203 y114 w200 h30 ", "AHK-FOR-RPM")
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
SOP_LABEL2 := SettingsUI.AddText("Hidden x203 y144 w200 h30 ", "AFR EDITION | V2 by Agzes")
SOP_DEV := SettingsUI.AddButton("Hidden x198 h30 w155 y308 ", Chr(0xE13D) "  Разработчик")
CreateImageButton(SOP_DEV, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_DEV.OnEvent("Click", ToDev)
SOP_CONTACT := SettingsUI.AddButton("Hidden x359 h30 w155 y308 ", Chr(0xE136) "  Связаться")
CreateImageButton(SOP_CONTACT, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_CONTACT.OnEvent("Click", ToMessage)
SOP_GITHUB := SettingsUI.AddButton("Hidden x520 h30 w107 y308 ", Chr(0xE136) "  GitHub")
CreateImageButton(SOP_GITHUB, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_GITHUB.OnEvent("Click", ToGitHub)
SOP_CREDITS := SettingsUI.AddButton("Hidden x568 h23 w60 y12 ", "credits")
CreateImageButton(SOP_CREDITS, 0, ButtonStyles["fake_for_hotkey"]*)
SOP_CREDITS.OnEvent("Click", ToCredits)

AutoChatParser() {
    text := StrReplace(INPUT.Value, "AutoChat - функция позволяющая автоматически отправлять отыгровки без* вероятности кика с сервера. *функция в разработке, кикнуть может.  `n`nАвтоматически переходит к окну Minecraft. `nАвтоматически разделяет текст больше 255 символов на 2+ отправки. `nАвтоматически подбирает кд для отыгровок. `n!Автоматически убирает все ``  `nДля разделения отыгровок пропускайте строку.  `n`nПример: `n", "")

    text := StrReplace(text, "``", "")
    lines := StrSplit(text, "`n")


    finalLines := []
    limit := 255

    for index, line in lines {
        if (line = "") {
            continue
        }

        if (StrLen(line) <= limit) {
            finalLines.Push(line)
        } else {
            while (StrLen(line) > limit) {
                pos := limit
                foundSpace := false
                Loop limit {
                    ch := SubStr(line, pos, 1)
                    if (ch = " ") {
                        foundSpace := true
                        break
                    }
                    pos--
                }
                if (foundSpace and pos > 1) {
                    chunk := Trim(SubStr(line, 1, pos - 1))
                    finalLines.Push(chunk)
                    line := Trim(SubStr(line, pos + 1))
                } else {
                    chunk := SubStr(line, 1, limit)
                    finalLines.Push(chunk)
                    line := SubStr(line, limit + 1)
                }
            }
            if (StrLen(line) > 0) {
                finalLines.Push(line)
            }
        }
    }
    finalSendArray := []
    for index, line in finalLines {
        if (line = "")
            continue
        finalSendArray.Push(["AutoChat", line " {ENTER}"])
    }
    return finalSendArray
}

STB1012 := SettingsUI.AddButton("x198 y13 w430 h290 0x100 Disabled Hidden", "")
CreateImageButton(STB1012, 0, ButtonStyles["fake_for_group"]*)

SettingsUI.SetFont("cWhite s" FontSize - 2, Font)
INPUT := SettingsUI.AddEdit("x198 y13 w447 h290 Hidden", 
"AutoChat - функция позволяющая автоматически отправлять отыгровки без* вероятности кика с сервера. *функция в разработке, кикнуть может.  `n`nАвтоматически переходит к окну Minecraft. `nАвтоматически разделяет текст больше 255 символов на 2+ отправки. `nАвтоматически подбирает кд для отыгровок. `n!Автоматически убирает все ``  `nДля разделения отыгровок пропускайте строку.  `n`nПример: `n/me взял книгу с полки`n/do Книга в руках`n/me подошёл к столу и положил книгу`n/do Книга на столе")
INPUT.SetRounded(7)
SettingsUI.SetFont("cWhite s" FontSize - 1, Font)
Clear(*) {
    INPUT.Value := ""
}
HideHelp(*) {
    INPUT.Value := StrReplace(INPUT.Value, "AutoChat - функция позволяющая автоматически отправлять отыгровки без* вероятности кика с сервера. *функция в разработке, кикнуть может.  `n`nАвтоматически переходит к окну Minecraft. `nАвтоматически разделяет текст больше 255 символов на 2+ отправки. `nАвтоматически подбирает кд для отыгровок. `n!Автоматически убирает все ``  `nДля разделения отыгровок пропускайте строку.  `n`nПример: `n/me взял книгу с полки`n/do Книга в руках`n/me подошёл к столу и положил книгу`n/do Книга на столе", "")
}
INPUT.OnEvent("Focus", HideHelp)
ClearButton := SettingsUI.AddButton("x198 y308 w120 h30 Hidden ", "очистить")
ClearButton.OnEvent("Click", Clear)
CreateImageButton(ClearButton, 0, ButtonStyles["reset"]*)

CounterText := SettingsUI.AddText("x318 y318 w185 +Center Hidden", "0 / 0 RP")
UpdateCounter(*) {
    text := StrReplace(INPUT.Value, "AutoChat - функция позволяющая автоматически отправлять отыгровки без* вероятности кика с сервера. *функция в разработке, кикнуть может.  `n`nАвтоматически переходит к окну Minecraft. `nАвтоматически разделяет текст больше 255 символов на 2+ отправки. `nАвтоматически подбирает кд для отыгровок. `n!Автоматически убирает все ``  `nДля разделения отыгровок пропускайте строку.  `n`nПример: `n", "")
    chars := StrLen(text)

    CounterText.Value := "CH " chars " / " AutoChatParser().Length " RP"
}

INPUT.OnEvent("Change", UpdateCounter)

AutoChatStart := false
StartSendChat(Element?, *) {
    global AutoChatStart := true
    RPAction(AutoChatParser())
}

SendButton := SettingsUI.AddButton("x508 y308 w120 h30 Hidden", "Начать >")
SendButton.OnEvent("Click", StartSendChat)
CreateImageButton(SendButton, 0, ButtonStyles["fake_for_hotkey"]*)

LogSent("[status] Интерфейс инициализирован")
LogSent("[info] запускаю дополнительные скрипты интерфейса")

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
SettingsPage := [SSP_LABEL, SSP_PANEL_1, SSP_PANEL_2, SSP_PANEL_3, SSP_P1_NAME, SSP_P1_NAME_BG, SSP_P1_NAME_LABEL, SSP_P1_ROLE, SSP_P1_ROLE_BG, SSP_P1_ROLE_LABEL, SSP_P1_SAVEBUTTON, SSP_P1_USERNAME, SSP_P1_USERNAME_BG, SSP_P1_USERNAME_LABEL, SSP_P2_BEFORERP_LABEL, SSP_P2_CHECKNEED, SSP_P2_CHECKNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_ESCNEED, SSP_P2_ESCNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_LIMIT, SSP_P2_LIMIT_HELP, SSP_P2_LIMIT_TEXT, SSP_P2_STATUS, SSP_P2_STATUS_HELP, SSP_P2_STATUS_TEXT, SSP_P2_UIMETHOD, SSP_P2_UIMETHOD_BG, SSP_P2_UIMETHOD_LABEL, SSP_P2_UPDATE, SSP_P2_UPDATE_HELP, SSP_P2_UPDATE_TEXT, SSP_P3_BUTTON, SSP_P3_DESC, SSP_P3_STATS, SSP_P2_ESCNEED_TEXT, SSP_P2_OTHER, SSP_P4_BUTTON, SSP_P5_BUTTON]
AutoChatPage := [STB1012, INPUT, ClearButton, SendButton, CounterText]
OtherPage := [SOP_CONTACT, SOP_DEV, SOP_GITHUB, SOP_LABEL, SOP_LABEL2, SOP_CREDITS]

LogSent("[info] применяю атрибуты и тему для окна")
SetWindowAttribute(SettingsUI)
SetWindowTheme(SettingsUI)
SetWindowColor(SettingsUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
LogSent("[info] показываю интерфейс")
SettingsUI.OnEvent("Close", OnCloseMenu)
SettingsUI.Show("h350 w640")
RemoveScrollBar(SettingsUI)

temp_for_size := 0
AutoCreateUI(emoji?) {
    t := GuiExt("", "AHK ! " RevName " v2 ")
    t.SetFont("cWhite s" FontSize - 1, Font)
    t.BackColor := 0x171717
    CreateImageButton("SetDefGuiColor", 0x171717)
    if emoji != "None"
        t.AddText("w250 x5 +Center", emoji)
    return t
}
AutoInitUI(ui) {
    SetWindowAttribute(ui)
    SetWindowColor(ui.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)
    return size := t.y + 35
}
AutoAddButton(ui, label, function, size) {
    global temp_for_size, t
    if size = "full" {
        t := ui.AddButton("w250 h30 y+5 x5", label)
        CreateImageButton(t, 0, ButtonStyles["binds"]*)
        t.OnEvent("Click", function)
    } else if size = "mini1" {
        t := ui.AddButton("w123 h30 y+5 x5", label)
        CreateImageButton(t, 0, ButtonStyles["binds"]*)
        t.OnEvent("Click", function)
        temp_for_size := t.Y
    } else if size = "mini2" {
        t := ui.AddButton("w123 h30 y" t.Y " x133", label)
        CreateImageButton(t, 0, ButtonStyles["binds"]*)
        t.OnEvent("Click", function)
        temp_for_size := 0
    }
    return t
}
hide_ui(Element?,*) {
    temp := false
    if WinExist("AHK ! " RevName " v2") {
        temp := true
    }
    for i in G_WindowData {
        G_WindowData[i][1].Hide()
    }
    MenuUI.Hide()
    Sleep(S100)
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
    Sleep(S100)
    if BeforeEsc and temp {
        SendInput("{Esc}")
    }
}
ForceStop(Element?, *) { 
    global ForceStopRP
    ForceStopRP := true
    ProgressBar.Opt("c9c0101")
    SetNStatusBar(20)
}
ChatAction(sleep1, value, sleep2) {
    SendInput("{t}")
    if ForceStopRP {
        HideStatusBar()
        return
    }
    Sleep(sleep1)
    if ForceStopRP {
        HideStatusBar()
        return
    }
    SendInput(value)
    Sleep(sleep2)
}
RPAction(actions) {
    global CurrentProgress, SBMaximum, SBMaximumForOne, ForceStopRP

    ForceStopRP := false

    
    hide_ui()
    if AutoChatStart = true {
        global AutoChatStart := false
        SendInput("{Esc}")
    }
    if BeforeCheck {
        if !WinActive("ahk_exe javaw.exe") and !WinActive("Minecraft") {
            return 0
        }
    }

    SendMessage(0x50, , 0x4190419, , "A")
    SetMStatusBar(actions.Length)
    ProgressBar.Opt("c019C9A")
    if ShowStatus and actions.Length > 1
        ShowStatusBar()

    Loop(actions.Length) {
        action := actions[A_Index]
        type := action[1]
        value := action[2]

        if action.Length < 5
            action.Push(true)
        
        if ForceStopRP {
            HideStatusBar()
            return
        }

        if (type == "Text") {
            SendInput(value)
        } else if (type == "Sleep") {
            Sleep(value)
        } else if (type == "Chat") {
            if action[5]
                ChatAction(action[3], value, action[4])
        } else if (type == "/med") {
            if G_Binds_cfg["Global_HealCommand"]
                ChatAction(action[3], value, action[4])
        } else if (type == "AutoChat") {
            totalActions := actions.Length
            if (totalActions <= 2) {
                autoSleepBefore := S300
                autoSleepAfter := S300
            } else if (totalActions <= 3) {
                autoSleepBefore := S700
                autoSleepAfter := S1000
            } else if (totalActions <= 5) {
                autoSleepBefore := S2000
                autoSleepAfter := S2000
            } else {
                autoSleepBefore := S2000
                autoSleepAfter := S4000
            }
            ChatAction(autoSleepBefore, value, autoSleepAfter)
        }

        SetNStatusBar(A_Index)
    }

    Sleep(S250)
    HideStatusBar()
}
UpdateAHK(Element?, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM/releases/download/latest/" RevName ".exe")
    UpdateUI.Hide()
}
CloseUpdateAHK(Element?, *) {
    UpdateUI.Hide()
}
open_settings_ui(Element?, *) {
    SettingsUI.Show("h350 w640")
    MenuUI.Hide()
}
open_menu_ui(Element?, *) {
    SettingsUI.Show("w260 h" mainbindy)
}
WHR_Request(whr, link) {
    whr.Open("GET", link, true)
    whr.Send()
    whr.WaitForResponse()
    if (whr.status == 200) {
        return whr.ResponseText
    } else {
        return "ERROR"
    }
    
}
CheckAnnouncement(Element?, *) {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    AID         := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/ID")
    AisEnabled  := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/isEnabled")
    AisEveryRun := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/isEveryRun")
    AisNotify   := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/isNotify")
    ALabel      := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/Label")
    ALink       := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/Link")
    AText       := WHR_Request(whr, "https://raw.githubusercontent.com/Agzes/AHK-FOR-RPM/refs/heads/main/!Announcement/Text")

    if (AID == "ERROR") or (AisEnabled == "ERROR") or (AisEveryRun == "ERROR") or (AisNotify == "ERROR") or (ALabel == "ERROR") or (ALink == "ERROR") or (AText == "ERROR") {
        return
    } 
    
    if (!AisEnabled) {
        return
    }

    AID_Current := 0
    try {
        AID_Current := RegRead(ConfigPath, "IDForAnnouncement")
    }

    if (!AisEveryRun) and (AID <= AID_Current) {
        return
    }

    if (AisNotify) and (ALink == "None") {
        Result := MsgBox(AText, ALabel)
    } else if (AisNotify) {
        Result := MsgBox(AText, ALabel, "YesNo")
        if Result = "Yes"
            Run(ALink)
    }

    RegWrite(AID, "REG_SZ", ConfigPath, "IDForAnnouncement")
}
MenuUI := AutoCreateUI("(. ❛ ᴗ ❛.)")
AutoAddButton(MenuUI, "открыть меню", open_settings_ui, "full")
AutoAddButton(MenuUI, Chr(0xE117), ReloadFromUI, "full")
menu_stopstart := AutoAddButton(MenuUI, Chr(0xE103), PlayPause, "full")
mainbindy := AutoInitUI(MenuUI)

UpdateUI := AutoCreateUI("Найдено новое обновление!`n")
AutoAddButton(UpdateUI, Chr(0xE117) " Обновить", UpdateAHK, "full")
AutoAddButton(UpdateUI, "Закрыть", CloseUpdateAHK, "full")
UpdateUIy := AutoInitUI(UpdateUI)

if UpdateCheck {
    CheckForUpdate()
    CheckAnnouncement()
} else {
    CheckAnnouncement()
}
if BeforeLimit {
    A_HotkeyInterval := 1000
    A_MaxHotkeysPerInterval := 1
}
if (VerCompare(A_OSVersion, "10.0.22200") < 0) {
    LogSent("[WinCheck] [Info] Версия Windows ниже 10.0.22200: -ColorWindow")
    LogSent("[WinCheck] [Info] Вы можете игнорировать ошибку -> ColorWindow")
}

}
; AFR v.2.2 CODE PART (Не изменяйте для корректной работы конфига) 

InitFuncAndHotKeyForAFR()
InitWindowForAFR()
InitBindsForAFR()

; made with ❤️  by Agzes!