#Requires AutoHotkey v2.0

sendWithInterrupt(key, delayMs) {
    global isMacroRunning
    if !isMacroRunning
        return false
    Send(key)
    return interruptibleSleep(delayMs)
}

interruptibleSleep(msTotal) {
    global isMacroRunning
    local interval := 10
    local elapsed := 0
    while elapsed < msTotal {
        if !isMacroRunning
            return false
        Sleep(interval)
        elapsed += interval
    }
    return true
}

; Holds a movement key for a set duration
holdKey(key, duration := 1000) {
    if !isMacroRunning
        return
    Send("{" key " down}")
    interruptibleSleep(duration)
    Send("{" key " up}")
}

; Sends a key multiple times with delay
spamSkill(key, times, delay) {
    Loop times {
        sendWithInterrupt(key, delay)
    }
}