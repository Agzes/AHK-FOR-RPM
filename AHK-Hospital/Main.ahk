#Requires AutoHotkey v2.0
#SingleInstance Force

; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |  AHK Больница  | by Agzes | 02.04.23  |
; |         https://e-z.bio/agzes         |
; \_______________________________________/





StructFromPtr(StructClass, Address) => StructClass(Address)

class NMCUSTOMDRAWINFO
{
    static Call(ptr)
    {
        return {
            hdr: {
                hwndFrom: NumGet(ptr, 0 ,"uptr"),
                idFrom  : NumGet(ptr, 8 ,"uptr"),
                code    : NumGet(ptr, 16 ,"int")
            },
            dwDrawStage: NumGet(ptr, 24, "uint"),
            hdc        : NumGet(ptr, 32, "uptr"),
            rc         : RECT(
                NumGet(ptr, 40, "uint"),
                NumGet(ptr, 44, "uint"),
                NumGet(ptr, 48, "int"),
                NumGet(ptr, 52, "int")
            ),
            dwItemSpec : NumGet(ptr, 56, "uptr"),
            uItemState : NumGet(ptr, 64, "int"),
            lItemlParam: NumGet(ptr, 72, "iptr")
        }
        
        RECT(left := 0, top := 0, right := 0, bottom := 0)
        {
            static ofst := Map("left", 0, "top", 4, "right", 8, "bottom", 12)
            NumPut("int", left, "int", top, "int", right, "int", bottom, buf := Buffer(16))
            for k, v in ofst
                buf.DefineProp(k, {Get: NumGet.Bind(, v, "int"), Set: IntPut.Bind(v)})
            return buf
            IntPut(ofst, _, v) => NumPut("int", v, _, ofst)
        }
    }
}

class _Gui extends Gui
{
    static __New() => (super.Prototype.OnMessage := ObjBindMethod(this, "OnMessage"))

    static OnMessage(obj, Msg, Callback, AddRemove?)
    {
        OnMessage(Msg, _callback, AddRemove?)
        obj.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd)
        {
            if (uMsg = Msg && hWnd = obj.hwnd)
                return Callback(obj, wParam, lParam, uMsg)
        }
    }
}

class _BtnColor extends Gui.Button
{
    static __New() => super.Prototype.SetBackColor := ObjBindMethod(this, "SetBackColor")

    /**
     * @param {Gui.Button} myBtn omitted.
     * @param {integer} btnBgColor Button's background color. (RGB)
     * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`. **(Usually let it be transparent looks better.)**
     * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
     * > For Windows 11: Enabled. (value: 9)  
     * > For Windows 10: Disabled.   
     */
    static SetBackColor(myBtn, btnBgColor, colorBehindBtn?, roundedCorner?)
    {
        static BS_FLAT          := 0x8000
        static BS_BITMAP        := 0x0080
        static IS_WIN11         := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static WM_CTLCOLORBTN   := 0x0135
        static NM_CUSTOMDRAW    := -12
        static WM_DESTROY       := 0x0002
        static WS_EX_COMPOSITED := 0x02000000
        static WS_CLIPSIBLINGS  := 0x04000000

        rcRgn       := unset
        clr         := IsNumber(btnBgColor) ? btnBgColor : ColorHex(btnBgColor)
        isDark      := IsColorDark(clr)
        hoverColor  := RgbToBgr(BrightenColor(clr, isDark ? 15 : -15))
        pushedColor := RgbToBgr(BrightenColor(clr, isDark ? -10 : 10))
        clr         := RgbToBgr(clr)
        btnBkColr   := (colorBehindBtn??0) && RgbToBgr(ColorHex(myBtn.Gui.BackColor))
        hbrush      := btnBkColr ? CreateSolidBrush(btnBkColr) : GetStockObject(5)

        myBtn.Gui.Opt("+" WS_CLIPSIBLINGS)
        myBtn.Gui.OnMessage(WM_CTLCOLORBTN, ON_WM_CTLCOLORBTN)

        if btnBkColr
            myBtn.Gui.OnEvent("Close", (*) => DeleteObject(hbrush))

        myBtn.Opt("+" (WS_CLIPSIBLINGS | BS_FLAT | BS_BITMAP))
        SetWindowTheme(myBtn.hwnd, isDark ? "DarkMode_Explorer" : "Explorer")
        myBtn.OnNotify(NM_CUSTOMDRAW, ON_NM_CUSTOMDRAW)
        myBtn.Redraw()

        ON_WM_CTLCOLORBTN(GuiObj, wParam, lParam, Msg)
        {
            Critical(-1)

            if btnBkColr 
                SelectObject(wParam, hbrush),
                SetBkMode(wParam, 0),
                SetBkColor(wParam, btnBkColr)

            return hbrush 
        }

        ON_NM_CUSTOMDRAW(gCtrl, lParam)
        {
            static CDDS_PREPAINT        := 0x1
            static CDDS_PREERASE        := 0x3
            static CDIS_HOT             := 0x40
            static CDRF_NOTIFYPOSTPAINT := 0x10
            static CDRF_SKIPPOSTPAINT   := 0x100
            static CDRF_SKIPDEFAULT     := 0x4
            static CDRF_NOTIFYPOSTERASE := 0x40
            static CDRF_DODEFAULT       := 0x0
            static DC_BRUSH             := GetStockObject(18)
            static DC_PEN               := GetStockObject(19)
            
            Critical(-1)

            lpnmCD := StructFromPtr(NMCUSTOMDRAWINFO, lParam)

            if (lpnmCD.hdr.code != NM_CUSTOMDRAW || lpnmCD.hdr.hwndFrom != gCtrl.hwnd)
                return
            
            switch lpnmCD.dwDrawStage {
            case CDDS_PREERASE:
            {
                if (roundedCorner ?? IS_WIN11) {
                    rcRgn := CreateRoundRectRgn(lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right, lpnmCD.rc.bottom, roundedCorner ?? 9, roundedCorner ?? 9)
                    SetWindowRgn(gCtrl.hwnd, rcRgn, 1)
                }

                SetBkMode(lpnmCD.hdc, 0)
                return CDRF_NOTIFYPOSTERASE 
            }
            case CDDS_PREPAINT: 
            {
                brushColor := (!(lpnmCD.uItemState & CDIS_HOT) ? clr : (GetKeyState("LButton", "P")) ? pushedColor : hoverColor)

                SelectObject(lpnmCD.hdc, DC_BRUSH)
                SetDCBrushColor(lpnmCD.hdc, brushColor)
                
                SelectObject(lpnmCD.hdc, DC_PEN)
                SetDCPenColor(lpnmCD.hdc, gCtrl.Focused ? 0x1C1C1C : brushColor)

                if gCtrl.Focused 
                    DrawFocusRect(lpnmCD.hdc, lpnmCD.rc)

                rounded := !!(rcRgn ?? 0)

                RoundRect(lpnmCD.hdc, lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right - rounded, lpnmCD.rc.bottom - rounded, roundedCorner ?? 9, roundedCorner ?? 9)

                if rounded {
                    DeleteObject(rcRgn)
                    rcRgn := ""
                }

                return CDRF_NOTIFYPOSTPAINT 
            }}
            
            return CDRF_DODEFAULT
        }

        static RgbToBgr(color) => (IsInteger(color) ? ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16) : NUMBER(RegExReplace(STRING(color), "Si)c?(?:0x)?(?<R>\w{2})(?<G>\w{2})(?<B>\w{2})", "0x${B}${G}${R}")))

        static CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('Gdi32\CreateRoundRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')

        static CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        static ColorHex(clr) => Number((!InStr(clr, "0x") ? "0x" : "") clr)

        static DrawFocusRect(hDC, lprc) => DllCall("User32\DrawFocusRect", "ptr", hDC, "ptr", lprc, "int")

        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

        static SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')

        static SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

        static SetWindowRgn(hWnd, hRgn, bRedraw) => DllCall("User32\SetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int", bRedraw, "int")

        static DeleteObject(hObject) {
            DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')
        }

        static FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

        static IsColorDark(clr) => 
            ( (clr >> 16 & 0xFF) / 255 * 0.2126 
            + (clr >>  8 & 0xFF) / 255 * 0.7152 
            + (clr       & 0xFF) / 255 * 0.0722 < 0.5 )

        static RGB(R := 255, G := 255, B := 255) => ((R << 16) | (G << 8) | B)
        
        static BrightenColor(clr, perc := 5) => ((p := perc / 100 + 1), RGB(Round(Min(255, (clr >> 16 & 0xFF) * p)), Round(Min(255, (clr >> 8 & 0xFF) * p)), Round(Min(255, (clr & 0xFF) * p))))

        static RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight) => DllCall('Gdi32\RoundRect', 'ptr', hdc, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidth, 'int', nHeight, 'int')
        
        static SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)
        
        static SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
        
        static SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')
                
        static SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')
        
        static SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')
    }
}


