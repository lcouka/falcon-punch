--------------------------------------------------------------------------------
--! Chord Suite
--! Note to chords
--! Author : Louis Couka
--! Date : 25/02/2016
--------------------------------------------------------------------------------

require "Piano"

-------------------------------------------------------------------------------- PIANO WIDGETS

pianoIn = Piano.create("Input")
pianoIn:setY(5)

pianoOut = Piano.create("Output")
pianoOut:setY(84)

local currentIndexIn

for ii = 1,pianoIn.numberKeys do
    pianoIn.keyButtons[ii].changed = function(self)
        if (pianoIn.keyButtons[ii].value) then
            pianoOut:setClickable(true)
            learn.enabled = true
            if (currentIndexIn) then -- Radio button behavior
                pianoIn.keyButtons[currentIndexIn]:setValue(false, false)
            end
            currentIndexIn = ii
            for jj = 1,pianoOut.numberKeys do -- Show out
                pianoOut.keyButtons[jj]:setValue(matrix[ii][jj], false)
            end
        else
            noInputSelected()
        end
    end
end

for jj = 1,pianoOut.numberKeys do
    pianoOut.keyButtons[jj].changed = function(self)
        matrixSet(currentIndexIn, jj, pianoOut.keyButtons[jj].value)
    end
end

-- Radio button off
function noInputSelected()
    pianoOut:setClickable(false)
    learn.enabled = false
    currentIndexIn = nil
    for jj = 1,pianoIn.numberKeys do -- Hide in
        pianoIn.keyButtons[jj]:setValue(false, false)
    end
    for jj = 1,pianoOut.numberKeys do -- Hide out
        pianoOut.keyButtons[jj]:setValue(false, false)
    end
end

-------------------------------------------------------------------------------- WRAP MATRIX

matrix = {}

for ii = 1, pianoIn.numberKeys do
    matrix[ii] = {}
end

function matrixSet(ii, jj, value)
    if (matrix[ii][jj] ~= value) then
        matrix[ii][jj] = value
        
        -- Check if pianoOut should be red
        if (ii == currentIndexIn and pianoOut.keyButtons[jj] ~= value) then
            pianoOut.keyButtons[jj]:setValue(value)
        end
        
        -- Check if pianoIn should be green
        local colourId = 0
        for jj = 1,pianoOut.numberKeys do
            if matrix[ii][jj] ~= (ii == jj) then
                colourId = 1
                break
            end
        end
        pianoIn:setColourOff(ii, colourId)
        
        -- Check if transpose button should be off (when identity matrix)
        local isIdentity = true
        for ii = 1,pianoIn.numberKeys do
            if pianoIn.colourOff[ii] == 1 then
                isIdentity = false
                break
            end
        end
        for i = 1, 4 do
            transposeButtonsIn[i].enabled = not isIdentity
            transposeButtonsOut[i].enabled = not isIdentity
        end
        
        -- Force pianoOut note releasing
        j = jj - 1
        if (pianoOut.isNotePlaying[jj] > 0) then
            pianoOut.isNotePlaying[jj] = 0
            pianoOut:refreshColour(jj)
        end
    end
end

-------------------------------------------------------------------------------- TRANSPOSE STUFF

function TransposeInput(semiton)
    local start, end_, step
    if (semiton < 0) then
        start = 1
        end_ = pianoIn.numberKeys
        step = 1
    else
        start = pianoIn.numberKeys
        end_ = 1
        step = -1
    end
    
    for ii = start,end_ + semiton, step do
        if (pianoIn.colourOff[ii - semiton] == 0) then -- Reset
            for jj = 1,pianoOut.numberKeys do
                matrixSet(ii, jj, ii == jj)
            end
        else -- Only transpose green keys
            for jj = 1,pianoOut.numberKeys do
                matrixSet(ii, jj, matrix[ii - semiton][jj])
            end
        end
    end
    
    for ii = end_ + semiton + step, end_, step do -- Reset extrems keys
        for jj = 1,pianoOut.numberKeys do
            matrixSet(ii, jj, ii == jj)
        end
    end
end

