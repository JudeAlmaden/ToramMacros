#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\utils\utils.ahk 

Title := "Cyclone"

; Key bindings
keyCyclone       := "1"
keyEmote         := "r"
keyBuff1         := "z"
keyBuff2         := "x"
keyBuff3         := "c"
keyBuff4        := "v" 

; Global state variables
global isMacroRunning := false
global currentStage := 0
global cycloneSkillDelay := 600

;Cyclone and emote Settings
global iterationsBeforeBuff := 4 
global cycloneCountCap := 70
global emoteDuration := 3000
global emoteCount := 3

; Buff settings
global willUseSupportBuffs := true
global buff1 := true ; Whether to use Brave Aura
global buff2 := true ; Whether to use Quick Motion
global buff3 := true ; Whether to use Mana Recovery
global buff4 := true ; Whether to use any other buffs

; Counters for skills and buffs
global skillCounter := 0
global buffCounter := 0

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
            SetTimer(runFarmingMacro, 100)
        } else {
            SetTimer(runFarmingMacro, 0)
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

            if buffCounter >= iterationsBeforeBuff {
                currentStage := 0
                buffCounter := 0
            }
    }
}
; Cast Quick Motion and Brave Aura
castSupportBuffs() {
    global willUseSupportBuffs
    global buff1
    global buff2
    global buff3

    if !willUseSupportBuffs
        return

    if buff1 {
        sendWithInterrupt(keyBuff1, 2000)
    }
    if buff2 {
        sendWithInterrupt(keyBuff2, 2000)
    }
    if buff3 {
        sendWithInterrupt(keyBuff3, 2000)
    }
    if buff4 {
        sendWithInterrupt(keyBuff4, 2000)
    }
}

; Simulate MP recovery routine with emotes + movement
recoverMP() {
    interruptibleSleep(2000)
    global emoteDuration 
    global emoteCount 

    loop(emoteCount){
        holdKey("a", 100)
        interruptibleSleep(100)
        holdKey("d", 100)
        sendWithInterrupt(keyEmote, emoteDuration)
    }
}

