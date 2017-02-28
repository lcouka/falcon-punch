--------------------------------------------------------------------------------
--! Chord
--! Author : Louis Couka
--! Date : 03/03/2016
--------------------------------------------------------------------------------

require "Piano"

piano = Piano.create("Key")
piano:setY(5)

isPlaying = 0
learn = OnOffButton{"Chord_Learn", false, displayName = "Chord Learn", backgroundColourOn = ("#f11a1a"), x = 605, y = 75}
learn.changed = function(self)
    if (self.value) then
        for i = 1,piano.numberKeys do
            if (piano.isNotePlaying[i] > 0) then
                piano.keyButtons[i]:setValue(true)
                piano.isNotePlaying[i] = 0 -- Reset play shadow
                piano:refreshColour(i)
            end
        end        
    end
end

-------------------------------------------------------------------------------- TRANSPOSE STUFF

function transpose(semiton)
    local start, end_, step
    if (semiton < 0) then
        start = 1
        end_ = piano.numberKeys
        step = 1
    elseif (semiton > 0) then
        start = piano.numberKeys
        end_ = 1
        step = -1
    else
        return
    end
    
    for jj=start,end_ + semiton, step do
        piano.keyButtons[jj]:setValue(piano.keyButtons[jj - semiton].value)
    end
    for jj=end_ + semiton,end_ + semiton, step do -- Disable extrems keys
        piano.keyButtons[jj]:setValue(false)
    end
end

