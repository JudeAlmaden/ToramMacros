#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\utils\utils.ahk 

Title := "Cyclone"

; Key bindings
keyCyclone       := "1"
keyEmote         := "r"
keyBrave         := "c"
keyQuickMotion   := "v"

; Global state variables
global isMacroRunning := false
global currentStage := 0
global cycloneSkillDelay := 450
global mpRegenDuration := 500
global cycloneCountCap := 35
global emoteDuration := 3000
global emoteCount := 5

; Counters for skills and buffs
global skillCounter := 0
global buffCounter := 0
global willUseSupportBuffs := false

class UserEvents {
    ;Constructor
    __New(gui, textCtrl, btnStart, btnRestart) {
        this.gui := gui
        this.textCtrl := textCtrl
        this.btnStart := btnStart
        this.btnRestart :=btnRestart
    }

    btnStartEvent(*) {
        global isMacroRunning
        isMacroRunning := !isMacroRunning

        this.startMacro()
    }

    btnRestartEvent(*){
        global currentStage := 0
        global skillCounter := 0
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

            ; Reset counters
            currentStage := 0
            skillCounter := 0
            buffCounter := 0
        }

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

            ; Reset counters
            currentStage := 0
            skillCounter := 0
            buffCounter := 0
        }
    }
}

; GUI Setup
MyGui := Gui("+Resize -MaximizeBox +AlwaysOnTop", Title)

; Add controls
textCtrl := MyGui.Add("Text",, "Macro: " . Title)
btnStart := MyGui.Add("Button", "Default w80", "Start")
btnRestart := MyGui.Add("Button", "Default w80", "Restart")

; Pass controls to event handler
EventObj := UserEvents(MyGui, textCtrl, btnStart, btnRestart)

; Bind event
btnStart.OnEvent("Click", EventObj.btnStartEvent.bind(EventObj))
btnRestart.OnEvent("Click", EventObj.btnRestartEvent.bind(EventObj))

; Show GUI
MyGui.Show()


; Main farming loop
runFarmingMacro() {
    global currentStage
    global skillCounter
    global willUseSupportBuffs
    global buffCounter
    if !isMacroRunning
        return

    switch currentStage {
        case 0:
            if willUseSupportBuffs {
                castSupportBuffs()
                recoverMP()
            }
            currentStage := 1

        case 1:
            spamSkill(keyCyclone, 4, 300)
            interruptibleSleep(cycloneSkillDelay)
            skillCounter += 1

            if skillCounter >= cycloneCountCap {
                recoverMP()
                buffCounter += 1
                skillCounter := 0
            }

            if buffCounter >= 3 {
                currentStage := 0
                buffCounter := 0
            }
    }
}
; Cast Quick Motion and Brave Aura
castSupportBuffs() {
    sendWithInterrupt(keyQuickMotion, 3000)
    sendWithInterrupt(keyBrave, 7000)
}

; Simulate MP recovery routine with emotes + movement
recoverMP() {
    interruptibleSleep(2000)
    global emoteDuration 
    global emoteCount 

    loop(emoteCount){
        holdKey("a", 200)
        Sleep(200)
        holdKey("d", 200)
        sendWithInterrupt(keyEmote, emoteDuration)
    }
}

