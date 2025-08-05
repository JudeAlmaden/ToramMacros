#Requires AutoHotkey v2.0
#SingleInstance Force
#Include utils\utils.ahk 

; Define the lines to send in chat
Title := "Chat Spam"
global chatDelay := 2800 ; Delay between messages
global isMacroRunning := false ; Controls whether the macro is active
global chatMessages := [
    "S>HB 2s @1050 POT 107 40m",
    "S>HB 2s @1050 POT 107 40m."
]

; Test comment
; Event class
class UserEvents {
    ;Constructor
    __New(gui, textCtrl, btnCtrl) {
        this.gui := gui
        this.textCtrl := textCtrl
        this.btnCtrl := btnCtrl
    }

    onButtonClick(*) {
        global isMacroRunning
        isMacroRunning := !isMacroRunning

        ; Update button label
        this.btnCtrl.Text := isMacroRunning ? "Stop" : "Start"

        if isMacroRunning {
            WinActivate("ToramOnline")
            WinWaitActive("ToramOnline")
            DllCall("SetForegroundWindow", "ptr", WinExist("ToramOnline"))

            ToolTip("Macro: ON")
            SetTimer(runChatMacro, 100) ; Start loop
        } else {
            ToolTip("Macro: OFF")
            SetTimer(runChatMacro, 0) ; Stop loop
            SetTimer(() => ToolTip(), -1500) ; Hide tooltip after 1.5s
        }
    }
}

; Main macro loop — sends each message in the list
runChatMacro() {
    global isMacroRunning

    if !isMacroRunning
        return

    for line in chatMessages {
        ; Send Enter, wait 200ms
        if !sendWithInterrupt("{Enter}", 200)
            return

        ; Send the message, wait 200ms
        if !sendWithInterrupt(line, 200)
            return

        ; Send Enter again, wait configured delay
        if !sendWithInterrupt("{Enter}", chatDelay)
            return
    }
}


; GUI Setup
MyGui := Gui("+Resize -MaximizeBox +AlwaysOnTop", Title)

; Add controls
textCtrl := MyGui.Add("Text",, "Macro: " . Title)
btnCtrl := MyGui.Add("Button", "Default w80", "Start")

; Pass controls to event handler
EventObj := UserEvents(MyGui, textCtrl, btnCtrl)

; Bind event
btnCtrl.OnEvent("Click", EventObj.onButtonClick.bind(EventObj))

; Show GUI
MyGui.Show()