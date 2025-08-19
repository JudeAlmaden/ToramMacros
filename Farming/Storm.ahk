#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\utils\utils.ahk 

Title := "Storm"

; === Skill Key Bindings ===
keyStorm             := "3"
keyOverlimit         := "4"
keyMaximizer         := "x"
keyEnchantedBarrier  := "z"
keyBrave             := "c"
keyQuickMotion       := "v"

; === Macro State Variables ===
global isMacroRunning := false
global currentStage := 0
global stormCounter := 0
global buffCounter := 0

class UserEvents {
    ;Constructor
    __New(gui, textCtrl, btnStart, btnRestart) {
        this.gui := gui
        this.textCtrl := textCtrl
        this.btnStart := btnStart
        this.btnRestart := btnRestart
    }

    onButtonStart(*) {
        global isMacroRunning
        isMacroRunning := !isMacroRunning
        this.startMacro
    }

    onButtonRestart(*){
        global currentStage := 0
        global stormCounter := 0
        global buffCounter := 0
        global isMacroRunning
        isMacroRunning := true

        this.startMacro()
    }

    startMacro(){
        global isMacroRunning

        ; Update button label
        this.btnStart.Text := isMacroRunning ? "Stop" : "Start"

        if isMacroRunning {
            WinActivate("ToramOnline")
            WinWaitActive("ToramOnline")
            DllCall("SetForegroundWindow", "ptr", WinExist("ToramOnline"))

            ToolTip("Farming: ON")
            SetTimer(runFarmingMacro, 100)
        } else {
            ToolTip("Farming: OFF")
            SetTimer(runFarmingMacro, 0)
            SetTimer(() => ToolTip(), -1500)

            ; Reset all counters and stage
            currentStage := 0
            stormCounter := 0
            buffCounter := 0
        }
    }
}

; GUI Setup
MyGui := Gui("+Resize -MaximizeBox +AlwaysOnTop", Title)

;  Add controls
textCtrl := MyGui.Add("Text",, "Macro: " . Title)
btnStart := MyGui.Add("Button", "Default w80", "Start")
btnRestart := MyGui.Add("Button", "Default w80", "Restart")

; Pass controls to event handler
EventObj := UserEvents(MyGui, textCtrl, btnStart, btnRestart)

; Bind event
btnStart.OnEvent("Click", EventObj.onButtonStart.bind(EventObj))
btnRestart.OnEvent("Click", EventObj.onButtonRestart.bind(EventObj))

; Show GUI
MyGui.Show()


; === Main Farming Loop ===
runFarmingMacro() {
    global isMacroRunning
    global currentStage 
    global stormCounter 
    global buffCounter 

    if !isMacroRunning
        return

    switch currentStage {
        case 0:
            castSupportBuffs()
            currentStage := 1

        case 1:
            castMainBuffs()
            stormCounter := 0
            currentStage := 2

        case 2:
            if stormCounter < 20 {
                castStormCycle()
                stormCounter += 1
            } else {
                buffCounter += 1
                if buffCounter < 3 {
                    currentStage := 1
                } else {
                    buffCounter := 0
                    currentStage := 0
                }
            }
    }
}

; === Skill Casts ===

; Quick Motion + Brave + MP Recovery
castSupportBuffs() {
    sendWithInterrupt(keyQuickMotion, 2000)
    sendWithInterrupt(keyBrave, 2000)
    recoverMP()
}
; Enchanted Barrier + Overlimit + MP Recovery
castMainBuffs() {
    sendWithInterrupt(keyOverlimit, 1000)
    recoverMP()
}
; Storm skill spam and quick MP recovery
castStormCycle() {
    spamSkill(keyStorm, 5, 600)
    interruptibleSleep(2000)
    recoverMP()
    interruptibleSleep(1000)
}
; Charge + Maximizer combo
recoverMP() {
    sendWithInterrupt(keyEnchantedBarrier, 750)
    sendWithInterrupt(keyMaximizer, 1000)
}

