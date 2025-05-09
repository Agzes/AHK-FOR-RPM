; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |              AHK-FOR-RPM              |
; |      AHK Hospital v2  | by Agzes      |
; |         https://e-z.bio/agzes         |
; \_______________________________________/

global logs := []
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include %A_ScriptDir%\..\!Libs\!CreateImageButton.ahk
#Include %A_ScriptDir%\..\!Libs\!WinDarkUI.ahk
#Include %A_ScriptDir%\..\!Libs\!GuiEnchancerKit.ahk
#Include %A_ScriptDir%\..\!Libs\!ScroolBar.ahk
#Include %A_ScriptDir%\..\!Libs\!DarkStyleMsgBox.ahk
#Include %A_ScriptDir%\..\!Libs\!JXON.ahk
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
program_version := 2.1 ; !Don`t change
code_version := 6 ; !Don`t change
HotKeyStatus := true ; !Don`t change
CurrentPage := "SBT01"
Font := "Segoe UI" ; !Change > you can change this font to any other font you like (NEED INSTALL THIS FONT TO SYSTEM)
FontSize := 11 ; !Change > for custom font work
ScrollActive := false ;
CurrentBindsRecords := "" ;


global GBinds := Map()
global GBinds_cfg := Map()
InitGbinds(i) {
    i["ForceStop"] := ['Insert', "[ForceStop] - Остановка отыгровок"]
    i["UI_Main"] := ['F4', "[UI] Основное"]
    i["UI_Educ"] := ['F6', "[UI] Обучение мл. состава"]
    i["UI_Rare"] := ['F8', "[UI] Редкое, операции"]
    i["UI_Menu"] := ['F9', "[UI] Меню"]
    i["Restart"] := ['F10', "Перезагрузка"]
    i["Greetings"] := ['!q', "Приветствие"]
    i["GivePill"] := ['!t', "Передать таблетку"]
    i["SellMed"] := ['!l', "Продать мед"]
    i["Bruise"] := ['!y', "Ушиб"]
    i["Ammonia"] := ['!h', "Нашатырь"]
    i["Inject"] := ['!i', "Инъекция"]
    i["MedCard"] := ['!m', "Мед.Карта (выдача)"]
    i["Discharge"] := ['!v', "Выписка из 6 палаты"]
    i["Examination"] := ['!o', "Мед.осмотр"]
    i["Suitability"] := ['!p', "Проф. Пригодность "]
    i["Knife"] := ['!u', "Ножевое"]
    i["Bullet"] := ['!b', "Пулевое"]
    i["Stretcher"] := ['!n', "Носилки"]
    i["Drip"] := ['!k', "Капельница"]
    i["Defib"] := ['!d', "Дефибриллятор"]
    i["TwistAndCalm"] := ['!g', "Скрутить + успокоительное"]
    i["CalmInjection"] := ['!j', "Успокаивающий укол"]
    i["PlasticSurgery"] := ['!1', "Пластическая операция"]
    i["BloodTest"] := ['!2', "Взятие крови на анализ"]
    i["WoundRepair"] := ['!3', "Обработать и зашить рану"]
    i["ExtractBullet"] := ['!5', "Операция по извлечению пули"]
    i["ClosedFracture"] := ['!8', "Закрытый перелом"]
    i["OpenFracture"] := ['!9', "Открытый перелом"]
    i["Xray"] := ['!6', "Рентген"]
    i["Dislocation"] := ['!7', "Вывих"]
    i["CPR"] := ['', "СЛР"]
    i["ECG"] := ['', "ЭКГ"]
    i["ApplyCast"] := ['!0', "Наложить гипс"]
    i["LectureIntern"] := ['^!1', "Лекция интерну"]
    i["Regulation_Part1"] := ['^!2', "Устав [1/3 часть] 'Вы готовы... ?'"]
    i["Regulation_Part2"] := ['^!3', "Устав [2/3 часть] 3 Устава"]
    i["Regulation_Part3"] := ['^!4', "Устав [3/3 часть] 3 Термин"]
    i["Oath"] := ['^!6', "Клятва ['Вы готовы?']"]
    i["Practice_RP1"] := ['^!9', "Практика [РП, задание]"]
    i["Calls"] := ['!c', "/calls"]
    i["PassAccept"] := ['!r', "/pass accept"]
    i["MedHeal"] := ['!e', "/med heal _ 100"]
    i["GPSCancel"] := ['!s', "/gps cancel"]
    i["HospitalID"] := ['!f', "Удостоверение [см. Параметры]"]
} InitGbinds(GBinds)

InitGBindsCfg(i) {
    i["Global_HealCommand"] := true
    i["Global_HealPrice"] := 111
    i["Global_InjectPrice"] := 1111
    i["Greetings_UseName"] := false
    i["Greetings_UseRole"] := false
    i["MedCard_Command"] := true
    i["ID_Date"] := "03.05.25"
    i["ID_Role"] := "Отсутствует"
} InitGBindsCfg(GBinds_cfg)

global G_Binds := GBinds
global G_Binds_cfg := GBinds_cfg
GBindsSortedArray := ["ForceStop", "UI_Main", "UI_Educ", "UI_Rare", "UI_Menu", "Restart", "Greetings", "GivePill", "SellMed", "Bruise", "Ammonia", "Inject", "MedCard", "Discharge", "Examination", "Suitability", "Knife", "Bullet", "Stretcher", "Drip", "Defib", "TwistAndCalm", "CalmInjection", "PlasticSurgery", "BloodTest", "WoundRepair", "ExtractBullet", "ClosedFracture", "OpenFracture", "Xray", "Dislocation", "CPR", "ECG", "ApplyCast", "LectureIntern", "Regulation_Part1", "Regulation_Part2", "Regulation_Part3", "Oath", "Practice_RP1", "Calls", "PassAccept", "MedHeal", "GPSCancel", "HospitalID"]

A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 50

global SBMaximum := 0
global SBMaximumForOne := 0
global CurrentProgress := 0

LogAdd("[status] получение файлов конфига")

try {
    global G_Binds
    LogAdd("[info] получение файлов конфига `"Binds`" ")
    T_Temp := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Binds")
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
    T_Temp := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "BindsCFG")
    T_Data := Jxon_Load(&T_Temp)
    LogAdd("[info] `"BindsCFG`" найдено")
    for key, value in T_Data {
        G_Binds_cfg[key] := value
    }
    LogAdd("[info] `"BindsCFG`" загружено")
}

UserName := LoadConfig("UserName", "User")
Role := LoadConfig("Role", "")
Name := LoadConfig("Name", "")
FocusMethod := LoadConfig("focus_method", 1)
BeforeEsc := LoadConfig("before_esc", 1)
BeforeCheck := LoadConfig("before_check", 0)
BeforeLimit := LoadConfig("before_limit", 0)
ShowStatus := LoadConfig("show_status", 1)
UpdateCheck := LoadConfig("update_check", 1)

S100 := LoadConfig("S100", 100)
S250 := LoadConfig("S250", 250)
S300 := LoadConfig("S300", 300)
S500 := LoadConfig("S500", 500)
S700 := LoadConfig("S700", 700)
S800 := LoadConfig("S800", 800)
S1000 := LoadConfig("S1000", 1000)
S2000 := LoadConfig("S2000", 2000)
S3000 := LoadConfig("S3000", 3000)
S4000 := LoadConfig("S4000", 4000)

