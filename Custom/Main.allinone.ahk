; /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
; |              AHK-FOR-RPM              |
; |           AFR v2  | by Agzes          |
; |         https://e-z.bio/agzes         |
; \_______________________________________/


; / AFR VERSION 2.2 | CONFIG

;!      ВСТАВЬТЕ КОНФИГ СЮДА       !

; \ AFR VERSION 2.2 | CONFIG


; <--------------->
;       LIBS
; <--------------->

; AFR v.2.2 LIBS PART (Не изменяйте для корректной работы конфига)
{
    ; Credits:
    ; just me - CreateImageButton() - 2024-01-01
    ; https://www.autohotkey.com/boards/viewtopic.php?t=93339

    ; ======================================================================================================================
    ; Name:              CreateImageButton()
    ; Function:          Create images and assign them to pushbuttons.
    ; Tested with:       AHK 2.0.11 (U32/U64)
    ; Tested on:         Win 10 (x64)
    ; Change history:    1.0.01/2024-01-01/just me   - Use Gui.Backcolor as default for the background if available
    ;                    1.0.00/2023-02-03/just me   - Initial stable release for AHK v2
    ; Credits:           THX tic for GDIP.AHK, tkoi for ILBUTTON.AHK
    ; ======================================================================================================================
    ; How to use:
    ;     1. Call UseGDIP() to initialize the Gdiplus.dll before the first call of this function.
    ;     2. Create a push button (e.g. "MyGui.AddButton("option", "caption").
    ;     3. If you want to want to use another color than the GUI's current Backcolor for the background of the images
    ;        - especially for rounded buttons - call CreateImageButton("SetDefGuiColor", NewColor) where NewColor is a RGB
    ;        integer value (0xRRGGBB) or a HTML color name ("Red"). You can also change the default text color by calling
    ;        CreateImageButton("SetDefTxtColor", NewColor).
    ;        To reset the colors to the AHK/system default pass "*DEF*" in NewColor, to reset the background to use
    ;        Gui.Backcolor pass "*GUI*".
    ;     4. To create an image button call CreateImageButton() passing two or more parameters:
    ;        GuiBtn      -  Gui.Button object.
    ;        Mode        -  The mode used to create the bitmaps:
    ;                       0  -  unicolored or bitmap
    ;                       1  -  vertical bicolored
    ;                       2  -  horizontal bicolored
    ;                       3  -  vertical gradient
    ;                       4  -  horizontal gradient
    ;                       5  -  vertical gradient using StartColor at both borders and TargetColor at the center
    ;                       6  -  horizontal gradient using StartColor at both borders and TargetColor at the center
    ;                       7  -  'raised' style
    ;                       8  -  forward diagonal gradient from the upper-left corner to the lower-right corner
    ;                       9  -  backward diagonal gradient from the upper-right corner to the lower-left corner
    ;                      -1  -  reset the button
    ;        Options*    -  variadic array containing up to 6 option arrays (see below).
    ;        ---------------------------------------------------------------------------------------------------------------
    ;        The index of each option object determines the corresponding button state on which the bitmap will be shown.
    ;        MSDN defines 6 states (http://msdn.microsoft.com/en-us/windows/bb775975):
    ;           PBS_NORMAL    = 1
    ;	         PBS_HOT       = 2
    ;	         PBS_PRESSED   = 3
    ;	         PBS_DISABLED  = 4
    ;	         PBS_DEFAULTED = 5
    ;	         PBS_STYLUSHOT = 6 <- used only on tablet computers (that's false for Windows Vista and 7, see below)
    ;        If you don't want the button to be 'animated' on themed GUIs, just pass one option object with index 1.
    ;        On Windows Vista and 7 themed bottons are 'animated' using the images of states 5 and 6 after clicked.
    ;        ---------------------------------------------------------------------------------------------------------------
    ;        Each option array may contain the following values:
    ;           Index Value
    ;           1     StartColor  mandatory for Option[1], higher indices will inherit the value of Option[1], if omitted:
    ;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
    ;                             -  Path of an image file or HBITMAP handle for mode 0.
    ;           2     TargetColor mandatory for Option[1] if Mode > 0. Higher indcices will inherit the color of Option[1],
    ;                             if omitted:
    ;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
    ;                             -  String "HICON" if StartColor contains a HICON handle.
    ;           3     TextColor   optional, if omitted, the default text color will be used for Option[1], higher indices
    ;                             will inherit the color of Option[1]:
    ;                             -  ARGB integer value (0xAARRGGBB) or HTML color name ("Red").
    ;                                Default: 0xFF000000 (black)
    ;           4     Rounded     optional:
    ;                             -  Radius of the rounded corners in pixel; the letters 'H' and 'W' may be specified
    ;                                also to use the half of the button's height or width respectively.
    ;                                Default: 0 - not rounded
    ;           5     BorderColor optional, ignored for modes 0 (bitmap) and 7, color of the border:
    ;                             -  RGB integer value (0xRRGGBB) or HTML color name ("Red").
    ;           6     BorderWidth optional, ignored for modes 0 (bitmap) and 7, width of the border in pixels:
    ;                             -  Default: 1
    ;        ---------------------------------------------------------------------------------------------------------------
    ;        If the the button has a caption it will be drawn upon the bitmaps.
    ;     5. Call GdiplusShutDown() to clean up the resources used by GDI+ after the last function call or
    ;        before the script terminates.
    ; ======================================================================================================================
    ; This software is provided 'as-is', without any express or implied warranty.
    ; In no event will the authors be held liable for any damages arising from the use of this software.
    ; ======================================================================================================================
    #Requires AutoHotkey 2.0.0
    ; ======================================================================================================================
    ; CreateImageButton()
    ; ======================================================================================================================
    CreateImageButton(GuiBtn, Mode, Options*) {
        ; Default colors - COLOR_3DFACE is used by AHK as default Gui background color
        Static DefGuiColor := SetDefGuiColor("*GUI*"),
            DefTxtColor := SetDefTxtColor("*DEF*"),
            GammaCorr := False
        Static HTML := { BLACK: 0x000000, GRAY: 0x808080, SILVER: 0xC0C0C0, WHITE: 0xFFFFFF,
            MAROON: 0x800000, PURPLE: 0x800080, FUCHSIA: 0xFF00FF, RED: 0xFF0000,
            GREEN: 0x008000, OLIVE: 0x808000, YELLOW: 0xFFFF00, LIME: 0x00FF00,
            NAVY: 0x000080, TEAL: 0x008080, AQUA: 0x00FFFF, BLUE: 0x0000FF }
        Static MaxBitmaps := 6, MaxOptions := 6
        Static BitMaps := [], Buttons := Map()
        Static Bitmap := 0, Graphics := 0, Font := 0, StringFormat := 0, HIML := 0
        Static BtnCaption := "", BtnStyle := 0
        Static HWND := 0
        Bitmap := Graphics := Font := StringFormat := HIML := 0
        NumBitmaps := 0
        BtnCaption := ""
        BtnStyle := 0
        BtnW := 0
        BtnH := 0
        GuiColor := ""
        TxtColor := ""
        HWND := 0
        ; -------------------------------------------------------------------------------------------------------------------
        ; Check for 'special calls'
        If !IsObject(GuiBtn) {
            Switch GuiBtn {
                Case "SetDefGuiColor":
                    DefGuiColor := SetDefGuiColor(Mode)
                    Return True
                Case "SetDefTxtColor":
                    DefTxtColor := SetDefTxtColor(Mode)
                    Return True
                Case "SetGammaCorrection":
                    GammaCorr := !!Mode
                    Return True
            }
        }
        ; -------------------------------------------------------------------------------------------------------------------
        ; Check the control object
        If (Type(GuiBtn) != "Gui.Button")
            Return ErrorExit("Invalid parameter GuiBtn!")
        HWND := GuiBtn.Hwnd
        ; -------------------------------------------------------------------------------------------------------------------
        ; Check Mode
        If !IsInteger(Mode) || (Mode < -1) || (Mode > 9)
            Return ErrorExit("Invalid parameter Mode!")
        If (Mode = -1) { ; reset the button
            If Buttons.Has(HWND) {
                Btn := Buttons[HWND]
                BIL := Buffer(20 + A_PtrSize, 0)
                NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
                SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
                IL_Destroy(Btn["HIML"])
                ControlSetStyle(Btn["Style"], HWND)
                Buttons.Delete(HWND)
                Return True
            }
            Return False
        }
        ; -------------------------------------------------------------------------------------------------------------------
        ; Check Options
        If !(Options Is Array) || !Options.Has(1) || (Options.Length > MaxOptions)
            Return ErrorExit("Invalid parameter Options!")
        ; -------------------------------------------------------------------------------------------------------------------
        HBITMAP := HFORMAT := PBITMAP := PBRUSH := PFONT := PGRAPHICS := PPATH := 0
        ; -------------------------------------------------------------------------------------------------------------------
        ; Get control's styles
        BtnStyle := ControlGetStyle(HWND)
        ; -------------------------------------------------------------------------------------------------------------------
        ; Get the button's font
        PFONT := 0
        If (HFONT := SendMessage(0x31, 0, 0, HWND)) { ; WM_GETFONT
            DC := DllCall("GetDC", "Ptr", HWND, "Ptr")
            DllCall("SelectObject", "Ptr", DC, "Ptr", HFONT)
            DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", DC, "PtrP", &PFONT)
            DllCall("ReleaseDC", "Ptr", HWND, "Ptr", DC)
        }
        If !(Font := PFONT)
            Return ErrorExit("Couldn't get button's font!")
        ; -------------------------------------------------------------------------------------------------------------------
        ; Get the button's width and height
        ControlGetPos(, , &BtnW, &BtnH, HWND)
        ; -------------------------------------------------------------------------------------------------------------------
        ; Get the button's caption
        BtnCaption := GuiBtn.Text
        ; -------------------------------------------------------------------------------------------------------------------
        ; Create a GDI+ bitmap
        PBITMAP := 0
        DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0",
            "Int", BtnW, "Int", BtnH, "Int", 0, "UInt", 0x26200A, "Ptr", 0, "PtrP", &PBITMAP)
        If !(Bitmap := PBITMAP)
            Return ErrorExit("Couldn't create the GDI+ bitmap!")
        ; Get the pointer to its graphics
        PGRAPHICS := 0
        DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", PBITMAP, "PtrP", &PGRAPHICS)
        If !(Graphics := PGRAPHICS)
            Return ErrorExit("Couldn't get the the GDI+ bitmap's graphics!")
        ; Quality settings
        DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", PGRAPHICS, "UInt", 4)
        DllCall("Gdiplus.dll\GdipSetInterpolationMode", "Ptr", PGRAPHICS, "Int", 7)
        DllCall("Gdiplus.dll\GdipSetCompositingQuality", "Ptr", PGRAPHICS, "UInt", 4)
        DllCall("Gdiplus.dll\GdipSetRenderingOrigin", "Ptr", PGRAPHICS, "Int", 0, "Int", 0)
        DllCall("Gdiplus.dll\GdipSetPixelOffsetMode", "Ptr", PGRAPHICS, "UInt", 4)
        DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", PGRAPHICS, "Int", 0)
        ; Create a StringFormat object
        HFORMAT := 0
        DllCall("Gdiplus.dll\GdipStringFormatGetGenericTypographic", "PtrP", &HFORMAT)
        ; Horizontal alignment
        ; BS_LEFT = 0x0100, BS_RIGHT = 0x0200, BS_CENTER = 0x0300, BS_TOP = 0x0400, BS_BOTTOM = 0x0800, BS_VCENTER = 0x0C00
        ; SA_LEFT = 0, SA_CENTER = 1, SA_RIGHT = 2
        HALIGN := (BtnStyle & 0x0300) = 0x0300 ? 1
            : (BtnStyle & 0x0300) = 0x0200 ? 2
            : (BtnStyle & 0x0300) = 0x0100 ? 0
            : 1
        DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", HFORMAT, "Int", HALIGN)
        ; Vertical alignment
        VALIGN := (BtnStyle & 0x0C00) = 0x0400 ? 0
            : (BtnStyle & 0x0C00) = 0x0800 ? 2
            : 1
        DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", HFORMAT, "Int", VALIGN)
        DllCall("Gdiplus.dll\GdipSetStringFormatHotkeyPrefix", "Ptr", HFORMAT, "UInt", 1) ; THX robodesign
        StringFormat := HFORMAT
        ; -------------------------------------------------------------------------------------------------------------------
        ; Create the bitmap(s)
        BitMaps := []
        BitMaps.Length := MaxBitmaps
        Opt1 := Options[1]
        Opt1.Length := MaxOptions
        Loop MaxOptions
            If !Opt1.Has(A_Index)
                Opt1[A_Index] := ""
        If (Opt1[3] = "")
            Opt1[3] := GetARGB(DefTxtColor)
        For Idx, Opt In Options {
            If !IsSet(Opt) || !IsObject(Opt) || !(Opt Is Array)
                Continue
            BkgColor1 := BkgColor2 := TxtColor := Rounded := GuiColor := Image := ""
            ; Replace omitted options with the values of Options.1
            If (Idx > 1) {
                Opt.Length := MaxOptions
                Loop MaxOptions {
                    If !Opt.Has(A_Index) || (Opt[A_Index] = "")
                        Opt[A_Index] := Opt1[A_Index]
                }
            }
            ; ----------------------------------------------------------------------------------------------------------------
            ; Check option values
            ; StartColor & TargetColor
            If (Mode = 0) && BitmapOrIcon(Opt[1], Opt[2])
                Image := Opt[1]
            Else {
                If !IsInteger(Opt[1]) && !HTML.HasOwnProp(Opt[1])
                    Return ErrorExit("Invalid value for StartColor in Options[" . Idx . "]!")
                BkgColor1 := GetARGB(Opt[1])
                If (Opt[2] = "")
                    Opt[2] := Opt[1]
                If !IsInteger(Opt[2]) && !HTML.HasOwnProp(Opt[2])
                    Return ErrorExit("Invalid value for TargetColor in Options[" . Idx . "]!")
                BkgColor2 := GetARGB(Opt[2])
            }
            ; TextColor
            If (Opt[3] = "")
                Opt[3] := GetARGB(DefTxtColor)
            If !IsInteger(Opt[3]) && !HTML.HasOwnProp(Opt[3])
                Return ErrorExit("Invalid value for TxtColor in Options[" . Idx . "]!")
            TxtColor := GetARGB(Opt[3])
            ; Rounded
            Rounded := Opt[4]
            If (Rounded = "H")
                Rounded := BtnH * 0.5
            If (Rounded = "W")
                Rounded := BtnW * 0.5
            If !IsNumber(Rounded)
                Rounded := 0
            ; GuiColor
            If DefGuiColor = "*GUI*"
                GuiColor := GetARGB(GuiBtn.Gui.Backcolor != "" ? "0x" GuiBtn.Gui.Backcolor : SetDefGuiColor("*DEF*"))
            Else
                GuiColor := GetARGB(DefGuiColor)
            ; BorderColor
            BorderColor := ""
            If (Opt[5] != "") {
                If !IsInteger(Opt[5]) && !HTML.HasOwnProp(Opt[5])
                    Return ErrorExit("Invalid value for BorderColor in Options[" . Idx . "]!")
                BorderColor := 0xFF000000 | GetARGB(Opt[5]) ; BorderColor must be always opaque
            }
            ; BorderWidth
            BorderWidth := Opt[6] ? Opt[6] : 1
            ; ----------------------------------------------------------------------------------------------------------------
            ; Clear the background
            DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", PGRAPHICS, "UInt", GuiColor)
            ; Create the image
            If (Image = "") { ; Create a BitMap based on the specified colors
                PathX := PathY := 0, PathW := BtnW, PathH := BtnH
                ; Create a GraphicsPath
                PPATH := 0
                DllCall("Gdiplus.dll\GdipCreatePath", "UInt", 0, "PtrP", &PPATH)
                If (Rounded < 1) ; the path is a rectangular rectangle
                    PathAddRectangle(PPATH, PathX, PathY, PathW, PathH)
                Else ; the path is a rounded rectangle
                    PathAddRoundedRect(PPATH, PathX, PathY, PathW, PathH, Rounded)
                ; If BorderColor and BorderWidth are specified, 'draw' the border (not for Mode 7)
                If (BorderColor != "") && (BorderWidth > 0) && (Mode != 7) {
                    ; Create a SolidBrush
                    PBRUSH := 0
                    DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", BorderColor, "PtrP", &PBRUSH)
                    ; Fill the path
                    DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                    ; Free the brush
                    DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
                    ; Reset the path
                    DllCall("Gdiplus.dll\GdipResetPath", "Ptr", PPATH)
                    ; Add a new 'inner' path
                    PathX := PathY := BorderWidth, PathW -= BorderWidth, PathH -= BorderWidth, Rounded -= BorderWidth
                    If (Rounded < 1) ; the path is a rectangular rectangle
                        PathAddRectangle(PPATH, PathX, PathY, PathW - PathX, PathH - PathY)
                    Else ; the path is a rounded rectangle
                        PathAddRoundedRect(PPATH, PathX, PathY, PathW, PathH, Rounded)
                    ; If a BorderColor has been drawn, BkgColors must be opaque
                    BkgColor1 := 0xFF000000 | BkgColor1
                    BkgColor2 := 0xFF000000 | BkgColor2
                }
                PathW -= PathX
                PathH -= PathY
                PBRUSH := 0
                RECTF := 0
                Switch Mode {
                    Case 0:                    ; the background is unicolored
                        ; Create a SolidBrush
                        DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", BkgColor1, "PtrP", &PBRUSH)
                        ; Fill the path
                        DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                    Case 1, 2:                 ; the background is bicolored
                        ; Create a LineGradientBrush
                        SetRectF(&RECTF, PathX, PathY, PathW, PathH)
                        DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect",
                            "Ptr", RECTF, "UInt", BkgColor1, "UInt", BkgColor2, "Int", Mode & 1, "Int", 3, "PtrP", &PBRUSH)
                        DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", PBRUSH, "Int", GammaCorr)
                        ; Set up colors and positions
                        SetRect(&COLORS, BkgColor1, BkgColor1, BkgColor2, BkgColor2) ; sorry for function misuse
                        SetRectF(&POSITIONS, 0, 0.5, 0.5, 1) ; sorry for function misuse
                        DllCall("Gdiplus.dll\GdipSetLinePresetBlend",
                            "Ptr", PBRUSH, "Ptr", COLORS, "Ptr", POSITIONS, "Int", 4)
                        ; Fill the path
                        DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                    Case 3, 4, 5, 6, 8, 9:     ; the background is a gradient
                        ; Determine the brush's width/height
                        W := Mode = 6 ? PathW / 2 : PathW  ; horizontal
                        H := Mode = 5 ? PathH / 2 : PathH  ; vertical
                        ; Create a LineGradientBrush
                        SetRectF(&RECTF, PathX, PathY, W, H)
                        LGM := Mode > 6 ? Mode - 6 : Mode & 1 ; LinearGradientMode
                        DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect",
                            "Ptr", RECTF, "UInt", BkgColor1, "UInt", BkgColor2, "Int", LGM, "Int", 3, "PtrP", &PBRUSH)
                        DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", PBRUSH, "Int", GammaCorr)
                        ; Fill the path
                        DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                    Case 7:                    ; raised mode
                        DllCall("Gdiplus.dll\GdipCreatePathGradientFromPath", "Ptr", PPATH, "PtrP", &PBRUSH)
                        ; Set Gamma Correction
                        DllCall("Gdiplus.dll\GdipSetPathGradientGammaCorrection", "Ptr", PBRUSH, "UInt", GammaCorr)
                        ; Set surround and center colors
                        ColorArray := Buffer(4, 0)
                        NumPut("UInt", BkgColor1, ColorArray)
                        DllCall("Gdiplus.dll\GdipSetPathGradientSurroundColorsWithCount",
                            "Ptr", PBRUSH, "Ptr", ColorArray, "IntP", 1)
                        DllCall("Gdiplus.dll\GdipSetPathGradientCenterColor", "Ptr", PBRUSH, "UInt", BkgColor2)
                        ; Set the FocusScales
                        FS := (BtnH < BtnW ? BtnH : BtnW) / 3
                        XScale := (BtnW - FS) / BtnW
                        YScale := (BtnH - FS) / BtnH
                        DllCall("Gdiplus.dll\GdipSetPathGradientFocusScales", "Ptr", PBRUSH, "Float", XScale, "Float", YScale)
                        ; Fill the path
                        DllCall("Gdiplus.dll\GdipFillPath", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Ptr", PPATH)
                }
                ; Free resources
                DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
                DllCall("Gdiplus.dll\GdipDeletePath", "Ptr", PPATH)
            }
            Else { ; Create a bitmap from HBITMAP or file
                PBM := 0
                If IsInteger(Image)
                    If (Opt[2] = "HICON")
                        DllCall("Gdiplus.dll\GdipCreateBitmapFromHICON", "Ptr", Image, "PtrP", &PBM)
                    Else
                        DllCall("Gdiplus.dll\GdipCreateBitmapFromHBITMAP", "Ptr", Image, "Ptr", 0, "PtrP", &PBM)
                Else
                    DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", Image, "PtrP", &PBM)
                ; Draw the bitmap
                DllCall("Gdiplus.dll\GdipDrawImageRectI",
                    "Ptr", PGRAPHICS, "Ptr", PBM, "Int", 0, "Int", 0, "Int", BtnW, "Int", BtnH)
                ; Free the bitmap
                DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBM)
            }
            ; ----------------------------------------------------------------------------------------------------------------
            ; Draw the caption
            If (BtnCaption != "") {
                ; Text color
                DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", TxtColor, "PtrP", &PBRUSH)
                ; Set the text's rectangle
                RECT := Buffer(16, 0)
                NumPut("Float", BtnW, "Float", BtnH, RECT, 8)
                ; Draw the text
                DllCall("Gdiplus.dll\GdipDrawString",
                    "Ptr", PGRAPHICS, "Str", BtnCaption, "Int", -1,
                    "Ptr", PFONT, "Ptr", RECT, "Ptr", HFORMAT, "Ptr", PBRUSH)
            }
            ; ----------------------------------------------------------------------------------------------------------------
            ; Create a HBITMAP handle from the bitmap and add it to the array
            HBITMAP := 0
            DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", PBITMAP, "PtrP", &HBITMAP, "UInt", 0X00FFFFFF)
            BitMaps[Idx] := HBITMAP
            NumBitmaps++
            ; Free resources
            DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
        }
        ; Now free remaining the GDI+ objects
        DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBITMAP)
        DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", PGRAPHICS)
        DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", PFONT)
        DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", HFORMAT)
        Bitmap := Graphics := Font := StringFormat := 0
        ; -------------------------------------------------------------------------------------------------------------------
        ; Create the ImageList
        ; ILC_COLOR32 = 0x20
        HIL := DllCall("Comctl32.dll\ImageList_Create"
            , "UInt", BtnW, "UInt", BtnH, "UInt", 0x20, "Int", 6, "Int", 0, "Ptr") ; ILC_COLOR32
        Loop (NumBitmaps > 1) ? MaxBitmaps : 1 {
            HBITMAP := BitMaps.Has(A_Index) ? BitMaps[A_Index] : BitMaps[1]
            DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", HBITMAP, "Ptr", 0)
        }
        ; Create a BUTTON_IMAGELIST structure
        BIL := Buffer(20 + A_PtrSize, 0)
        ; Get the currently assigned image list
        SendMessage(0x1603, 0, BIL.Ptr, HWND) ; BCM_GETIMAGELIST
        PrevIL := NumGet(BIL, "UPtr")
        ; Remove the previous image list, if any
        BIL := Buffer(20 + A_PtrSize, 0)
        NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
        SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
        ; Create a new BUTTON_IMAGELIST structure
        ; BUTTON_IMAGELIST_ALIGN_LEFT = 0, BUTTON_IMAGELIST_ALIGN_RIGHT = 1, BUTTON_IMAGELIST_ALIGN_CENTER = 4,
        BIL := Buffer(20 + A_PtrSize, 0)
        NumPut("Ptr", HIL, BIL)
        Numput("UInt", 4, BIL, A_PtrSize + 16) ; BUTTON_IMAGELIST_ALIGN_CENTER
        ControlSetStyle(BtnStyle | 0x0080, HWND) ; BS_BITMAP
        ; Remove the currently assigned image list, if any
        If (PrevIL)
            IL_Destroy(PrevIL)
        ; Assign the ImageList to the button
        SendMessage(0x1602, 0, BIL.Ptr, HWND) ; BCM_SETIMAGELIST
        ; Free the bitmaps
        FreeBitmaps()
        NumBitmaps := 0
        ; -------------------------------------------------------------------------------------------------------------------
        ; All done successfully
        Buttons[HWND] := Map("HIML", HIL, "Style", BtnStyle)
        Return True
        ; ===================================================================================================================
        ; Internally used functions
        ; ===================================================================================================================
        ; Set the default GUI color.
        ; GuiColor - RGB integer value (0xRRGGBB) or HTML color name ("Red").
        ;          - "*GUI*" to use Gui.Backcolor (default)
        ;          - "*DEF*" to use AHK's default Gui color.
        SetDefGuiColor(GuiColor) {
            Static DefColor := DllCall("GetSysColor", "Int", 15, "UInt") ; COLOR_3DFACE
            Switch
            {
                Case (GuiColor = "*GUI*"):
                    Return GuiColor
                Case (GuiColor = "*DEF*"):
                    Return GetRGB(DefColor)
                Case IsInteger(GuiColor):
                    Return GuiColor & 0xFFFFFF
                Case HTML.HasOwnProp(GuiColor):
                    Return HTML.%GuiColor% &0xFFFFFF
                Default:
                    Throw ValueError("Parameter GuiColor invalid", -1, GuiColor)
            }
        }
        ; ===================================================================================================================
        ; Set the default text color.
        ; TxtColor - RGB integer value (0xRRGGBB) or HTML color name ("Red").
        ;          - "*DEF*" to reset to AHK's default text color.
        SetDefTxtColor(TxtColor) {
            Static DefColor := DllCall("GetSysColor", "Int", 18, "UInt") ; COLOR_BTNTEXT
            Switch
            {
                Case (TxtColor = "*DEF*"):
                    Return GetRGB(DefColor)
                Case IsInteger(TxtColor):
                    Return TxtColor & 0xFFFFFF
                Case HTML.HasOwnProp(TxtColor):
                    Return HTML.%TxtColor% &0xFFFFFF
                Default:
                    Throw ValueError("Parameter TxtColor invalid", -1, TxtColor)
            }
            Return True
        }
        ; ===================================================================================================================
        ; PRIVATE FUNCTIONS =================================================================================================
        ; ===================================================================================================================
        BitmapOrIcon(O1, O2) {
            ; OBJ_BITMAP = 7
            Return IsInteger(O1) ? (O2 = "HICON") || (DllCall("GetObjectType", "Ptr", O1, "UInt") = 7) : FileExist(O1)
        }
        ; -------------------------------------------------------------------------------------------------------------------
        FreeBitmaps() {
            For HBITMAP In BitMaps
                IsSet(HBITMAP) ? DllCall("DeleteObject", "Ptr", HBITMAP) : 0
            BitMaps := []
        }
        ; -------------------------------------------------------------------------------------------------------------------
        GetARGB(RGB) {
            ARGB := HTML.HasOwnProp(RGB) ? HTML.%RGB% : RGB
            Return (ARGB & 0xFF000000) = 0 ? 0xFF000000 | ARGB : ARGB
        }
        ; -------------------------------------------------------------------------------------------------------------------
        GetRGB(BGR) {
            Return ((BGR & 0xFF0000) >> 16) | (BGR & 0x00FF00) | ((BGR & 0x0000FF) << 16)
        }
        ; -------------------------------------------------------------------------------------------------------------------
        PathAddRectangle(Path, X, Y, W, H) {
            Return DllCall("Gdiplus.dll\GdipAddPathRectangle", "Ptr", Path, "Float", X, "Float", Y, "Float", W, "Float", H)
        }
        ; -------------------------------------------------------------------------------------------------------------------
        PathAddRoundedRect(Path, X1, Y1, X2, Y2, R) {
            D := (R * 2), X2 -= D, Y2 -= D
            DllCall("Gdiplus.dll\GdipAddPathArc",
                "Ptr", Path, "Float", X1, "Float", Y1, "Float", D, "Float", D, "Float", 180, "Float", 90)
            DllCall("Gdiplus.dll\GdipAddPathArc",
                "Ptr", Path, "Float", X2, "Float", Y1, "Float", D, "Float", D, "Float", 270, "Float", 90)
            DllCall("Gdiplus.dll\GdipAddPathArc",
                "Ptr", Path, "Float", X2, "Float", Y2, "Float", D, "Float", D, "Float", 0, "Float", 90)
            DllCall("Gdiplus.dll\GdipAddPathArc",
                "Ptr", Path, "Float", X1, "Float", Y2, "Float", D, "Float", D, "Float", 90, "Float", 90)
            Return DllCall("Gdiplus.dll\GdipClosePathFigure", "Ptr", Path)
        }
        ; -------------------------------------------------------------------------------------------------------------------
        SetRect(&Rect, L := 0, T := 0, R := 0, B := 0) {
            Rect := Buffer(16, 0)
            NumPut("Int", L, "Int", T, "Int", R, "Int", B, Rect)
            Return True
        }
        ; -------------------------------------------------------------------------------------------------------------------
        SetRectF(&Rect, X := 0, Y := 0, W := 0, H := 0) {
            Rect := Buffer(16, 0)
            NumPut("Float", X, "Float", Y, "Float", W, "Float", H, Rect)
            Return True
        }
        ; -------------------------------------------------------------------------------------------------------------------
        ErrorExit(ErrMsg) {
            If (Bitmap)
                DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", Bitmap)
            If (Graphics)
                DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", Graphics)
            If (Font)
                DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", Font)
            If (StringFormat)
                DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", StringFormat)
            If (HIML) {
                BIL := Buffer(20 + A_PtrSize, 0)
                NumPut("Ptr", -1, BIL) ; BCCL_NOGLYPH
                DllCall("SendMessage", "Ptr", HWND, "UInt", 0x1602, "Ptr", 0, "Ptr", BIL) ; BCM_SETIMAGELIST
                IL_Destroy(HIML)
            }
            Bitmap := 0
            Graphics := 0
            Font := 0
            StringFormat := 0
            HIML := 0
            FreeBitmaps()
            Throw Error(ErrMsg)
        }
    }
    ; Credits:
    ; jNizM - DarkMode (Force or Toggle)
    ; https://www.autohotkey.com/boards/viewtopic.php?f=92&t=115952

    SetWindowAttribute(GuiObj, DarkMode := True)
    {
        global DarkColors := Map("Background", "0x171717", "Controls", "0x1b1b1b", "Font", "0xE0E0E0")
        global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
        static PreferredAppMode := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

        if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
        {
            DWMWA_USE_IMMERSIVE_DARK_MODE := 19
            if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
            {
                DWMWA_USE_IMMERSIVE_DARK_MODE := 20
            }
            uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
            SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
            FlushMenuThemes := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
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
        static GWL_WNDPROC := -4
        static GWL_STYLE := -16
        static ES_MULTILINE := 0x0004
        static LVM_GETTEXTCOLOR := 0x1023
        static LVM_SETTEXTCOLOR := 0x1024
        static LVM_GETTEXTBKCOLOR := 0x1025
        static LVM_SETTEXTBKCOLOR := 0x1026
        static LVM_GETBKCOLOR := 0x1000
        static LVM_SETBKCOLOR := 0x1001
        static LVM_GETHEADER := 0x101F
        static GetWindowLong := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
        static SetWindowLong := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
        static Init := False
        static LV_Init := False
        global IsDarkMode := DarkMode

        Mode_Explorer := (DarkMode ? "DarkMode_Explorer" : "Explorer")
        Mode_CFD := (DarkMode ? "DarkMode_CFD" : "CFD")
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
                        case "EDITE": ;Edit
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
                                    static LV_TEXTCOLOR := SendMessage(LVM_GETTEXTCOLOR, 0, 0, GuiCtrlObj.hWnd)
                                    static LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
                                    static LV_BKCOLOR := SendMessage(LVM_GETBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
                                    LV_Init := True
                                }
                                GuiCtrlObj.Opt("-Redraw")
                                switch DarkMode
                                {
                                    case True:
                                    {
                                        SendMessage(LVM_SETTEXTCOLOR, 0, DarkColors["Font"], GuiCtrlObj.hWnd)
                                        SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
                                        SendMessage(LVM_SETBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
                                    }
                                        default:
                                        {
                                            SendMessage(LVM_SETTEXTCOLOR, 0, LV_TEXTCOLOR, GuiCtrlObj.hWnd)
                                            SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
                                            SendMessage(LVM_SETBKCOLOR, 0, LV_BKCOLOR, GuiCtrlObj.hWnd)
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
            Init := False ; Need For UI
        }
    } WindowProc(hwnd, uMsg, wParam, lParam)
    {
        critical
        static WM_CTLCOLOREDIT := 0x0133
        static WM_CTLCOLORLISTBOX := 0x0134
        static WM_CTLCOLORBTN := 0x0135
        static WM_CTLCOLORSTATIC := 0x0138
        static DC_BRUSH := 18

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
    ; Credits:
    ; Nikola Perovic - https://github.com/nperovic
    ; https://github.com/nperovic/GuiEnhancerKit

    /************************************************************************
     * @description Elevate your AHK Gui development with extended methods and properties.  
     * @file GuiEnhancerKit.ahk
     * @author Nikola Perovic
     * @link https://github.com/nperovic/GuiEnhancerKit
     * @date 2024/06/16
     * @version 1.0.0
     ***********************************************************************/

    #Requires AutoHotkey v2

    #DllLoad gdi32.dll
    #DllLoad uxtheme.dll
    #DllLoad dwmapi.dll

    class GuiExt extends Gui
    {
        class __Struct extends Buffer
        {
            __New(ByteCount?, FillByte?) => super.__New(ByteCount?, FillByte?)

            Set(ptr?)
            {
                if !(ptr ?? 0)
                    return
                for p, v in ptr.OwnProps()
                    if this.HasProp(p)
                        this.%p% := v
            }

            PropDesc(name, ofst, type, ptr?)
            {
                if ((ptr ?? 0) && IsNumber(ptr))
                    NumPut(type, NumGet(ptr, ofst, type), this, ofst)
                this.DefineProp(name, {
                    Get: NumGet.Bind(, ofst, type),
                    Set: (p, v) => NumPut(type, v, this, ofst)
                })
            }
        }

        class RECT extends GuiExt.__Struct
        {
            /**
             * The `RECT` structure defines a rectangle by the coordinates of its upper-left and lower-right corners.
             * @param {object|integer} [objOrAddress] *Optional:* Create rect object and set values to each property. It can be object or the `ptr` address.  
             * @example
             * DllCall("GetWindowRect", "Ptr", WinExist("A"), "ptr", rc := GuiExt.RECT())
             * MsgBox rc.left " " rc.top " " rc.right " " rc.bottom
             * 
             * @example
             * rc := GuiExt.RECT({top: 10, bottom: 69})
             * MsgBox "L" rc.left "/ T" rc.top "/ R" rc.right "/ B" rc.bottom ; L0/ T10/ R0/ B69
             * 
             * @example
             * myGui.OnMessage(WM_NCCALCSIZE := 0x0083, NCCALCSIZE)
             * NCCALCSIZE(guiObj, wParam, lParam, msg)
             * {
             *      if !wParam {
             *          rc := GuiExt.RECT(lParam)
             *          ToolTip "L" rc.left "/ T" rc.top "/ R" rc.right "/ B" rc.bottom
             *      }
             * }
             * 
             * @returns The Buffer object that defined the `RECT` structure.
             * @link [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect)
             */
            __New(objOrAddress?)
            {
                super.__New(16)
                (IsSet(objOrAddress) && IsNumber(objOrAddress) && (ptr := objOrAddress))
                (IsSet(objOrAddress) && IsObject(objOrAddress) && (objOrAddress := objOrAddress))
                for i, prop in ["left", "top", "right", "bottom"]
                    this.PropDesc(prop, 4 * (i - 1), "int", ptr?)
                this.Set(objOrAddress?)
            }

            /** @prop {integer} left Specifies the x-coordinate of the upper-left corner of the rectangle. */
            left := unset

            /** @prop {integer} top Specifies the y-coordinate of the upper-left corner of the rectangle. */
            top := unset

            /** @prop {integer} right Specifies the x-coordinate of the lower-right corner of the rectangle. */
            right := unset

            /** @prop {integer} bottom Specifies the y-coordinate of the lower-right corner of the rectangle. */
            bottom := unset

            /** @prop {integer} width Rect width. */
            width => (this.right - this.left)

            /** @prop {integer} width Rect width. */
            height => (this.bottom - this.top)
        }

        static __New()
        {
            GuiExt.Control.__New(p := this.Prototype, sp := super.Prototype)

            for _p in [sp, this.Control.Prototype, Gui.Control.Prototype]
                for prop in ["x", "y", "w", "h"]
                    _p.DefineProp(prop, { Get: p.__GetPos.Bind(, prop), Set: p.__SetPos.Bind(, prop) })
        }

        /**
         * Create a new Gui object.
         * @param Options AlwaysOnTop Border Caption Disabled -DPIScale LastFound
         * MaximizeBox MinimizeBox MinSize600x600 MaxSize800x800 Resize
         * OwnDialogs '+Owner' OtherGui.hwnd +Parent
         * SysMenu Theme ToolWindow
         * @param Title The window title. If omitted, it defaults to the current value of A_ScriptName.
         * @param EventObj OnEvent, OnNotify and OnCommand can be used to register methods of EventObj to be called when an event is raised
         * @returns {GuiExt|Gui}
         */
        __New(Options := '', Title := A_ScriptName, EventObj?) => super.__New(Options?, Title?, EventObj ?? this)

        /**
         * @prop {Integer} X X position
         * @prop {Integer} Y Y position
         * @prop {Integer} W Width
         * @prop {Integer} H Height
         */
        X := Y := W := H := 0

        /**
         * Create controls such as text, buttons or checkboxes, and return a GuiControl object.
         * @param {'ActiveX'|'Button'|'Checkbox'|'ComboBox'|'Custom'|'DateTime'|'DropDownList'|'Edit'|'GroupBox'|'Hotkey'|'Link'|'ListBox'|'ListView'|'MonthCal'|'Picture'|'Progress'|'Radio'|'Slider'|'StatusBar'|'Tab'|'Tab2'|'Tab3'|'Text'|'TreeView'|'UpDown'} ControlType
         * @param Options V:    Sets the control's Name.
         * Pos: xn yn wn hn rn Right Left Center Section
         *         VScroll HScroll -Tabstop -Wrap
         *         BackgroundColor Border Theme Disabled Hidden
         * @returns {GuiExt.Control|GuiExt.ActiveX|GuiExt.Button|GuiExt.Checkbox|GuiExt.ComboBox|GuiExt.Custom|GuiExt.DateTime|GuiExt.DropDownList|GuiExt.Edit|GuiExt.GroupBox|GuiExt.Hotkey|GuiExt.Link|GuiExt.ListBox|GuiExt.ListView|GuiExt.MonthCal|GuiExt.Picture|GuiExt.Progress|GuiExt.Radio|GuiExt.Slider|GuiExt.StatusBar|GuiExt.Tab|GuiExt.Tab2|GuiExt.Tab3|GuiExt.Text|GuiExt.TreeView|GuiExt.UpDown}
         */
        Add(ControlType, Options?, Text?) => super.Add(ControlType, Options?, Text?)

        __GetPos(prop) => (this.GetPos(&x, &y, &w, &h), %prop%)

        __SetPos(prop, value)
        {
            SetWinDelay(-1), SetControlDelay(-1)
            try %prop% := value
            try this.Move(x?, y?, w?, h?)
        }

        /**
         * To create a borderless window with customizable resizing behavior.
         * @param {Integer} [border=6] The width of the edge of the window where the window size can be adjusted. If this value is `0`, the window will not be resizable.
         * @param {(guiObj, x, y) => Integer} [DragWndFunc=""] A callback function used to check whether the window is currently in a drag state. If the function returns `true` and the left mouse button is held down on the `Gui` window, the effect is the same as holding down the left button on the window title bar.
         * @param {number} [cxLeftWidth] The width of the left border that retains its size.
         * @param {number} [cxRightWidth] The width of the right border that retains its size.
         * @param {number} [cyTopHeight] The height of the top border that retains its size.
         * @param {number} [cyBottomHeight] The height of the bottom border that retains its size.
         */
        SetBorderless(border := 6, dragWndFunc := "", cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
        {
            static WM_NCCALCSIZE := 0x83
            static WM_NCHITTEST := 0x84
            static WM_NCACTIVATE := 0x86
            static WM_ACTIVATE := 0x6

            this.SetWindowAttribute(3, 1)

            ; Set Rounded Corner for Windows 11
            if (VerCompare(A_OSVersion, "10.0.22000") >= 0)
                this.SetWindowAttribute(33, 2)

            this.OnMessage(WM_ACTIVATE, CB_ACTIVATE)
            this.OnMessage(WM_NCACTIVATE, CB_NCACTIVATE)
            this.OnMessage(WM_NCCALCSIZE, CB_NCCALCSIZE)

            ; Make window resizable.
            this.OnMessage(WM_NCHITTEST, CB_NCHITTEST.Bind(dragWndFunc ? dragWndFunc.Bind(this) : 0))

            ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)

            CB_ACTIVATE(g, wParam, lParam, Msg)
            {
                SetWinDelay(-1), SetControlDelay(-1), WinRedraw(g)
                if (lParam = g.hwnd && (wParam & 0xFFFF))
                    ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
            }

            CB_NCCALCSIZE(g, wParam, lParam, Msg)
            {
                if wParam
                    return 0
            }

            CB_NCACTIVATE(g, wParam, lParam, *)
            {
                if !wParam
                    return true
                if (lParam != g.hwnd) && GetKeyState("LButton", "P")
                    return false
                SetWinDelay(-1)
                WinRedraw(g)
            }

            /**
             * @param {Function} HTFunc 
             * @param {GuiExt} g 
             * @param {integer} wParam 
             * @param {integer} lParam 
             * @param {integer} Msg 
             * @returns {Integer | unset} 
             */
            CB_NCHITTEST(HTFunc?, g?, wParam?, lParam?, Msg?)
            {
                static HTLEFT := 10, HTRIGHT := 11
                    , HTTOP := 12, HTTOPLEFT := 13
                    , HTTOPRIGHT := 14, HTBOTTOM := 15
                    , HTBOTTOMLEFT := 16, HTBOTTOMRIGHT := 17
                    , TCAPTION := 2

                if !(g is Gui)
                    return

                CoordMode("Mouse")
                MouseGetPos(&x, &y)

                rc := g.GetWindowRect()
                R := (x >= rc.right - border)
                L := (x < rc.left + border)

                if (B := (y >= rc.bottom - border))
                    return R ? HTBOTTOMRIGHT : L ? HTBOTTOMLEFT : HTBOTTOM

                if (T := (y < rc.top + border))
                    return R ? HTTOPRIGHT : L ? HTTOPLEFT : HTTOP

                return L ? HTLEFT : R ? HTRIGHT : (HTFunc && HTFunc(x, y) ? TCAPTION : (_ := unset))
            }

            ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
            {
                rc := this.GetWindowRect()
                NumPut('int', cxLeftWidth ?? rc.width, 'int', cxRightWidth ?? rc.width, 'int', cyTopHeight ?? rc.height, 'int', cyBottomHeight ?? rc.height, margin := Buffer(16))
                DllCall("Dwmapi\DwmExtendFrameIntoClientArea", "Ptr", this.hWnd, "Ptr", margin)
            }
        }

        /**
         * Retrieves the dimensions of the bounding rectangle of the specified window. The dimensions are given in screen coordinates that are relative to the upper-left corner of the screen.  
         * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect)
         * @returns {RECT} 
         */
        GetWindowRect() => (DllCall("GetWindowRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

        /**
         * Retrieves the coordinates of a window's client area. The client coordinates specify the upper-left and lower-right corners of the client area. Because client coordinates are relative to the upper-left corner of a window's client area, the coordinates of the upper-left corner are (0,0).  
         * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
         * @returns {RECT} 
         */
        GetClientRect() => (DllCall("GetClientRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

        /**
         * Sets the attributes of a window. Specifically, it can set the color of the window's caption, text, and border.
         * @param {integer} [titleText] Specifies the color of the caption text. Specifying `0xFFFFFFFF` will reset to the system's default caption text color.  
         * @param {integer} [titleBackground] Specifies the color of the caption. Specifying `0xFFFFFFFF` will reset to the system's default caption color.
         * @param {integer} [border] Specifies the color of the window border.
         * - Specifying `0xFFFFFFFE` will suppress the drawing of the window border. 
         * - Specifying `0xFFFFFFFF` will reset to the system's default border color.  
         * The application is responsible for changing the border color in response to state changes, such as window activation.
         * @since This is supported starting with Windows 11 Build 22000.
         * @returns {String} - The result of the attribute setting operation.
         */
        SetWindowColor(titleText?, titleBackground?, border?)
        {
            static DWMWA_BORDER_COLOR := 34
            static DWMWA_CAPTION_COLOR := 35
            static DWMWA_TEXT_COLOR := 36
            static SetClrMap := Map(DWMWA_BORDER_COLOR, "border", DWMWA_CAPTION_COLOR, "titleBackground", DWMWA_TEXT_COLOR, "titleText")

            if (VerCompare(A_OSVersion, "10.0.22200") < 0)
                throw OSError("This is supported starting with Windows 11 Build 22000.")

            for attr, var in SetClrMap
                if (%var% ?? 0)
                    this.SetWindowAttribute(attr, RgbToBgr(%var% is string && !InStr(%var%, "0x") ? Number("0x" %var%) : %var%))

            RgbToBgr(color) => (((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16))
        }

        /**
         * Calls the DwmSetWindowAttribute function from the dwmapi library to set attributes of a window.
         * @param {number} dwAttribute - The attribute constant to set.
         * @param {number} [pvAttribute] - The value of the attribute to set. Optional parameter.
         * @returns {number} The result of the DllCall, typically indicating success or failure.
         * @see [MSDN](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)
         */
        SetWindowAttribute(dwAttribute, pvAttribute?) => DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', this.Hwnd, "uint", dwAttribute, "uint*", pvAttribute, "int", 4)

        /**
         * Sets the dark mode title bar for the window if the operating system version supports it.
         * @returns {number|undefined} The result of setting the window attribute, or undefined if not applicable.
         */
        SetDarkTitle()
        {
            if (attr := ((VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : (VerCompare(A_OSVersion, "10.0.17763") >= 0) ? 19 : 0))
                return this.SetWindowAttribute(attr, true)
        }

        ; Apply dark theme to all the context menus that is created by this script.
        SetDarkMenu()
        {
            uxtheme := DllCall("GetModuleHandle", "ptr", StrPtr("uxtheme"), "ptr")
            SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
            FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
            DllCall(SetPreferredAppMode, "int", 1)
            DllCall(FlushMenuThemes)
        }

        /**
         * Send the message to the window or control, and then wait for confirmation.
         * @param {Integer} Msg
         * @param {Integer} [wParam=0]
         * @param {Integer} [lParam=0] 
         * @returns {Integer} 
         */
        SendMsg(Msg, wParam := 0, lParam := 0) {
            return SendMessage(Msg, wParam?, lParam?, , this)
        }

        /**
         * Registers a function or method to be called whenever the Gui receives the specified message.
         * @param {Integer} Msg The number of the message to monitor, which should be between 0 and 4294967295 (0xFFFFFFFF).
         * @param {String|(GuiObj, wParam, lParam, Msg) => Integer} Callback The function, method or object to call when the event is raised.
         * If the GUI has an event sink (that is, if Gui()'s EventObj parameter was specified), this parameter may be the name of a method belonging to the event sink.
         * Otherwise, this parameter must be a function object. (**ahk_h 2.0**)The function may also consult the built-in variable `A_EventInfo`, which contains 0 if the message was sent via SendMessage.
         * If sent via PostMessage, it contains the tick-count time the message was posted.
         * @param {Integer} MaxThreads This integer is usually omitted. In this case, the monitoring function can only process one thread at a time. This is usually the best, because otherwise whenever the monitoring function is interrupted, the script will process the messages in chronological order. Therefore, as an alternative to MaxThreads, Critical can be considered, as shown below.
         * 
         * Specify 0 to unregister the function previously identified by Function.
         * 
         * By default, when multiple functions are registered for a MsgNumber, they will be called in the order of registration. To register a function before the previously registered function, specify a negative value for MaxThreads. For example, OnMessage Msg, Fn, -2 Register Fn to be called before any other functions registered for Msg, and allow Fn to have up to 2 threads. However, if the function has already been registered, the order will not change unless the registration is cancelled and then re-registered.
         */
        OnMessage(Msg, Callback, MaxThreads?)
        {
            OnMessage(Msg, _callback, MaxThreads?)
            super.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

            _callback(wParam, lParam, uMsg, hWnd) {
                try if (uMsg = Msg && hwnd = this.hwnd)
                    return Callback(this, wParam, lParam, uMsg)
            }
        }

        class Control extends Gui.Control
        {
            static __New(p := this.Prototype, sp?)
            {
                sp := sp ?? super.Prototype
                for prop in p.OwnProps()
                    if (!sp.HasMethod(prop) && !InStr(prop, "__"))
                        sp.DefineProp(prop, p.GetOwnPropDesc(prop))

                if sp.HasMethod("OnMessage")
                    p.DeleteProp("OnMessage")
            }

            /**
             * @property {Integer} X X position
             * @property {Integer} Y Y position
             * @property {Integer} W Width
             * @property {Integer} H Height
             */
            X := unset, Y := unset, W := unset, H := unset

            /**
             * Retrieves the dimensions of the bounding rectangle of the specified window. The dimensions are given in screen coordinates that are relative to the upper-left corner of the screen.  
             * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
             * @returns {RECT} 
             */
            GetWindowRect() => (DllCall("GetWindowRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

            /**
             * Retrieves the coordinates of a window's client area. The client coordinates specify the upper-left and lower-right corners of the client area. Because client coordinates are relative to the upper-left corner of a window's client area, the coordinates of the upper-left corner are (0,0).  
             * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
             * @returns {RECT} 
             */
            GetClientRect() => (DllCall("GetClientRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

            /**
             * Registers a function or method to be called whenever the GuiControl receives the specified message.
             * @param {Integer} Msg The number of the message to monitor, which should be between 0 and 4294967295 (0xFFFFFFFF).
             * @param {String|(GuiCtrlObj, wParam, lParam, Msg) => Integer} Callback The function, method or object to call when the event is raised.
             * If the GUI has an event sink (that is, if Gui()'s EventObj parameter was specified), this parameter may be the name of a method belonging to the event sink.
             * Otherwise, this parameter must be a function object. The function may also consult the built-in variable `A_EventInfo`, which contains 0 if the message was sent via SendMessage.
             * If sent via PostMessage, it contains the tick-count time the message was posted.
             * @param {Integer} AddRemove If omitted, it defaults to 1 (call the callback after any previously registered callbacks). Otherwise, specify one of the following numbers: 
             * - 1  = Call the callback after any previously registered callbacks.
             * - -1 = Call the callback before any previously registered callbacks.
             * - 0  = Do not call the callback.
             */
            OnMessage(Msg, Callback, AddRemove := 1)
            {
                static SubClasses := Map()
                static HookedMsgs := Map()

                if !SubClasses.Has(this.hwnd) {
                    SubClasses[this.hwnd] := CallbackCreate(SubClassProc, , 6)
                    HookedMsgs[this.hwnd] := Map(Msg, Callback.Bind(this))
                    SetWindowSubclass(this, SubClasses[this.hwnd])
                    OnExit(RemoveWindowSubclass)
                    this.Gui.OnEvent("Close", RemoveWindowSubclass)
                }

                hm := HookedMsgs[this.hwnd]

                if AddRemove
                    hm[Msg] := Callback.Bind(this)
                else if hm.Has(Msg)
                    hm.Delete(Msg)

                SubClassProc(hWnd?, uMsg?, wParam?, lParam?, uIdSubclass?, dwRefData?)
                {
                    if HookedMsgs.Has(uIdSubclass) && HookedMsgs[uIdSubclass].Has(uMsg) {
                        reply := HookedMsgs[uIdSubclass][uMsg](wParam?, lParam?, uMsg?)
                        if IsSet(reply)
                            return reply
                    }

                    return DefSubclassProc(hwnd, uMsg?, wParam?, lParam?)
                }

                DefSubclassProc(hwnd?, uMsg?, wParam?, lParam?) => DllCall("DefSubclassProc", "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")

                SetWindowSubclass(obj, cb) => DllCall("SetWindowSubclass", "Ptr", obj.hwnd, "Ptr", cb, "Ptr", obj.hwnd, "Ptr", 0)

                RemoveWindowSubclass(*)
                {
                    DetectHiddenWindows true

                    for hwnd, cb in SubClasses.Clone() {
                        try if WinExist(hwnd) {
                            DllCall("RemoveWindowSubclass", "Ptr", hWnd, "Ptr", cb, "Ptr", hWnd)
                            CallbackFree(cb)
                        }
                        SubClasses.Delete(hwnd)
                    }
                    OnExit(RemoveWindowSubclass, 0)
                }
            }

            /**
             * Applies a specified theme to the window through the SetWindowTheme function from the uxtheme library.
             * @param {string} pszSubAppName - The name of the application's subcomponent to apply the theme to.
             * @param {string} [pszSubIdList] - A semicolon-separated list of class names to apply the theme to. Optional parameter.
             * @returns {boolean} True if the theme was set successfully, false otherwise.
             * @link https://learn.microsoft.com/en-us/windows/win32/api/uxtheme/nf-uxtheme-setwindowtheme
             */
            SetTheme(pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", this.hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)

            /**
             * Set the control's border style to rounded corners.
             * @param {Integer} [corner=9] The radius of the rounded corners.
             * @returns {void}
             */
            SetRounded(corner := 9)
            {
                static WM_SIZE := 0x0005

                SIZING(this)
                this.OnMessage(WM_SIZE, SIZING)

                SIZING(ctrl, wParam?, lParam?, msg?)
                {
                    ; ctrl.Opt("+0x4000000")
                    rc := ctrl.GetClientRect()
                    rcRgn := DllCall('Gdi32\CreateRoundRectRgn', 'int', rc.left + 3, 'int', rc.top + 3, 'int', rc.right - 3, 'int', rc.bottom - 3, 'int', corner, 'int', corner, 'ptr')
                    DllCall("SetWindowRgn", "ptr", ctrl.hWnd, "ptr", rcRgn, "int", 1, "int")
                    ctrl.Redraw()
                    DllCall('Gdi32\DeleteObject', 'ptr', rcRgn, 'int')
                }
            }

            /**
             * Send the message to the window or control, and then wait for confirmation.
             * @param {Integer} Msg
             * @param {Integer} [wParam=0]
             * @param {Integer} [lParam=0] 
             * @returns {Integer} 
             */
            SendMsg(Msg, wParam := 0, lParam := 0) => (SendMessage(Msg, wParam?, lParam?, this))
        }

        ;;{ Gui.Addxxx methods:

        /**
         * Create a text control that the user cannot edit. Often used to label other controls.
         * @param Options V:    Sets the control's Name.
         *   Pos:  xn yn wn hn rn  Right Left Center Section
         *         VScroll  HScroll -Tabstop -Wrap
         *         BackgroundColor  BackgroundTrans
         *         Border  Theme  Disabled  Hidden
         * @param Text The text  
         * @returns {GuiExt.Control|GuiExt.Text}
         */
        AddText(Options?, Text?) => super.AddText(Options?, Text?)

        /**
         * Create controls such as text, buttons or checkboxes, and return a GuiControl object.
         * @param Options Limit Lowercase Multi Number Password ReadOnly
         *        Tn Uppercase WantCtrlA WantReturn WantTab
         *  V:    Sets the control's Name.
         *  Pos:  xn yn wn hn rn Right Left Center Section
         *        VScroll HScroll -Tabstop -Wrap
         *        BackgroundColor Border Theme Disabled Hidden
         * @param Text The text in the Edit  
         * @returns {GuiExt.Control|GuiExt.Edit|Gui.Edit}
         */
        AddEdit(Options?, Text?) => super.AddEdit(Options?, Text?)

        /**
         * Create UpDown control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.UpDown|Gui.UpDown}
         */
        AddUpDown(Options?, Text?) => super.AddUpDown(Options?, Text?)

        /**
         * Create Picture control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Picture|Gui.Picture}
         */
        AddPicture(Options?, FileName?) => super.AddPicture(Options?, FileName?)

        /**
         * Create Picture control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Picture|Gui.Picture}
         */
        AddPic(Options?, FileName?) => super.AddPicture(Options?, FileName?)

        /**
         * Adds a Button control and returns a GuiControl object.
         * @param Options Positioning and Sizing of Controls
         *   V:  Sets the control's Name.
         *   Positioning:  xn yn wn hn rn Right Left Center Section -Tabstop -Wrap
         *   BackgroundColor Border Theme Disabled Hidden
         * @param Text The text of the button  
         * @returns {GuiEx.Control}
         */
        AddButton(Options?, Text?) => super.AddButton(Options?, Text?)

        /**
         * Create Checkbox and return a GuiControl object.
         * GuiCtrl.Value returns the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate.
         * @param Options  V:           Sets the control's Name.
         *  Checked:     Start off checked
         *  Check3:      Enable a third "indeterminate" state that displays a gray checkmark
         *  CheckedGray: Start off checked or indeterminate
         *  CheckedN:    Set state: 0, 1 or -1
         *  Pos:         xn yn wn Right Left Center Section
         *               VScroll  HScroll -Tabstop -Wrap
         *               BackgroundColor  BackgroundTrans
         *               Border  Theme  Disabled  Hidden
         * @param Text The text of the Checkbox  
         * @returns {GuiExt.Control|GuiExt.Checkbox|Gui.Checkbox}
         */
        AddCheckbox(Options?, Text?) => super.AddCheckbox(Options?, Text?)

        /**
         * Create Radio control and return a GuiControl object.
         * GuiCtrl.Value returns the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate.
         * Events:       DoubleClick, Focus & LoseFocus
         * @param Options  V:           Sets the control's Name.
         *  Checked:     Start off checked
         *  CheckedN:    Set state: 0 or 1
         *  Group:       Start a new group
         *  Pos:         xn yn wn Right Left Center Section
         *               VScroll  HScroll -Tabstop -Wrap
         *               BackgroundColor  BackgroundTrans
         *               Border  Theme  Disabled  Hidden
         * @param Text The text of the Checkbox  
         * @returns {GuiExt.Control|GuiExt.Radio|Gui.Radio}
         */
        AddRadio(Options?, Text?) => super.AddRadio(Options?, Text?)

        /**
         * Create DropDownList control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.DropDownList|Gui.DropDownList}
         */
        AddDropDownList(Options?, Items?) => super.AddDropDownList(Options?, Items?)

        /**
         * Create DropDownList control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.DropDownList|Gui.DropDownList}
         */
        AddDDL(Options?, Items?) => super.AddDropDownList(Options?, Items?)


        /**
         * Create ComboBox control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.ComboBox|Gui.ComboBox}
         */
        AddComboBox(Options?, Items?) => super.AddComboBox(Options?, Items?)

        /**
         * Create ListBox control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.ListBox|Gui.ListBox}
         */
        AddListBox(Options?, Items?) => super.AddListBox(Options?, Items?)

        /**
         * Create ListView control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.ListView|Gui.ListView}
         */
        AddListView(Options?, Titles?) => super.AddListView(Options?, Titles?)

        /**
         * Create TreeView control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.TreeView|Gui.TreeView}
         */
        AddTreeView(Options?, Text?) => super.AddTreeView(Options?, Text?)

        /**
         * Create Link control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Link|Gui.Link}
         */
        AddLink(Options?, Text?) => super.AddLink(Options?, Text?)

        /**
         * Create Hotkey control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Hotkey|Gui.Hotkey}
         */
        AddHotkey(Options?, Text?) => super.AddHotkey(Options?, Text?)

        /**
         * Create DateTime control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.DateTime|Gui.DateTime}
         */
        AddDateTime(Options?, DateTime?) => super.AddDateTime(Options?, DateTime?)

        /**
         * Create MonthCal control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.MonthCal|Gui.MonthCal}
         */
        AddMonthCal(Options?, YYYYMMDD?) => super.AddMonthCal(Options?, YYYYMMDD?)

        /**
         * Create Slider control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Slider|Gui.Slider}
         */
        AddSlider(Options?, Value?) => super.AddSlider(Options?, Value?)

        /**
         * Create Progress control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Progress|Gui.Progress}
         */
        AddProgress(Options?, Value?) => super.AddProgress(Options?, Value?)

        /**
         * Create GroupBox control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.GroupBox|Gui.GroupBox}
         */
        AddGroupBox(Options?, Text?) => super.AddGroupBox(Options?, Text?)

        /**
         * Create Tab control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Tab|Gui.Tab}
         */
        AddTab(Options?, Pages?) => super.AddTab(Options?, Pages?)

        /**
         * Create Tab2 control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Tab2|Gui.Tab2}
         */
        AddTab2(Options?, Pages?) => super.AddTab2(Options?, Pages?)

        /**
         * Create Tab3 control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Tab3|Gui.Tab3}
         */
        AddTab3(Options?, Pages?) => super.AddTab3(Options?, Pages?)

        /**
         * Create StatusBar control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.StatusBar|Gui.StatusBar}
         */
        AddStatusBar(Options?, Text?) => super.AddStatusBar(Options?, Text?)

        /**
         * Create ActiveX control and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.ActiveX|Gui.ActiveX}
         */
        AddActiveX(Options?, Component?) => super.AddActiveX(Options?, Component?)

        /**
         * Create Custom controls and return a GuiControl object.
         * @returns {GuiExt.Control|GuiExt.Custom|Gui.Custom}
         */
        AddCustom(Win32Class?, Text?) => super.AddCustom(Win32Class?, Text?)

        ;;}
    }


    /*
    Example_SetBorderless()
    {
        myGui := GuiExt("-Caption +Resize")
        myGui.SetFont("cWhite s16", "Segoe UI")
        myGui.SetDarkTitle()
        myGui.SetDarkMenu()
    
        myGui.BackColor := 0x202020
        text            := myGui.AddText("vTitlebar Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Titlebar Area")
    
        text.Base := GuiExt.Control
    
        text.SetRounded()
    
        myGui.OnEvent('Size', Size)
    
        ;Set Mica (Alt) background. (Supported starting with Windows 11 Build 22000.)
        if (VerCompare(A_OSVersion, "10.0.22600") >= 0)
            myGui.SetWindowAttribute(38, 4)
    
        myGui.SetBorderless(6, (g, x, y) => (y <= g['Titlebar'].GetWindowRect().bottom), 500, 500, 500, 500)
    
        myGui.Show("h500")
    
        Size(g, minmax, width, height)
        {
            SetControlDelay(-1)
            ; Set titlebar's width to fix the gui.
            g["Titlebar"].W := (width - (g.MarginX*2))
        }
    }*/
    ; Credits:
    ; just me - POC - Scrollable GUI (2024-07-26)
    ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=112708

    ; Changes (by Agzes):
    ; Added a function to dark style ScroolBar.
    ; Added a function to show and hide ScrollBar.
    ; Added a function to add fixed elements to the GUI.


    WS_VSCROLL := 0x200000
    WM_VSCROLL := 0x0115

    SCROLL_NOT_DARK := true

    SB_LINEUP := 0
    SB_LINEDOWN := 1

    global fixedElements := []

    AddFixedElement(control) {
        fixedElements.Push({
            control: control,
            x: control.X,
            y: control.Y,
            w: control.W,
            h: control.H,
            originalPos: { x: control.X, y: control.Y }
        })
    }

    UpdateFixedElements() {
        for index, element in fixedElements {
            element.control.Move(
                element.originalPos.x,
                element.originalPos.y
            )
        }
    }

    RemoveScrollBar(GuiObj) {
        currentStyle := DllCall("GetWindowLongPtr", "Ptr", GuiObj.hWnd, "Int", -16, "Ptr")
        newStyle := currentStyle & ~WS_VSCROLL
        result := DllCall("SetWindowLongPtr", "Ptr", GuiObj.hWnd, "Int", -16, "Ptr", newStyle)
        result := DllCall("SetWindowPos", "Ptr", GuiObj.hWnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27)
        UpdateScrollBars(GuiObj)
    }

    ShowScrollBar(GuiObj) {
        currentStyle := DllCall("GetWindowLongPtr", "Ptr", GuiObj.hWnd, "Int", -16, "Ptr")
        newStyle := currentStyle | WS_VSCROLL
        result := DllCall("SetWindowLongPtr", "Ptr", GuiObj.hWnd, "Int", -16, "Ptr", newStyle)
        result := DllCall("SetWindowPos", "Ptr", GuiObj.hWnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27)
        UpdateScrollBars(GuiObj)
    }

    UpdateScrollBars(GuiObj, *) {
        WinGetClientPos(, , &GuiW, &GuiH, GuiObj.Hwnd)
        T := 2147483647
        B := -2147483648
        For CtrlHwnd In WinGetControlsHwnd(GuiObj.Hwnd) {
            ControlGetPos(&CX, &CY, &CW, &CH, CtrlHwnd)
            T := Min(CY, T)
            B := Max(CY + CH, B)
        }
        T -= 8
        B += 8
        ScrH := B - T

        SI := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 3, SI, 0)
        NumPut("Int", ScrH, "UInt", GuiH, SI, 12)
        DllCall("SetScrollInfo", "Ptr", GuiObj.Hwnd, "Int", 1, "Ptr", SI, "Int", 1)

        Y := (T < 0) && (B < GuiH) ? Min(Abs(T), GuiH - B) : 0
        If (Y)
            DllCall("ScrollWindow", "Ptr", GuiObj.Hwnd, "Int", 0, "Int", Y, "Ptr", 0, "Ptr", 0)
        global SCROLL_NOT_DARK
        If SCROLL_NOT_DARK {
            DllCall("uxtheme\SetWindowTheme", "Ptr", GuiObj.hWnd, "Str", "DarkMode_Explorer", "Ptr", 0)
            SCROLL_NOT_DARK := false
        }
    }

    OnWheel(W, L, M, H) {
        If !(HWND := WinExist()) || GuiCtrlFromHwnd(H)
            Return
        HT := DllCall("SendMessage", "Ptr", HWND, "UInt", 0x0084, "Ptr", 0, "Ptr", L)
        If (HT = 7) {
            SB := 1
            SM := 0x0115
            OnScroll(SB, 0, SM, HWND)
            Return 0
        }
        UpdateFixedElements()
    }

    OnScroll(WP, LP, M, H) {
        Static SCROLL_STEP := 10
        Bar := (M = 0x0115)
        If !Bar
            Return
        SI := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 0x17, SI)
        If !DllCall("GetScrollInfo", "Ptr", H, "Int", Bar, "Ptr", SI)
            Return
        RC := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", H, "Ptr", RC)
        NewPos := NumGet(SI, 20, "Int")
        MinPos := NumGet(SI, 8, "Int")
        MaxPos := NumGet(SI, 12, "Int")
        Switch (WP & 0xFFFF) {
            Case 0: NewPos -= SCROLL_STEP
            Case 1: NewPos += SCROLL_STEP
            Case 2: NewPos -= NumGet(RC, 12, "Int") - SCROLL_STEP
            Case 3: NewPos += NumGet(RC, 12, "Int") - SCROLL_STEP
            Case 4, 5: NewPos := WP >> 16
            Case 6: NewPos := MinPos
            Case 7: NewPos := MaxPos
            Default: Return
        }
        MaxPos -= NumGet(SI, 16, "Int")
        NewPos := Min(NewPos, MaxPos)
        NewPos := Max(MinPos, NewPos)
        OldPos := NumGet(SI, 20, "Int")
        Y := OldPos - NewPos
        If (Y) {
            DllCall("ScrollWindow", "Ptr", H, "Int", 0, "Int", Y, "Ptr", 0, "Ptr", 0)
            NumPut("Int", NewPos, SI, 20)
            DllCall("SetScrollInfo", "Ptr", H, "Int", Bar, "Ptr", SI, "Int", 1)
            UpdateFixedElements()
        }
    }
    ; Credits:
    ; Nikola Perovic - https://github.com/nperovic
    ; https://gist.github.com/nperovic/0b9a511eda773f9304813a6ad9eec137

    /************************************************************************
     * @description Apply dark theme to the built-in MsgBox and InputBox.
     * @file Dark_MsgBox_v2.ahk
     * @link https://gist.github.com/nperovic/0b9a511eda773f9304813a6ad9eec137
     * @author Nikola Perovic
     * @date 2024/04/22
     * @version 1.1.0
     ***********************************************************************/
    #Requires AutoHotkey v2
    #DllLoad gdi32.dll
    /*
    ; for v2.1.alpha.9 or later
    class POINT {
        x: i32, y: i32
    }
    class RECT  {
        left: i32, top: i32, right: i32, bottom: i32
    }
    */

    ; for v2.0 or later
    POINT(x := 0, y := 0) {
        NumPut("int", x, "int", y, buf := Buffer(8))
        buf.DefineProp("x", { Get: NumGet.Bind(, 0, "int"), Set: IntPut.Bind(0) })
        buf.DefineProp("y", { Get: NumGet.Bind(, 4, "int"), Set: IntPut.Bind(4) })
        return buf
    }

    RECT(left := 0, top := 0, right := 0, bottom := 0) {
        static ofst := Map("left", 0, "top", 4, "right", 8, "bottom", 12)
        NumPut("int", left, "int", top, "int", right, "int", bottom, buf := Buffer(16))
        for k, v in ofst
            buf.DefineProp(k, { Get: NumGet.Bind(, v, "int"), Set: IntPut.Bind(v) })
        return buf
    }

    IntPut(ofst, _, v) => NumPut("int", v, _, ofst)

    class __MsgBox
    {
        static __New()
        {
            /** Thanks to geekdude & Mr Doge for providing this method to rewrite built-in functions. */
            static nativeMsgbox := MsgBox.Call.Bind(MsgBox)
            static nativeInputBox := InputBox.Call.Bind(InputBox)

            MsgBox.DefineProp("Call", { Call: BoxEx })
            InputBox.DefineProp("Call", { Call: BoxEx })
            BoxEx(_this, params*)
            {
                static WM_COMMNOTIFY := 0x44
                static WM_INITDIALOG := 0x0110

                iconNumber := 1
                iconFile := ""

                if (params.length = (_this.MaxParams + 2))
                    iconNumber := params.Pop()

                if (params.length = (_this.MaxParams + 1))
                    iconFile := params.Pop()

                SetThreadDpiAwarenessContext(-4)
                if (_this.Name = "MsgBox")
                    OnMessage(WM_COMMNOTIFY, ON_WM_COMMNOTIFY, -1)
                else
                    OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, -1)
                return native%_this.Name%(params*)
                ON_WM_INITDIALOG(wParam, lParam, msg, hwnd)
                {
                    OnMessage(WM_INITDIALOG, ON_WM_INITDIALOG, 0)
                    WNDENUMPROC(hwnd)
                }

                ON_WM_COMMNOTIFY(wParam, lParam, msg, hwnd)
                {
                    DetectHiddenWindows(true)
                    if (msg = 68 && wParam = 1027)
                        OnMessage(0x44, ON_WM_COMMNOTIFY, 0),
                            EnumThreadWindows(GetCurrentThreadId(), CallbackCreate(WNDENUMPROC), 0)
                }
                WNDENUMPROC(hwnd, *)
                {
                    static SM_CICON := "W" SysGet(11) " H" SysGet(12)
                    static SM_CSMICON := "W" SysGet(49) " H" SysGet(50)
                    static ICON_BIG := 1
                    static ICON_SMALL := 0
                    static WM_SETICON := 0x80
                    static WS_CLIPCHILDREN := 0x02000000
                    static WS_CLIPSIBLINGS := 0x04000000
                    static WS_EX_COMPOSITED := 0x02000000
                    static WS_VSCROLL := 0x00200000
                    static winAttrMap := Map(2, 2, 4, 0, 10, true, 17, true, 20, true, 38, 2, 35, 0x2b2b2b) ; 34, 0xFFFFFFFE,
                    Critical()
                    SetWinDelay(-1)
                    SetControlDelay(-1)
                    DetectHiddenWindows(true)
                    if !WinExist("ahk_class #32770 ahk_id" hwnd)
                        return 1
                    WinSetStyle("+" (WS_CLIPCHILDREN | WS_CLIPSIBLINGS))
                    WinSetExStyle("+" (WS_EX_COMPOSITED))
                    SetWindowTheme(hwnd, "DarkMode_Explorer")
                    if iconFile {
                        hICON_SMALL := LoadPicture(iconFile, SM_CSMICON " Icon" iconNumber, &handleType)
                        hICON_BIG := LoadPicture(iconFile, SM_CICON " Icon" iconNumber, &handleType)
                        PostMessage(WM_SETICON, ICON_SMALL, hICON_SMALL)
                        PostMessage(WM_SETICON, ICON_BIG, hICON_BIG)
                    }
                    for dwAttribute, pvAttribute in winAttrMap
                        DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute)

                    GWL_WNDPROC(hwnd, hICON_SMALL?, hICON_BIG?)
                    return 0
                }

                GWL_WNDPROC(winId := "", hIcons*)
                {
                    static SetWindowLong := DllCall.Bind(A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong", "ptr", , "int", , "ptr", , "ptr")
                    static BS_FLAT := 0x8000
                    static BS_BITMAP := 0x0080
                    static DPI := (A_ScreenDPI / 96)
                    static WM_CLOSE := 0x0010
                    static WM_CTLCOLORBTN := 0x0135
                    static WM_CTLCOLORDLG := 0x0136
                    static WM_CTLCOLOREDIT := 0x0133
                    static WM_CTLCOLORSTATIC := 0x0138
                    static WM_DESTROY := 0x0002
                    static WM_SETREDRAW := 0x000B
                    DetectHiddenWindows(true)
                    SetControlDelay(-1)

                    btns := []
                    btnHwnd := hbrush1 := hbrush2 := ""
                    for ctrl in WinGetControlsHwnd(winId)
                    {
                        classNN := ControlGetClassNN(ctrl)
                        SetWindowTheme(ctrl, !InStr(classNN, "Edit") ? "DarkMode_Explorer" : "DarkMode_CFD")
                        if !InStr(classNN, "B")
                            continue

                        ControlSetStyle("+" (BS_FLAT | BS_BITMAP), ctrl)
                        btns.Push(btnHwnd := ctrl)
                    }

                    WindowProcOld := SetWindowLong(winId, -4, CallbackCreate(WNDPROC))

                    WNDPROC(hwnd, uMsg, wParam, lParam)
                    {
                        Critical(-1)
                        DetectHiddenWindows(true)
                        SetWinDelay(-1)
                        SetControlDelay(-1)

                        if !hbrush1
                            hbrush1 := CreateSolidBrush(0x202020)

                        if !hbrush2
                            hbrush2 := CreateSolidBrush(0x2b2b2b)

                        switch uMsg {
                            case WM_CTLCOLORSTATIC:
                            {
                                SelectObject(wParam, hbrush2)
                                SetBkMode(wParam, 0)
                                SetTextColor(wParam, 0xFFFFFF)
                                SetBkColor(wParam, 0x2b2b2b)

                                for _hwnd in btns
                                    PostMessage(WM_SETREDRAW, , , _hwnd)

                                GetWindowRect(winId, rcW := RECT())
                                GetClientRect(winId, rcC := RECT())
                                GetWindowRect(btnHwnd, rcBtn := RECT())
                                pt := POINT()
                                pt.y := rcW.bottom - rcBtn.bottom
                                ScreenToClient(winId, pt)
                                hdc := GetWindowDC(winId)
                                rcC.top := rcBtn.top + pt.y - 2
                                rcC.bottom *= 2
                                rcC.right *= 2

                                SetBkMode(hdc, 0)
                                FillRect(hdc, rcC, hbrush1)
                                ReleaseDC(winId, hdc)

                                for _hwnd in btns
                                    PostMessage(WM_SETREDRAW, 1, , _hwnd)

                                return hbrush2
                            }
                                case WM_CTLCOLORDLG, WM_CTLCOLOREDIT:
                                {
                                    SelectObject(wParam, hbrush2)
                                    SetBkMode(wParam, 0)
                                    SetTextColor(wParam, 0xFFFFFF)
                                    SetBkColor(wParam, 0x2b2b2b)
                                    return hbrush2
                                }
                                    case WM_CTLCOLORBTN:
                                    {
                                        SelectObject(wParam, hbrush1)
                                        SetBkMode(wParam, 0)
                                        SetTextColor(wParam, 0xFFFFFF)
                                        SetBkColor(wParam, 0x202020)
                                        return hbrush2
                                    }
                                        case WM_DESTROY:
                                        {
                                            for v in [hbrush1, hbrush2]
                                                (v && DeleteObject(v))

                                            for v in hIcons
                                                (v ?? 0) && DestroyIcon(v)
                                        } }

                        return CallWindowProc(WindowProcOld, hwnd, uMsg, wParam, lParam)
                    }
                }
            }
            CallWindowProc(lpPrevWndFunc, hWnd, uMsg, wParam, lParam) => DllCall("CallWindowProc", "Ptr", lpPrevWndFunc, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
            ClientToScreen(hWnd, lpPoint) => DllCall("User32\ClientToScreen", "ptr", hWnd, "ptr", lpPoint, "int")
            CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

            DestroyIcon(hIcon) => DllCall("DestroyIcon", "ptr", hIcon)
            /** @see — https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute */
            DWMSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute := 4) => DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", dwAttribute, "Ptr*", &pvAttribute, "UInt", cbAttribute)

            DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')

            EnumThreadWindows(dwThreadId, lpfn, lParam) => DllCall("User32\EnumThreadWindows", "uint", dwThreadId, "ptr", lpfn, "uptr", lParam, "int")

            FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

            GetClientRect(hWnd, lpRect) => DllCall("User32\GetClientRect", "ptr", hWnd, "ptr", lpRect, "int")

            GetCurrentThreadId() => DllCall("Kernel32\GetCurrentThreadId", "uint")

            GetWindowDC(hwnd) => DllCall("User32\GetWindowDC", "ptr", hwnd, "ptr")

            GetWindowRect(hWnd, lpRect) => DllCall("User32\GetWindowRect", "ptr", hWnd, "ptr", lpRect, "uptr")
            GetWindowRgn(hWnd, hRgn) => DllCall("User32\GetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int")
            GetWindowRgnBox(hWnd, hRgn) => DllCall("User32\GetWindowRgnBox", "ptr", hWnd, "ptr", hRgn, "int")
            ReleaseDC(hWnd, hDC) => DllCall("User32\ReleaseDC", "ptr", hWnd, "ptr", hDC, "int")

            ScreenToClient(hWnd, lpPoint) => DllCall("User32\ScreenToClient", "ptr", hWnd, "ptr", lpPoint, "int")
            SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')

            SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')

            SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')

            SetTextColor(hdc, crColor) => DllCall('Gdi32\SetTextColor', 'ptr', hdc, 'uint', crColor, 'uint')

            SetThreadDpiAwarenessContext(dpiContext) => DllCall("SetThreadDpiAwarenessContext", "ptr", dpiContext, "ptr")
            SetWindowTheme(hwnd, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)
        }
    }
    ; Credits:
    ; TheArkive - https://github.com/TheArkive
    ; https://github.com/TheArkive/JXON_ahk2

    ; d["g"] := 1, d["h"] := 2, d["i"] := ["purple","pink","pippy red"]
    ; e["g"] := 1, e["h"] := 2, e["i"] := Map("1","test1","2","test2","3","test3")
    ; f["g"] := 1, f["h"] := 2, f["i"] := [1,2,Map("a",1.0009,"b",2.0003,"c",3.0001)]

    ; a["test1"] := "test11", a["d"] := d
    ; b["test3"] := "test33", b["e"] := e
    ; c["test5"] := "test55", c["f"] := f

    ; myObj := Map()
    ; myObj["a"] := a, myObj["b"] := b, myObj["c"] := c, myObj["test7"] := "test77", myObj["test8"] := "test88"

    ; g := ["blue","green","red"], myObj["h"] := g ; add linear array for testing

    ; q := Chr(34)
    ; textData2 := Jxon_dump(myObj,4) ; ===> convert array to JSON
    ; msgbox "JSON output text:`r`n===========================================`r`n(Should match second output.)`r`n`r`n" textData2

    ; newObj := Jxon_load(&textData2) ; ===> convert json back to array

    ; textData3 := Jxon_dump(newObj,4) ; ===> break down array into 2D layout again, should be identical
    ; msgbox "Second output text:`r`n===========================================`r`n(should be identical to first output)`r`n`r`n" textData3

    ; msgbox "textData2 = textData3:  " ((textData2=textData3) ? "true" : "false")

    ; ===========================================================================================
    ; End Example ; =============================================================================
    ; ===========================================================================================

    ; originally posted by user coco on AutoHotkey.com
    ; https://github.com/cocobelgica/AutoHotkey-JSON

    Jxon_Load(&src, args*) {
        key := "", is_key := false
        stack := [tree := []]
        next := '"{[01234567890-tfn'
        pos := 0

        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")

                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                    : (next == "\") ? "Invalid \escape"
                    : (next == ":") ? "Expecting ':' delimiter"
                    : (next == '"') ? "Expecting object key enclosed in double quotes"
                    : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                    : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                    : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                    : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                        , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                    , ln, col, pos)

                throw Error(msg, -1, ch)
            }

            obj := stack[1]
            is_array := (obj is Array)

            if i := InStr("{[", ch) { ; start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2

                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)

                next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else { ; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue

                    pos := i ; update pos

                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")

                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2

                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }

                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }

                    pos += i - 1
                }

                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }

        return tree[1]
    }

    Jxon_Dump(obj, indent := "", lvl := 1) {
        if IsObject(obj) {
            If !(obj is Array || obj is Map || obj is String || obj is Number)
                throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

            if IsInteger(indent)
            {
                if (indent < 0)
                    throw Error("Indent parameter must be a postive integer.", -1, indent)
                spaces := indent, indent := ""

                Loop spaces ; ===> changed
                    indent .= " "
            }
            indt := ""

            Loop indent ? lvl : 0
                indt .= indent

            is_array := (obj is Array)

            lvl += 1, out := "" ; Make #Warn happy
            for k, v in obj {
                if IsObject(k) || (k == "")
                    throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

                if !is_array ;// key ; ObjGetCapacity([k], 1)
                    out .= (ObjGetCapacity([k]) ? Jxon_Dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

                out .= Jxon_Dump(v, indent, lvl) ; value
                    . (indent ? ",`n" . indt : ",") ; token + indent
            }

            if (out != "") {
                out := Trim(out, ",`n" . indent)
                if (indent != "")
                    out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
            }

            return is_array ? "[" . out . "]" : "{" . out . "}"

        } Else If (obj is Number)
            return obj
        Else ; String
            return escape_str(obj)

        escape_str(obj) {
            obj := StrReplace(obj, "\", "\\")
            obj := StrReplace(obj, "`t", "\t")
            obj := StrReplace(obj, "`r", "\r")
            obj := StrReplace(obj, "`n", "\n")
            obj := StrReplace(obj, "`b", "\b")
            obj := StrReplace(obj, "`f", "\f")
            obj := StrReplace(obj, "/", "\/")
            obj := StrReplace(obj, '"', '\"')

            return '"' obj '"'
        }
    }
}
; AFR v.2.2 LIBS PART (Не изменяйте для корректной работы конфига)

; <--------------->
;       CODE
; <--------------->

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
    AFR_Version := "2.2b"
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
        global S2500 := LoadConfig("S2500", 2500)
        global S3000 := LoadConfig("S3000", 3000)
        global S5000 := LoadConfig("S5000", 4000)
    }
    Init() {
        InitBeforeCFGInit()
        global Role := LoadConfig("Role", "")
        global Gender := LoadConfig("Gender", 1)
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

            if (WBind != "None") {
                try {
                    SetHotKey(G_Binds[WBind][1], CreateWindowFunction(WName))
                } catch {
                    MsgBox("Кажется произошла ошибка :( `n Не удалось назначить бинд для открытия окна: " WName)
                }
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
            } catch {
                LogSent("Note | Бинд: " i " не имеет действие ")
            }
        }
    }
    lastRandom := 0
    RandomNew(min, max) {
        global lastRandom := Random(min, max)
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
            local value := RegRead(ConfigPath, configName)
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
    UpdateBindsInConfigurator(Element?, *) {
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
        MsgBox "Авто-проверка обновлений`n`nАвтоматически проверяет обновления`n`nПо умолчанию -> ВКЛ"
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
            RegWrite(SSP_P1_GENDER.Value, "REG_SZ", ConfigPath, "Gender")
            ; MsgBox("Данные успешно сохранены!`nПерезапустите для применения")
            SaveSettingsForDATA(Element, true)

        } catch Error as e {
            MsgBox("Ошибка при сохранении!")
        }
    }
    DropDownListWorker(Element, *) {
        SSP_P2_UIMETHOD_BG.Text := "  ᐁ I " UiMethodList[Element.Value]
        CreateImageButton(SSP_P2_UIMETHOD_BG, 0, ButtonStyles["fake_for_hotkey"]*)
        SaveSettingsForDATA(Element, false)
    }
    GenderDropDownListWorker(Element, *) {
        GenderList := ["Мужской", "Женский"]
        SSP_P1_GENDER_BG.Text := "  ᐁ I " GenderList[Element.Value]
        CreateImageButton(SSP_P1_GENDER_BG, 0, ButtonStyles["fake_for_hotkey"]*)
        global Gender := Element.Value
        SaveSettingsForDATA(Element, false)
    }
    SaveSettingsForDATA(Element, showMsgBox := true) {
        try {
            RegWrite(SSP_P2_UIMETHOD.Value, "REG_SZ", ConfigPath, "focus_method")
            RegWrite(SSP_P2_ESCNEED.Value, "REG_SZ", ConfigPath, "before_esc")
            RegWrite(SSP_P2_CHECKNEED.Value, "REG_SZ", ConfigPath, "before_check")
            RegWrite(SSP_P2_LIMIT.Value, "REG_SZ", ConfigPath, "before_limit")
            RegWrite(SSP_P2_STATUS.Value, "REG_SZ", ConfigPath, "show_status")
            RegWrite(SSP_P1_GENDER.Value, "REG_SZ", ConfigPath, "Gender")
            RegWrite(SSP_P2_UPDATE.Value, "REG_SZ", ConfigPath, "update_check")
            if (showMsgBox)
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
    S2500_Warning(Element, *) {
        MsgBox("Используется в: Средних отыгровок`nПо умолчанию -> 2500")
    }
    S3000_Warning(Element, *) {
        MsgBox("Используется в: Больших отыгровок`nПо умолчанию -> 3000")
    }
    S5000_Warning(Element, *) {
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
        global S100, S250, S300, S700, S1000, S2500, S3000, S5000

        S300 := Round(300 * multiplier)
        S500 := Round(500 * multiplier)
        S700 := Round(700 * multiplier)
        S800 := Round(800 * multiplier)
        S1000 := Round(1000 * multiplier)
        S2500 := Round(2500 * multiplier)
        S3000 := Round(3000 * multiplier)
        S5000 := Round(4000 * multiplier)

        S300_Input.Text := S300
        S500_Input.Text := S500
        S700_Input.Text := S700
        S800_Input.Text := S800
        S1000_Input.Text := S1000
        S2500_Input.Text := S2500
        S3000_Input.Text := S3000
        S5000_Input.Text := S5000

    }
    SaveTimeSettings(Element, *) {
        global S100, S250, S300, S500, S700, S800, S1000, S2500, S3000, S5000

        S100 := S100_Input.Text
        S250 := S250_Input.Text
        S300 := S300_Input.Text
        S500 := S500_Input.Text
        S700 := S700_Input.Text
        S800 := S800_Input.Text
        S1000 := S1000_Input.Text
        S2500 := S2500_Input.Text
        S3000 := S3000_Input.Text
        S5000 := S5000_Input.Text

        LogSent("[SaveTimeSettings] -> Попытка сохранения")
        try {
            RegWrite(S100, "REG_SZ", ConfigPath, "S100")
            RegWrite(S250, "REG_SZ", ConfigPath, "S250")
            RegWrite(S300, "REG_SZ", ConfigPath, "S300")
            RegWrite(S500, "REG_SZ", ConfigPath, "S500")
            RegWrite(S700, "REG_SZ", ConfigPath, "S700")
            RegWrite(S800, "REG_SZ", ConfigPath, "S800")
            RegWrite(S1000, "REG_SZ", ConfigPath, "S1000")
            RegWrite(S2500, "REG_SZ", ConfigPath, "S2500")
            RegWrite(S3000, "REG_SZ", ConfigPath, "S3000")
            RegWrite(S5000, "REG_SZ", ConfigPath, "S5000")
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
        RpSetUI.Show("w260")
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
    SMP_GREETINGS := SettingsUI.AddText("x194 y44 w438 h30 +Center", "Привет, " Name "!")
    SettingsUI.SetFont("cGray s" 8, Font)
    SMP_VERSION := SettingsUI.AddText("x194 y325 w438 +Center", "AHK-FOR-RPM: v" AFR_Version ' I ' "RP: v" AHK_version)
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
    SSP_P1_NAME_LABEL := SettingsUI.AddText("Hidden x203 y50", Chr(0xE136) " РП Имя Фамилия ↴")
    SSP_P1_NAME_BG := SettingsUI.AddButton("Hidden x203 y70 Disabled w203 h25", "")
    CreateImageButton(SSP_P1_NAME_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P1_NAME := SettingsUI.AddEdit("Hidden x203 y70 w203", Name)
    SSP_P1_NAME.SetRounded(3)
    SSP_P1_ROLE_LABEL := SettingsUI.AddText("Hidden x203 y97", Chr(0xE181) " Должность ↴")
    SSP_P1_ROLE_BG := SettingsUI.AddButton("Hidden x203 y117 Disabled w203 h25", "")
    CreateImageButton(SSP_P1_ROLE_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P1_ROLE := SettingsUI.AddEdit("Hidden x203 y117 w203", Role)
    SSP_P1_ROLE.SetRounded(3)
    global GenderList := ["Мужской", "Женский"]
    SSP_P1_GENDER_LABEL := SettingsUI.AddText("Hidden x203 y144", Chr(0xE13D) " Пол ↴")
    SSP_P1_GENDER_BG := SettingsUI.AddButton("Hidden x203 y164 Disabled w203 h25 Left", "  ᐁ I " GenderList[Gender])
    CreateImageButton(SSP_P1_GENDER_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P1_GENDER := SettingsUI.AddDropDownList("Hidden x203 y164 w203 +0x4000000", GenderList)
    SSP_P1_GENDER.OnEvent("Change", GenderDropDownListWorker)
    SSP_P1_GENDER.Text := GenderList[Gender]
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
    SSP_P2_ESCNEED := SettingsUI.AddCheckBox("Hidden x420 y117 h" SGH " w" SGW)
    SSP_P2_ESCNEED_TEXT := SettingsUI.AddText("Hidden x434 y115 0x200 h" SGH, " Нажимать ESC")
    SSP_P2_ESCNEED_HELP := SettingsUI.AddButton("Hidden x600 y117 h17 w17", "?")
    SSP_P2_ESCNEED_HELP.OnEvent("Click", ShowInformationESC)
    CreateImageButton(SSP_P2_ESCNEED_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P2_ESCNEED.OnEvent("Click", (ctrl, *) => SaveSettingsForDATA(ctrl, false))
    SSP_P2_ESCNEED.Value := BeforeEsc
    SGW2 := SysGet(SM_CXMENUCHECK := 71)
    SGH2 := SysGet(SM_CYMENUCHECK := 72)
    SSP_P2_CHECKNEED := SettingsUI.AddCheckBox("Hidden x420 y137 h" SGH2 " w" SGW2)
    SSP_P2_CHECKNEED_TEXT := SettingsUI.AddText("Hidden x434 y135 0x200 h" SGH2, " Проверять открытую игру")
    SSP_P2_CHECKNEED_HELP := SettingsUI.AddButton("Hidden x600 y137 h17 w17", "?")
    SSP_P2_CHECKNEED_HELP.OnEvent("Click", ShowInformationCHECK)
    CreateImageButton(SSP_P2_CHECKNEED_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P2_CHECKNEED.OnEvent("Click", (ctrl, *) => SaveSettingsForDATA(ctrl, false))
    SSP_P2_CHECKNEED.Value := BeforeCheck
    SGW3 := SysGet(SM_CXMENUCHECK := 71)
    SGH3 := SysGet(SM_CYMENUCHECK := 72)
    SSP_P2_LIMIT := SettingsUI.AddCheckBox("Hidden x420 y157 h" SGH3 " w" SGW3)
    SSP_P2_LIMIT_TEXT := SettingsUI.AddText("Hidden x434 y155 0x200 h" SGH3, " Ограничить hotkey")
    SSP_P2_LIMIT_HELP := SettingsUI.AddButton("Hidden x600 y157 h17 w17", "?")
    SSP_P2_LIMIT_HELP.OnEvent("Click", ShowInformationLIMIT)
    CreateImageButton(SSP_P2_LIMIT_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P2_LIMIT.OnEvent("Click", (ctrl, *) => SaveSettingsForDATA(ctrl, false))
    SSP_P2_LIMIT.Value := BeforeLimit
    SSP_P2_OTHER := SettingsUI.AddText("Hidden x420 y177", Chr(0xE14C) " Прочее ↴")
    SGW4 := SysGet(SM_CXMENUCHECK := 71)
    SGH4 := SysGet(SM_CYMENUCHECK := 72)
    SSP_P2_STATUS := SettingsUI.AddCheckBox("Hidden x420 y197 Checked h" SGH4 " w" SGW4)
    SSP_P2_STATUS_TEXT := SettingsUI.AddText("Hidden x434 y195 0x200 h" SGH4, " Показывать статус рп")
    SSP_P2_STATUS_HELP := SettingsUI.AddButton("Hidden x600 y197 h17 w17", "?")
    SSP_P2_STATUS_HELP.OnEvent("Click", ShowInformationSTATUS)
    CreateImageButton(SSP_P2_STATUS_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P2_STATUS.OnEvent("Click", (ctrl, *) => SaveSettingsForDATA(ctrl, false))
    SSP_P2_STATUS.Value := ShowStatus
    SGW5 := SysGet(SM_CXMENUCHECK := 71)
    SGH5 := SysGet(SM_CYMENUCHECK := 72)
    SSP_P2_UPDATE := SettingsUI.AddCheckBox("Hidden x420 y217 Checked h" SGH4 " w" SGW4)
    SSP_P2_UPDATE_TEXT := SettingsUI.AddText("Hidden x434 y215 0x200 h" SGH4, " Авто-проверка обновлений")
    SSP_P2_UPDATE_HELP := SettingsUI.AddButton("Hidden x600 y217 h17 w17", "?")
    SSP_P2_UPDATE_HELP.OnEvent("Click", ShowInformationUPDATE)
    CreateImageButton(SSP_P2_UPDATE_HELP, 0, ButtonStyles["fake_for_hotkey"]*)
    SSP_P2_UPDATE.OnEvent("Click", (ctrl, *) => SaveSettingsForDATA(ctrl, false))
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
    S2500_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
    CreateImageButton(S2500_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    S2500_Input := TimeSetUI.AddEdit("x5 y" S2500_BG.Y " w220", S2500)
    S2500_Input.SetRounded(3)
    S2500_Help := TimeSetUI.AddButton("x230 y" S2500_BG.Y " h25 w25", "?")
    S2500_Help.OnEvent("Click", S2500_Warning)
    CreateImageButton(S2500_Help, 0, ButtonStyles["fake_for_hotkey"]*)
    S3000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
    CreateImageButton(S3000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    S3000_Input := TimeSetUI.AddEdit("x5 y" S3000_BG.Y " w220", S3000)
    S3000_Input.SetRounded(3)
    S3000_Help := TimeSetUI.AddButton("x230 y" S3000_BG.Y " h25 w25", "?")
    S3000_Help.OnEvent("Click", S3000_Warning)
    CreateImageButton(S3000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
    S5000_BG := TimeSetUI.AddButton("x5 y+5 Disabled w220 h25", "")
    CreateImageButton(S5000_BG, 0, ButtonStyles["fake_for_hotkey"]*)
    S5000_Input := TimeSetUI.AddEdit("x5 y" S5000_BG.Y " w220", S5000)
    S5000_Input.SetRounded(3)
    S5000_Help := TimeSetUI.AddButton("x230 y" S5000_BG.Y " h25 w25", "?")
    S5000_Help.OnEvent("Click", S5000_Warning)
    CreateImageButton(S5000_Help, 0, ButtonStyles["fake_for_hotkey"]*)
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
    SOP_DEV := SettingsUI.AddButton("Hidden x198 h30 w155 y308 ", Chr(0xE13D) "  Разработчик AFR")
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
    SettingsPage := [SSP_LABEL, SSP_PANEL_1, SSP_PANEL_2, SSP_PANEL_3, SSP_P1_NAME, SSP_P1_NAME_BG, SSP_P1_NAME_LABEL, SSP_P1_ROLE, SSP_P1_ROLE_BG, SSP_P1_ROLE_LABEL, SSP_P1_SAVEBUTTON, SSP_P1_GENDER, SSP_P1_GENDER_BG, SSP_P1_GENDER_LABEL, SSP_P2_BEFORERP_LABEL, SSP_P2_CHECKNEED, SSP_P2_CHECKNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_ESCNEED, SSP_P2_ESCNEED_HELP, SSP_P2_CHECKNEED_TEXT, SSP_P2_LIMIT, SSP_P2_LIMIT_HELP, SSP_P2_LIMIT_TEXT, SSP_P2_STATUS, SSP_P2_STATUS_HELP, SSP_P2_STATUS_TEXT, SSP_P2_UIMETHOD, SSP_P2_UIMETHOD_BG, SSP_P2_UIMethod_LABEL, SSP_P2_UPDATE, SSP_P2_UPDATE_HELP, SSP_P2_UPDATE_TEXT, SSP_P3_BUTTON, SSP_P3_DESC, SSP_P3_STATS, SSP_P2_ESCNEED_TEXT, SSP_P2_OTHER, SSP_P4_BUTTON, SSP_P5_BUTTON]
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
    hide_ui(Element?, *) {
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
                    autoSleepBefore := S2500
                    autoSleepAfter := S2500
                } else {
                    autoSleepBefore := S2500
                    autoSleepAfter := S5000
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