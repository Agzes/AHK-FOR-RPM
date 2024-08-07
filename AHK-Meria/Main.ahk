#Requires AutoHotkey v2.0
#SingleInstance Force

global roles := ["Водитель", "Телохранитель", "Секретарь", "Председатель", "Адвокат", "Судья", "Вице. Губернатор", "Губернатор"]



SetWindowAttribute(GuiObj, DarkMode := True)
{
	global DarkColors          := Map("Background", "0x202020", "Controls", "0x404040", "Font", "0xE0E0E0")
	global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
	static PreferredAppMode    := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

	if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
	{
		DWMWA_USE_IMMERSIVE_DARK_MODE := 19
		if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
		{
			DWMWA_USE_IMMERSIVE_DARK_MODE := 20
		}
		uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
		SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
		FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
		switch DarkMode
		{
			case True:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := DarkColors["Background"]
			}
			default:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", False, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["Default"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := "Default"
			}
		}
	}
}
SetWindowTheme(GuiObj, DarkMode := True)
{   
	static GWL_WNDPROC        := -4
	static GWL_STYLE          := -16
	static ES_MULTILINE       := 0x0004
	static LVM_GETTEXTCOLOR   := 0x1023
	static LVM_SETTEXTCOLOR   := 0x1024
	static LVM_GETTEXTBKCOLOR := 0x1025
	static LVM_SETTEXTBKCOLOR := 0x1026
	static LVM_GETBKCOLOR     := 0x1000
	static LVM_SETBKCOLOR     := 0x1001
	static LVM_GETHEADER      := 0x101F
	static GetWindowLong      := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
	static SetWindowLong      := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
	static Init               := False
	static LV_Init            := False
	global IsDarkMode         := DarkMode

	Mode_Explorer  := (DarkMode ? "DarkMode_Explorer"  : "Explorer" )
	Mode_CFD       := (DarkMode ? "DarkMode_CFD"       : "CFD"      )
	Mode_ItemsView := (DarkMode ? "DarkMode_ItemsView" : "ItemsView")

	for hWnd, GuiCtrlObj in GuiObj
	{
		switch GuiCtrlObj.Type
		{
			case "Button", "CheckBox", "ListBox", "UpDown":
			{
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
			}
			case "ComboBox", "DDL":
			{
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
			}
			case "Edit":
			{
				if (DllCall("user32\" GetWindowLong, "Ptr", GuiCtrlObj.hWnd, "Int", GWL_STYLE) & ES_MULTILINE)
				{
					DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
				}
				else
				{
					DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
				}
			}
			case "ListView":
			{
				if !(LV_Init)
				{
					static LV_TEXTCOLOR   := SendMessage(LVM_GETTEXTCOLOR,   0, 0, GuiCtrlObj.hWnd)
					static LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
					static LV_BKCOLOR     := SendMessage(LVM_GETBKCOLOR,     0, 0, GuiCtrlObj.hWnd)
					LV_Init := True
				}
				GuiCtrlObj.Opt("-Redraw")
				switch DarkMode
				{
					case True:
					{
						SendMessage(LVM_SETTEXTCOLOR,   0, DarkColors["Font"],       GuiCtrlObj.hWnd)
						SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
						SendMessage(LVM_SETBKCOLOR,     0, DarkColors["Background"], GuiCtrlObj.hWnd)
					}
					default:
					{
						SendMessage(LVM_SETTEXTCOLOR,   0, LV_TEXTCOLOR,   GuiCtrlObj.hWnd)
						SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
						SendMessage(LVM_SETBKCOLOR,     0, LV_BKCOLOR,     GuiCtrlObj.hWnd)
					}
				}
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
				
				; To color the selection - scrollbar turns back to normal
				;DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_ItemsView, "Ptr", 0)

				; Header Text needs some NM_CUSTOMDRAW coloring
				LV_Header := SendMessage(LVM_GETHEADER, 0, 0, GuiCtrlObj.hWnd)
				DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", Mode_ItemsView, "Ptr", 0)
				GuiCtrlObj.Opt("+Redraw")
			}
		}
	}

	if !(Init)
	{
		; https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm#ExSubclassGUI
		global WindowProcNew := CallbackCreate(WindowProc)  ; Avoid fast-mode for subclassing.
		global WindowProcOld := DllCall("user32\" SetWindowLong, "Ptr", GuiObj.Hwnd, "Int", GWL_WNDPROC, "Ptr", WindowProcNew, "Ptr")
		Init := False
	}
}
WindowProc(hwnd, uMsg, wParam, lParam)
{
	critical
	static WM_CTLCOLOREDIT    := 0x0133
	static WM_CTLCOLORLISTBOX := 0x0134
	static WM_CTLCOLORBTN     := 0x0135
	static WM_CTLCOLORSTATIC  := 0x0138
	static DC_BRUSH           := 18

	if (IsDarkMode)
	{
		switch uMsg
		{
			case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
			{
				DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
				DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Controls"])
				DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Controls"], "UInt")
				return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
			}
			case WM_CTLCOLORBTN:
			{
				DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Background"], "UInt")
				return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
			}
			case WM_CTLCOLORSTATIC:
			{
				DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
				DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Background"])
				return TextBackgroundBrush
			}
		}
	}
	return DllCall("user32\CallWindowProc", "Ptr", WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
}
CloseNotify(GuiObject?, eventInfo?) {
    notify_save.Hide()
    Reload()
}
SaveSettings(GuiObject?, eventInfo?) {
    global rp_name, rp_role, rp_rang
    RegWrite(rp_name.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Name")
    RegWrite(rp_rang.Value, "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Role")
    if rp_role.Value != 1
        RegWrite(roles[rp_role.Value-1], "REG_SZ", "HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Rang")
    setup.Hide()
    notify_save.Show("w313 h109")
}
greetings(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("Здравствуйте.{ENTER}")
    Sleep(300)
    SendInput("{t}")
    Sleep(300)
    SendInput("Меня зовут " rp_name_data " моя должность " rp_role_data ", Чем могу помочь? {ENTER}")
    Return
}
pass(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(300)
    SendInput("{t}")
    Sleep(300)
    SendInput("/mee вытаскивает удостоверение из кармана, показывает его человеку напротив. {ENTER}")
    Sleep(350) ; 
    SendInput("{t}")
    Sleep(350)
    SendInput("/do Информация в документе: Личное удостоверение сотрудника Мэрии. Имя, Фамилия: " rp_name_data ". Должность: " rp_role_data ". Отдел: " rp_otdel_data ". Подпись Губернатора и печать Мэрии {ENTER}")
    Sleep(350) ; 
    SendInput("{t}")
    Sleep(350)
    SendInput("/mee после доказательства информации, захлопнул документ, перекинул его во вторую руку и положил обратно в карман.{ENTER}")
    Return
}
restart(GuiObject?, eventInfo?) {
    hide_ui()
    Reload()
}
tech(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("/mee запустил двигатель на короткое время, затем выключил и подождал, пока давление масла снизится{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee разместил домкрат для подъема машины и, после подъема автомобиля, установил подставки на опоры, дабы зафиксировать автомобиль в поднятом положении{ENTER}")
    Sleep(3000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee открутил пробку слива масла, чтобы масло могло вытечь из системы{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee открутил масляный фильтр, затем установил новый фильтр на место и затянул его{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee установил все детали на место, аккуратно опустил автомобиль на землю, затем утилизировал старое масло{ENTER}")
    Sleep(5000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee запустил двигатель и дал ему прогреться на протяжении нескольких минут, затем выключил двигатель и дал ему остыть{ENTER}")
    Sleep(3000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee проверил уровень масла на щупе, после, найдя резервуар для тормозной жидкости, очистил его от грязи и пыли{ENTER}")
    Sleep(6000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Уровень жидкости находиться между двумя метками на индикаторном стержне.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(6750)
    SendInput("/mee нашёл расширительный бачок и проверил уровень охлаждающей жидкости, а после проверил уровень жидкости гидроусилителя руля{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee снял колесо с тормозного механизма{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee снял тормозные колодки из механизма{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee установил новые тормозные колодки на место, используя крепежные детали{ENTER}")
    Sleep(6000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee несколько раз нажал на педаль тормоза, чтобы колодки притерлись к тормозным дискам{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee после проверки работоспособности тормозов установил колеса на место и затянул колесные гайки{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(10000)
    SendInput("/mee проверил общее состояние аккумулятора{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Аккумулятор не поврежден и не имеет коррозии на клеммах{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee снял крышку с каждой из ячеек и убедился, что уровень жидкости находится выше пластины аккумулятора{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee подключил вольтметр к аккумулятору, используя красный провод к положительной клемме, а черный - к отрицательной{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(10000)
    SendInput("/do Вольтметр показывает напряжение от 12,4 до 12,7 вольт{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee проверил состояние шлангов системы охлаждения на наличие трещин или других повреждений{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee проверил, нет ли утечек в системе охлаждения{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(6000)
    SendInput("/mee проверил состояние радиатора на наличие повреждений и загрязнений{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(9000)
    SendInput("/mee запустил двигатель, подождал, пока он разогреется и убедился, что вентилятор запускается при достижении определенной температуры{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee закрыл капот и опустил машину на землю, домкрат положил в багажник{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("Тех. обслуживание окончено{ENTER}")
    Sleep(100)
    Return
}
visit_to_meria(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(100)
    SendInput("Здравствуйте, я сотрудник правительства " rp_name_data ". Занимаюсь охраной мэрии. Представьтесь пожалуйста.{ENTER}")
    Sleep(500)
    SendInput("{t}")
    Sleep(500)
    SendInput("Какова ваша цель визита в здание правительства?{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(700)
    SendInput("/do Продолжает взглядом осматривать человека перед собой{ENTER}")
    Return
}
docs(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("Разрешите пожалуйста проверить ваши документы. {ENTER}")
    Sleep(300)
    SendInput("{t}")
    Sleep(300)
    SendInput("/pass {SPACE}")
    Return
}
stop_human(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("Извините но я обязан применить силу.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(400)
    SendInput("/me Быстро подойдя к человеку начал его захват. Быстрыми и тактичными действиями скручивает человека.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(500)
    SendInput("/do Человек на полу. Руки гражданина зафиксированны за спиной{ENTER}")
    Sleep(100)
    Return
}
docs_back(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/me Возвращает документы человеку напротив.{ENTER}")
    Sleep(100)
    SendInput("{t}")
    Sleep(100)
    SendInput("Пожалуйста проходите и хорошего вам дня.{ENTER}")
    Sleep(100)
    Return
}
request_dont(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("Сер, прошу вас не нарушать порядок мерии и покинуть здание.{ENTER}")
    Sleep(300)
    SendInput("{t}")
    Sleep(300)
    SendInput("/do Смотря на человека приготовился выводить его силой{ENTER}")
    Sleep(300)
    Return
}
get_fast(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("/me берет человека в захват.{ENTER}")
    Sleep(100)
    Return
}
give_pass(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("Cейчас я вам выдам бланк, заполните в полях имя и фамилию с заглавной буквы.{ENTER}")
    Sleep(300) ; 
    SendInput("{t}")
    Sleep(300)
    SendInput("/n РП имя должно быть без капса, без матов, без оскорблений, на русском языке Пример: Саша Браун, Плохой пример: Тупой Саня.{ENTER}")
    Sleep(4000) ; 
    SendInput("{t}")
    Sleep(600)
    SendInput("/todo забрав бланк из ящика и положив его на стол : Заполните все поля.{ENTER}")
    Sleep(300) ; 
    SendInput("{t}")
    Sleep(300) ; 
    SendInput("/todo берёт заполненный бланк, ставит на нем печать, печатает паспорт, передав его гражданину : Ваш паспорт готов, держите{!}.{ENTER}")
    Sleep(300) ; 
    SendInput("{t}")
    Sleep(300) ; 
    SendInput("/pass give{Space}")
    Sleep(300) ; 
    Return
}
change_pass(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("/me взял документы из рук гражданина, положил в тумбочку старый паспорт, после чего взял бланк на смену паспорта с рук гражданина и изменил в базе данных, а затем распечатал и передал новый паспорт гражданину{ENTER}")
    Sleep(300)
    SendInput("{t}")
    Sleep(300)
    SendInput("/pass changepass{Space}")
    Return
}
billboard(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(200)
    SendInput("/me достал плакат из сумки и начал клеить на пустой билборд{ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(200)
    SendInput("/billboard {ENTER}")
    Sleep(500)
    SendInput("{t}")
    Sleep(200)
    SendInput("/do Плакат висит ровно{ENTER}")
    Sleep(200)
    Return

}
price_udo(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(200)
    SendInput("{t}")
    Sleep(500)
    SendInput("Цена условно досрочного освобождения зависит от уровня розыска, с которым вы попали в КПЗ, и количества вашей законопослушности.{ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(1000)
    SendInput("Первый уровень розыска -> 7.000 {ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(200)
    SendInput("Второй уровень розыска -> 14.000 {ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(200)
    SendInput("Третий уровень розыска -> 42.000 {ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(200)
    SendInput("Четвертый уровень розыска -> 84.000 {ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(200)
    SendInput("Пятый уровень розыска -> 105.000 {ENTER}")
    Sleep(200)
    SendInput("{t}")
    Sleep(1000)
    SendInput("Каждую минуту сумма уменьшается на 350$ {ENTER}")
    Sleep(200)
    Return
}
check_pass(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(100)
    SendInput("Пожалуйста, скажите, по какой причине вы были задержаны и доставлены в КПЗ? На сколько лет вы были задержаны?{ENTER}")
    SendInput("{t}")
    Sleep(100)
    SendInput("Предъявите ваш паспорт для подтверждение личности и для проверки вашей законопослушности. {ENTER}")
    SendInput("{t}")
    Sleep(100)
    SendInput("/pass{Space}")
    Return
}
give_udo(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(500)
    SendInput("/me вынул из ящика подготовленные бланки на УДО и положил их на стол {ENTER}")
    Sleep(100)
    SendInput("{t}")
    Sleep(600)
    SendInput("/me взял из кармана пиджака ручку и начал заполнение документа, после чего протянул ручку и документ о соглашении на УДО задержанному гражданину{ENTER}")
    Sleep(100)
    SendInput("{t}")
    Sleep(300)
    SendInput("/advocate{Space}")
    Return
}
start_sud(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
	SendInput("{t}")
    Sleep(1000)
    SendInput("Итак дамы и господа, начинается заседание суда. Проводит его судья " rp_name_data ". {ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me Открыв папку,лежавшую на столе перед собой, начал читать информацию по делу {ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me Прочитав содержимое папки с делом закрыл её и положил на стол перед собой {ENTER}")
    Sleep(3000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("Теперь,когда дело повторно изучено, можно приступать к заседанию. {ENTER}")
    Sleep(100)
    Return
}
end_sud(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
	SendInput("{t}")
    Sleep(1000)
    SendInput("И так, выслушав все претензии со стороны истца и со стороны ответчика, комиссия решила удалится на совещание.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me Встав с места забирает с собой папки с досье по делу и доказательствами с обеих сторон .{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Все папки сложены в единую стопку и находятся в руках судьи{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me Поправив стопку у себя в руках удалился в зал совещаний.{ENTER}")
    Sleep(1000)
    Return
}
rules_sud(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("В течение всего судебного заседания запрещается разговаривать, издавать шумы или двигаться по залу суда без разрешения судьи. Аудио- и видеозапись разрешена только в открытом заседании, если судья не запретил съемку.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Присутствующие на суде обязаны обращаться друг к другу с уважением. Запрещено использование нецензурных выражений, физическое воздействие, повышение голоса или перебивание(исключение перебивания - протест).{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Обращение друг к другу осуществляется формально через `"Вы`". Слушатели не имеют права вмешиваться в ход судебного разбирательства и нарушать порядок заседания.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("К суду все обязаны обращаться как `"Ваша Честь`" или “Уважаемый суд”, избегая упоминания личных данных судьи. В начале заседания все встают.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Все участники суда выступают, давая показания, делая заявления и принимая решения суда, стоя. Исключения могут быть по разрешению судьи.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Участники должны прибыть на судебное разбирательство вовремя. Исключение составляют случаи, когда суд решает, что их присутствие необязательно.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Нарушение правил поведения в суде может быть расценено как неуважение к суду. Нарушители могут быть заключены под стражу в сизо до конца судебного разбирательства по решению судьи.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("Судья также может наложить административное или уголовное взыскание на лиц, нарушивших правила.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Перед началом заседания судья должен произнести следующую клятву суда, а затем все участники суда должны повторить ее: `"Клянетесь ли вы говорить правду и только правду?`" - `"Клянусь говорить правду и только правду`".{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("При проведении судебного заседания все обязаны соблюдать спокойствие и учтивость. Участники не могут обсуждать дело или вести диалоги без разрешения судьи.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Прерывать выступление других участников запрещено. Лица, имеющие право выступления, должны дождаться своей очереди и не мешать друг другу.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("В случае необходимости судья может дать указания по порядку поведения в зале судебного заседания. Все присутствующие обязаны следовать указаниям судьи без возражений.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Публичные высказывания о ходе разбирательства запрещены до завершения судебного процесса. Это включает обсуждение дела в СМИ, публичных местах и т.д.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("Перед началом судебного процесса судебный секретарь, судебный советник или судья обязаны ясно изложить все установленные правила судопроизводства, включая возможность заключения мирового соглашения.{ENTER}")
    Sleep(1000) ;
    SendInput("{t}")
    Sleep(1000)
    SendInput("В случае отклонения хотя бы одной из сторон от предложения о мировом соглашении, судебное разбирательство продолжается.{ENTER}")
    Sleep(1000) ;
    Return
}
walk_sud(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("И так, выслушав все претензии со стороны истца и со стороны ответчика, комиссия решила удалится на совещание. {ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me встав с места забирает с собой папки с досье по делу и доказательствами с обеих сторон{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Все папки сложены в единую стопку и находятся в руках судьи.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/me поправив стопку у себя в руках удалился в зал совещаний{ENTER}")
    Sleep(1000)
    Return
}
lecture_change_in_rpm(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000)
    SendInput("Здравствуйте господа, меня зовут " rp_name_data ". Сегодня хотелось бы поговорить об изменениях в штате с приходои нового губернатора.{ENTER}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("Губернатор принял решение об изменение комуникации между фракциями, тоесть. Теперь во время отчета вы ОБЯЗАТЕЛЬНО контактируете с другими фракциями. Полици с мэрией, СМИ с армией и т.д.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Так же хотелось бы затронуть тему Государственный мероприятий. Теперь для их проведения были созданы спец. фонды из которых изымаются деньги на эти самые мероприятия. Тоесть тем самым у низких слоев населения появился шанс заработать.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(7000)
    SendInput("Теперь речь пойдет об создании фондов для обучающихся. Это помоглы бы им выучится и получить хорошее образовани так же, мы заметили что если  вы даете деньги ученику он вас очень хорошо запоминает, так что, это неплохой способ прославиться среди нового поколения.{ENTER}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("И на последок, это гранты для политических гениев. Тоесть людей которые отлично показывают себя в политике штата. Ну, думаю это было бы неплохо ведь очень мало людей доходят до должности выше председателя, это бы увеличило их интерес к этой работе.{ENTER}")
    SendInput("{t}")
    Sleep(3000)
    SendInput("Ну а на этом все, спасибо что выслушали, а вам хорошего настроения и конца рабочего дня. Всем до свидания.{ENTER}")
    Return
}
lecture_alco(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Добрый день, уважаемые студенты{!} Сегодня Я - " rp_name_data " поговорю о вреде наркотиков, алкоголя и табака для нашего здоровья и жизни.{ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(4000)
    SendInput("Наркотики, алкоголь и табак - это вещества, которые, к сожалению, широко распространены в нашей жизни.{ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(4000)
    SendInput("Многие люди, особенно молодые, пробуют их из любопытства, желания оторваться или из-за давления со стороны сверстников.{ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(4000)
    SendInput("Однако, употребление наркотиков, алкоголя и табака может привести к серьезным последствиям для нашего здоровья и жизни. {ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Давайте сначала поговорим о наркотиках. наркотики это сильнодействующие вещества, которые вызывают нарушения функций организма и психики.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("В зависимости от вида наркотика, его дозы и способа употребления, наркомания может развиться очень быстро и привести к серьезным последствиям{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("например нарушения работы органов и систем организма, психические расстройства и даже смерть.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Теперь давайте поговорим об алкоголе. алкоголь это вещество, которое может вызвать зависимость и привести к серьезным последствиям для здоровья. {ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Употребление алкоголя может повредить печень, сердечно-сосудистую систему и мозг. {ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Алкоголизм может привести к психическим расстройствам, смерти и другим серьезным проблемам.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Также важно отметить, что алкоголь является одним из основных факторов риска для развития рака.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Поэтому, если вы регулярно употребляете алкоголь, то вы должны осознавать, что вы увеличиваете риск заболевания раком.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Наконец, давайте поговорим о табаке. Курение - это один из наиболее распространенных способов употребления табака{!}{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Табачный дым содержит более 4 000 вредных химических веществ которые могут повредить практически все органы и системы организма.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Курение может привести к раку легких, хроническим заболеваниям легких, сердечным заболеваниям, инфарктам и инсультам.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Употребление наркотиков, алкоголя и табака является серьезной проблемой для нашего здоровья и жизни.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Если вы хотите оставаться здоровыми и жить полноценной жизнью, то вам следует избегать употребления этих веществ.{ENTER}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("Лекция закончена. Спасибо за внимание.")
    Sleep(2000)
    Return
}
ak_yk(GuiObject?, eventInfo?) {
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("Здравствуйте, меня зовут " rp_name_data ".Мне хотелось бы рассказать вам о важности соблюдения Уголовного и Административного кодекса нашего штата.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Ну во первых соблюдение УК и АК помогут вам не оказаться в КПЗ.{ENTER}")
    SendInput("{t}")
    Sleep(2000)
    SendInput("Но перед этим я все таки советую вам прочитать и запомнить некоторые законы.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Если вы нарушили закон, то вас найдут и посадят в КПЗ.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Но если вас подставили или вы впринципе хотите оспорить решение гос.сотрудника то тогда вы можете подать в суд.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Только помните если вы проиграете суд вам придется платить за это. Если же вы его выиграете все издержки выплачивает подсудимый.{ENTER}")
    SendInput("{t}")
    Sleep(1000)
    SendInput("Ну а на этом лекция окончена, спасибо за то что выслушали.{ENTER}")
    Return
}
ekzam(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100)
    SendInput("Здравствуйте, меня зовут " rp_name_data ".Мне хотелось бы рассказать вам о важности соблюдения Уголовного и Административного кодекса нашего штата.{ENTER}")
    SendInput("{t}")
    Sleep(1000)
    SendInput("Ну во первых соблюдение УК и АК помогут вам не оказаться в КПЗ.{ENTER}")
    SendInput("{t}")
    Sleep(2000)
    SendInput("Но перед этим я все таки советую вам прочитать и запомнить некоторые законы.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Если вы нарушили закон, то вас найдут и посадят в КПЗ.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Но если вас подставили или вы впринципе хотите оспорить решение гос.сотрудника то тогда вы можете подать в суд.{ENTER}")
    SendInput("{t}")
    Sleep(4000)
    SendInput("Только помните если вы проиграете суд вам придется платить за это. Если же вы его выиграете все издержки выплачивает подсудимый.{ENTER}")
    SendInput("{t}")
    Sleep(1000)
    SendInput("Ну а на этом лекция окончена, спасибо за то что выслушали.{ENTER}")
    Return

}
get_permision(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    
}
hide_ui() {
    If WinExist("AHK | RP Термины") or WinExist("AHK | Основное"){    
        vodila.Hide()
        telo.Hide()
        sekr.Hide()
        pred.Hide()
        advo.Hide()
        cudia.Hide()
        vice.Hide()
        guber.Hide()
        main.Hide()
        Sleep(100)
        MouseClick("Left")
        Sleep(100) ;
        ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
        Sleep(100)
        SendInput("{Esc}")
    } else 
    {
        Sleep(400)
    }
}

licens_advo(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee зарегистрировался в свой рабочий аккаунт, зашел в закрытый канал реестра лицензий частных адвокатов и выдал лицензию частного адвоката {Enter}")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do В закрытом канале реестра появилась лицензия частного адвоката для: " licens_name.Value " на номер паспорта RPM-" licens_pass.Value "{Enter}")
    return
}
permision(GuiObject?, eventInfo?){
    hide_ui()
    currentDate := FormatTime(, "dd.MM.yyyy")
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(1000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Папка с разрешениями находится в руках{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee открывает папку и достаёт оттуда лист бумаги, после чего достает ручку из кармана и ставит подпись вписывая разрешение и данные человека на против.{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Информация в документе: `"Даю разрешение на " permision_for.Value " гражданину: " permisions_to.Value ", дата начала действия " currentDate ", подпись: " permisionfrom.Value "`"{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee передаёт разрешение человеку на против.{Enter}")
    Sleep(550)
    return
}
advok(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Папка с бланками в руках{Enter}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("/me открывает папку и достаёт оттуда бланк, после чего достает из кармана и ставит подпись.{Enter}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("/do Информация в документе: `"Я " rp_role_data " штата РПМ, " rp_name_data ", подписываю документ о снятии неприкосновенности с адвоката " advok_name.Value "`" {Enter}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(4000)
    currentDate := FormatTime(, "dd.MM.yyyy")
    SendInput("/do Дата начала действия документа: " currentDate ", подпись в документе: " advok_pass.Value "`" {Enter}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(4000)
    SendInput("/do Документ о снятии неприкосновенности с адвоката будет снят сразу как только его посадят за розыск{Enter}")
    Sleep(4000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee передаёт бланк человеку на против.{Enter}")
    Sleep(2000)
}

vlicens_advo(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(300)
    SendInput("/mee зарегистрировался в свой рабочий аккаунт, зашел в закрытый канал реестра лицензий частных адвокатов и выдал лицензию частного адвоката {Enter}")
    Sleep(100)
    SendInput("{t}")
    Sleep(300)
    SendInput("/do В закрытом канале реестра появилась лицензия частного адвоката для: " vlicens_name.Value " на номер паспорта RPM-" vlicens_pass.Value "{Enter}")
}
vpermision(GuiObject?, eventInfo?){
    hide_ui()
    currentDate := FormatTime(, "dd.MM.yyyy")
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(1000)
    SendInput("{t}")
    Sleep(100)
    SendInput("/do Папка с разрешениями находится в руках{Enter}")
    Sleep(100)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee открывает папку и достаёт оттуда лист бумаги, после чего достает ручку из кармана и ставит подпись вписывая разрешение и данные человека на против.{Enter}")
    Sleep(300)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Информация в документе: `"Даю разрешение на " vpermision_for.Value " гражданину: " vpermisions_to.Value ", дата начала действия " currentDate ", подпись: " vpermisionfrom.Value "`"{Enter}")
    Sleep(300)
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee передаёт разрешение человеку на против.{Enter}")
    Sleep(550)
}
vadvok(GuiObject?, eventInfo?){
    hide_ui()
    ErrorLevel := SendMessage(0x50, , 0x4190419, , "A")
    Sleep(100)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Папка с бланками в руках{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/me открывает папку и достаёт оттуда бланк, после чего достает из кармана и ставит подпись.{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Информация в документе: `"Я " rp_role_data " штата РПМ, " rp_name_data ", подписываю документ о снятии неприкосновенности с адвоката " vadvok_name.Value "`" {Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    currentDate := FormatTime(, "dd.MM.yyyy")
    SendInput("/do Дата начала действия документа: " currentDate ", подпись в документе: " vadvok_pass.Value "`" {Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/do Документ о снятии неприкосновенности с адвоката будет снят сразу как только его посадят за розыск{Enter}")
    Sleep(2000)
    SendInput("{t}")
    Sleep(2000)
    SendInput("/mee передаёт бланк человеку на против.{Enter}")
    Sleep(2000)
}




try {
    global rp_name_data := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Name")
    global rp_otdel_data := RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Role")
    global rp_role_data :=  RegRead("HKEY_CURRENT_USER\Software\Agzes\AHK_FOR_RPM\AHK_Meria", "Rang")
}
if !IsSet(rp_name_data) or !IsSet(rp_otdel_data) or !IsSet(rp_role_data) {
    setup := Gui()
    SetWindowAttribute(setup)
    setup.Opt("+AlwaysOnTop")
    setup.Title := "AHK | Привет! "
    setup.BackColor := 0x202020
    setup.SetFont("s16", "Impact")
    setup.AddText("cWhite","                           \ ( ' o ' ) /")
    setup.SetFont("s11", "Segoe UI")
    setup.AddText("cWhite   y37 x136","!привет!")
    setup.SetFont("s10", "Segoe UI")
    setup.Add("Text","cWhite x7 y65", "Для начала введи своё РП Имя и Фамилию ниже")
    rp_name := setup.Add("Edit", "vMyEdit w297 Background0x4e4e4e cWhite x7 y85")
    setup.Add("Text","x7 y136 cWhite",'А также выбери вашу должность в фракции выше')
    rp_role := setup.Add("DropDownList", "vMyDropDown cWhite w297 Background0x4e4e4e x7 y111 Choose1", ["Выбор","Водитель", "Телохранитель", "Секретарь", "Председатель", "Адвокат", "Судья", "Вице. Губернатор", "Губернатор"])
    save_button := setup.Add("Button", "w301 x6 y233" , "Сохранить")
    save_button.OnEvent("Click", SaveSettings)
    setup.Add("Text","cWhite x7 y165", "А ещё ты можешь ввести отдел если ты в нем:")
    rp_rang := setup.Add("Edit", " w297 Background0x4e4e4e cWhite x7 y185", "Отсутствует")
    SetWindowTheme(setup)
    setup.Show("w313 h268")
} else {
    setup := Gui()
    SetWindowAttribute(setup)
    setup.Opt("+AlwaysOnTop")
    setup.Title := "AHK | Настройки "
    setup.BackColor := 0x202020
    setup.SetFont("s16", "Impact")
    setup.AddText("cWhite","                           ( -_- )")
    setup.SetFont("s11", "Segoe UI")
    setup.AddText("cWhite   y37 x114","настройки")
    setup.SetFont("s10", "Segoe UI")
    setup.Add("Text","cWhite x7 y65", "РП Имя и Фамилию ниже")
    rp_name := setup.Add("Edit", "vMyEdit w297 Background0x4e4e4e cWhite x7 y85", rp_name_data)
    setup.Add("Text","x7 y136 cWhite",'Должность в фракции выше')
    rp_role := setup.Add("DropDownList", "vMyDropDown cWhite w297 Background0x4e4e4e x7 y111 Choose1", [rp_role_data,"Водитель", "Телохранитель", "Секретарь", "Председатель", "Адвокат", "Судья", "Вице. Губернатор", "Губернатор"])
    save_button := setup.Add("Button", "w301 x6 y233" , "Сохранить")
    save_button.OnEvent("Click", SaveSettings)
    setup.Add("Text","cWhite x7 y165", "Отдел если ты в нем ниже")
    rp_rang := setup.Add("Edit", " w297 Background0x4e4e4e cWhite x7 y185", rp_otdel_data)
    SetWindowTheme(setup)
}

notify_save := Gui()
SetWindowAttribute(notify_save)
notify_save.Opt("+AlwaysOnTop")
notify_save.Title := "AHK | Уведомление! "
notify_save.BackColor := 0x202020
notify_save.SetFont("s16", "Impact")
notify_save.AddText("cWhite","                           ( .❛ ᴗ ❛. )")
notify_save.SetFont("s11", "Segoe UI")
notify_save.AddText("cWhite   y37 x57","Я сохранил!  Да-да я сохранил!")
notify_save.SetFont("s10", "Segoe UI")
notify_button := notify_save.Add("Button", "w300 x7 y72" , "ОК")
notify_button.OnEvent("Click", CloseNotify)
SetWindowTheme(notify_save)




vodila := Gui()
SetWindowAttribute(vodila)
vodila.Opt("+AlwaysOnTop")
vodila.Title := "AHK | Основное"
vodila.BackColor := 0x202020
vodila.SetFont("s16", "Impact")
vodila.AddText("cWhite x10 y7","( ⚆_⚆ ) Водитель")
vodila.SetFont("s10", "Segoe UI")
vodila.Add("Button", "w300 x5 y40" , "Alt+Q | приветствие").OnEvent("Click", greetings)
vodila.Add("Button", "w300 x5 y75" , "Alt+1 | показать удостоверение").OnEvent("Click", pass)
vodila.Add("Button", "w300 x5 y110" , "тех. обслуживание").OnEvent("Click", tech)
vodila.AddText("cWhite   x5 y145","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(vodila)

telo := Gui()
SetWindowAttribute(telo)
telo.Opt("+AlwaysOnTop")
telo.Title := "AHK | Основное"
telo.BackColor := 0x202020
telo.SetFont("s16", "Impact")
telo.AddText("cWhite x10 y7","( ⚆_⚆ ) Телохранитель")
telo.SetFont("s10", "Segoe UI")
telo.Add("Button", "w300 x5 y40 " , "Alt+Q | приветствие").OnEvent("Click", greetings)
telo.Add("Button", "w300 x5 y75 " , "Alt+1 | показать удостоверение").OnEvent("Click", pass)
telo.Add("Button", "w300 x5 y110" , "NumPad1 | спросить цель визита в мэрию").OnEvent("Click", visit_to_meria)
telo.Add("Button", "w300 x5 y145" , "NumPad2 | попросить документы").OnEvent("Click",docs )
telo.Add("Button", "w300 x5 y180" , "NumPad3 | применить силу(задержать чела)").OnEvent("Click", stop_human)
telo.Add("Button", "w300 x5 y215" , "NumPad4 | вернуть документы").OnEvent("Click", docs_back)
telo.Add("Button", "w300 x5 y250" , "NumPad5 | попросить не нарушать порядок").OnEvent("Click", request_dont)
telo.Add("Button", "w300 x5 y285" , "NumPad6 | захват").OnEvent("Click", get_fast)
telo.AddText("cWhite x5 y320","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(telo)

sekr := Gui()
SetWindowAttribute(sekr)
sekr.Opt("+AlwaysOnTop")
sekr.Title := "AHK | Основное"
sekr.BackColor := 0x202020
sekr.SetFont("s16", "Impact")
sekr.AddText("cWhite x10 y7","( ⚆_⚆ ) Секретарь")
sekr.SetFont("s10", "Segoe UI")
sekr.Add("Button", "w300 w300 x5 y40" , "Alt+Q | приветствие").OnEvent("Click", greetings)
sekr.Add("Button", "w300 w300 x5 y75" , "Alt+1 | показать удостоверение").OnEvent("Click", pass)
sekr.Add("Button", "w300 w300 x5 y110" , "Alt+P | выдать паспорт").OnEvent("Click", give_pass)
sekr.Add("Button", "w300 w300 x5 y145" , "Alt+C | изменить паспорт").OnEvent("Click", change_pass)
sekr.AddText("cWhite   x5 y180","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(sekr)

pred := Gui()
SetWindowAttribute(pred)
pred.Opt("+AlwaysOnTop")
pred.Title := "AHK | Основное"
pred.BackColor := 0x202020
pred.SetFont("s16", "Impact")
pred.AddText("cWhite x10 y7","( ⚆_⚆ ) Председатель")
pred.SetFont("s10", "Segoe UI")
pred.Add("Button", "w300 x5 y40  x5 y40 " , "Alt+Q | приветствие").OnEvent("Click", greetings)
pred.Add("Button", "w300 x5 y75  x5 y75 " , "Alt+1 | показать удостоверение").OnEvent("Click", pass)
pred.Add("Button", "w300 x5 y110 x5 y110" , "Alt+P | выдать паспорт").OnEvent("Click", give_pass)
pred.Add("Button", "w300 x5 y145 x5 y145" , "Alt+C | изменить паспорт").OnEvent("Click", change_pass)
pred.Add("Button", "w300 x5 y180 x5 y180" , "Alt+B | развесить биллборд").OnEvent("Click", billboard)
pred.AddText("cWhite   x5 y215","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(pred)


advo := Gui()
SetWindowAttribute(advo)
advo.Opt("+AlwaysOnTop")
advo.Title := "AHK | Основное"
advo.BackColor := 0x202020
advo.SetFont("s16", "Impact")
advo.AddText("cWhite x10 y7","( ⚆_⚆ ) Адвокат")
advo.SetFont("s10", "Segoe UI")
advo.Add("Button", "w300 x5 y40 " , "Alt+Q | приветствие").OnEvent("Click", greetings)
advo.Add("Button", "w300 x5 y75 " , "Alt+1 | показать удостоверение").OnEvent("Click", pass)
advo.Add("Button", "w300 x5 y110" , "Alt+Y | назвать цены УДО").OnEvent("Click", price_udo)
advo.Add("Button", "w300 x5 y145" , "Alt+U | проверить паспорт и спросить звёзды").OnEvent("Click", check_pass)
advo.Add("Button", "w300 x5 y180" , "Alt+I | выдать УДО").OnEvent("Click", give_udo)
advo.Add("Button", "w300 x5 y215" , "Alt+P | выдать паспорт").OnEvent("Click", give_pass)
advo.Add("Button", "w300 x5 y250" , "Alt+C | изменить паспорт").OnEvent("Click", change_pass)
advo.AddText("cWhite   x5 y285","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(advo)


cudia := Gui()
SetWindowAttribute(cudia)
cudia.Opt("+AlwaysOnTop")
cudia.Title := "AHK | Основное"
cudia.BackColor := 0x202020
cudia.SetFont("s16", "Impact")
cudia.AddText("cWhite x10 y7","( ⚆_⚆ ) Судья")
cudia.SetFont("s10", "Segoe UI")
cudia.Add("Button", "w300 x5 y40 " , "Alt+Q | Приветствие").OnEvent("Click", greetings)
cudia.Add("Button", "w300 x5 y75 " , "Alt+1 | Показать удостоверение").OnEvent("Click", pass)
cudia.Add("Button", "w300 x5 y110" , "Начать суд").OnEvent("Click", start_sud)
cudia.Add("Button", "w300 x5 y145" , "Правила суда").OnEvent("Click", rules_sud)
cudia.Add("Button", "w300 x5 y180" , "Уйти на совещание").OnEvent("Click", walk_sud)
cudia.Add("Button", "w300 x5 y215" , "Закончить суд").OnEvent("Click", end_sud)
cudia.Add("Button", "w300 x5 y250" , "Alt+P | выдать паспорт").OnEvent("Click", give_pass)
cudia.Add("Button", "w300 x5 y285" , "Alt+C | изменить паспорт").OnEvent("Click", change_pass)
cudia.AddText("cWhite   x5 y320","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(cudia)


vice := Gui()
SetWindowAttribute(vice)
vice.Opt("+AlwaysOnTop")
vice.Title := "AHK | Основное"
vice.BackColor := 0x202020
vice.SetFont("s16", "Impact")
vice.AddText("cWhite x10 y7","( ⚆_⚆ ) Вице.Губернатор")
vice.SetFont("s10", "Segoe UI")
vice.Add("Button", "w300 w300 x5 y40 " , "Alt+Q | Приветствие").OnEvent("Click", greetings)
vice.Add("Button", "w300 w300 x5 y75 " , "Alt+1 | Показать удостоверение").OnEvent("Click", pass)
Tab2 := vice.Add("Tab3", "w300 h153 cWhite", ["Лицензия", "Разрешения", "Неприконсовенность"])

Tab2.UseTab(1)
vice.Add("Text", "x10 y150", "Гражданину:")
vlicens_name := vice.Add("Edit", "w204 x96 y146")
vice.Add("Text", "x10 y178" , "C паспортом:")
vlicens_pass := vice.Add("Edit", "w204 x96 y175")
vice.Add("Button", "w290 x10 y234" , "Выдать лицензию").OnEvent("Click", vlicens_advo)

Tab2.UseTab(2)
vice.Add("Text", "x10 y150" , "Разрешение на:")
vpermision_for := vice.Add("Edit", " w185 x115 y146")
vice.Add("Text", "x10 y178" , "Гражданину:")
vpermisions_to := vice.Add("Edit", "w204 x96 y175")
vice.Add("Text", "x10 y207" , "Подпись:")
vpermisionfrom := vice.Add("Edit", "w224 x76 y204", rp_name_data)
vice.Add("Button","w290 x10 y234" , "Выдать разрешение").OnEvent("Click", vpermision)

Tab2.UseTab(3)
vice.Add("Text", "x10 y150" , "С адвоката:")
vadvok_name := vice.Add("Edit", "w204 x96 y146")
vice.Add("Text", "x10 y178" , "Подпись:")
vadvok_pass := vice.Add("Edit", "w224 x76 y175", rp_name_data)
vice.Add("Button", "w290 x10 y234" , "Снять неприкосновенность").OnEvent("Click", vadvok)

SetWindowTheme(vice)

guber := Gui()
SetWindowAttribute(guber)
guber.Opt("+AlwaysOnTop")
guber.Title := "AHK | Основное"
guber.BackColor := 0x202020
guber.SetFont("s16", "Impact")
guber.AddText("cWhite x10 y7","( ⚆_⚆ ) Губернатор")
guber.SetFont("s10", "Segoe UI")
guber.Add("Button", "w300 w300 x5 y40 " , "Alt+Q | Приветствие").OnEvent("Click", greetings)
guber.Add("Button", "w300 w300 x5 y75 " , "Alt+1 | Показать удостоверение").OnEvent("Click", pass)
Tab := guber.Add("Tab3", "w300 h153 cWhite", ["Лицензия", "Разрешения", "Неприконсовенность"])

Tab.UseTab(1)
guber.Add("Text", "x10 y150", "Гражданину:")
licens_name := guber.Add("Edit", "w204 x96 y146")
guber.Add("Text", "x10 y178" , "C паспортом:")
licens_pass := guber.Add("Edit", "w204 x96 y175")
guber.Add("Button", "w290 x10 y234" , "Выдать лицензию").OnEvent("Click", licens_advo)

Tab.UseTab(2)
guber.Add("Text", "x10 y150" , "Разрешение на:")
permision_for := guber.Add("Edit", " w185 x115 y146")
guber.Add("Text", "x10 y178" , "Гражданину:")
permisions_to := guber.Add("Edit", "w204 x96 y175")
guber.Add("Text", "x10 y207" , "Подпись:")
permisionfrom := guber.Add("Edit", "w224 x76 y204", rp_name_data)
guber.Add("Button","w290 x10 y234" , "Выдать разрешение").OnEvent("Click", permision)

Tab.UseTab(3)
guber.Add("Text", "x10 y150" , "С адвоката:")
advok_name := guber.Add("Edit", "w204 x96 y146")
guber.Add("Text", "x10 y178" , "Подпись:")
advok_pass := guber.Add("Edit", "w224 x76 y175", rp_name_data)
guber.Add("Button", "w290 x10 y234" , "Снять неприкосновенность").OnEvent("Click", advok)


SetWindowTheme(guber)

main := Gui()
SetWindowAttribute(main)
main.Opt("+AlwaysOnTop")
main.Title := "AHK | Основное"
main.BackColor := 0x202020
main.SetFont("s16", "Impact")
main.AddText("cWhite x10 y7","( ⚆_⚆ ) Главная")
main.SetFont("s10", "Segoe UI")
main.Add("Button", "w300 x5  y40 " , "Alt+Q | Приветствие").OnEvent("Click", greetings)
main.Add("Button", "w300 x5  y75 " , "Alt+1 | Показать удостоверение").OnEvent("Click", pass)
main.Add("Button", "w300 x5  y110" , "NumPad1 | спросить цель визита в мэрию").OnEvent("Click", visit_to_meria)
main.Add("Button", "w300 x5  y145" , "NumPad2 | попросить документы").OnEvent("Click",docs )
main.Add("Button", "w300 x5  y180" , "NumPad3 | применить силу(задержать чела)").OnEvent("Click", stop_human)
main.Add("Button", "w300 x5  y215" , "NumPad4 | вернуть документы").OnEvent("Click", docs_back)
main.Add("Button", "w300 x5  y250" , "NumPad5 | попросить не нарушать порядок").OnEvent("Click", request_dont)
main.Add("Button", "w300 x5  y285" , "NumPad6 | захват").OnEvent("Click", get_fast)
main.Add("Button", "w300 x5  y320" , "Alt+P | выдать паспорт").OnEvent("Click", give_pass)
main.Add("Button", "w300 x5  y355" , "Alt+C | изменить паспорт").OnEvent("Click", change_pass)
main.Add("Button", "w300 x5  y390" , "Alt+B | развесить биллборд").OnEvent("Click", billboard)
main.Add("Button", "w300 x5  y425" , "Alt+Y | назвать цены УДО").OnEvent("Click", price_udo)
main.Add("Button", "w300 x5  y460" , "Alt+U | проверить паспорт и спросить звёзды").OnEvent("Click", check_pass)
main.Add("Button", "w300 x5  y495" , "Alt+I | выдать УДО").OnEvent("Click", give_udo)
main.Add("Button", "w300 x5  y530" , "Начать суд").OnEvent("Click", start_sud)
main.Add("Button", "w300 x5  y565" , "Закончить суд").OnEvent("Click", end_sud)
main.AddText("cWhite   x5 y600","   AHK | Meria | сделано Agzes[WertyKnack] с ❤")
SetWindowTheme(main)



:?:?тех.обслуживание::{
    Send("{Esc}")
    tech()
    return
}
:?:?суд1::{
    Send("{Esc}")
    start_sud()
    return
}
:?:?суд2::{
    Send("{Esc}")
    rules_sud()
    return
}
:?:?суд3::{
    Send("{Esc}")
    walk_sud()
    return
}
:?:?суд4::{
    Send("{Esc}")
    end_sud()
    return
}
:?:?лекц1::{
    Send("{Esc}")
    lecture_change_in_rpm()
    return
}
:?:?лекц2::{
    Send("{Esc}")
    lecture_alco()
    return
}
:?:?лекц3::{
    Send("{Esc}")
    ak_yk()
    return
}
F4::{
    if (rp_role_data == "Водитель")
        vodila.Show("w310")
    if (rp_role_data == "Телохранитель")
        telo.Show("w310")
    if (rp_role_data == "Секретарь")
        sekr.Show("w310")
    if (rp_role_data == "Председатель")
        pred.Show("w310")
    if (rp_role_data == "Адвокат")
        advo.Show("w310")
    if (rp_role_data == "Судья")
        cudia.Show("w310")
    if (rp_role_data == "Вице. Губернатор")
        vice.Show("w310")
    if (rp_role_data == "Губернатор")
        guber.Show("w310")
}
F8::{
    main.Show("w310")
}
F9::{
    setup.Show("w313 h268")
}
F10::{
    Reload
}
!q::{
    greetings()
    return
}
!1::{
    pass()
    return
}
!r::{
    restart()
    return
}
Numpad1::{
    visit_to_meria()
    return
}
Numpad2::{
    docs()
}
Numpad3::{
    stop_human()
}
Numpad4::{
    docs_back()
}
Numpad5::{
    request_dont()
    return
}
Numpad6::{
    get_fast()
    return
}
!p::{
    give_pass()
    return
}
!c::{
    change_pass()
    return
}
!y::{
    price_udo()
    return
}
!u::{
    check_pass()
    return
}
!i::{
    give_udo()
    return
}