StatusUI := GuiExt("+AlwaysOnTop -Caption", "AHK | Status")
StatusUI.BackColor := "0"
WinSetTransColor(0, StatusUI.Hwnd)
ProgressBar := StatusUI.AddProgress("w300 h32 x0 y0 Background171717 c019C9A")
ProgressBar.Value := 0
ProgressBar.SetRounded(6)


SaveBindsCFG() {
    RegWrite(Jxon_Dump(G_Binds_cfg), "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "BindsCFG")
}
LogAdd(Text) {
    logs.Push(Text)
}
LoadConfig(configName, basic) {
    try {
        LogAdd("[info] получение файлов конфига `" " configName " `" ")
        local value := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", configName)
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
    RegWrite(Jxon_Dump(G_Binds), "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "Binds")
}
BindHotkey(BtnObj) {
    global CurrentBindsRecords
    BtnObj.Text := Chr(0xE15B)
    CreateImageButton(BtnObj, 0, ButtonStyles["fake_for_hotkey"]*)
    CurrentBindsRecords := BtnObj.Hwnd
    tbind := WaitForBind()
    if tbind != "" {
        tt := StrReplace(BtnObj.Name, "EBIND_", "")
        G_Binds[GBindsSortedArray[tt]][1] := tbind
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
    G_Binds[GBindsSortedArray[StrReplace(CtrlElement.Name, "BIND_", "")]][1] := HotkeyToBind(CtrlElement.Text)
    SaveBindCfg()
}
UpdateBindsInConfigurator(Element?, *) {
    for i, x in GBindsSortedArray {
        temp1 := GuiCtrlFromHwnd(BindHwnd[i])
        temp2 := G_Binds[x][1]
        temp1.Text := BindToHotkey(temp2)
    }
}
ImportBinds(Element, *) {
    LogSent("[info] [bind-sys] [import] > start")
    PathToFile := FileSelect("", "Hospital_cfg.json", "Импорт файла конфигурации", "AHK_FOR_RPM Config file (*.json*)")
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
    PathToFile := FileSelect("S", "Hospital_cfg.json", "Сохранение файла конфигурации", "AHK_FOR_RPM Config file (*.json*)")
    if PathToFile != "" {
        if FileExist(PathToFile) {
            Result := MsgBox("Файл уже существует! `nПерезаписать? (это удалит его содержимое)", "Warning", "YesNo")
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
        RegWrite(S100, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S100")
        RegWrite(S250, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S250")
        RegWrite(S300, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S300")
        RegWrite(S500, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S500")
        RegWrite(S700, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S700")
        RegWrite(S800, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S800")
        RegWrite(S1000, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S1000")
        RegWrite(S2000, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S2000")
        RegWrite(S3000, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S3000")
        RegWrite(S4000, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Hospital_v2", "S4000")
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
    for i, x in GBindsSortedArray {
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
MainBindUIopen(Element?, *) {
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
        t := ui.AddButton("w250 h54 y+" t " x5 Disabled",)
        CreateImageButton(t, 0, ButtonStyles["fake_for_group"]*)
        t := ui.AddText("x13 y" t.Y + 5, Label)
        t1 := SysGet(SM_CXMENUCHECK := 71)
        t2 := SysGet(SM_CYMENUCHECK := 72)
        t := Ui.AddButton("x232 y" t.Y " h17 w17", "?")
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


SettingsUI := GuiExt("", "!AHK | Hospital v2 ")
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
STB1 := SettingsUI.AddButton("x192 y6 w431 h1293 0x100 vSTB1 Disabled Hidden", "") ; Binds background
CreateImageButton(STB1, 0, ButtonStyles["fake_for_group"]*)
SettingsUI.SetFont("cWhite s" 13, Font)
SMP_GREETINGS := SettingsUI.AddText("x194 y44 w438 h30 +Center", "Привет, " UserName "!")
SettingsUI.SetFont("cGray s" 8, Font)
SMP_VERSION := SettingsUI.AddText("x338 y325", "AHK-FOR-RPM: v2.1" ' I ' "RP: v2.0.2")
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
for i, x in GBindsSortedArray {
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


TimeSetUI := GuiExt("", "!AHK | Hospital v2 ")
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


RpSetUI := GuiExt("", "!AHK | Hospital v2 ")
RpSetUI.SetFont("cWhite s" FontSize - 1, Font)
RpSetUI.BackColor := 0x171717
CreateImageButton("SetDefGuiColor", 0x171717)

RpSetUI.AddText("w250 x5 +Center", "( °o° )")
RpSetUI.AddText("w250 x5 +Center", "настройки сохраняются автоматически")
RpSetUIGen(RpSetUI, "CheckBox", "Авто-Написание команд", "Global_HealCommand", "Определяет будет ли автоматически вводиться команды")
RpSetUIGen(RpSetUI, "Input", "Цена на лечения (Число)", "Global_HealPrice", "Определяет цену которая будет писаться при лечении")
RpSetUIGen(RpSetUI, "Input", "Цена на инъекцию (Число)", "Global_InjectPrice", "Определяет цену которая будет писаться при инъекции")
RpSetUIGen(RpSetUI, "CheckBox", "[Приветствие] + Имя Фамилия", "Greetings_UseName", "Определяет будет ли использоваться РП ИмяФамилия в приветствии")
RpSetUIGen(RpSetUI, "CheckBox", "[Приветствие] + Ранг", "Greetings_UseRole", "Определяет будет ли использоваться РП Ранг в приветствии")
RpSetUIGen(RpSetUI, "CheckBox", "[Мед.Карта] /med givecard", "MedCard_Command", "Определяет будет ли автоматически вводиться команда /med givecard после отыгровок выдачи мед. карты.")
RpSetUIGen(RpSetUI, "Input", "Удостоверение > дата", "ID_Date", "Изменяет дату выдачи удостоверения.")
RpSetUIGen(RpSetUI, "Input", "Удостоверение > отдел", "ID_Role", "Изменяет отделение в удостоверении.")

SetWindowTheme(RpSetUI)
SetWindowAttribute(RpSetUI)
SetWindowColor(RpSetUI.Hwnd, 0xFFFFFFFF, 0x171717, 0xFF202020)

ToCredits(Element, *) {
    Run("https://github.com/Agzes/AHK-FOR-RPM/blob/main/CREDITS.md")
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
    t := GuiExt("", "AHK ! Hospital v2 ")
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
        t := RareBindUI.AddButton("w123 h30 y" t.Y " x133", label)
        CreateImageButton(t, 0, ButtonStyles["binds"]*)
        t.OnEvent("Click", function)
        temp_for_size := 0
    }
    return t
}
hide_ui(Element?, *) {
    temp := false
    if WinExist("AHK ! Hospital v2") {
        temp := true
    }
    MainBindUI.Hide()
    EducBindUI.Hide()
    RareBindUI.Hide()
    PMPBindUI.Hide()
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

    Loop (actions.Length) {
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


greetings(Element?, *) {
    gt := "Здравствуйте, чем я могу вам помочь? {ENTER}"
    if G_Binds_cfg["Greetings_UseName"] and G_Binds_cfg["Greetings_UseRole"] {
        gt := "Здравствуйте, меня зовут " Name ", моя должность " Role ". Чем я могу помочь? {ENTER}"
    } else if G_Binds_cfg["Greetings_UseName"] {
        gt := gt := "Здравствуйте, меня зовут " Name ", чем я могу помочь? {ENTER}"
    } else if G_Binds_cfg["Greetings_UseRole"] {
        gt := "Здравствуйте, я " Role ", чем я могу помочь? {ENTER}"
    }


    RPAction([
        ["Chat", gt, S100, S100]
    ])
}
give_pill(Element?, *)
{
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]

    RPAction([
        ["Chat", "/mee осмотрел пациента, выявил проблему и приступил искать лекарство или таблетку в своей аптечке {Enter}", S100, S300],
        ["Chat", "/do " . list[Random(1, 3)] . " в руках у мед. работника {Enter}", S300, S300],
        ["Chat", "/mee найдя нужное лекарство, достаёт и передает пациенту напротив, затем закрывает аптечку {Enter}", S300, S300],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
sell_pill(Element?, *)
{
    r1 := Random(1, 3)
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]
    list2 := ["красную аптечку", "аптечку с красным крестом", "аптечку"]

    RPAction([
        ["Chat", "/do " . list[r1] . " в руках у мед. работника" . " {Enter}", S100, S300],
        ["Chat", "/mee открыв " . list2[r1] . " и найдя нужное лекарство передаёт человеку напротив, затем подписывает листок c датой выдачи и своими данными {Enter}", S300, S300],
        ["Chat", "/med sell ", S100, S250]
    ])
}
bruise(Element?, *)
{
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]

    RPAction([
        ["Chat", "/do " . list[Random(1, 3)] . " в руках у мед. работника {Enter}", S300, S300],
        ["Chat", "/mee открыв свою аптечку ищет и достаёт мазь, затем одевает на свои руки перчатки и осматривает место ушиба пациента {Enter}", S300, S300],
        ["Chat", "/mee открыв крышку тюбика мази, и выдавив на перчатку немного мази начинает намазывать место ушиба пострадавшему, после этого берет бинт распаковав из пачки, забинтовывает место ушиба пациента {Enter}", S300, S300],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
ammonia(Element?, *)
{
    RPAction([
        ["Chat", "/mee открывает аптечку и достает нашатырный спирт вместе с ваткой, затем открывает крышку банки и немного смочив ватку подносит её перед носом человека без сознания, ожидая когда он придет в себя {Enter}", S100, S300],
        ["Chat", "/mee закрывает крышку банки и убирает нашатырь обратно в аптечку, продолжая наблюдать за состоянием пациента {ENTER}", S300, S300],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S300, S100]
    ])
}
inject(Element?, *)
{
    list := ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"]

    RPAction([
        ["Chat", "/do " . list[Random(1, 3)] . " в руках у мед. работника {Enter}", S300, S300],
        ["Chat", "/mee достает из аптечки шприц, спиртовую салфетку и бинт, протирает место для укола спиртовой салфеткой и начинает делать укол аккуратно вводя иглу в мышечную ткань{ENTER}", S1000, S1000],
        ["Chat", "/do Инъекция была сделана {ENTER}", S1000, S1000],
        ["Chat", "/mee прикладывая ватку на место укола вытаскивает иглу, убирает ватку и заклеивает место прокола кусочком пластыря {ENTER}", S1000, S1000],
        ["Chat", "/med inject  " G_Binds_cfg["Global_InjectPrice"] "{Left}{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
med_card(Element?, *) {
    RPAction([
        ["Chat", "/mee взяв паспорт из рук гражданина и держа его в руках, сверяет данные и проверяет фотографию {ENTER}", S100, S1000],
        ["Chat", "/mee доставая планшет, включает его, создаёт новую мед карту и начинает заполнять {ENTER}", S1000, S2000],
        ["Chat", "/todo заполнив мед. карту, ставит электронный штамп и подпись, а затем передает посетителю ключ доступа с паспортом : проверяйте. {ENTER}", S2000, S100],
        ["Chat", "/med givecard ", S100, S250, G_Binds_cfg["MedCard_Command"]]
    ])
}
extract(Element?, *) {
    RPAction([
        ["Chat", "/mee осмотрел пациента убедился что он в порядке, берёт незаполненную справку из сумки на плече и записывает данные человека на него, затем убирает справку в сумку {ENTER}", S100, S100],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
medical_examination(Element?, *) {
    RPAction([
        ["Chat", "/mee сняв стетоскоп со своей шеи и приподняв рубашку человеку напротив, начинает прослушивать дыхание {ENTER}", S100, S1000],
        ["Chat", "/mee обойдя со спины продолжает прослушивать дыхание {ENTER}", S1000, S2000],
        ["Chat", "/todo Опустив рубашку пациенту и повесив обратно стетоскоп себе на шею : Дыхание чистое. {ENTER}", S2000, S1000],
        ["Chat", "/do На плече висит медицинская сумка {ENTER}", S1000, S4000],
        ["Chat", "/mee достав тонометр из медицинской сумки и надев манжет на руку пациента выше локтя,  начинает накачивать воздух в манжет, измеряет давление смотря на манометр {ENTER}", S2000, S2000],
        ["Chat", "/todo Измерив давление, снимая манжет с руки пациента : Давление в норме. {ENTER}", S2000, S2000],
        ["Chat", "/todo Подписывает справку, передав человеку напротив : Вы прошли мед.осмотр, вы здоровы. {ENTER}", S2000, S250]
    ])
}
prof_suitability(Element?, *) {
    RPAction([
        ["Chat", "/mee снимает стетоскоп со своей шеи, начинает проверять дыхание, затем берёт тонометр и измеряет давление {ENTER}", S100, S1000],
        ["Chat", "/todo Убирая все на свое место : Дыхание и давление у вас в норме. {ENTER}", S2000, S4000],
        ["Chat", "/mee достаёт из кармана халата фонарик и начинает поочерёдно светить в глаза, смотря на реакцию зрачка {ENTER}", S2000, S2000],
        ["Chat", "/todo Выключив фонарик, возвращая его в карман медицинского халата : Всё в порядке. {ENTER}", S2000, S4000],
        ["Chat", "/mee достав отоскоп из медицинской сумки, держит ухо пациента слегка натянутым, прислонив отоскоп в каждое ухо по очереди, осматривает слуховой аппарат {ENTER}", S2000, S4000],
        ["Chat", "/todo Закончив осмотр слухового аппарата и спрятав отоскоп в медицинскую сумку : Слуховой аппарат в норме. {ENTER}", S2000, S3000],
        ["Chat", "/todo Выписывает справку, после чего передаёт человеку напротив : Вы здоровы и прошли осмотр на проф.пригодность. {ENTER}", S2000, S250]
    ])
}

hospital_id(Element?, *) {
    if (Name != "") and (Role != "") {
        RPAction([
            ["Chat", "/me достал удостоверение из кармана халата, открыл его и продемонстрировал человеку напротив {ENTER}", S100, S100],
            ["Chat", "/do Информация в удостоверении: " Name " | " Role " Hospital RPM | Фотография 3x4 | Отделение: " G_Binds_cfg["ID_Role"] " | Личная подпись | Печать: HOSPITAL | Подпись глав.врача | Дата выдачи: " G_Binds_cfg["ID_Date"] " {ENTER}", S100, S250],
            ["Chat", "/mee после подтверждения информации захлопнул документ, перекинул его во вторую руку и аккуратно положил в карман халата {ENTER}", S250, S250]
        ])
    } else {
        MsgBox("Не заполнены данные для удостоверения! `n`nПерейдите в параметры и заполните поля:`nРП Имя Фамилия, Должность.")
    }
}


MainBindUI := AutoCreateUI("\^o^/")
AutoAddButton(MainBindUI, "Приветствие", greetings, "full")
AutoAddButton(MainBindUI, "Передать таблетку", give_pill, "full")
AutoAddButton(MainBindUI, "Продать мед", sell_pill, "full")
AutoAddButton(MainBindUI, "Ушиб", bruise, "full")
AutoAddButton(MainBindUI, "Нашатырь", ammonia, "full")
AutoAddButton(MainBindUI, "Инъекция", inject, "full")
AutoAddButton(MainBindUI, "Мед. Карта", med_card, "full")
AutoAddButton(MainBindUI, "Выписка из 6 палаты", extract, "full")
AutoAddButton(MainBindUI, "Мед. Осмотр", medical_examination, "full")
AutoAddButton(MainBindUI, "Проф. Пригодность", prof_suitability, "full")
AutoAddButton(MainBindUI, "Удостоверение", hospital_id, "full")
mainbindsy := AutoInitUI(MainBindUI)


knife(Element?, *) {
    RPAction([
        ["Chat", "/me готовит операционную для извлечения ножа, раскладывая необходимые инструменты на стерильном столе {ENTER}", S100, S1000],
        ["Chat", "/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}", S1000, S4000],
        ["Chat", "/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}", S1000, S4000],
        ["Chat", "Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}", S1000, S4000],
        ["Chat", "/me вводит местную анестезию вокруг раны {ENTER}", S1000, S4000],
        ["Chat", "/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}", S1000, S4000],
        ["Chat", "/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}", S1000, S4000],
        ["Chat", "/me делает аккуратный разрез вокруг ножевой раны, чтобы минимизировать повреждения при извлечении {ENTER}", S1000, S4000],
        ["Chat", "/do Кожа вокруг раны обработана, разрез сделан для облегчения извлечения ножа {ENTER}", S1000, S4000],
        ["Chat", "/me осторожно захватывает нож за рукоятку и начинает аккуратно вытаскивать его {ENTER}", S1000, S4000],
        ["Chat", "/me извлекает нож, держа его за рукоятку, и кладет в металлический лоток {ENTER}", S1000, S4000],
        ["Chat", "/do Нож успешно извлечен, рана открыта для обработки {ENTER}", S1000, S4000],
        ["Chat", "/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов и тампонов {ENTER}", S1000, S4000],
        ["Chat", "/me проверяет, не повреждены ли внутренние органы или крупные сосуды, используя специальные инструменты {ENTER}", S1000, S4000],
        ["Chat", "/do Внутренние органы и сосуды не повреждены, хирург продолжает обработку раны {ENTER}", S1000, S4000],
        ["Chat", "/me накладывает несколько швов, чтобы закрыть разрез и восстановить целостность тканей {ENTER}", S1000, S4000],
        ["Chat", "/do Швы аккуратно наложены, рана закрыта {ENTER}", S1000, S4000],
        ["Chat", "/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}", S1000, S4000],
        ["Chat", "/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}", S1000, S4000],
        ["Chat", "Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}", S1000, S4000],
        ["Chat", "/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}", S1000, S250]
    ])
}
peluvoe(Element?, *) {
    RPAction([
        ["Chat", "/me готовит операционную для извлечения пули, раскладывая необходимые инструменты на стерильном столе {ENTER}", S100, S1000],
        ["Chat", "/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}", S1000, S4000],
        ["Chat", "/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}", S1000, S4000],
        ["Chat", "Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}", S1000, S4000],
        ["Chat", "/me вводит местную анестезию вокруг раны {ENTER}", S1000, S4000],
        ["Chat", "/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}", S1000, S4000],
        ["Chat", "/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}", S1000, S4000],
        ["Chat", "/me делает аккуратный разрез вокруг раны, чтобы расширить доступ к пуле {ENTER}", S1000, S4000],
        ["Chat", "/do Рана слегка расширена, открывая доступ к пуле {ENTER}", S1000, S4000],
        ["Chat", "/me осторожно использует пинцет для захвата и извлечения пули {ENTER}", S1000, S4000],
        ["Chat", "/me извлекает пулю, держа её пинцетом, и помещает в металлический лоток {ENTER}", S1000, S4000],
        ["Chat", "/do Пуля успешно извлечена, рана готова к обработке {ENTER}", S1000, S4000],
        ["Chat", "/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов {ENTER}", S1000, S4000],
        ["Chat", "/me накладывает несколько швов, чтобы закрыть разрез {ENTER}", S1000, S4000],
        ["Chat", "/do Швы аккуратно наложены, рана закрыта {ENTER}", S1000, S4000],
        ["Chat", "/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}", S1000, S4000],
        ["Chat", "/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}", S1000, S4000],
        ["Chat", "Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}", S1000, S4000],
        ["Chat", "/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}", S1000, S250]
    ])
}
stretcher(Element?, *) {
    RPAction([
        ["Chat", "/mee осмотрел пострадавшего и убедившись что его можно перевозить, затем аккуратно укладывает его на носилки {ENTER}", S100, S300],
        ["Chat", "/do Пострадавший лежит на носилках {ENTER}", S100, S250]
    ])
}
dropper(Element?, *) {
    RPAction([
        ["Chat", "/mee ставит стойку для капельницы около кровати, проверяя устойчивая ли стойка для капельницы {ENTER}", S100, S1000],
        ["Chat", "/mee взяв нужный флакон лекарства, вставляет в стойку флакон лекарства {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв жгут ставит его чуть выше изгиба руки пациенту, протирает место для укола спиртовой салфеткой и начинает вводить катетер в набухшую вену, одновременно снимая жгут{ENTER}", S1000, S1000],
        ["Chat", "/mee берёт пластырь, отмотав 3 см отрывает кусок и закрепляет катетер пригладив пластырь к коже руки пациента{ENTER}", S1000, S250]
    ])
}
defibrillator(Element?, *) {
    RPAction([
        ["Chat", "/mee достает дефибриллятор и ставит рядом с пациентом на твердую и устойчивую поверхность{ENTER}", S100, S1000],
        ["Chat", "/mee оголив торс от одежды пациента берёт гель из своей аптечки, открыв крышку геля наносит его на правую ключицу, а также на левый бок под грудь{ENTER}", S1000, S2000],
        ["Chat", "/todo Взяв электроды кладет их на намазанные места гелем : Разряд! {ENTER}", S2000, S2000],
        ["Chat", "/do Подаётся напряжение, тело человека резко дернулось{ENTER}", S2000, S2000],
        ["Chat", "/try Пациент реанимирован?{ENTER}", S2000, S250]
    ])
}
twist(Element?, *) {
    RPAction([
        ["Chat", "/mee резким движением взяв руку неадекватного пациента и скрутил за его спину повалив его прижав к поверхности, подставил свое колено к спине пациента зажимая его {ENTER}", S1000, S1000],
        ["Chat", "/do Пациенту трудно двигаться {ENTER}", S1000, S1000],
        ["Chat", "/mee достает свободной рукой из кармана халата шприц с успокаивающим средством, снимая колпачок своими зубами и приспустив воздух вкалывает его в плечо пациента и убирает пустой шприц обратно в карман {ENTER}", S1000, S1000],
        ["Chat", "/do На пациента начинает действовать лекарство и он слабеет, успокаивается {ENTER}", S1000, S1000],
        ["Chat", "/mee поднимает пациента придерживая его руку за спиной {ENTER}", S1000, S250]
    ])
}
calm(Element?, *) {
    RPAction([
        ["Chat", "/mee засунув руку в карман и нащупав шприц с успокаивающим, незаметно достает его и приоткрывает колпачок приспускает воздух из шприца слегка нажав, вкалывает в плечо пациента и приспускает медленно лекарство придерживая пациента {ENTER}", S1000, S1000]
    ])
}
plast_operation(Element?, *) {
    RPAction([
        ["Chat", "/me проверяет записи в мед.карте пациента, убеждаясь, что все необходимые анализы и согласия на операцию оформлены {ENTER}", S100, S1000],
        ["Chat", "/me моет руки, надевает стерильные перчатки, затем проверяет готовность инструментов и материалов, после дезинфицирует операционное поле {ENTER}", S1000, S1000],
        ["Chat", "/do Операционное поле дезинфицировано, все инструменты и материалы подготовлены {ENTER}", S1000, S1000],
        ["Chat", "/me размечает разметку на коже пациента, учитывая запланированную форму и размер {ENTER}", S1000, S4000],
        ["Chat", "/me готовит препараты для наркоза и проверяет оборудование для анестезии {ENTER}", S1000, S1000],
        ["Chat", "/do Подготовительные работы завершены, пациент готов к операции {ENTER}", S1000, S1000],
        ["Chat", "/me вводит анестезиологический препарат, ожидая пока пациент полностью уснёт под действием наркоза {ENTER}", S4000, S1000],
        ["Chat", "/me делает аккуратный разрез в области под грудью, следуя заранее разработанной разметки {ENTER}", S1000, S1000],
        ["Chat", "/me аккуратно проводит установку имплантов, заранее их стерилизовав, следя за симметрией и правильным положением {ENTER}", S1000, S4000],
        ["Chat", "/do Импланты установлены, симметрия правильная, положение ровное {ENTER}", S1000, S1000],
        ["Chat", "/me накладывает швы на операционные разрезы {ENTER}", S1000, S4000],
        ["Chat", "/me проводит финальную дезинфекцию и накладывает стерильную повязку {ENTER}", S1000, S1000],
        ["Chat", "/do Операция завершена, пациент постепенно выходит из наркоза {ENTER}", S1000, S250]
    ])
}
blood(Element?, *) {
    RPAction([
        ["Chat", "/mee одевает перчатки и достаёт из медицинской сумки жгут{ENTER}", S1000, S1000],
        ["Chat", "/todo Наложив жгут на середину плеча : Сжимайте и разжимайте кулак{ENTER}", S1000, S1000],
        ["Chat", "/do Вена расширилась {ENTER}", S1000, S4000],
        ["Chat", "/todo Взяв иглу и распечатав из пачки, вводит её в вену пациента : Разжимайте кулак.{ENTER}", S2000, S2000],
        ["Chat", "/mee подставив пробирку к игле и снимает жгут с руки пациента, набирает кровь медленно стекающую в пробирку{ENTER}", S2000, S2000],
        ["Chat", "/do Необходимое количество крови набрано {ENTER}", S1000, S1000],
        ["Chat", "/todo Извлекая иглу из вены и прикладывает чистую салфетку к руке пациента : Согните руку в суставе{ENTER}", S1000, S2000],
        ["Chat", "/todo Выкидывает использованную иглу в урну : Ожидайте анализов.{ENTER}", S2000, S250]
    ])
}
wound(Element?, *) {
    RPAction([
        ["Chat", "/mee надевает стерильные перчатки и начинает осматривать рану у пациента{ENTER}", S1000, S1000],
        ["Chat", "/mee взяв шприц, распечатывает его из новой упаковки, затем берет ампулу, надламывает верхушку и сняв колпачок с иглы шприца набирает лекарство {ENTER}", S1000, S1000],
        ["Chat", "/mee протерев спиртовой салфеткой место укола, вводит в мышечную ткань иглу, начинает медленно вводить лекарство{ENTER}", S1000, S1000],
        ["Chat", "/do Укол сделан{ENTER}", S4000, S1000],
        ["Chat", "/mee вытаскивает иглу и выкидывает шприц в мусорку{ENTER}", S1000, S1000],
        ["Chat", "/mee взяв антисептик начинает обрабатывать рану, затем берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану{ENTER}", S1000, S1000],
        ["Chat", "/do Рана зашита{ENTER}", S4000, S1000],
        ["Chat", "/mee отложив иглу с пинцетом, берет бинт начинает перебинтовывать рану{ENTER}", S1000, S1000],
        ["Chat", "/do Рана перебинтована{ENTER}", S1000, S250]
    ])
}
bullet(Element?, *) {
    RPAction([
        ["Chat", "/mee подготавливает инструменты и надевает стерильные перчатки {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв шприц с обезболивающим выпустив воздух из иглы начинает делать укол в районе огнестрела протерев место укола салфеткой {ENTER}", S1000, S4000],
        ["Chat", "/mee сделав укол, выкидывает шприц в мусорку {ENTER}", S1000, S1000],
        ["Chat", "/mee берёт скальпель начинает делать надрез {ENTER}", S1000, S4000],
        ["Chat", "/mee отложив скальпель берет разжим и щипцы, начинает извлекать пулю разжав щипцами ткань {ENTER}", S1000, S1000],
        ["Chat", "/mee вытащив пулю кладет ее на поднос {ENTER}", S1000, S4000],
        ["Chat", "/mee обрабатывает рану спреем, подтирает капли вокруг раны стерильной салфеткой {ENTER}", S1000, S1000],
        ["Chat", "/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану {ENTER}", S1000, S4000],
        ["Chat", "/mee взяв бинты начинает забинтовывать {ENTER}", S1000, S1000],
        ["Chat", "/do Рана зашита. Бинты наложены {ENTER}", S1000, S4000],
        ["Chat", "/todo Передавая пулю пациенту : Держите на память. {ENTER}", S1000, S250]
    ])
}
close_fracture(Element?, *) {
    RPAction([
        ["Chat", "/todo Включив рентген и сняв снимки смотрит на них, затем ставит диагноз с дальнейшим исправлением : У вас закрытый перелом. {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв шприц с обезболивающим и салфетку, протерев место укола, выпустив воздух из иглы, начинает делать укол в районе перелома, приложив после на пару секунд салфетку на место укола, затем принимается вправлять кость {ENTER}", S1000, S4000],
        ["Chat", "/do Кость вправлена{ENTER}", S1000, S1000],
        ["Chat", "/mee подготавливает гипсовый бинт, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома, подождав пару минут, проверяет подсыхание гипса, затем берёт бинт и начинает накладывать поверх гипса{ENTER}", S1000, S1000],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
open_fracture(Element?, *) {
    RPAction([
        ["Chat", "/todo Включив рентген, смотрит на монитор и ставит диагноз с дальнейшим исправлением : У вас открытый перелом. {ENTER}", S1000, S1000],
        ["Chat", "/mee подготовив операционный стол и пациента, раскладывает нужные инструменты перед собой и одевает стерильные перчатки {ENTER}", S1000, S1000],
        ["Chat", "/mee ставит катетер, присоединяет трубку с анестезией пациенту, ожидает когда на пациента подействует наркоз {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв антисептик, начинает обрабатывать рану, затем проводит манипуляции с восстановлением костной ткани {ENTER}", S1000, S4000],
        ["Chat", "/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет, держа иглу, зашивает рану, после чего взяв бинты, начинает забинтовывать поврежденную конечность пациента {ENTER}", S1000, S4000],
        ["Chat", "/mee начинает подготавливать гипсовый бинт, налив воды в тару, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома {ENTER}", S1000, S4000],
        ["Chat", "/mee действие лекарства заканчивается и пока пациент приходит в себя, проверяет подсыхание гипса, затем берёт бинт и начинает обматывать гипс {ENTER}", S2000, S4000],
        ["Chat", "/mee закрепляет конец бинта и снимает катетер с уже закончившим наркозом, затем накладывает повязку {ENTER}", S2000, S100],
        ["/med", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S250]
    ])
}
rengen(Element?, *) {
    RPAction([
        ["Chat", "/mee включает рентген и нажимает кнопку пуска{ENTER}", S100, S500],
        ["Chat", "/do Рентген аппарат включён, идет сканирование{ENTER}", S500, S500],
        ["Chat", "/mee распечатывает снимок и взяв его из принтера поднеся к свету рассматривает снимок, ставит диагноз{ENTER}", S500, S250]
    ])
}
dislocation(Element?, *) {
    RPAction([
        ["Chat", "/mee одевает перчатки, подготавливает салфетки и ампулу с обезболивающим, надломив ампулу и взяв шприц вскрытый из новой пачки, набирает обезболивающее из ампулы{ENTER}", S100, S500],
        ["Chat", "/mee держа шприц с обезболивающим выпустив воздух из иглы начинает делать укол протерев место укола салфеткой{ENTER}", S500, S500],
        ["Chat", "/mee взяв конечность пациента начинает потихоньку натягивать на себя и вправляет сустав в нужную сторону{ENTER}", S500, S250]
    ])
}
slrt(Element?, *) {
    RPAction([
        ["Chat", "/mee осматривает пострадавшего, замечая остановку дыхания и отсутствия пульса приложив пальцы к шее лежащего {ENTER}", S100, S1000],
        ["Chat", "/mee открывает аптечку и достает стерильные перчатки, начинает одевать на свои руки {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв фонарик из аптечки и приоткрыв рот потерпевшему осматривает ротовую полость на инородные предметы {ENTER}", S1000, S4000],
        ["Chat", "/mee выключает фонарик и убирает обратно в аптечку, прихватив из аптечки ручной ИВЛ положив рядом{ENTER}", S1000, S1000],
        ["Chat", "/mee поставив ладони на вытянутых руках, строго вертикально на груди пострадавшего начинает проводить технику непрямого массажа сердца{ENTER}", S1000, S4000],
        ["Chat", "/mee поочередно надавливая на грудь, после возвращения в исходное положение 30 надавливаний {ENTER}", S1000, S1000],
        ["Chat", "/mee взяв ручной ИВЛ лежащий рядом, прикладывает маску на рот пострадавшего, тем самым приготовив для искусственного дыхания {ENTER}", S1000, S4000],
        ["Chat", "/mee придерживая маску начинает сжимать мешок рукой запуская воздух в легкие пострадавшего {ENTER}", S1000, S1000],
        ["Chat", "/mee контролируя пульс на сонной артерии и реакцию зрачков на свет приоткрывая веко пострадавшему продолжает делать массаж сердца до появления слабого пульса {ENTER}", S1000, S250]
    ])
}
ekgg(Element?, *) {
    RPAction([
        ["Chat", "/mee подготовив пациента, оголив ему грудь от одежды, включает аппарат ЭКГ, затем взяв гель начинает наносить на грудь пациенту и устанавливает присоски {ENTER}", S100, S1000],
        ["Chat", "/mee распечатывает данные, одной рукой берет край распечатки и изучает сердцебиение {ENTER}", S1000, S250]
    ])
}

RareBindUI := AutoCreateUI("None")
AutoAddButton(RareBindUI, "Ножевое", knife, "mini1")
AutoAddButton(RareBindUI, "Пулевое", peluvoe, "mini2")
AutoAddButton(RareBindUI, "Носилки", stretcher, "mini1")
AutoAddButton(RareBindUI, "Капельница", dropper, "mini2")
AutoAddButton(RareBindUI, "Дефибриллятор", defibrillator, "full")
AutoAddButton(RareBindUI, "Скрутить + успокаивающий укол", twist, "full")
AutoAddButton(RareBindUI, "Успокаивающий укол", calm, "full")
AutoAddButton(RareBindUI, "Пластическая операция", plast_operation, "full")
AutoAddButton(RareBindUI, "Взятие крови на анализ (в пробирку)", blood, "full")
AutoAddButton(RareBindUI, "Обработать и зашить рану", wound, "full")
AutoAddButton(RareBindUI, "Операция по извлечению пули", bullet, "full")
AutoAddButton(RareBindUI, "Закрытый перелом", close_fracture, "full")
AutoAddButton(RareBindUI, "Открытый перелом", open_fracture, "full")
AutoAddButton(RareBindUI, "Рентген", rengen, "mini1")
AutoAddButton(RareBindUI, "Вывих", dislocation, "mini2")
AutoAddButton(RareBindUI, "СЛР", slrt, "mini1")
AutoAddButton(RareBindUI, "ЭКГ", ekgg, "mini2")
rarebindy := AutoInitUI(RareBindUI)


lecture(Element?, *) {
    RPAction([
        ["Chat", "Добрый день, интерны! Ваша работа начинается с получения планшета на складе больницы. Это ваш основной инструмент для оформления медицинских карт. Убедитесь, что планшет исправен, и используйте его для записи данных пациентов. Корректность и точность заполнения медицинских карт крайне важны. {ENTER}", S100, S800],
        ["Chat", "Изучите устав больницы и строго придерживайтесь дресс-кода. Ваша форма должна быть аккуратной и соответствовать требованиям фракции. Устав поможет вам понять правила поведения, взаимодействия с коллегами и пациентов. Это основа вашей дисциплины и профессионализма. {ENTER}", S800, S800],
        ["Chat", "Если вы сталкиваетесь с ситуацией, где требуется помощь более квалифицированного специалиста, незамедлительно перенаправляйте пациента. Не стесняйтесь обращаться за советом к старшим сотрудникам — ваша задача обеспечивать качественную первичную помощь. {ENTER}", S800, S800],
        ["Chat", "Во время дежурства за регистратурой будьте внимательны и вежливы. Организуйте приём пациентов, направляйте их к нужным кабинетам и следите за порядком в приёмной зоне. Регистратура — это лицо больницы, и вы играете важную роль в создании доверия у пациентов. {ENTER}", S800, S800],
        ["Chat", "Вы прослушали лекцию. {ENTER}", S800, S250]
    ])
}
regulation1(Element?, *) {
    RPAction([
        ["Chat", "Вы готовы сдать тест по уставу? {ENTER}", S100, S100]
    ])
}
regulation2(Element?, *) {
    list := ["3.5", "2.12", "3.7", "2.18", "2.19", "1.2", "2.7", "1.4", "2.9", "2.4", "1.3", "2.16", "2.17", "3.3", "2.13", "3.6", "2.5", "2.8", "4.2", "4.1", "2.10", "2.15", "1.1", "2.2", "2.20", "2.6", "3.6.1", "2.11", "3.1", "3.9", "2.14", "3.8", "4.0", "2.3", "2.1", "3.2", "3.4"]
    Loop {
        r1 := Random(1, 37)
        r2 := Random(1, 37)
        r3 := Random(1, 37)
    } Until (r1 != r2) && (r1 != r3) && (r2 != r3)

    RPAction([
        ["Chat", "Сначала устав, " . list[r1] . ", " . list[r2] . " и " . list[r3] . ". {ENTER}", S100, S100]
    ])
}
regulation3(Element?, *) {
    list := ["ГКБ", "НРС", "СЛР", "МЗ", "ПМП", "СПИД", "АИК", "ЧМТ", "ИМ", "ДС", "НИВЛ", "ЭКГ", "УЗИ", "ВИЧ", "ТТЖ", "ОЧМТ", "МРТ", "ЛФК", "МП", "КТГ", "ИВЛ", "ЖКТ", "СМП", "ПП"]
    Loop
    {
        r1 := Random(1, 24)
        r2 := Random(1, 24)
        r3 := Random(1, 24)
    } Until (r1 != r2) && (r1 != r3) && (r2 != r3)

    RPAction([
        ["Chat", "Теперь расшифровки, " . list[r1] . ", " . list[r2] . " и " . list[r3] . ". {ENTER}", S100, S100]
    ])
}
oath_start(Element?, *) {
    RPAction([
        ["Chat", "Вы готовы дать клятву Гиппократа? {ENTER}", S100, S100]
    ])
}
practice(Element?, *) {
    RPAction([
        ["Chat", "/do Манекен лежит в шкафу {ENTER}", S100, S700],
        ["Chat", "/me достал манекен из шкафа и затем положил на кушетку  {ENTER}", S700, S700],
        ["Chat", "У него закрытый перелом, приступай.  {ENTER}", S700, S250]
    ])
}

EducBindUI := AutoCreateUI("\(ᵔ•ᵔ)/")
AutoAddButton(EducBindUI, "Лекция интерну", lecture, "full")
AutoAddButton(EducBindUI, "Устав [1/1] | `"Вы готовы?`"", regulation1, "full")
AutoAddButton(EducBindUI, "Устав [3/2] | `"3 устава`"", regulation2, "full")
AutoAddButton(EducBindUI, "Устав [3/3] | `"3 термина`"", regulation3, "full")
AutoAddButton(EducBindUI, "Клятва | `"Вы готовы?`"", oath_start, "full")
AutoAddButton(EducBindUI, "Практика | Отыгровки", practice, "full")
educbindy := AutoInitUI(EducBindUI)


open_settings_ui(Element?, *) {
    SettingsUI.Show("h350 w640")
    MenuUI.Hide()
}
open_pmp_window(Element?, *) {
    pmpbindy := t.Y + 35
    PMPBindUI.Show("w260 h" pmpbindy)
}

MenuUI := AutoCreateUI("(. ❛ ᴗ ❛.)")
AutoAddButton(MenuUI, "открыть меню", open_settings_ui, "full")
AutoAddButton(MenuUI, "пмп", open_pmp_window, "full")
AutoAddButton(MenuUI, Chr(0xE117), ReloadFromUI, "full")
menu_stopstart := AutoAddButton(MenuUI, Chr(0xE103), PlayPause, "full")
mainbindy := AutoInitUI(MenuUI)


pmp1_(Element?, *) {
    RPAction([
        ["Chat", "/todo Внимательно осматривая пациента и обнаруживая вывих в области сустава : У вас вывих сустава, сейчас вам помогу. {ENTER}", S100, S700],
        ["Chat", "/mee надевает перчатки, выдавливает небольшое кол-во Лидокаина на ватный диск и начинает промазывать им нужное место для купирования боли {ENTER}", S700, S700],
        ["Chat", "/mee аккуратно устанавливает поврежденный сустав в нормальное положение, применяя мягкий тягостойкий бандаж {ENTER}", S700, S250]
    ])
}
pmp2_(Element?, *) {
    RPAction([
        ["Chat", "/mee быстро берет из аптечки шину, бинты и накладывает ее с двух боковых сторон от конечности, дабы иммобилизовать ее, после чего обматывает бинтами {ENTER}", S100, S100]
    ])
}
pmp3_(Element?, *) {
    RPAction([
        ["Chat", "/mee открывает аптечку и достает от туда жгут, после чего накладывает его на место выше места кровотечения, после же берет из аптечки шину, бинты и накладывает ее в места, где не выступают кости и обматывает бинтами {ENTER}", S100, S100]
    ])
}
pmp15_(Element?, *) {
    RPAction([
        ["Chat", "/mee ставит и открывает аптечку рядом с собой, осматривает ранение пострадавшего, разрывает чуть одежду в районе огнестрела, ставит жгут, взяв из аптечки антисептик, обрабатывает свои руки и одевает перчатки {ENTER}", S100, S700],
        ["Chat", "/mee распечатывает из пачки антисептическую салфетку, взяв шприц с обезболивающим и выпустив воздух из иглы протирает салфеткой место укола и вводит иглу с обезболивающим в районе огнестрела {ENTER}", S700, S700],
        ["Chat", "/mee осматривает рану на наличие пули и глубины раны, берет из аптечки запечатанную салфетку гемостатик, открывает ее и начинает делать тампонаду раны, останавливая кровотечение, затем берет бинт из аптечки и начинает накладывать тугую повязку {ENTER}", S4000, S250]
    ])
}
pmp17_(Element?, *) {
    RPAction([
        ["Chat", "/mee быстра надев перчатки и маску достал из аптечки все нужное для укола и резким, а также точным движением ввел шприц в мышечную ткань пациента, рядом с местом ранения и надавил на конец шприца для введения препарата внутрь человека {ENTER}", S100, S700],
        ["Chat", "/mee взяв ватку смочил ее антисептическим веществом и прошелся им по краю раны, для обработки ранения {ENTER}", S700, S250]
    ])
}
pmp18_(Element?, *) {
    RPAction([
        ["Chat", "/mee быстра надев перчатки и маску достал из аптечки слабый раствор антисептика и прошелся им по месту ранения, а после бинтами замотал рану в несколько слоев {ENTER}", S100, S100]
    ])
}
pmp25_(Element?, *) {
    RPAction([
        ["Chat", "/me пальцем надавливает на место кровотечения, после другой рукой берет жгут и накладывает его выше ранения, помечая время, после берет стерильную марлевую повязку и тампонирует ее, если есть возможность сжать конечность пациенту, то делает это {ENTER}", S100, S100]
    ])
}
pmp39_(Element?, *) {
    RPAction([
        ["Chat", "/mee достает из кармана халата фонарик, включает его и проверяет глазное яблоко на чувствительность к свету {ENTER}", S100, S1000],
        ["Chat", "/try Пациент реагирует на свет фонарика? {ENTER}", S1000, S1000],
        ["Chat", "/mee достал из аптечки нашатырный спирт и ватку, промочил небольшим кол-вом спирта ватку и принялся водить перед носом пациента {ENTER}", S1000, S1000],
        ["Chat", "/mee подложил под голову пациента небольшую подушку {ENTER}", S1000, S250]
    ])
}
pmp40_(Element?, *) {
    RPAction([
        ["Chat", "/mee поставил мед.аптечку на землю, открыл ее и достал от туда Нитроглицерин, после же передал пациенту {ENTER}", S100, S100],
        ["Chat", "Возьмите эту таблетку под язык {ENTER}", S100, S100],
        ["Chat", "/do Через несколько минут таблетка подействовала и расширила артерии и снизила давление пациенту {ENTER}", S100, S250]
    ])
}
pmp41_(Element?, *) {
    RPAction([
        ["Chat", "/mee рассмотрел крепление ремня или галстука и помог пациенту ослабить их натяжение {ENTER}", S100, S100],
        ["Chat", "/do После действий мед.работника к пациенту пошел поток свежего воздуха {ENTER}", S100, S250]
    ])
}
pmp44_(Element?, *) {
    RPAction([
        ["Chat", "/mee присев к пациенту поставив аптечку рядом поворачивает его на правый бок взявшись за левую руку и левую ногу согнув при этом на 90 градусов и подкладывает его руку ему под голову, проверяет стопор колена и правильного положения пациента {ENTER}", S100, S700],
        ["Chat", "/mee открыв аптечку берет стерильные перчатки и одевает на свои руки, опрашивает прохожих и фиксирует с их слов время начала приступа {ENTER}", S700, S700],
        ["Chat", "/mee достает из аптечки шприц с лекарством, сняв колпачок с иглы и приспустив штаны человеку сделала укол в ягодичную мышцу {ENTER}", S700, S700],
        ["Chat", "/do Ожидает прохождения эпилептического шока, наблюдает состояние здоровья пациента {ENTER}", S700, S250]
    ])
}

PMPBindUI := AutoCreateUI("пмп")
AutoAddButton(PMPBindUI, "Вывих", pmp1_, "full")
AutoAddButton(PMPBindUI, "Закрытый перелом", pmp2_, "full")
AutoAddButton(PMPBindUI, "Открытый перелом", pmp3_, "full")
AutoAddButton(PMPBindUI, "Пулевое ранение", pmp15_, "full")
AutoAddButton(PMPBindUI, "Ножевое с ножом", pmp17_, "full")
AutoAddButton(PMPBindUI, "Ножевое без ножом", pmp18_, "full")
AutoAddButton(PMPBindUI, "Кровотечение: Артериальное", pmp25_, "full")
AutoAddButton(PMPBindUI, "Сотрясение мозга: проверка", pmp39_, "full")
AutoAddButton(PMPBindUI, "Сердечный приступ", pmp40_, "full")
AutoAddButton(PMPBindUI, "Сердечный приступ (рубашка, ремень)", pmp41_, "full")
AutoAddButton(PMPBindUI, "Эпилепсия", pmp44_, "full")
pmpbindy := AutoInitUI(PMPBindUI)


Cast(Element?, *) {
    RPAction([
        ["Chat", "/mee взяв тару и бутылку с водой из шкафа, наливает воду из бутылки в тару {ENTER}", S100, S2000],
        ["Chat", "/mee берет гипсовый бинт, вскрывает пачку и начинает раскладывать на столе в 6 слоев по одинаковому размеру, скрутив с двух сторон опускает на 3 секунды в воду {ENTER}", S2000, S2000],
        ["Chat", "/mee отжав лишнюю воду с бинтов, раскладывает на столе и  разглаживает гипсовый бинт {ENTER}", S2000, S2000],
        ["Chat", "/mee взяв двумя руками бинт прикладывает на место перелома, формирует и разглаживает края {ENTER}", S2000, S2000],
        ["Chat", "/mee подождав пару минут, проверяет подсыхание гипса надавив пальцами с краю, затем берёт бинт и начинает обматывать гипс, закрепляет конец бинта {ENTER}", S2000, S2000],
        ["Chat", "/todo Передавая костыли пациенту : Через 3 недели снимем гипс. {ENTER}", S2000, S2000]
    ])
}
MedHeal(Element?, *) {
    RPAction([
        ["Chat", "/med heal  " G_Binds_cfg["Global_HealPrice"] "{Left}{Left}{Left}{Left}", S100, S100]
    ])
}
GpsCansel(Element?, *) {
    RPAction([
        ["Chat", "/gps cancel {ENTER}", S100, S100]
    ])
}
Calls(Element?, *) {
    RPAction([
        ["Chat", "/calls {ENTER}", S100, S100]
    ])
}
PassAccept(Element?, *) {
    RPAction([
        ["Chat", "/pass accept {ENTER}", S100, S100]
    ])
}

SetHotKey(G_Binds["ForceStop"][1], ForceStop)
SetHotKey(G_Binds["UI_Main"][1], MainBindUIopen)
SetHotKey(G_Binds["UI_Educ"][1], EducBindUIopen)
SetHotKey(G_Binds["UI_Rare"][1], RareBindUIopen)
SetHotKey(G_Binds["UI_Menu"][1], MenuUIopen)
SetHotKey(G_Binds["Restart"][1], ReloadFromUI)
SetHotKey(G_Binds["Greetings"][1], greetings)
SetHotKey(G_Binds["GivePill"][1], give_pill)
SetHotKey(G_Binds["SellMed"][1], sell_pill)
SetHotKey(G_Binds["Bruise"][1], bruise)
SetHotKey(G_Binds["Ammonia"][1], ammonia)
SetHotKey(G_Binds["Inject"][1], inject)
SetHotKey(G_Binds["MedCard"][1], med_card)
SetHotKey(G_Binds["Discharge"][1], extract)
SetHotKey(G_Binds["Examination"][1], medical_examination)
SetHotKey(G_Binds["Suitability"][1], prof_suitability)
SetHotKey(G_Binds["Knife"][1], knife)
SetHotKey(G_Binds["Bullet"][1], peluvoe)
SetHotKey(G_Binds["Stretcher"][1], stretcher)
SetHotKey(G_Binds["Drip"][1], dropper)
SetHotKey(G_Binds["Defib"][1], defibrillator)
SetHotKey(G_Binds["TwistAndCalm"][1], twist)
SetHotKey(G_Binds["CalmInjection"][1], calm)
SetHotKey(G_Binds["PlasticSurgery"][1], plast_operation)
SetHotKey(G_Binds["BloodTest"][1], blood)
SetHotKey(G_Binds["WoundRepair"][1], wound)
SetHotKey(G_Binds["ExtractBullet"][1], bullet)
SetHotKey(G_Binds["ClosedFracture"][1], close_fracture)
SetHotKey(G_Binds["OpenFracture"][1], open_fracture)
SetHotKey(G_Binds["Xray"][1], rengen)
SetHotKey(G_Binds["Dislocation"][1], dislocation)
SetHotKey(G_Binds["CPR"][1], slrt)
SetHotKey(G_Binds["ECG"][1], ekgg)
SetHotKey(G_Binds["ApplyCast"][1], Cast)
SetHotKey(G_Binds["LectureIntern"][1], lecture)
SetHotKey(G_Binds["Regulation_Part1"][1], regulation1)
SetHotKey(G_Binds["Regulation_Part2"][1], regulation2)
SetHotKey(G_Binds["Regulation_Part3"][1], regulation3)
SetHotKey(G_Binds["Oath"][1], oath_start)
SetHotKey(G_Binds["Practice_RP1"][1], practice)
SetHotKey(G_Binds["Calls"][1], Calls)
SetHotKey(G_Binds["PassAccept"][1], PassAccept)
SetHotKey(G_Binds["MedHeal"][1], MedHeal)
SetHotKey(G_Binds["GPSCancel"][1], GpsCansel)
SetHotKey(G_Binds["HospitalID"][1], hospital_id)


if UpdateCheck
    CheckForUpdate()
if BeforeLimit {
    A_HotkeyInterval := 1000
    A_MaxHotkeysPerInterval := 1
}

if (VerCompare(A_OSVersion, "10.0.22200") < 0) {
    LogSent("[WinCheck] [Info] Версия Windows ниже 10.0.22200: -ColorWindow")
    LogSent("[WinCheck] [Info] Вы можете игнорировать ошибку -> ColorWindow")
}


; made with ❤️  by Agzes!