greetings(GuiObject?, eventInfo?)
{      
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(500)
    SendInput("Здравствуйте, чем я могу вам помочь? {ENTER}")
    Return
}
give_pill(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["Красная аптечка","Аптечка с красным крестом","Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(500) ;
    SendInput("/mee осмотрел пациента, затем выявил проблему и приступил искать лекарство или таблетку в своей аптечке {Enter}")
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500)  ;
    SendInput(temp2 " {Enter}")
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500) ;
    SendInput("/mee найдя нужное лекарство, достаёт и передает пациенту напротив, затем закрывает аптечку {Enter}")
    Sleep(500) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Return
}
sell_pill(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["Красная аптечка","Аптечка с красным крестом","Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    list2 := ["красную аптечку","аптечку с красным крестом","аптечку"]
    temp3 := list2[r1]
    temp4 := "/mee открыв " . temp3 . " и найдя нужное лекарство передаёт человеку напротив, затем подписывает листок на котором написана дата выдачи, а также имя и фамилия врача который его выдал"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(500) ;
    SendInput(temp2 " {Enter}")
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500) ;
    SendInput(temp4 " {Enter}")
    Sleep(500) ;
    SendInput("{t}")
    Sleep(500) ;
    SendInput("/med sell")
    Return
}
bruise(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["Красная аптечка","Аптечка с красным крестом","Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300) ;
    SendInput(temp2 " {Enter}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee открыв свою аптечку ищет и достаёт мазь, затем одевает на свои руки перчатки и осматривает место ушиба пациента {Enter}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee открыв крышку тюбика мази, и выдавив на перчатку немного мази начинает намазывать место ушиба пострадавшему, после этого берет бинт распаковав из пачки, забинтовывает место ушиба пациента {Enter}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Return
}
ammonia(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee открывает аптечку и достает нашатырный спирт вместе с ваткой, затем открывает крышку банки и немного смочив ватку подносит её перед носом человека без сознания, ожидая когда он придет в себя {Enter}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/mee закрывает крышку банки и убирает нашатырь обратно в аптечку, продолжая наблюдать за состоянием пациента {ENTER}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(300) ;
    SendInput("/med heal  100")
    Sleep(300) ;
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Return
}
stretcher(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(500)
    SendInput("/mee осмотрел пострадавшего и убедивщись что его можно перевозить, затем аккуратно укладывает его на носилки {ENTER}")
    Sleep(500) ; 
    SendInput("{t}")
    Sleep(500)
    SendInput("/do Пострадавший лежит на носилках {ENTER}")
    Return
}
defibrillator(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee достает дефибриллятор и ставит рядом с пациентом на твердую и устойчивую поверхность{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee оголив торс от одежды пациента берёт гель из своей аптечки, открыв крышку геля наносит его на правую ключицу, а также на левый бок под грудь{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Взяв электроды кладет их на намазанные места гелем : Разряд! {ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Подаётся напряжение, тело человека резко дернулось{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/try Пациент реанимирован?{ENTER}")
    Return
}
inject(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["Красная аптечка","Аптечка с красным крестом","Аптечка"]
    r1 := Random(1, 3)
    temp := list[r1]
    temp2 := "/do " . temp . " в руках у мед. работника"
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300) ;
    SendInput(temp2 " {Enter}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee достает из аптечки шприц, спиртовую салфетку и бинт, протирает место для укола спиртовой салфеткой и начинает делать укол аккуратно вводя иглу в мышечную ткань{ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/do Инъекция была сделана{ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee прикладывая ватку на место укола вытаскивает иглу, убирает ватку и заклеивает место прокола кусочком пластыря {ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/med inject")
    Return
}
dropper(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee ставит стойку для капельницы около кровати, проверая устойчивая ли стойка для капельницы {ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee взяв нужный флакон лекарства, вставляет в стойку флакон лекарства {ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee взяв жгут ставит его чуть выше изгиба руки пациенту, протерает место для укола спиртовой салфеткой и начинает вводить катетер в набухшую вену, одновременно снимая жгут{ENTER}")
    Sleep(700) ; 
    SendInput("{t}")
    Sleep(700)
    SendInput("/mee берёт пластырь, отмотав 3 см оторывает кусок и закрепляет катетер пригладив пластырь к коже руки пациента{ENTER}")
    Return
}
medcard(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee взяв паспорт из рук гражданна и держа его в руках, сверяет данные и проверяет фотографию, после чего, берёт чистую и незаполненную медкарту из аптечки и начинает заполнять по паспортным данным {ENTER}")
    Sleep(500) ; 
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/todo Заполнив мед. карту, ставит штамп и расписывается, а затем передает посетителю вместе с паспортом : проверяйте. {ENTER}")
    Sleep(500) ; 
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/n Смотреть свою медкарту командой /med card , там можно узнать о зависимостях, есть ли у вас переломы, ушибы, отравление и тд   {ENTER}")
    Sleep(300) ; 
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med givecard")
    Return
}
extract(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee осмотрел пациента увидел что с ним всё хорошо, берёт незаполненную справку из сумки которая весит на плече и записывает имя человека на него, затем убирает справку в сумку {ENTER}")
    Sleep(300) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Return
}
medical_examination(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee сняв стетоскоп со своей шеи и приподняв рубашку человеку напротив, начинает прослушивать дыхание{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee обойдя со спины продолжает прослушивать дыхание{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Опустив рубашку пациенту и повесив обратно стетоскоп себе на шею : Дыхание чистое.{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do На плече висит медицинская сумка{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee достав тонометр из медицинской сумки и надев манжет на руку пациента выше локтя,  начинает накачивать воздух в манжет, измеряет давление смотря на манометр{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Измерив давление, снимая манжет с руки пациента : Давление в норме.{ENTER}")
    Sleep(1850)
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Подписывает справку, передав человеку напротив : Вы прошли мед.осмотр, вы здоровы.{ENTER}")
    Return
}
prof_suitability(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee снимает стетоскоп со своей шеи, начинает проверять дыхание, затем берёт тонометр и измеряет давление {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/todo Убирая все на свое место : Дыхание и давление у вас в норме. {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee достаёт из кармана халата фонарик и начинает поочерёдно светить в глаза, смотря на реакцию зрачка {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/todo Выключив фонарик, вовзращая его в карман медицинского халата : Всё в порядке. {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/mee достав отоскоп из медицинской сумки, держит ухо пациента слегка натянутым, прислонив отоскоп в каждое ухо по очереди, осматривает слуховой аппарат {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/todo Закончив осмотр слухового аппарата и спрятав отоскоп в медицинскую сумку : Слуховой аппарат в норме. {ENTER}")
    Sleep(5000) ;
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/todo Выписывает справку, после чего передаёт человеку напротив : Вы здоровы и прошли осмотр на проф.пригодность. {ENTER}")
    Sleep(1850)
    Return
}
twist(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(750)
    SendInput("/mee резким движением взяв руку неадекватного пациента и скрутил за его спину повалив его прижав к поверхности, подставил свое колено к спине пациента зажимая его {ENTER}")
    Sleep(750) ; 
    SendInput("{t}")
    Sleep(750)
    SendInput("/do Пациенту трудно двигаться {ENTER}")
    Sleep(750) ; 
    SendInput("{t}")
    Sleep(750)
    SendInput("/mee достает свободной рукой из кармана халата шприц с успокаивающим средством, снимая колпачок своими зубами и приспустив воздух вкалывает его в плечо пациента и убирает пустой шприц обратно в карман {ENTER}")
    Sleep(750) ; 
    SendInput("{t}")
    Sleep(750)
    SendInput("/do На пациента начинает действовать лекарство и он слабеет, успокаивается {ENTER}")
    Sleep(750) ; 
    SendInput("{t}")
    Sleep(750)
    SendInput("/mee поднимает пациента придерживая его руку за спиной {ENTER}")
    Return
}
calm(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(300)
    SendInput("/mee засунув руку в карман и нащупав шприц с успокаивающим, незаметно достает его и приоткрывает колпачок приспускает воздух из шприца слегка нажав, вкалывает в плечо пациента и приспускает медленно лекарство придерживая пациента {ENTER}")
    Return
}
blood_vien(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee одевает перчатки и достает жгут из медицинской сумки{ENTER}")
    Sleep(1000) ; 
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee налкладывает жгут на середину плеча, через пару секунд вена набухла, затем берёт антисептическую салфетку вскрывает ее из пачки, протирает место укола{ENTER}")
    Sleep(1000) ; 
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee взяв иглу распечатывает из пачки, вводит её в вену пациента и потихоньку набирает кровь в шприц{ENTER}")
    Sleep(1000) ; 
    SendInput("{t}")
    Sleep(1000)
    SendInput("/do Необходимое количество крови набрано{ENTER}")
    Sleep(1000) ; 
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee извлекает иглу из вены и прикладывает салфетку к руке пациента, надорвав ленту пластыря наклеивает сверху на салфетку пригладив края к коже руки{ENTER}")
    Sleep(1000) ; 
    SendInput("{t}")
    Sleep(1000)
    SendInput("/mee выкидывает использованную иглу и вскрытые пачки в урну{ENTER}")
    Return
}
blood(GuiObject?, eventInfo?)
{   
    hide_ui()
    ErrorLevel := SendMessage(0x20, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee одевает перчатки и достаёт из медицинской сумки жгут{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Наложив жгут на середину плеча : Сжимайте и разжимайте кулак{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Вена расширилась {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Взяв иглу и распечатав из пачки, вводит её в вену пациента : Разжимайте кулак.{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee подставив пробирку к игле и сняимает жгут с руки пациента, набирает кровь медленно стекающую в пробирку{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Необходимое количество крови набрано {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Извлекая иглу из вены и прикладывает чистую салфетку к руке пациента : Согните руку в суставе{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Выкидывает использованную иглу в урну : Ожидайте анализов.{ENTER}")
    Return
}
wound(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee надевает стерильные перчатки и начинает осматривать рану у пациента{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв шприц, распечатывает его из новой упаковки, затем берет ампулу, надламывает верхушку и сняв колпачок с иглы шприца набирает лекарство {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee протерев спиртовой салфеткой место укола, вводит в мышечную ткань иглу, начинает медленно вводить лекарство{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Укол сделан{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee вытаскивает иглу и выкидывает шприц в мусорку{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв антисептик начинает обрабатывать рану, затем берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Рана зашита{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee отложив иглу с пинцетом, берет бинт начинает перебинтовывать рану{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Рана перебинтована{ENTER}")
    Return
}
wound_plus(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee подготовив операционный стол и пациента, раскладывает нужные инструменты перед собой и одевает стерильные перчатки{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee одевает маску анестезии на нос и рот пациента, ожидает когда на пациента подействует наркоз{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв антисептик начинает обрабатывать рану и приступает к операции{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee заканчивает операцию обработав еще раз рану, берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв бинт, забинтовывает {ENTER}")
    Sleep(1850) ;
    SendInput("{t}")
    Sleep(1850) ;
    SendInput("/do Операция прошла успешно{ENTER}")
    Return
}
bullet(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee подготавливает инструменты и надевает стерильные перчатки {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв шприц с обезболивающим выпустив воздух из иглы начинает делать укол в районе огнестрела протерев место укола салфеткой {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee сделав укол, выкидывает шприц в мусорку {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee берёт скальпель начинает делать надрез {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee отложив скальпель берет разжим и щипцы, начинает извлекать пулю разжав щипцами ткань {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee вытащив пулю кладет ее на поднос {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee обрабатывает рану спреем, подтирает капли вокруг раны стерильной салфеткой {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет держа иглу зашивает рану {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв бинты начинает забинтовывать {ENTER}")
    Sleep(1850) ;
    SendInput("{t}")
    Sleep(1850) ;
    SendInput("/do Рана зашита. Бинты наложены {ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Передавая пулю пациенту : Держите на память. {ENTER}")
    Return
}
rengen(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee включает рентген и нажимает кнопку пуска{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/do Рентген аппарат включён, идет сканирование{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee распечатывает снимок и взяв его из принтера поднеся к свету рассматривает снимок, ставит диагноз{ENTER}")
    Return
}
dislocation(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee одевает перчатки, подготавливает салфетки и ампулу с обезболивающим, надломив ампулу и взяв шприц вскрытый из новой пачки, набирает обезболивающее из ампулы{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee держа шприц с обезболивающим выпустив воздух из иглы начинает делать укол протерев место укола салфеткой{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв конечность пациента начинает потихоньку натягивать на себя и вправляет сустав в нужную сторону{ENTER}")
    Return
}
close_fracture(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/todo Включив рентген и сняв снимки смотрит на них, затем ставит диагноз с дальнейшим исправлением : У вас закрытый перелом. {ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee взяв шприц с обезболивающим и салфетку, протерев место укола, выпустив воздух из иглы, начинает делать укол в районе перелома, приложив после на пару секунд салфетку на место укола, затем принимается вправлять кость {ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(1850) ; 
    SendInput("/do Кость вправлена{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/mee подготавливает гипсовый бинт, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома, подождав пару минут, проверяет подсыхание гипса, затем берёт бинт и начинает накладывать поверх гипса{ENTER}")
    Sleep(2000) ; 
    SendInput("{t}")
    Sleep(1000) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(1000) ;
    Return
}
open_fracture(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/todo Включив рентген, смотрит на монитор и ставит диагноз с дальнейшим исправлением : У вас открытый перелом. {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee подготовив операционный стол и пациента, раскладывает нужные инструменты перед собой и одевает стерильные перчатки {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee ставит катетер, присоединяет трубку с анестезией пациенту, ожидает когда на пациента подействует наркоз {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee взяв антисептик, начинает обрабатывать рану, проводит манипуляции с восстановлением костной ткани {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee берет медицинскую нить и иглу, продевает нить в ушко иглы и взяв пинцет, держа иглу, зашивает рану, после чего взяв бинты, начинает забинтовывать поврежденную конечность пациента {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee начинает подготавливать гипсовый бинт, налив воды в тару, размачивает и раскладывает рядом на столе, затем берёт бинт и накладывает на место исправленного перелома {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(3000) ;
    SendInput("/mee действие лекарства заканчивается и пока пациент приходит в себя, проверяет подсыхание гипса, затем берёт бинт и начинает обматывать гипс, закрепляет конец бинта и снимает катетер с закончившим уже наркозом, накладывает повязку {ENTER}")
    Sleep(3000) ; 
    SendInput("{t}")
    Sleep(100) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(1850)
    Return
}
gypsum(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв тару и бутылку с водой из шкафа, наливает воду из бутылки в тару{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee берет гипсовый бинт, вскрывает пачку и начинает раскладывать на столе в 6 слоев по одинаковому размеру, скрутив с двух сторон опускает на 3 секунды в воду{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee отжав лишнюю воду с бинтов, раскладывает на столе и  разглаживает гипсовый бинт{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee взяв двумя руками бинт прикладывает на место перелома, формирует и разглаживает края{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/mee подождав пару минут, проверяет подсыхание гипса надавив пальцами с краю, затем берёт бинт и начинает обматывать гипс, закрепляет конец бинта{ENTER}")
    Sleep(1850) ; 
    SendInput("{t}")
    Sleep(1850)
    SendInput("/todo Передавая костыли пациенту : Через 3 недели снимем гипс.{ENTER}")
    Return
}
lecture(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Гиппократ – великий древнегреческий врач и философ, вошедший в историю как “отец медицины”. Его медицинские трактаты оказали огромное влияние на медицинскую науку и практику. В биографии Гиппократа есть немало ярких и  трагических моментов, которые  {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("способствовали развитию его дарования. Гиппократ был первым врачом, отвергшим теорию о том, что болезни на человека насылают боги. Благодаря ему медицина была выделена в отдельную науку. По мнению великого врача, болезнь является следствием влияния  {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("характера человека, его питания, привычек, а также природных факторов. Гиппократ принадлежал к Косской школе врачей. Ее представители стремились отыскать первопричину патологии.  {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("Для этого за больными организовывалось наблюдение. Врачи создавали специальный режим, способствующий самоизлечению. В это время был “рожден” один из важнейших принципов великого врача – “Не навреди”.  {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("Вы прослушали лекцию.  {ENTER}")
    Return
}
regulation1(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Вы готовы сдать тест по уставу?  {ENTER}")
    Return
}
regulation2(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["3.5","2.12","3.7","2.18","2.19","1.2","2.7","1.4","2.9","2.4","1.3","2.16","2.17","3.3","2.13","3.6","2.5","2.8","4.2","4.1","2.10","2.15","1.1","2.2","2.20","2.6","3.6.1","2.11","3.1","3.9","2.14","3.8","4.0","2.3","2.1","3.2","3.4"]
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
    Sleep(850) ; 
    SendInput(sentence " {ENTER}")
}
regulation3(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["ГКБ","НРС","СЛР","МЗ","ПМП","СПИД","АИК","ЧМТ","ИМ","ДС","НИВЛ","ЭКГ","УЗИ","ВИЧ","ТТЖ","ОЧМТ","МРТ","ЛФК","МП","КТГ","ИВЛ","ЖКТ","СМП","ПП"]
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
    Sleep(850) ; 
    SendInput(sentence " {ENTER}")
}
regulation4(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Вы сдали тест на Устав и термины Больницы. {ENTER}")
    Return
}
oath(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Вы дали клятву Гиппократа. {ENTER}")
    Return
}
assingments(GuiObject?, eventInfo?)
{   
    hide_ui()
    list := ["разложи медикаменты по ящикам в архиве","помой стенки лифта","протри листики деревьев на 1 этаже","поменяй постельное белье на кроватях в 6 палате","покорми рыбок на -1 этаже", "поправь одеяла и подушку в 6 палате","протри раковины в туалете","подмети дорожку у входа в больницу","заправь кровати в палате номер 6","полей цветы в горшках в холле","помой стойку регистратуры","протри пыль на полках регистратуры","помой полы в архиве","поправь стулья в зале собраний","пребири и поправь папки в архиве","помой окна на 1 этаже","поправь книги на полках в комнате отдыха","помой полы на 1 этаже","помой пол в лифте"]
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
    Sleep(850) ; 
    SendInput(sentence " {ENTER}")
}
practice(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("/do Манекен лежит в шкафу {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("/me достал манекен из шкафа и затем положил на кушетку  {ENTER}")
    Sleep(850) ;
    SendInput("{е}")
    Sleep(850) ; 
    SendInput("У него закрытый перелом, приступай.  {ENTER}")
    Return
}
practice2(GuiObject?, eventInfo?)
{   
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Вы сдали практику на парамедика. {ENTER}")
    Return
}
oath_start(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(100) ;
    SendInput("Вы готовы дать клятву Гиппократа? {ENTER}")
    Return
}
pmp1_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Внимательно осматривая пациента и обнаруживая вывих в области сустава : У вас вывих сустава, сейчас вам помогу. {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee надевает перчатки, выдавливает небольшое кол-во Лидокаина на ватный диск и начинает промазывать им нужное место для купирования боли {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee аккуратно устанавливает поврежденный сустав в нормальное положение, применяя мягкий тягостойкий бандаж {ENTER}")
    Sleep(3000) ;
    Return
}
pmp2_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстро берет из аптечки шину, бинты и накладывает ее с двух боковых сторон от конечности, дабы иммобилизовать ее, после чего обматывает бинтами {ENTER}")
    Sleep(3000) ;
    Return
}
pmp3_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee открывает аптечку и достает от туда жгут, после чего накладывает его на место выше места кровотечения, после же берет из аптечки шину, бинты и накладывает ее в места, где не выступают кости и обматывает бинтами {ENTER}")
    Sleep(3000) ;
    Return
}
pmp4_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("Для начала сядьте и облокотилась немного вперед, это нужно для того чтобы кровь не попадал в горло и не вызывала кашель {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee тщательно осматривает нос пациента, а после берет перекись, ватку и аккуратно обрабатывает ссадины {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Доставая из аптечки 2 стерильных тампона смачивает их в растворе перикиси и вставляя в ноздри пациент {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достает из сумки мед.пакет со льдом и аккуратно, не надавливая на нос, делает холодный компресс {ENTER}")
    Sleep(3000) ;
    Return
}
pmp5_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял из мед.сумки бандаж, подошел к пациенту и одел на него бандаж {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("Сейчас вам нужно будет выдохнуть и я затяну его для фиксации ребер {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Затягивая бандаж после выдоха пациента : Теперь аккуратно садитесь в машину в полулежачем состоянии и пытайтесь не сильно вдыхать воздух {ENTER}")
    Sleep(3000) ;
    Return
}
pmp6_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял из мед.сумки антисептический спрей и продезинфицировал им место ранения {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достает из мед.сумки “Окклюзионную повязку” и аккуратно, стерильной стороной ИПП, накладывает ее и плотно закрывает ранение {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee укладывает марлевые подушечки на прорезиненную сторону повязки, а после же фиксирует лейкопластырем {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("Теперь аккуратно садитесь в машину в полулежачем состоянии и пытайтесь не сильно вдыхать воздух {ENTER}")
    Sleep(3000) ;
    Return
}
pmp7_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee осмотрел лицо и губы на синюшный оттенок, после же достал стетоскоп и надевая его принялся слушать пациента на наличие сухого кашля {ENTER}")
    Sleep(3000) ;
    Return
}
pmp8_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me резко достает из мед.сумки стерильный дренажный шланг и осматривает его, а после точным движением вводит дренажный шланг в плевральную полость, а после подключает к дренажной системе {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Плевральная жидкость начинает вытекать через шланг. Мед.сотрудник сделал правильные действия {ENTER}")
    Sleep(3000) ;
    Return
}
pmp9_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee открывает аптечку и достает от туда жгут, после чего накладывает его на место выше места кровотечения и попутно продезинфицировал место ранения {ENTER}")
    Sleep(3000) ;
    Return
}
pmp10_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me аккуратно уложил пострадавшего на спину, достал из своей аптечки одеяло, и накрыл одеялом пострадавшего {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me открывает аптечку и достает оттуда ампулу с “Новокаином”, шприц и вводит иглу в место перелома, после же надавливает на поршень и вводит препарат {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me приложил холод на область перелома для снятия отека и боли, используя лед или холодный компресс {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me принялся накладывать шину Дитерихса, которая бы шла на внешней поверхности ноги длинный костыль от подмышечной впадины до стопы и на внутренней поверхности ноги короткий костыль от паха до стопы, после крепко зафиксировал бинтами {ENTER}")
    Sleep(3000) ;
    Return
}
pmp11_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee подбежав к пострадавшему человеку, ставит медицинскую аптечку рядом, после чего осматривает гражданина снаружи {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me открывает аптечку и достает оттуда ампулу с “Новокаином”, шприц и вводит иглу в место перелома, после же надавливает на поршень и вводит препарат {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Осмотрев пострадавшего, медицинский работник делает подозрения на перелом позвоночника, после чего быстрыми движениями вытаскивает из медицинской машины носилки и осторожными манипуляциями перекладывает на них гражданина, положив его голову на бок {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee положив пострадавшего на носилки, наклоняется к медицинской аптечке, после чего взяв от туда мягкий валик и подсунув его под спину пострадавшего, тащит носилки в машину скорой помощи {ENTER}")
    Sleep(3000) ;
    Return
}
pmp12_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me подходит к человеку и опускает свой взгляд на место ожога внимательно анализируя и стараясь поставить стадию {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/n Отыграй по RP какая у тебя стадия, 1-2 самые легкие, 4 - ампутация конечности. {ENTER}")
    Sleep(3000) ;
    Return
}
pmp13_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me открывает аптечку, надевает медицинские перчатки и  достает гидротермический пакет, но прежде чем применить его, врач нажимает, аккуратно перемешивает компоненты внутри, затем прикладывает его к пораженной области тела, чуть надавливая на него {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Гидротермический пакет прижимается к коже, моментально снимая тепло от ожога, пациент чувствует облегчение. Убрав пакет, врач находит гепариновую мазь и начинает наносить ее на охлажденную кожу. Легкими движениями руки мазь покрывает пораженную область  {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me берет бинт из медицинской сумки и аккуратно обматывает мазью покрытую часть тела, обеспечивая дополнительную защиту {ENTER}")
    Sleep(3000) ;
    Return
}
pmp14_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me открывает аптечку, надевает медицинские перчатки и  достает гидротермический пакет, но прежде чем применить его, врач нажимает, аккуратно перемешивает компоненты внутри, затем прикладывает его к пораженной области тела, чуть надавливая на него {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Гидротермический пакет прижимается к коже, моментально снимая тепло от ожога, пациент чувствует облегчение. Не убирая пакет, находит достает бинты, специальную мазь и антисептик из медицинской сумки, после наносит мазь на бинты и обрабатывает их антисептиком {ENTER}")
    Sleep(3000) ;
    Return 
}
pmp15_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee ставит и открывает аптечку рядом с собой, осматривает ранение пострадавшего, разрывает чуть одежду в районе огнестрела, ставит жгут, взяв из аптечки антисептик, обрабатывает свои руки и одевает перчатки {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee распечатывает из пачки антисептическую салфетку, взяв шприц с обезболивающим и выпустив воздух из иглы протирает салфеткой место укола и вводит иглу с обезболивающим в районе огнестрела {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee осматривает рану на наличие пули и глубины раны, берет из аптечки запечатанную салфетку гемостатик, открывает ее и начинает делать тампонаду раны, останавливая кровотечение, затем берет бинт из аптечки и начинает накладывать тугую повязку {ENTER}")
    Sleep(3000) ;
    Return
}
pmp16_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee подойдя к пациенту внимательно осмотрел место потери конечности, после открыл аптечку и вытащил от туда медицинский жгут {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстрыми движениями наложил его выше места травмы, для остановки кровотечения, после достал из аптечки шприц, открыл ампулу обезбола и набрал ее в шприц {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee резким и точным движением ввел шприц в мышечную ткань пациента, рядом с местом ранения и осторожно обернул конечность чистым марлевым бинтом, который смочен дезинфицирующем средстве , чтобы предотвратить возможное заражение {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Постепенно все лекарство вводится внутрь пациента до последней капли. Препарат введен. Кровотечение почти остановилось и свелось к минимуму {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достал из аптечки спец.пакет со льдом, открыл его и аккуратно переложил конечность в пакет, после же закрыл его и убрал {ENTER}")
    Sleep(3000) ;
    Return
}
pmp17_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстра надев перчатки и маску достал из аптечки все нужное для укола и резким, а также точным движением ввел шприц в мышечную ткань пациента, рядом с местом ранения и надавил на конец шприца для введения препарата внутрь человека {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взяв ватку смочил ее антисептическим веществом и прошелся им по краю раны, для обработки ранения {ENTER}")
    Sleep(3000) ;
    Return
}
pmp18_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстра надев перчатки и маску достал из аптечки слабый раствор антисептика и прошелся им по месту ранения, а после бинтами замотал рану в несколько слоев {ENTER}")
    Sleep(3000) ;
    Return
}
pmp19_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me достает необходимое оборудование и инструменты, такие как портативный кислородный баллон, дефибриллятор, интубационный набор и медицинский арсенал для первой помощи {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me оценивает состояние пациента, проверяет наличие признаков ожогов, затрудненного дыхания и других признаков отравления, быстро принимает меры по перемещению пациента на безопасное место, если это необходимо {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me  обеспечивает проходимость дыхательных путей, применяет кислородную маску, чтобы обеспечить пострадавшего кислородом {ENTER}")
    Sleep(3000) ;
    Return
}
pmp20_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee поставил мед.сумку рядом с пациентом, надел перчатки и внимательно осмотрел место укуса {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do По оставленным следам животного, пациента укусила собака {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee вытащил из сумки бутылку воды, обычное хозяйственное мыло и принялся промывать рану от слюны животного {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял в руку мед.спирт, смочил им повязку и продезинфицировал место укуса, а после же туго перевязал {ENTER}")
    Sleep(3000) ;
    Return
}
pmp21_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee надел стерильные перчатки и аккуратно осмотрел место укуса {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взяв из аптечки мед.спирт смочил им стерильную ватку и продезинфицировал место раны {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do После действий мед.работника рана продезинфицирована и можно приступать к удалению жала {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял в руку пинцет и аккуратно принялся извлекать жало не повреждая мешочяек с ядом {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Передавая из аптечки бутылку воды пациенту : Выпейте все {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял пачку бинтов, открыл их, промокнул в мед.спирте и замотал рану делая холодный компресс {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Спустя некоторое время у пациента исчезнет покраснение, опухоль {ENTER}")
    Sleep(3000) ;
    Return
}
pmp22_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("Переводим пациента в палату и смотрим за его состоянием, даем горячий чай, а так же при необходимости даем антигистаминные средства {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взяв чайник и кружку заваривает чай с добавлением ромашки, после заварки передает чай пациенту {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взял из шкафчика преппараты, налил в стаканчик воду и передал пациенту {ENTER}")
    Sleep(3000) ;
    Return
}
pmp23_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достаёт из кармана халата перчатки, надевает их на руки, положив руки на щёки пациента, вставил два больших пальца в ротовую полость пациента, что-бы зафиксировать язык в нужное положение, а так-же пощупать перелом, после вытаскивает пальцы из рта {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee снимает с плеча аптечку и кладёт её на пол, открыв достаёт из неё бинт и ножницы, отматывает от бинта определённую длину и отрезает с помощью ножниц, после кладёт ножницы и оставшийся комок с бинтом в аптечку {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee держа в руках бинт с определённым размером, фиксирует сломанную челюсть в неподвижном состоянии по типу «Пращевидной», продевает несколько раз концы бинта друг друга дабы сделать узелок на повязке {ENTER}") 
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достаёт жгут из аптечки и накладывает его выше изгиба руки пациента, так-же достаёт салфетку и протирает место для укола ею, начинает вводить катетер в набухшую вену, одновременно снимая жгут другой рукой {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достаёт из аптечки коробочку с ампулами обезболивающего,  готовый шприц, открывает коробочку, а после и ампулу, вводит в шприц препарат и убирает ампулу вместе с коробочкой в кармашек, после подносит его к катетеру и вводит иглу в него {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достаёт из открытой аптечки одной рукой гипотермический пакет «СНЕЖОК», прикладывает его к отделу перелома, другой берёт руку пострадавшего и прикладывает к гипотермическому пакету убирая свою руку {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee снимает со своих рук перчатки и кладёт их в карман халата, после тянется к аптечке и закрывает её, берёт с пола и закидывает на плечо, встаёт и держа человека за руку помогает дойти ему {ENTER}")
    Sleep(3000) ;
    Return
}
pmp24_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстро подходит к пациенту и осматривает ранение, после же достает хлоргексидин и промывает им место кровотечения, после накладывает несколько слоев бинт и закрепляет их пластырем и прикладывает пакет со льдом для сжатия сосудов {ENTER}")
    Sleep(3000) ;
    Return
}
pmp25_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me пальцем надавливает на место кровотечения, после другой рукой берет жгут и накладывает его выше ранения, помечая время, после берет стерильную марлевую повязку и тампонирует ее, если есть возможность сжать конечность пациенту, то делает это {ENTER}")
    Sleep(3000) ;
    Return
}
pmp26_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me увидев в воде человека, быстро побежал к нему и принялся вытаскивать пострадавшего на берег, после быстро оценивает его состояние {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Пульс слабый, дыхание нерегулярное. Пострадавший подвергся воздействию холодной воды, что может вызвать судороги и проблемы с дыханием {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me немедленно приступает к проведению первой помощи, укладывает пациента животом на свое, уделяет внимание поддержанию проходимости дыхательных путей, освобождает рот от возможных преград {ENTER}")
    Sleep(3000) ;
    Return
}
pmp27_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee поставил мед.сумку на землю и вытащил от туда быстро действущий углевод, а именно бутылку сока и передал пациенту {ENTER}")
    Sleep(3000) ;
    Return
}
pmp28_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me немедленно вводит инсулин в быстро действующую зону, а именно передняя поверхность живота, рассчитывая необходимую дозу для нормализации уровня глюкозы {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Пока инсулин начинает действовать, персонаж употребляет дополнительное количество воды, чтобы предотвратить дегидрацию и уменьшить содержание глюкозы {ENTER}")
    Sleep(3000) ;
    Return
}
pmp29_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do В мед.сумке врача было : 1 литр бутылки воды, пакетик сахара, пакетик соли, трубочка для питья, большой одноразовый стакан и больничные простыни {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me берёт простыни, немного промакивает их водой из под бутылки, подходя к пациенту оборачивает его голову и тело влажной простыней {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me берёт большой одноразовый стакан, вливает туда оставшуюся воду, добавляет столовую ложку сахара, треть чайной ложки соли, для восполнения дефицита солей, калия и натрия {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput('/me перемешивает мед."Коктейль", поставив в стакан трубочку подходит к пациенту и поднося ему стакан, помогает выпить мелкими глотками через трубочку содержимое стакана {ENTER}')
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput('/do Спустя некоторое время, пациент выпил весь мед."Коктейль". Выкинув одноразовый стакан с трубочкой в урну, продолжает следить за состоянием пациента {ENTER}')
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Взяв листок бумаги с ручкой, вписывает нужные препараты для пациента, после чего : Вижу, с вами уже все в норме. {ENTER}")
    Sleep(3000) ;
    Return
}
pmp30_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me проводит быстрый общий осмотр, обращая внимание на цвет кожи, наличие отеков, частоту и характер дыхания {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me берет стетоскоп, прикладывает его к грудной клетке пациента и внимательно слушает звуки дыхания, ища характерные признаки {ENTER}")
    Sleep(3000) ;
    Return
}
pmp31_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me достает из мед.сумки небольшой ингалятор для астматиков и вводит в него бронходилататором, а после прикладывает ко рту пациента {ENTER}")
    Sleep(3000) ;
    Return
}
pmp32_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/todo Доставая из мед.сумки таблетку эпинефрина, бутылку обычной воды и передавая ее пациенту : Быстрее пейте и отек сойдет {ENTER}")
    Sleep(3000) ;
    Return
}
pmp33_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee осматривает пациента, встает позади него чуть наклонив вперед")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee обхватывает руками вокруг пояса, чуть выше пупка, под реберной дугой, после резко надавливает на живот пострадавшего, сгибая руки в локтях {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/try Предмет выпал, дыхательные пути свободны? {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/try Надавливает резко ещё раз в ожидании освобождения дыхательных путей ")
    Sleep(3000) ;
    Return
}
pmp34_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee укладывает пострадавшего в удобное положение, запрокидывая голову пациента назад, после обрабатывает свои руки антисептиком и одевает перчатки {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee обрабатывает место разреза антисептиком, пальпаторно определяет щитоперстневидную связку и взяв скальпель проводит надрез, после  вводит в отверстие трахеостомическую трубку и фиксирует ее к шее пластырем {ENTER}")
    Sleep(3000) ;
    Return
}
pmp35_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee подошел к пациенту и переложил его на бок, дабы исключить западение языка, а под ноги кинул свою куртку скомканную в клубок, после ослабил давление одежды и поднес два пальца к шее, а именно к сонной артерии пострадавшего {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/try У пострадавшего есть пульс? {ENTER}")
    Sleep(3000) ;
    Return
}
pmp36_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee открывает аптечку, достает нашатырный спирт прихватив ватку и смочив ватку подносит слегка махнув перед носом человека без сознания, ожидая когда он придет в себя {ENTER}")
    Sleep(3000) ;
    Return
}
pmp37_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee поставив ладони на вытянутых руках, строго вертикально на груди пострадавшего начинает проводить технику непрямого массажа сердца 30 раз {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee взяв ручной ИВЛ из аптечки, прикладывает маску на рот пострадавшего и нажимает своей рукой на мешок {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee контролируя пульс на сонной артерии и реакцию зрачков на свет приоткрывая веко пострадавшему продолжает делать массаж сердца до появления слабого пульса {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/try У пострадавшего появился пульс? {ENTER}")
    Sleep(3000) ;
    Return
}
pmp38_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee открывает аптечку, достает шприц с адреналином, поставив жгут выше локтя на руке пациента, достает спиртовую салфетку и распечатав ее протирает место укола и вводит иглу шприца в вену приспуская вещество, после продолжает СЛР {ENTER}")
    Sleep(3000) ;
    Return
}
pmp39_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достает из кармана халата фонарик, включает его и проверяет глазное яблоко на чувствительность к свету {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/try Пациент реагирует на свет фонарика? {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достал из аптечки нашатырный спирт и ватку, промочил небольшим кол-вом спирта ватку и принялся водить перед носом пациента {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee подложил под голову пациента небольшую подушку {ENTER}")
    Sleep(3000) ;
    Return
}
pmp40_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee поставил мед.аптечку на землю, открыл ее и достал от туда Нитроглицерин, после же передал пациенту {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("Возьмите эту таблетку под язык {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Через несколько минут таблетка подействовала и расширила артерии и снизила давление пациенту {ENTER}")
    Sleep(3000) ;
    Return
}
pmp41_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee рассмотрел крепление ремня или галстука и помог пациенту ослабить их натяжение {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do После действий мед.работника к пациенту пошел поток свежего воздуха {ENTER}")
    Sleep(3000) ;
    Return
}
pmp42_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput('/mee открыв аптечку ставит на пол, ищет шприц и ампулу "Морфин", после набирает нужную дозу морфина, щупает руку в поиске вены после вводит препарат в кровеносную систему {ENTER}')
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/me с помощью инструментов проводит мониторинг жизненно важных показателей пострадавшего, таких как пульс, артериальное давление и частота дыхания, для контроля состояния пациента {ENTER}")
    Sleep(3000) ;
    Return
}
pmp43_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee быстро достает из аптечки бутылку воды, специальный марлевый бинт и небольшой пакет с холодным льдом, после просит пациента открыть рот и взять в рот воду, сполоснуть и выплюнуть {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do После всех действий пациента работник берет марлю и накладывает ее круговыми движениями на часть оставшегося языка, после берет небольшой пакет с холодом и прислоняет к языку {ENTER}")
    Sleep(3000) ;
    Return
}
pmp44_(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee присев к пациенту поставив аптечку рядом поворачивает его на правый бок взявшись за левую руку и левую ногу согнув при этом на 90 градусов и подкладывает его руку ему под голову, проверяет стопор колена и правильного положения пациента {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee открыв аптечку берет стерильные перчатки и одевает на свои руки, опрашивает прохожих и фиксирует с их слов время начала приступа {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/mee достает из аптечки шприц с лекарством, сняв колпачок с иглы и приспустив штаны человеку сделала укол в ягодичную мышцу {ENTER}")
    Sleep(3000) ;
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/do Ожидает прохождения эпилептического шока, наблюдает состояние здоровья пациента {ENTER}")
    Sleep(3000) ;
    Return
}
calls(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/calls {ENTER}")
    Sleep(3000) ;
    Return
}
pass_accept(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/pass accept {ENTER}")
    Sleep(3000) ;
    Return
}
med_heal(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/med heal  100")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    SendInput("{Left}")
    Sleep(3000) ;
    Return
}
drops_time(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/drops time {ENTER}")
    Sleep(3000) ;
    Return
}
gps_cancel(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(3000) ;
    SendInput("/gps cancel {ENTER}")
    Sleep(3000) ;
    Return
}

med_termin(GuiObject?, eventInfo?)
{
    Main.Hide()
    Rare.Hide()
    Educ.Hide()
    pmp.Hide()
    rp_termin.Hide()
    terminnn.Show("AutoSize")
    menu_ui.Hide()
    Return
}
ystav(GuiObject?, eventInfo?)
{
    Main.Hide()
    Rare.Hide()
    Educ.Hide()
    pmp.Hide()
    terminnn.Hide()
    rp_termin.Hide()
    menu_ui.Hide()
    Run("https://discord.com/channels/1215940333486080060/1216812050177724426")
    Return
}
ques(GuiObject?, eventInfo?)
{
    Main.Hide()
    Rare.Hide()
    Educ.Hide()
    pmp.Hide()
    terminnn.Hide()
    rp_termin.Hide()
    menu_ui.Hide()
    Run("https://discord.com/channels/1215940333486080060/1229786538876076102/1229787011909419050")
    Return
}
med_tools(GuiObject?, eventInfo?)
{
    Main.Hide()
    Rare.Hide()
    Educ.Hide()
    pmp.Hide()
    terminnn.Hide()
    rp_termin.Hide()
    menu_ui.Hide()
    Run("https://discord.com/channels/1215940333486080060/1216099736881467492")
    Return
}
knife(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me готовит операционную для извлечения ножа, раскладывая необходимые инструменты на стерильном столе {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me вводит местную анестезию вокруг раны, проверяя её действие. Пациент не чувствует боли {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me делает аккуратный разрез вокруг ножевой раны, чтобы минимизировать повреждения при извлечении {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Кожа вокруг раны обработана, разрез сделан для облегчения извлечения ножа {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me осторожно захватывает нож за рукоятку и начинает аккуратно вытаскивать его {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me извлекает нож, держа его за рукоятку, и кладет в металлический лоток {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Нож успешно извлечен, рана открыта для обработки {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов и тампонов {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me проверяет, не повреждены ли внутренние органы или крупные сосуды, используя специальные инструменты {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Внутренние органы и сосуды не повреждены, хирург продолжает обработку раны {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me накладывает несколько швов, чтобы закрыть разрез и восстановить целостность тканей {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Швы аккуратно наложены, рана закрыта {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}")
    Sleep(2500) ;
    Return
}
peluvoe(GuiObject?, eventInfo?)
{
    hide_ui()
    SendMessage(0x50, , 0x4190419, , "A")
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me готовит операционную для извлечения пули, раскладывая необходимые инструменты на стерильном столе {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do На столе лежат скальпель, пинцет, зажимы, антисептик и швы. Операционная готова {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me моет и дезинфицирует руки, надевает стерильные перчатки, маску и хирургический халат {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("Сейчас я введу анестезию, чтобы вы не чувствовали боли. {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me вводит местную анестезию вокруг раны, проверяя её действие. Пациент не чувствует боли {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Анестезия начинает действовать, область вокруг раны немеет {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me тщательно обрабатывает кожу вокруг раны антисептиком, готовя её к операции {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me делает аккуратный разрез вокруг раны, чтобы расширить доступ к пуле {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Рана слегка расширена, открывая доступ к пуле {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me осторожно использует пинцет для захвата и извлечения пули {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me извлекает пулю, держа её пинцетом, и помещает в металлический лоток {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Пуля успешно извлечена, рана готова к обработке {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me тщательно очищает рану антисептиком, останавливает кровотечение при помощи зажимов {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me накладывает несколько швов, чтобы закрыть разрез {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Швы аккуратно наложены, рана закрыта {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me наносит антисептический раствор на швы и накладывает стерильную повязку {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/do Повязка плотно прилегает к ране, защищая её от инфекции {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("Операция завершена. Следуйте рекомендациям по уходу за раной и приходите на осмотр через несколько дней. {ENTER}")
    Sleep(2500) ;
    SendInput("{е}")
    Sleep(2500) ;
    SendInput("/me убирает использованные инструменты и снимает перчатки, завершая операцию {ENTER}")
    Sleep(2500) ;
    Return
}


DirCreate(A_Temp . "\ahk-hospital")
cfg_file:=A_Temp . "\ahk-hospital\config.cfg"
temp_file:=A_Temp . "\ahk-hospital\temp.cfg"
if !FileExist(temp_file){
    FileAppend("", temp_file, "utf-8")
}
if FileExist(temp_file){
    temp_data := Fileread(temp_file)
}
if FileExist(cfg_file){
    cfg_data := Fileread(cfg_file)
}

restart_ui(GuiObject?, eventInfo?)
{   
    temp_file:=A_Temp . "\ahk-hospital\temp.cfg"
    e := "
  (Ltrim join`r`n
restart
  )"
    FileAppend(e, temp_file, "utf-8")
    Reload()
}

open_rp_termin(GuiObject?, eventInfo?)
{   
    Main.Hide()
    Rare.Hide()
    Educ.Hide()
    pmp.Hide()
    menu_ui.Hide()
    terminnn.Hide()
    rp_termin.Show("AutoSize")
}

hide_ui()
{   
    If WinExist("AHK | Редкое") or WinExist("AHK | RP Термины") or WinExist("AHK | Обучение") or WinExist("AHK | Основное") or WinExist("AHK | ПМП | Первая Медицинская Помощь") or WinExist("AHK | Hospital") or WinExist("AHK | Термины")
    {    
        Main.Hide()
        Rare.Hide()
        Educ.Hide()
        pmp.Hide()
        terminnn.Hide()
        rp_termin.Hide()
        menu_ui.Hide()
        Sleep(100)
        MouseClick("Left")
        SendMessage(0x50, , 0x4190419, , "A")
        Sleep(100)
        SendInput("{Esc}")
        
    } else 
    {
        Sleep(1000)
    }
    
}




Main := Gui()
Main.Title := "AHK | Основное"
Main.Opt("+AlwaysOnTop")
Main.BackColor := 0x1C1C1C
Main.Add("Text", "cWhite", "AHK | Больница                                         By Agzes")

aq := Main.AddButton("w250 h20", "Alt + Q | Приветствие")
aq.SetBackColor(0x4e4e4e, 0x1C1C1C)
aq.OnEvent("Click", greetings)

at := Main.AddButton("w250 h20", "Alt + T | Передать таблетку")
at.SetBackColor(0x4e4e4e, 0x1C1C1C)
at.OnEvent("Click", give_pill)

al := Main.AddButton("w250 h20", "Alt + L | Продать мед")
al.SetBackColor(0x4e4e4e, 0x1C1C1C)
al.OnEvent("Click", sell_pill)

ay := Main.AddButton("w250 h20", "Alt + Y | Ушиб")
ay.SetBackColor(0x4e4e4e, 0x1C1C1C)
ay.OnEvent("Click", bruise)

ah := Main.AddButton("w250 h20", "Alt + H | Нашатырь")
ah.SetBackColor(0x4e4e4e, 0x1C1C1C)
ah.OnEvent("Click", ammonia)

ai := Main.AddButton("w250 h20", "Alt + I | Инъекция")
ai.SetBackColor(0x4e4e4e, 0x1C1C1C)
ai.OnEvent("Click", inject)

am := Main.AddButton("w250 h20", "Alt + M | Мед. Карта")
am.SetBackColor(0x4e4e4e, 0x1C1C1C)
am.OnEvent("Click", medcard)

av := Main.AddButton("w250 h20", "Alt + V | Выписка из 6 палаты")
av.SetBackColor(0x4e4e4e, 0x1C1C1C)
av.OnEvent("Click", extract)

ao := Main.AddButton("w250 h20", "Alt + O | Мед. Осмотр")
ao.SetBackColor(0x4e4e4e, 0x1C1C1C)
ao.OnEvent("Click", medical_examination)

ap := Main.AddButton("w250 h20", "Alt + P | Проф. Пригодность")
ap.SetBackColor(0x4e4e4e, 0x1C1C1C)
ap.OnEvent("Click", prof_suitability)







Rare := Gui()
Rare.Title := "AHK | Редкое"
Rare.Opt("+AlwaysOnTop")
Rare.BackColor := 0x1C1C1C
Rare.Add("Text", "cWhite", "AHK | Больница                                         By Agzes")

an := Rare.AddButton("w250 h20", "Alt + U | Ножевое")
an.SetBackColor(0x4e4e4e, 0x1C1C1C)
an.OnEvent("Click", knife)

an := Rare.AddButton("w250 h20", "Alt + B | Пулевое")
an.SetBackColor(0x4e4e4e, 0x1C1C1C)
an.OnEvent("Click", peluvoe)

an := Rare.AddButton("w250 h20", "Alt + N | Носилки")
an.SetBackColor(0x4e4e4e, 0x1C1C1C)
an.OnEvent("Click", stretcher)

ad := Rare.AddButton("w250 h20", "Alt + D | Дефибриллятор")
ad.SetBackColor(0x4e4e4e, 0x1C1C1C)
ad.OnEvent("Click", defibrillator)

ak := Rare.AddButton("w250 h20", "Alt + K | Капельница")
ak.SetBackColor(0x4e4e4e, 0x1C1C1C)
ak.OnEvent("Click", dropper)

ag := Rare.AddButton("w250 h20", "Alt + G | Скрутить, успокоительный укол")
ag.SetBackColor(0x4e4e4e, 0x1C1C1C)
ag.OnEvent("Click", twist)

aj := Rare.AddButton("w250 h20", "Alt + J | Успокаивающий укол")
aj.SetBackColor(0x4e4e4e, 0x1C1C1C)
aj.OnEvent("Click", calm)

a1 := Rare.AddButton("w250 h20", "Alt + 1 | Кровь из вены")
a1.SetBackColor(0x4e4e4e, 0x1C1C1C)
a1.OnEvent("Click", blood_vien)

a2 := Rare.AddButton("w250 h20", "Alt + 2 | Кровь на анализ")
a2.SetBackColor(0x4e4e4e, 0x1C1C1C)
a2.OnEvent("Click", blood)

a3 := Rare.AddButton("w250 h20", "Alt + 3 | Обработать, зашить рану")
a3.SetBackColor(0x4e4e4e, 0x1C1C1C)
a3.OnEvent("Click", wound)

a4 := Rare.AddButton("w250 h20", "Alt + 4 | Обработать, зашить рану (анастезия)")
a4.SetBackColor(0x4e4e4e, 0x1C1C1C)
a4.OnEvent("Click", wound_plus)

a5 := Rare.AddButton("w250 h20", "Alt + 5 | Извлечение пули")
a5.SetBackColor(0x4e4e4e, 0x1C1C1C)
a5.OnEvent("Click", bullet)

a6 := Rare.AddButton("w250 h20", "Alt + 6 | Ренген")
a6.SetBackColor(0x4e4e4e, 0x1C1C1C)
a6.OnEvent("Click", rengen)

a7 := Rare.AddButton("w250 h20", "Alt + 7 | Вправить сустав")
a7.SetBackColor(0x4e4e4e, 0x1C1C1C)
a7.OnEvent("Click", dislocation)

a8 := Rare.AddButton("w250 h20", "Alt + 8 | Закрытый перелом")
a8.SetBackColor(0x4e4e4e, 0x1C1C1C)
a8.OnEvent("Click", close_fracture)

a9 := Rare.AddButton("w250 h20", "Alt + 9 | Открытый перелом")
a9.SetBackColor(0x4e4e4e, 0x1C1C1C)
a9.OnEvent("Click", open_fracture)

a0 := Rare.AddButton("w250 h20", "Alt + 0 | Наложить гипс")
a0.SetBackColor(0x4e4e4e, 0x1C1C1C)
a0.OnEvent("Click", gypsum)







Educ := Gui()
Educ.Title := "AHK | Обучение"
Educ.Opt("+AlwaysOnTop")
Educ.BackColor := 0x1C1C1C
Educ.Add("Text", "cWhite", "AHK | Больница                                         By Agzes")

c1 := Educ.AddButton("w250 h20", "Cltr + Alt + 1 | Лекция | Фулл Лекция")
c1.SetBackColor(0x4e4e4e, 0x1C1C1C)
c1.OnEvent("Click", lecture)

c2 := Educ.AddButton("w250 h20", "Cltr + Alt + 2 | Устав (1/4) | Вы готовы..")
c2.SetBackColor(0x4e4e4e, 0x1C1C1C)
c2.OnEvent("Click", regulation1)
 
c3 := Educ.AddButton("w250 h20", "Cltr + Alt + 3 | Устав (2/4) | Авто 3 устава ")
c3.SetBackColor(0x4e4e4e, 0x1C1C1C)
c3.OnEvent("Click", regulation2)

c4 := Educ.AddButton("w250 h20", "Cltr + Alt + 4 | Устав (3/4) | Авто 3 термин..")
c4.SetBackColor(0x4e4e4e, 0x1C1C1C)
c4.OnEvent("Click", regulation3)

c5 := Educ.AddButton("w250 h20", "Cltr + Alt + 5 | Устав (4/4) | Вы сдали..")
c5.SetBackColor(0x4e4e4e, 0x1C1C1C)
c5.OnEvent("Click", regulation4)

c6 := Educ.AddButton("w250 h20", "Cltr + Alt + 6 | Клятва | Вы дали клятву")
c6.SetBackColor(0x4e4e4e, 0x1C1C1C)
c6.OnEvent("Click", oath)

c7 := Educ.AddButton("w250 h20", "Cltr + Alt + 7 | Поручения | Автоматически")
c7.SetBackColor(0x4e4e4e, 0x1C1C1C)
c7.OnEvent("Click", assingments)

c8 := Educ.AddButton("w250 h20", "Cltr + Alt + 8 | Практика (1/2) | РП")
c8.SetBackColor(0x4e4e4e, 0x1C1C1C)
c8.OnEvent("Click", practice)
 
c9 := Educ.AddButton("w250 h20", "Cltr + Alt + 9 | Практика (2/2) | Вы сдали")
c9.SetBackColor(0x4e4e4e, 0x1C1C1C)
c9.OnEvent("Click", practice2)

c10 := Educ.AddButton("w250 h20", "Cltr + Alt + 0 | Клятва | Вы готовы?")
c10.SetBackColor(0x4e4e4e, 0x1C1C1C)
c10.OnEvent("Click", oath_start)



pmp := Gui()
pmp.Opt("+AlwaysOnTop")
pmp.Title := "AHK | ПМП | Первая Медицинская Помощь"
pmp.BackColor := 0x1C1C1C
pmp.Add("Text", "cWhite", "AHK | Больница                                                                                                                               By Agzes")

pmp1 := pmp.AddButton("w250 h20", "Вывих")
pmp1.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp1.OnEvent("Click", pmp1_)
pmp2 := pmp.AddButton("w250 h20", "Закрытый перелом")
pmp2.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp2.OnEvent("Click", pmp2_)
pmp3 := pmp.AddButton("w250 h20", "Открытый перелом")
pmp3.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp3.OnEvent("Click", pmp3_)
pmp4 := pmp.AddButton("w250 h20", "Перелом носа")
pmp4.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp4.OnEvent("Click", pmp4_)
pmp5 := pmp.AddButton("w250 h20", "Закрытый перелом рёбер")
pmp5.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp5.OnEvent("Click", pmp5_)
pmp6 := pmp.AddButton("w250 h20", "Открытый перелом рёбер")
pmp6.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp6.OnEvent("Click", pmp6_)
pmp7 := pmp.AddButton("w250 h20", "Пневмоторакс: проверка")
pmp7.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp7.OnEvent("Click", pmp7_)
pmp77 := pmp.AddButton("w250 h20", "Пневмоторакс: есть повреждения")
pmp77.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp77.OnEvent("Click", pmp8_)
pmp8 := pmp.AddButton("w250 h20", "Открытый перелом шейки бедра")
pmp8.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp8.OnEvent("Click", pmp9_)
pmp88 := pmp.AddButton("w250 h20", "Закрытый перелом шейки бедра")
pmp88.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp88.OnEvent("Click", pmp10_)
pmp9 := pmp.AddButton("w250 h20", "Перелом позвоночника")
pmp9.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp9.OnEvent("Click", pmp11_)
pmp10 := pmp.AddButton("w250 h20", "Ожог: диагностика")
pmp10.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp10.OnEvent("Click", pmp12_)
pmp11 := pmp.AddButton("w250 h20", "Ожог: 1-2 стадия")
pmp11.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp11.OnEvent("Click", pmp13_)
pmp12 := pmp.AddButton("w250 h20", "Ожог: 3-4 стадия")
pmp12.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp12.OnEvent("Click", pmp14_)
pmp13 := pmp.AddButton("w250 h20", "Пулевое ранение")
pmp13.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp13.OnEvent("Click", pmp15_)
pmp14 := pmp.AddButton("w250 h20", "Травматическая ампутация конечности")
pmp14.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp14.OnEvent("Click", pmp16_)
pmp15 := pmp.AddButton("w250 h20", "Ножевое с ножом")
pmp15.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp15.OnEvent("Click", pmp17_)
pmp16 := pmp.AddButton("w250 h20", "Ножевое без ножа")
pmp16.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp16.OnEvent("Click", pmp18_)
pmp17 := pmp.AddButton("w250 h20", "Отравление газом [Co2]")
pmp17.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp17.OnEvent("Click", pmp19_)
pmp18 := pmp.AddButton("w250 h20", "Укус бешенного животного ПМП")
pmp18.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp18.OnEvent("Click", pmp20_)
pmp19 := pmp.AddButton("w250 h20", "Укус пчелы: на улице")
pmp19.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp19.OnEvent("Click", pmp21_)
pmp20 := pmp.AddButton("w250 h20", "Укус пчелы: в больнице")
pmp20.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp20.OnEvent("Click", pmp22_)

pmp21 := pmp.AddButton("w250 h20 x270 y25", "Перелом/ушиб челюсти")
pmp21.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp21.OnEvent("Click", pmp23_)
pmp22 := pmp.AddButton("w250 h20 x270 y51", "Кровотечение: Капилярное")
pmp22.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp22.OnEvent("Click", pmp24_)
pmp23 := pmp.AddButton("w250 h20 x270 y77", "Кровотечение: Артериальное")
pmp23.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp23.OnEvent("Click", pmp25_)
pmp24 := pmp.AddButton("w250 h20 x270 y103", "Вытаскивание из воды (пульс есть)")
pmp24.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp24.OnEvent("Click", pmp26_)
pmp25 := pmp.AddButton("w250 h20 x270 y129", "Сахарный диабет (низкий сахар)")
pmp25.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp25.OnEvent("Click", pmp27_)
pmp26 := pmp.AddButton("w250 h20 x270 y155", "Сахарный диабет (высокий сахар)")
pmp26.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp26.OnEvent("Click", pmp28_)
pmp27 := pmp.AddButton("w250 h20 x270 y182", "Обезвоживание")
pmp27.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp27.OnEvent("Click", pmp29_)
pmp28 := pmp.AddButton("w250 h20 x270 y207", "Затруднее дыхания: диагностика")
pmp28.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp28.OnEvent("Click", pmp30_)
pmp29 := pmp.AddButton("w250 h20 x270 y233", "Затруднее дыхания: Астма")
pmp29.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp29.OnEvent("Click", pmp31_)
pmp30 := pmp.AddButton("w250 h20 x270 y259", "Затруднее дыхания: Алергия")
pmp30.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp30.OnEvent("Click", pmp32_)
pmp31 := pmp.AddButton("w250 h20 x270 y285", "Затруднее дыхания: пища | инородный предмет")
pmp31.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp31.OnEvent("Click", pmp33_)
pmp32 := pmp.AddButton("w250 h20 x270 y311", "Затруднее дыхания: Коникотомия ")
pmp32.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp32.OnEvent("Click", pmp34_)
pmp33 := pmp.AddButton("w250 h20 x270 y337", "Человек без сознания: диагностика")
pmp33.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp33.OnEvent("Click", pmp35_)
pmp34 := pmp.AddButton("w250 h20 x270 y363", "Человек без сознания: пульс есть")
pmp34.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp34.OnEvent("Click", pmp36_)
pmp35 := pmp.AddButton("w250 h20 x270 y389", "Человек без сознания: пульса нет")
pmp35.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp35.OnEvent("Click", pmp37_)
pmp36 := pmp.AddButton("w250 h20 x270 y415", "Человек без сознания: Укол адреналина")
pmp36.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp36.OnEvent("Click", pmp38_)
pmp37 := pmp.AddButton("w250 h20 x270 y441", "Сотрясение мозга: проверка фонариком")
pmp37.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp37.OnEvent("Click", pmp39_)
pmp38 := pmp.AddButton("w250 h20 x270 y467", "Сердчный приступ")
pmp38.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp38.OnEvent("Click", pmp40_)
pmp388 := pmp.AddButton("w250 h20 x270 y493", "Сердчный приступ: если есть рубашка, ремень")
pmp388.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp388.OnEvent("Click", pmp41_)
pmp39 := pmp.AddButton("w250 h20 x270 y519", "Болевой шок")
pmp39.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp39.OnEvent("Click", pmp42_)
pmp40 := pmp.AddButton("w250 h20 x270 y545", "Отрезали язык")
pmp40.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp40.OnEvent("Click", pmp43_)
pmp41 := pmp.AddButton("w250 h20 x270 y571", "Эпилепсия")
pmp41.SetBackColor(0x4e4e4e, 0x1C1C1C)
pmp41.OnEvent("Click", pmp44_)

terminnn := Gui()
terminnn.Opt("+AlwaysOnTop")
terminnn.Title := "AHK | Термины"
terminnn.BackColor := 0x1C1C1C

terminnn.AddText("cWhite","
(Ltrim join`r`n
AHK | Hospital | Термины Больницы:
МП   — Мероприятие 
ПП   — Первая помощь
СМП  — Скорая медицинская помощь
ПМП  — Первая медицинская помощь
ГКБ  — Городская клиническая больница
МЗ   — Министерство Здравоохранения
СМП — Скорая медицинская помощь

ДС   — Дыхательная система
ЛФК  — Лечебная физкультура
ЖКТ  — желудочно-кишечный тракт
СПИД — Синдром приобретённого иммунного дефицита
ВИЧ  — Вирус иммунодефицита человека
ОРВИ — Острая респираторная вирусная инфекция

ТТЖ  — Тупая травма живота 
ОЧМТ — Открытая черепно-мозговая травма
ЧМТ  — Черепно-мозговая травма
СЛР  — Сердечно-лёгочная реанимация
НРС  — Нарушения ритма сердца
ИМ   — Инфаркт миокарда
АД - Артериальное давление
ЧСС -  Частоту Сердечных Сокращений
ХОБЛ - Хроническая Обструктивная Болезнь Легкого
ТЭЛА - Тромбоэмболия Лёгочной Артерии

НИВЛ — Неинвазивная вентиляция легких (маска)
ИВЛ  — Искусственная вентиляция легких (трубкой)
ЗМС — Закрытый массаж сердца
ОМС - Открытый массаж сердца

АИК  — аппарат искусственного кровообращения
УЗИ  — Ультразвуковое исследование
МРТ  — Магнитно-резонансная томография
ЭКГ  — Электрокардиограмма (электрокардиография)
КТГ  — Кардиотокография (на живот беременным)
)")


rp_termin := Gui()
rp_termin.Opt("+AlwaysOnTop")
rp_termin.Title := "AHK | RP Термины"
rp_termin.BackColor := 0x1C1C1C

rp_termin.AddText("cWhite","
(Ltrim join`r`n
OOC  ( НонРП чат ) - это все, что касается реального 
мира. (пишется /n текст)
IC ( Игровой/рп чат ) - это все, что касается 
виртуального мира, то есть игры. (пишется в обычный чат)

ДМ - Убийство без причины.
СК- Спавн килл, т.е. убийство при появлении.
ТК- "Team Kill" - Убийство своих.
РП- "Role Play"- Игра по ролям где каждый 
должен соблюдать свою роль.
МГ- "Meta Gaming" - Использование информации 
из реального мира в игровой
ПГ- "Power Gaming" - Изображение из себя героя. 
(Например когда у тебя нет оружия и ты идешь на 
человека у которого оно есть , или например драка 
5 против одного.)
РК- Возвращение на место где тебя убили.
ЗЗ- "Зеленая Зона". Общественные места-площадь у 
мэрии, вокзалы, больницы и т.п. (В этой зоне запрещено 
стрелять, наносить вред)
БЮ - Багаюз. Использование багов сервера или плагина 
в личных целях, прохождениях преград
FearRP - боязнь смерти. Вы должны отыгрывать боязнь смерти.
ДБ (Damage Bikes) - наносить урон с машин. 
LeaveRP - выйти с сервера во время любой РП ситуации.
FunRP - неадекватные отыгровки
Non Role Play ( NonRp/НонРП ) - действие, которое персонаж 
не смог бы совершить в реальной жизни.

НПРА-Нарушения Правил Рейда Авианосца
НППГ-Нарушения Правил Посещения Гетто
НПО - Нарушение правил ограбления
НПОБ-нарушение правил ограбления банка
НППС-Нарушения правил поведения суда
НПКСК - Нарушения правила капта убийства при появлении 
ЦК - Убийство своего РП перса
УБП - угроза безопасности проекта
НПП - Нарушения правил похищений.
НПК - Нарушение правил каптов/криминала
НПМ - Нарушение правил митингов
НПРПК - Нарушение правил РП килла
НПРГ - Нарушение правил рейда гетто
НПСЗ - Нарушение правил судебного заседания
НПФ - Нарушения правила ферм
НПР - нарушения правил регионов
НПН - Нарушение правил никнеймов
НПС - Нарушение правил скинов
НПЧ - Нарушения правил чата
НПИП -Нарушение правил игрового процесса
НПКЧ - Нарушение правил комендантского часа
НППР - Нарушение правил перестрой районов
НПРПИ - Нарушение правил рп имён
НПЭ - Нарушение правил эмоций
НППСС - нарушение правил поведения со стримерами
НПСЗ - Нарушения правил снятия звёзд
НПБ - Нарушение правил бизнеса
НПНГ - Нарушение правил нахождения в гетто
НПЗГ - Нарушение правил захвата гетто
)")


pmp_window_open(GuiObject?, eventInfo?)
{
    menu_ui.Hide()
    pmp.Show("AutoSize")
}

menu_ui := Gui()
menu_ui.Opt("+AlwaysOnTop")
menu_ui.Title := "AHK | Hospital"
menu_ui.BackColor := 0x1C1C1C 
menu_ui.AddText("cWhite","------------------------------------------ Меню -------------------------------------------")

menu_ui.AddText("cWhite","______________________ПМП______________________")
menus := menu_ui.AddButton("w290 h20", "ПМП")
menus.SetBackColor(0x4e4e4e, 0x1C1C1C)
menus.OnEvent("Click", pmp_window_open)

menu_ui.AddText("cWhite","____________________Проверка____________________")
rpcheck1 := menu_ui.AddButton("w290 h20 ", "Мед. Термины")
rpcheck1.SetBackColor(0x4e4e4e, 0x1C1C1C)
rpcheck1.OnEvent("Click", med_termin)

rpcheck2 := menu_ui.AddButton("w290 h20", "Устав (перекинет в дс)")
rpcheck2.SetBackColor(0x4e4e4e, 0x1C1C1C)
rpcheck2.OnEvent("Click", ystav)

rpcheck3 := menu_ui.AddButton("w290 h20", "Вопросы (перекинет в дс)")
rpcheck3.SetBackColor(0x4e4e4e, 0x1C1C1C)
rpcheck3.OnEvent("Click", ques)

rpcheck4 := menu_ui.AddButton("w290 h20", "Мед. Инструменты (перекинет в дс)")
rpcheck4.SetBackColor(0x4e4e4e, 0x1C1C1C)
rpcheck4.OnEvent("Click", med_tools)

rpcheck5 := menu_ui.AddButton("w290 h20 ", "Рп Термины")
rpcheck5.SetBackColor(0x4e4e4e, 0x1C1C1C)
rpcheck5.OnEvent("Click", open_rp_termin)

menu_ui.AddText("cWhite","____________________ Команды____________________")

rp1 := menu_ui.AddButton("w290 h20", "Alt + C | /calls")
rp1.SetBackColor(0x4e4e4e, 0x1C1C1C)
rp1.OnEvent("Click", calls)

rp2 := menu_ui.AddButton("w290 h20", "Alt + R | /pass accept")
rp2.SetBackColor(0x4e4e4e, 0x1C1C1C)
rp2.OnEvent("Click", pass_accept)
 
rp3 := menu_ui.AddButton("w290 h20", "Alt + E | /med heal ")
rp3.SetBackColor(0x4e4e4e, 0x1C1C1C)
rp3.OnEvent("Click", med_heal)

rp5 := menu_ui.AddButton("w290 h20", "Alt + S | /gps cancel")
rp5.SetBackColor(0x4e4e4e, 0x1C1C1C)
rp5.OnEvent("Click", gps_cancel)

rp4 := menu_ui.AddButton("w290 h20", "/drops time")
rp4.SetBackColor(0x4e4e4e, 0x1C1C1C)
rp4.OnEvent("Click", drops_time)














close_notify(GuiObject?, eventInfo?)
{
    notify.Hide()
}

notify := Gui()
notify.Opt("+AlwaysOnTop")
notify.Title := "AHK | Статус"
notify.BackColor := 0x1C1C1C 
if temp_data == "restart" {
    notify.AddText("cWhite","AHK | Hospital | Программа была перезапущена")
}
else{
    notify.AddText("cWhite","AHK | Hospital | Программа запущена и свёрнута в трей")
}
if !FileExist(cfg_file){
    notify.AddText("cWhite","
    (Ltrim join`r`n
AHK | Hospital | Список изменений:
[+] Добавлено меню которое совместило меню 
"проверка", "команды" и "ПМП"
[+] Добавлен пункт "Rp Термины" в меню "проверка"
[+] При первом запуске добавлен текст 
"Список изменений"
[+] Теперь текст в мед.терминах более компактнее 
[+] Добавлены бинды на NumPad для интерфейса
[+] Теперь после лечение вводиться не просто:
"/med heal", a "/med heal _ 100", при этом
ввод будет там где знак "_"
[+] Добавлено отдельное уведомление при перезапуске
[+] Добавлена кнопка и бинд для /gps cancel

[=] Исправлены ошибки когда текст не отправлялся
[=] Исправлены орфографические ошибки в ui

[!] Убраны бинд на F7 [!]
[!] Заменён бинд на F8 [!]
    )")
    FileAppend("non_first_start", cfg_file, "utf-8")
}
notifya := notify.AddButton("w290 h20", "OK")
notifya.SetBackColor(0x4e4e4e, 0x1C1C1C)
notifya.OnEvent("Click", close_notify)
notify.Show("AutoSize")











FileDelete(temp_file)
F1::{
    Main.Show("AutoSize")
}
F6::{
    Educ.Show("AutoSize")
}
F8::{
    menu_ui.Show("AutoSize")
}
F9::{
    Rare.Show("AutoSize")
}
F10::{
    restart_ui()
}
Numpad0::{
    Reload()
}
Numpad1::{
    Main.Show("AutoSize")
}
Numpad2::{
    Educ.Show("AutoSize")
}
Numpad3::{
    Rare.Show("AutoSize")
}
Numpad5::{
    menu_ui.Show("AutoSize")
}
!c::{
    calls()
    Return
}
!r::{
    pass_accept()
    Return
}
!u::{
    knife()
    Return
}
!b::{
    peluvoe()
    Return
}
!e::{
    med_heal()
    Return
}
!q::{
    greetings()
    Return
}
!t::{
    give_pill()
    Return
}
!l::{
    sell_pill()
    Return
}
!y::{
    bruise()
    Return
}
!h::{
    ammonia()
    Return
}
!n::{
    stretcher()
    Return
}
!d::{
    defibrillator()
    Return
}
!i::{
    inject()
    Return
}
!k::{
    dropper()
    Return
}
!m::{
    medcard()
    Return
}
!v::{
    extract()
    Return
}
!o::{
    medical_examination()
    Return
}
!p::{
    prof_suitability()
    Return
}
!g::{
    twist()
    Return
}
!j::{
    calm()
    Return
}
!s::{
    gps_cancel()
    Return
}
!1::{
    blood_vien()
    Return
}
!2::{
    blood()
    Return
}
!3::{
    wound()
    Return
}
!4::{
    wound_plus()
    Return
}
!5::{
    bullet()
    Return
}
!6::{
    rengen()
    Return
}
!7::{
    dislocation()
    Return
}
!8::{
    close_fracture()
    Return
}
!9::{
    open_fracture()
    Return
}
!0::{
    gypsum()
    Return
}
^!1::{
    lecture()
    Return
}
^!2::{
    regulation1()
    Return
}
^!3::{
    regulation2()
    Return
}
^!4::{
    regulation3()
    Return
}
^!5::{
    regulation4()
    Return
}
^!6::{
    oath()
    Return
}
^!7::{
    assingments()
    Return
}
^!8::{
    practice()
    Return
}
^!9::{
    practice2()
    Return
}
^!0::{
    oath_start()
    Return
}