function TransposeOutput(semiton)
    local start, end_, step
    if (semiton < 0) then
        start = 1
        end_ = pianoOut.numberKeys
        step = 1
    elseif (semiton > 0) then
        start = pianoOut.numberKeys
        end_ = 1
        step = -1
    else
        return
    end
    
    for ii = 1,pianoIn.numberKeys do
        if (pianoIn.colourOff[ii] ~= 0) then -- Only transpose green keys
            for jj=start,end_ + semiton, step do
                matrixSet(ii, jj, matrix[ii][jj - semiton])
            end
            for jj=end_ + semiton,end_ + semiton, step do -- Disable extrems keys
                matrixSet(ii, jj, false)
            end
        end
    end
end

transposeButtonsIn = {}
transposeButtonsOut = {}
local transposeNames = {"Semiton_Down", "Semiton_Up", "Octave_Down", "Octave_Up"}
local transposeDisplay = {"<", ">", "<<", ">>"}
local transposeValue = {-1, 1, -12, 12}
local transposeX = {25, 50, 0, 75}
for i = 1, 4 do
    transposeButtonsIn[i] = Button{"Input_"..transposeNames[i], displayName = transposeDisplay[i], x = 313 + transposeX[i], y = 67, width = 20, height = 12}
    transposeButtonsOut[i] = Button{"Output_"..transposeNames[i], displayName = transposeDisplay[i], x = 313 + transposeX[i], y = 146, width = 20, height = 12}
    transposeButtonsIn[i].changed = function() TransposeInput(transposeValue[i]) end
    transposeButtonsOut[i].changed = function() TransposeOutput(transposeValue[i]) end
end

-------------------------------------------------------------------------------- MIDI SELECT

midiSelect = OnOffButton("Midi_Select", false)
midiSelect.displayName = "Midi Select"
midiSelect.x = 605
midiSelect.y = 153

-------------------------------------------------------------------------------- CHORD LEARN

isPlaying = 0
learn = OnOffButton("Chord_Learn", false)
learn.displayName = "Chord Learn"
learn.backgroundColourOn = ("#f11a1a") -- red
learn.x = 605
learn.y = 178
learn.changed = function(self)
    if (self.value) then
        for jj = 1,pianoOut.numberKeys do
            if (pianoOut.isNotePlaying[jj] > 0) then
                matrixSet(currentIndexIn, jj, true) -- Optionnal : add note that are playing to our chord (provide a way to copy/paste)
                pianoOut.isNotePlaying[jj] = 0 -- Reset play shadow
                pianoOut:refreshColour(jj)
            end
        end        
    end
end

-------------------------------------------------------------------------------- EVENT CALLBACKS

