#Requires AutoHotkey v2.0
#SingleInstance Force
#Include utils\OCR.ahk
#Include utils\utils.ahk

toramWindowTitle := "ToramOnline"
hWnd := WinExist(toramWindowTitle)
if !hWnd {
    MsgBox "Toram Online window not found!"
    ExitApp
}
global isMacroRunning := false
global numberOfSlots := 50
global startingSlotIndex := 0

sentGiftButtonCoords := [600,285]
selectThePlayerCoords := [490,480]
playerToGiftCoords := [460,300]
tapToSelectGiftCoords := [460, 280]

firstSlotCoords := [520,150]
lastSlotCoords := [930,530]
numberOfVisibleRows := 4
numberOfVisibleColumns := 5

scrollStartCoords := [600, 466]
scrollEndCoords := [600, 550]

selectMaxButtonCoords := [690,250]
reduceByOneButtonCoords := [340,250]
confirmSelectionButtonCoords := [500, 430]
finalConfirmButtonCoords := [270, 250]

sendGiftButtonFinalCoords := [500, 500]
complete := [500, 490]

; === Failsafe Hotkey ===
Esc::ExitApp

class UserEvents {
    __New(gui, btnCtrl, inputSlots, inputStartIndex, lblCurrent, lblScroll, lblRow, lblCol) {
        this.gui := gui
        this.btnCtrl := btnCtrl
        this.inputSlots := inputSlots
        this.inputStartIndex := inputStartIndex
        this.lblCurrent := lblCurrent
        this.lblScroll := lblScroll
        this.lblRow := lblRow
        this.lblCol := lblCol
    }

    startGifting(*) {
        global isMacroRunning, numberOfSlots, startingSlotIndex, hWnd
        isMacroRunning := !isMacroRunning
        this.btnCtrl.Text := isMacroRunning ? "Stop" : "Start"

        if !isMacroRunning
            return

        numberOfSlots := this.inputSlots.Value
        startingSlotIndex := this.inputStartIndex.Value

        DllCall("SetForegroundWindow", "ptr", hWnd)
        Sleep(200)

        distanceBetweenColumns := (lastSlotCoords[1] - firstSlotCoords[1]) / numberOfVisibleColumns
        distanceBetweenRows := (lastSlotCoords[2] - firstSlotCoords[2]) / numberOfVisibleRows

        currentColumn := Mod(startingSlotIndex, numberOfVisibleColumns)  ; 0 to 4
        currentRow := Floor(startingSlotIndex / numberOfVisibleColumns)  ; 0 to 3 (as long as total slots ≤ 20)


        loop numberOfSlots - startingSlotIndex {
            if (!isMacroRunning) {
                ToolTip "Stopped manually."
                return
            }

            slotIndex := A_Index + startingSlotIndex - 1
            scrollIndex := slotIndex // 40

            ; Update GUI
            this.lblCurrent.Text := "Current Slot Index: " slotIndex
            this.lblScroll.Text := "Scroll Index: " scrollIndex
            this.lblRow.Text := "Row: " currentRow
            this.lblCol.Text := "Col: " currentColumn

            this.repeatUntilTextFound("Send Gift", 5, [500,250], [200,100])
            Click sentGiftButtonCoords[1], sentGiftButtonCoords[2]

            this.repeatUntilTextFound("Send Gift to Friend", 5, [320,380], [300,50])
            interruptibleSleep(700)

            Click selectThePlayerCoords[1], selectThePlayerCoords[2]
            interruptibleSleep(700)

            Click playerToGiftCoords[1], playerToGiftCoords[2]
            interruptibleSleep(700)

            Click tapToSelectGiftCoords[1], tapToSelectGiftCoords[2]
            interruptibleSleep(700)

            loop scrollIndex {
                this.scrollOneScreen()
                interruptibleSleep(750)
            }

            Click firstSlotCoords[1] + (distanceBetweenColumns * currentColumn),
                  firstSlotCoords[2] + (distanceBetweenRows * currentRow)
            interruptibleSleep(500)

            Click firstSlotCoords[1] + (distanceBetweenColumns * currentColumn),
                  firstSlotCoords[2] + (distanceBetweenRows * currentRow)
            interruptibleSleep(1000)

            Click selectMaxButtonCoords[1], selectMaxButtonCoords[2]
            interruptibleSleep(500)
            Click reduceByOneButtonCoords[1], reduceByOneButtonCoords[2]
            interruptibleSleep(500)

            Click confirmSelectionButtonCoords[1], confirmSelectionButtonCoords[2]
            interruptibleSleep(500)
            Click finalConfirmButtonCoords[1], finalConfirmButtonCoords[2]
            interruptibleSleep(500)

            Click sendGiftButtonFinalCoords[1], sendGiftButtonFinalCoords[2]
            interruptibleSleep(500)

            this.repeatUntilTextFound("Sent the Gift", 5, [150, 200], [800, 1000])
            Click complete[1], complete[2]
            interruptibleSleep(500)

            currentColumn++
            if (currentColumn >= numberOfVisibleColumns) {
                currentColumn := 0
                currentRow++
            }
            if (currentRow > numberOfVisibleRows)
                currentRow := 0
        }
    }

    repeatUntilTextFound(text, inputScale, coords, dimension, timeout := 100000) {
        global hWnd
        startTime := A_TickCount
        
        while (A_TickCount - startTime < timeout) {
            result := OCR.FromWindow(hWnd, {scale:inputScale, X:coords[1], Y:coords[2], W:dimension[1], H:dimension[2]})
            ToolTip "OCR Result:`n" result.Text

            if (InStr(result.Text, text)) {
                ToolTip "" ; Hide tooltip
                return true
            }
            Sleep 100
        }

        ToolTip "" ; Hide tooltip
        return false
    }

    scrollOneScreen() {
        loop numberOfVisibleRows {
            SendEvent "{Click 700 450 Down 25}{Click 700 285 Up 25}"
        }
    }

    updateValues(*) {
        global numberOfSlots, startingSlotIndex
        numberOfSlots := this.inputSlots.Value
        startingSlotIndex := this.inputStartIndex.Value
    }
}

; === GUI Setup ===
Title := "Gifting Macro"
MyGui := Gui("+Resize -MaximizeBox +AlwaysOnTop", Title)

MyGui.Add("Text", , "Make sure resolution is set to lowest")
btnStart := MyGui.Add("Button", "Default w80", "Start")

MyGui.Add("Text", , "Number of Slots:")
inputSlots := MyGui.Add("Edit", "w80 Number", numberOfSlots)

MyGui.Add("Text", , "Starting Slot Index (0 Based):")
inputStartIndex := MyGui.Add("Edit", "w80 Number", startingSlotIndex)


lblCurrent := MyGui.Add("Text", "w200", "-")
lblScroll := MyGui.Add("Text", "w200", "-")
lblRow := MyGui.Add("Text", "w200", "-")
lblCol := MyGui.Add("Text", "w200", "-")

; === Event Binding ===
EventObj := UserEvents(MyGui, btnStart, inputSlots, inputStartIndex, lblCurrent, lblScroll, lblRow, lblCol)
btnStart.OnEvent("Click", EventObj.startGifting.bind(EventObj))
inputSlots.OnEvent("Change", EventObj.updateValues.bind(EventObj))
inputStartIndex.OnEvent("Change", EventObj.updateValues.bind(EventObj))

MyGui.Show("x0 y0")