function onNote(e)
    isPlaying = isPlaying + 1
    if (learn.value and learn.enabled) then
        playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
        if (isPlaying == 1) then -- New chord played
            for i = 1,piano.numberKeys do
                piano.keyButtons[i]:setValue(false) -- Reset
            end
        end
        piano.keyButtons[e.note + 1]:setValue(true) -- Add note
    else
        for i, keyButton in ipairs(piano.keyButtons) do
            if keyButton.value then
               playNote(i + e.note - 61, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
            end
        end
    end
    piano:onNote(e.note)
end

function onRelease(e)

    if (isPlaying > 0) then -- failsafe
        isPlaying = isPlaying - 1
    end
    piano:onRelease(e.note)
end

piano.keyButtons[61]:setValue(true)
function loadPreset(preset)
    -- Reset
    for i, keyButton in ipairs(piano.keyButtons) do
        keyButton:setValue(false, false)
    end
    for i = 1, table.getn(preset) do
        piano.keyButtons[preset[i]]:setValue(true, false)
    end
end

local presets =
{
    {
        "--",
        {
            {61}
        },
    },
    
    {
        "Major",
        {
            {49,56,61,65,68,73}, 
            {49,56,61,65,70,75}, 
            {49,56,61,65,68,72,75,80},   
            {49,56,61,63,65,68,70,72,75}, 
            {49,56,61,68,72,77}, 
            {49,56,61,63,65,68}, 
            {56,61,65,68,72,73,75}, 
            {49,56,61,63,65,68,73}, 
            {49,56,61,65,68,70,73}, 
            {49,56,60,63,65,68,72}, 
            {49,56,60,63,65,70}, 
            {49,56,60,63,65,68}, 
            {49,56,61,65,68,72,75}, 
            {49,56,61,65,70,75,80}, 
            {49,53,58,63,68,73}, 
            {53,58,63,68,73,77,80}, 
            {49,53,58,63,68,73,80}, 
            {49,53,58,63,65,68,70}, 
            {49,53,56,58,61,65,68}, 
            {49,53,56,60,63,65,68}, 
            {49,56,61,65,68,72,73,75},
            {49,56,61,65,70,75,77,80},
            {49,56,61,68,73,77,80}, --
            {49,56,65}, 
            {49,56,63,65,68}, 
            {49,56,61,63,65}, --
            {56,61,65,68,73,77}, --
            {53,56,61,65,68,73}, --
            {56,61,65,70,75,77,80}, --  
            {61,63,65,68,73,77,80}, --
            {56,61,65,68,73,77,80,82}, --
            {56,61,63,65,68,70,72,75}, --
            {49,56,61,65,68,72,75,77,80,84}, --
            {49,56,58,61,65,68,72,75,77,80,84,87}, --
        }
    },
    {
        "Minor",
        {
            {49,56,61,64,68,73}, 
            {49,56,61,63,64,68,71}, 
            {49,56,61,68,71,75,78}, 
            {49,56,59,64,68,73}, 
            {49,56,64,68,71,75}, 
            {61,63,64,68,71}, 
            {59,63,64,66,68,71,75,78}, 
            {61,63,64,66,68,71,75}, 
            {49,52,56,61,63,64,68}, 
            {49,52,56,59,64,68,71,75}, 
            {49,56,59,64,68}, 
            {49,56,59,64}, 
            {49,59,64,68,73,78}, 
            {49,56,61,64,68,71}, 
            {49,56,61,64,68,71,75}, 
            {49,56,59,61,64,68}, 
            {49,56,61,64,66,68,71}, 
            {49,56,61,68,71,76}, 
            {49,56,61,64,70,73,75}, 
            {49,56,59,64,68,73,78}, 
            {49,56,64,68,71,73,76},    
            {59,61,64,66,68,71,75,78}, --
            {49,56,59,64,68,73,78,85}, --
            {49,56,61,64,68,73,75}, --
            {49,56,61,64,68,72,75}, --
            {49,52,56,59,63,68,73,80}, --
            {56,59,61,64,66,68,71,73,76}, --
            {49,56,59,63,64,66,71,73,75,78}, --
            {49,52,54,56,59,63,66}, --
            {49,52,56,59,61,64,68}, --
            {49,52,58,63,68,73,78}, --
            {49,58,63,68,73,76,78}, --
            {49,56,59,64,70,75}, --
            {49,51,52,56,59,63}, --
            {49,52,58,63,68,73}, --
            {49,54,59,64,70,75}, --
            {49,56,61,66,71,76}, --
            {52,56,59,63,68,71,76,78,80}, --
            {49,56,61,63,64,68,71,75,78,80,83}, 
        }
    },
    {
        "Dominant",
        {
            --- 7
            {49,56,59,65,68,73}, 
            {49,56,61,65,68,71,73},
            {49,53,59,63,68}, 
            {49,53,59,63,68,73}, 
            {49,59,65,70,75,80}, 
            {59,65,70,75,80,85}, 
            {49,59,65,68,71,75}, 
            {49,59,63,65,68}, 
            
            --- Tensions
            {49,65,69,71,76}, 
            {49,59,65,69,73}, 
            {49,59,62,65,68,71}, 
            {49,56,59,62,67,71}, 
            {49,56,59,62,65,68,73}, 
            {49,56,59,61,62,65,68,71}, 
            {49,56,61,62,67,71,74}, 
            {49,53,59,63,67,70}, 
            {49,53,59,62,65,70}, 
            {49,53,59,62,67,70}, 
            {49,53,59,62,67,71}, 
            {61,63,65,67,69,71,73}, 
            {49,59,62,65,67,71}, 
            {49,59,62,65,71}, 
            {49,59,64,65,68}, 
            {49,53,59,64,68,73}, 
            {49,56,62,65,67,68,71,73}, 
            {49,56,59,61,62,65,68,71,74}, 
            {49,56,59,62,65,69}, 
            {49,56,61,65,69,71,76}, 
            {49,53,59,65,69,73}, 
            {49,56,61,65,69,71,74,76}, 
            {53,59,64,68,73,80}, 
            {49,56,59,65,67,69,71,73}, 
        }
    },
    {
        "Sus4",
        {
            {49,56,59,63,66,70,73}, 
            {49,56,59,61,63,66,68,73}, 
            {49,56,59,63,66,68,71}, 
            {49,56,59,63,66,70}, 
            {49,56,59,61,63,66,70,75}, 
            {49,56,59,61,63,66,68,71,73}, 
            {54,56,59,61,63,66,70,73}, 
            {49,54,59,63,66,70}, 
            {49,54,56,58,59,63}, 
            {49,56,63,66,68,71}, 
            {49,56,59,66,68,71,73,75}, 
            {49,56,61,68,71,75,78}, 
            {49,56,59,63,66,68}, 
            {49,56,59,63,66,71,73}, 
            {49,56,59,63,66,68,71,73}, 
            {56,59,61,63,66,68,71,73,75,78}, 
            {49,59,63,66,70,73}, 
            {49,59,63,66,70,73,75,78,80}, 
            {61,63,66,68,71,73,75,78}, 
            {54,56,59,61,63,66,68,70,73}, 
            {51,54,56,59,61,66,68,71,73}, 
            {49,54,59,63,66,71,75}, 
            {49,54,56,58,59,63,66}, 
            {61,66,68,71,75,78}, 
            {61,63,66,68,71,75}, 
            {61,66,68,70,71,75}, 
            {61,66,68,70,71,75,78}, 
            {49,54,59,63,66,71}, 
            {49,56,59,61,63,66,68,71,73,75,78,80}, 
            {49,54,59,63,68,73}, 
            {49,54,59,61,63,68,73,78}, 
            {49,54,56,59,61,64,66,68,71,73,78}, 
            {49,56,59,63,68,71,75}, 
        }
    }
}

presetNames = {}
for i = 1, table.getn(presets) do
    presetNames[i] = presets[i][1]
end

coloursMenu = Menu{"Colours", presetNames, showLabel = false, height = 20, x = 5, y = 75, width = 100, persistent = false}
voicing = NumBox{"Voicing", 1, 1, 99, true, x = coloursMenu.x + coloursMenu.width + 9, y = 75, width = coloursMenu.width, persistent = false}
function loadSelectedPreset()
    loadPreset(presets[coloursMenu.value][2][voicing.value])
end
voicing.changed = function(self)
    numVoicings = table.getn(presets[coloursMenu.value][2])
    if self.value > numVoicings then self:setValue(numVoicings, false) end
    self.displayText = tostring(self.value).."/"..tostring(numVoicings)
    loadSelectedPreset()
end
coloursMenu.changed = function(self)
    voicing:setValue(1, false)
    voicing.changed(voicing)
end
voicing.changed(voicing)

voicingUp = Button{"Voicing_Up", displayName = "+", width = 15, height = 12, x = voicing.x + voicing.width + 3, y = voicing.y - 1}
voicingUp.changed = function(self) voicing:setValue(voicing.value+1) end
voicingDown = Button{"Voicing_Down", displayName = "-", width = 15, height = 12, x = voicing.x + voicing.width + 3, y = voicing.y + 10}
voicingDown.changed = function(self) voicing:setValue(voicing.value-1) end

-- NOEXPORT
---- UNCOMMENT THIS TO SEE IF THERE ARE DOUBLONS
-- function compareTable(t1, t2)
--     if table.getn(t1) == table.getn(t2) then
--         for i, note in ipairs(preset) do
--             if t1[i] ~= t2[i] then return false end
--         end
--         return true
--     else
--         return false
--     end
-- end
-- 
-- for i, preset_ in ipairs(presets) do
--     print(preset_[1])
--     preset = preset_[2]
--     for j, note in ipairs(preset) do
--         for k, note in ipairs(preset) do
--             if j ~= k and compareTable(preset[j], preset[k]) then print(tostring(j).."="..tostring(k)) end
--         end
--     end
-- end

privateSave = Button("Private_Save")
privateSave.y = voicing.y
privateSave.changed = function(self)
    local out = "{"
    local first
    for i, keyButton in ipairs(piano.keyButtons) do
        if keyButton.value then
            if first then out = out.."," else first = true end
            out = out..tostring(i)
        end
    end 
    out = out.."},"
    print (out)
end