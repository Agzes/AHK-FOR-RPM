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