function onNote(e)
    isPlaying = isPlaying + 1
    if (learn.value and learn.enabled) then
        playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
        if (isPlaying == 1) then -- New chord played
            for jj = 1,pianoOut.numberKeys do
                matrixSet(currentIndexIn, jj, false) -- Reset
            end
        end
        matrixSet(currentIndexIn, e.note + 1, true) -- Add note
    else
        if (midiSelect.value) then
            pianoIn.keyButtons[e.note + 1]:setValue(true)
        end
        pianoIn:onNote(e.note)
        for jj = 1,pianoOut.numberKeys do
            if (matrix[e.note + 1][jj]) then
                playNote(jj - 1, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
                pianoOut:onNote(jj - 1)
            end
        end
    end
end

function onRelease(e)
    if (isPlaying > 0) then -- failsafe
        isPlaying = isPlaying - 1
    end
    pianoIn:onRelease(e.note)
    for jj = 1,pianoOut.numberKeys do
        if (matrix[e.note + 1][jj]) then
            pianoOut:onRelease(jj - 1)
        end
    end
end

-------------------------------------------------------------------------------- PRESETS

local presets = {
{"--"},
{"Unnamed",{49,61,68,71,73,75,78},{50,60,66,71,72,76},{51,60,66,69,72,75},{52,59,61,66,68,71,73},{53,52,53,59,63,68,73,75,80},{54,61,66,69,73,76},{55,62,65,70,74,77},{56,63,66,71,75,78},{57,64,68,73,76,80},{58,66,70,73,78,80},{59,66,71,75,78,83},{60,66,69,72,75,78,83},{61,68,71,73,76,80,83}}, 
{"Unnamed",{52,52,56,59,62,66,73,78,83},{54,59,64,68,73,78},{57,56,57,62,66,71,76,81},{58,56,58,62,66,71,76,81},{59,57,59,63,68,73,78,83},{60,60,61,66,71,76,81,86},{61,59,61,64,68,75,80,85},{62,61,62,66,71,76,81,86},{64,61,64,66,71,78,83,88},{65,62,65,67,72,79,84,89},{66,63,66,68,73,78,85,90}}, 
{"Chord Suite 1",{49,56},{49,61},{49,64},{49,68},{49,71},{51,59},{51,63},{51,66},{51,71},{52,59},{52,63},{52,68},{52,71},{54,61},{54,65},{54,70},{54,73},{56,63},{56,67},{56,72},{56,75},{57,64},{57,68},{57,73},{57,76},{59,66},{59,70},{59,73},{59,75},{61,68},{61,72},{61,75},{61,77},},
{"Chord Suite 1",{49,56},{49,61},},
{"Feel the Love Tonight",{39,58,61,66,70,73},{41,65,68,73},{42,66,70,73},{43,43,46,61,66,70,73},{44,63,66,68,72},{45,44,45,61,65,68,73},{46,65,70,73},{48,63,68,72},{49,56,61,63,65,68,73},{51,58,61,65,66,70,73},{53,56,61,65,68,73},{54,58,61,66,70,73},{56,66,70,72,75},{57,56,57,61,65,68,73,77},{58,61,65,70,73,77},{60,63,68,72,75,80},{61,65,68,73,77,80}}, 
}

function onSave()
  return matrix
end

function onLoad(data)
    for ii = 1,pianoIn.numberKeys do
        for jj = 1,pianoOut.numberKeys do
            matrixSet(ii, jj, data[ii][jj])
        end
    end
end

function loadPreset(preset)
    -- Reset
    for ii = 1,pianoIn.numberKeys do
        for jj = 1,pianoIn.numberKeys do
            matrixSet(ii , jj, ii == jj)
        end
    end
    noInputSelected()
    -- Load
    for ii = 2, table.getn(preset) do
        for jj = 2, table.getn(preset[ii]) do -- Recover chord per input note
            matrixSet(preset[ii][1], preset[ii][jj], not matrix[preset[ii][1]][preset[ii][jj]])
        end
    end
end

--Do loadPreset(presets[1]) mannualy as an optim
for ii = 1,pianoIn.numberKeys do
    for jj = 1,pianoIn.numberKeys do
        matrix[ii][jj] = ii == jj
    end
end
noInputSelected()
for i = 1, 4 do
    transposeButtonsIn[i].enabled = false
    transposeButtonsOut[i].enabled = false
end
------------------------------------------------
        
presetNames = {}
for i = 1, table.getn(presets) do
    presetNames[i] = presets[i][1]
end

presetsMenu = Menu("Presets", presetNames)
presetsMenu.changed = function(self)
    loadPreset(presets[self.value])
end
presetsMenu.x = 5
presetsMenu.y = 153

-- NOEXPORT
-------------------------------------------------------------------------------- INTERNAL SAVE

-- Only save position that are diff from identity matrix, and factorise them
    
privateSave = Button("Private_Save", false)
privateSave.displayName = "Save On Output"
privateSave.x = 125
privateSave.y = 178
privateSave.changed = function(self)
    local out = "{\"Unnamed\""
    for ii = 1,pianoIn.numberKeys do
        local first = true
        for jj = 1,pianoOut.numberKeys do
            if (matrix[ii][jj] ~= (ii == jj)) then
                if (first) then
                    out = out..",{"..tostring(ii)
                    first = false
                end
                out = out..","..tostring(jj)
            end
        end
        if not first then
            out = out.."}"
        end
    end   
    out = out.."},"
    print (out)
end

-- memoryGame = Button("Memory_Game", false)
-- memoryGame.displayName = "Memory Game"
-- memoryGame.x = 245
-- memoryGame.y = 178
-- memoryGame.changed = function(self)
--     local out = "chords = {"
--     for ii = 1,pianoIn.numberKeys do
--         local i = ii - 1
--         if (pianoIn.colourOff[ii] == 1) then
--             local first = true
--             for jj = 1,pianoOut.numberKeys do
--                 if (matrix[ii][jj] == true) then
--                     if (first) then
--                         out = out.."{"
--                         first = false
--                     else
--                         out = out..","
--                     end
--                     out = out..tostring(jj - 1)
--                 end
--             end
--             out = out.."},"
--         end
--     end   
--     out = out.."}"
--     print (out)
-- end