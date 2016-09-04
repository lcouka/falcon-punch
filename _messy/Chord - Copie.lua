--------------------------------------------------------------------------------
--! Chorder
--! Only play the lastest note
--! Author : Louis Couka
--! Date : 29/02/2016
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

rowNames = {"Pitch", "Tune", "Velocity"}
label = {}
cells = {}
for i = 1, 3 do
    label[i] = Label{rowNames[i], align="right", x = 5, y = 75 + 25 * (i-1), width = 50}
    cells[i] = {}
end

local MAX_LINES = 18
for j = 1, MAX_LINES do
    cells[1][j] = NumBox{rowNames[1].."_"..tostring(j), 0, -128, 128, true, showLabel = false, width = 32, x = 60 + (j-1) * 30, y = 75}
    cells[2][j] = NumBox{rowNames[2].."_"..tostring(j), 0, -1, 1, false, showLabel = false, width = 32, x = 60 + (j-1) * 30, y = 75 + 25}
    cells[3][j] = NumBox{rowNames[3].."_"..tostring(j), 1, 0, 2, false, showLabel = false, width = 32, x = 60 + (j-1) * 30, y = 75 + 50}
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

function addForLine(line, value)
    local i = 1
    while (i < MAX_LINES and cells[line][i].visible) do
        cells[line][i]:setValue(cells[line][i].value+value)
        i = i + 1
    end
end

down = {}
up = {}
addValues = {1, 0.01, 0.01}
for i = 1, 3 do
    down[i] = Button{rowNames[i].."_Down", displayName = "-", y = 75 + 25 * (i - 1), width = 15}
    up[i] = Button{rowNames[i].."_Up", displayName = "+", y = down[i].y, width = down[i].width}
    down[i].changed = function(self) addForLine(i, -addValues[i]) end
    up[i].changed = function(self) addForLine(i, addValues[i]) end
end

function refreshTable()
    local j = 1
    for k, keyButton in ipairs(piano.keyButtons) do
        if keyButton.value then
            cells[1][j].value = k - 61
            cells[1][j].value = k - 61
            for i = 1, 3 do
                cells[i][j].visible = true
            end
            j = j + 1
        end
    end
    
    for i = 1, 3 do
        down[i].x = 63 + (j-1) * 30
        up[i].x = down[i].x + down[i].width - 1
    end

    for i = 1, 3 do
        for j = j, 18 do
            cells[i][j].visible = false
        end
    end
    
    
end
refreshTable()

for i = 1, piano.numberKeys do
    piano.keyButtons[i].changed = function(self)
        refreshTable()
    end
end

function onNote(e)
    isPlaying = isPlaying + 1
    if (learn.value and learn.enabled) then
        playNote(e.note, e.velocity)
        if (isPlaying == 1) then -- New chord played
            for i = 1,piano.numberKeys do
                piano.keyButtons[i]:setValue(false) -- Reset
            end
        end
        piano.keyButtons[e.note + 1]:setValue(true) -- Add note
    else
        for i, keyButton in ipairs(piano.keyButtons) do
            if keyButton.value then
               playNote(i + e.note - 61, e.velocity)
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
    for i = 2, table.getn(preset) do
        piano.keyButtons[preset[i]]:setValue(true, false)
    end
    refreshTable()
end

-- local vocingPlus13
-- 
-- local vocingDominante
-- 
-- local vocingDim
-- 
-- local vocingAlt -- Augm

local vocingSus4

local vocingMinorMajor7

local vocingMajorMajor7 = {
    
}


local presets = {
{"Major M7",
    {
    {49,56,61,63,65,68,73}, 
    {49,56,61,65,68,70,73}, 
    {49,56,60,63,65,68,72}, 
    {49,56,60,63,65,70}, 
    {49,56,60,63,65,68}, 
    {53,56,61,65,68,73}, 
    {56,61,65,68,73,77}, 
    {61,63,65,68,73,77,80}, 
    {49,56,63,65,68}, 
    {49,56,61,65,68,72,75}, 
    {49,56,61,65,70,75,80}, 
    {49,53,58,63,68,73}, 
    {53,58,63,68,73,77,80}, 
    }
},
{"Major m7"



},
{"Minor"




},
{"Sus4"



}
}

presetNames = {}
for i = 1, table.getn(presets) do
    presetNames[i] = presets[i][1]
end

coloursMenu = Menu{"Colours", presetNames, showLabel = false, height = 20, x = 300, y = 75, width = 80}
coloursMenu.changed = function(self)
    loadPreset(presets[self.value])
end

vocing = NumBox{"Voicing", 1, 1, 12, true, x = coloursMenu.x + coloursMenu.width + 10, y = 75, width = 80}
vocing.changed = function(self)
end

privateSave = Button("Private_Save")
privateSave.changed = function(self)
    local out = "{\"Unnamed\""
    for i, keyButton in ipairs(piano.keyButtons) do
        if keyButton.value then
            out = out..","..tostring(i)
        end
    end 
    out = out.."},"
    print (out)
end