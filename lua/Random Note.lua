--------------------------------------------------------------------------------
--! Transpose
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

pitchLabel = Label{"Pitch", align="right", x = 5, y = 5, width = 50}
velocityLabel = Label{"Velocity", align="right", x = 5, y = 30, width = 50}
panLabel = Label{"Pan", align="right", x = 5, y = 55, width = 50}
delayLabel = Label{"Delay", align="right", x = 5, y = 80, width = 50}
pitchDeviation = NumBox{"Pitch_Deviation", 0, 0, 127, false, displayName="Deviation", x = 62, y = 5}
velocityDeviation = NumBox{"velocityDeviation", 0, 0, 127, false, displayName="Deviation", x = 62, y = 30}
panDeviation = NumBox{"panDeviation", 0, 0, 2, false, displayName="Deviation", x = 62, y = 55}
delayDeviation = NumBox{"delayDeviation", 0, 0, 1000, false, displayName="Deviation", x = 62, y = 80}

timbrePreservation = OnOffButton{"Timbre_Preservation", true, displayName="Timbre Preservation", x = 62 + 120}
tonalPitch = OnOffButton{"Tonal_Pitch", false, displayName="Tonal", x = 62 + 240}

mode = Menu{"Random_Mode", {"Dynamic", "Static"}, displayName="Random Mode", x = 605, y = 55}

-- TODO
-- presets = Menu{"Presets", {"--", "Detune Instrument", "Detune Player", "Subbtle", "Medium", "Hard"}, x = 605, y = 55}
-- presets.changed()
-- end

math.randomseed(0)
staticRandom = {}
for i = 1, 128 do 
    staticRandom[i] = {pitch = math.random() * 2 - 1, velocity = math.random() * 2 - 1, pan = math.random() * 2 - 1, delay = math.random()}
end

function onNote(e)
    local randomNumber
    if (mode.value == 1) then
        randomNumber = {pitch = math.random() * 2 - 1, velocity = math.random() * 2 - 1, pan = math.random() * 2 - 1, delay = math.random()}
    else--if (mode.value == 2) then
        randomNumber = staticRandom[e.note + 1]
    end
    
    local pitch = e.note + randomNumber.pitch * pitchDeviation.value
    local pitchInt = math.floor(pitch + 0.5)
    local pitchFrac
    if (tonalPitch.value) then
        pitchFrac = 0
    else
        pitchFrac = pitch - pitchInt
    end
    
    randomPanRange = math.min(1,panDeviation.value)
    randomPanOffset = panDeviation.value - randomPanRange
    pan = randomNumber.pan * randomPanRange
    if pan > 0 then pan = math.min(1,pan + randomPanOffset) else pan = math.max(-1,pan - randomPanOffset) end
    
    if (delayDeviation.value > 0) then wait(randomNumber.delay * delayDeviation.value) end
    playNote(pitchInt, e.velocity + randomNumber.velocity * velocityDeviation.value,
    -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune + pitchFrac, e.slice)
end

function onRelease(e)
end