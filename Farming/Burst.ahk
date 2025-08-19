#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\utils\utils.ahk 

Title := "Burst"

; Key bindings
keyComboBurst      := "2"
keyOverlimit       := "4"
keyChronosShift    := "r"
keyMaximizer       := "x"
keyEnchantedBarrier := "1"
keyBrave           := "c"
keyQuickMotion     := "v"

global isMacroRunning := false
global currentStage := 0
global burstCounter := 0

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
                
            ToolTip("Farming: ON")
            SetTimer(runFarmingLoop, 100)
        } else {
            ToolTip("Farming: OFF")
            SetTimer(runFarmingLoop, 0)
            SetTimer(() => ToolTip(), -1500)
            ; Reset state
            currentStage := 0
            burstCounter := 0
        }
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


; Main farming loop
runFarmingLoop() {
    if !isMacroRunning
        return

    switch currentStage {
        case 0:
            useSupportBuffs()
            useMainBuffs()
            currentStage := 1

        case 1:
            executeBurstCombo()
            burstCounter += 1

            if burstCounter >= 10 {
                currentStage := 0
                burstCounter := 0
            }
    }
}
; Cast support skills like Quick Motion and Brave Aura
useSupportBuffs() {
    sendWithInterrupt(keyQuickMotion, 2000)
    sendWithInterrupt(keyBrave, 2000)
}
; Cast main buffs and recover MP
useMainBuffs() {
    sendWithInterrupt(keyOverlimit, 500)
    recoverMP()
}
; Perform burst combo rotation
executeBurstCombo() {
    spamSkill(keyComboBurst, 4, 500)
    sendWithInterrupt(keyChronosShift, 2000)
    recoverMP()
}
; Recover MP using Charge and Maximizer
recoverMP() {
    sendWithInterrupt(keyEnchantedBarrier, 500)
    sendWithInterrupt(keyMaximizer, 500)
}