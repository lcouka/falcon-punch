--------------------------------------------------------------------------------
--! Chord Multi
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

function isInUIKeyValid(ii)
    return ii > 0 and ii <= pianoIn.numberKeys
end

function isOutUIKeyValid(jj)
    return jj > 0 and jj <= pianoOut.numberKeys
end

local currentIiM
function setCurrentIiM(iiM)
    -- Radio button behavior
    if currentIiM then
        currentIi = currentIiM - t()
        if isInUIKeyValid(currentIi) then
            pianoIn.keyButtons[currentIi]:setValue(false, false)
        end
    end
    currentIiM = iiM
    if iiM ~= nil then
        ii = iiM - t()
        -- Enable button
        if isInUIKeyValid(ii) then
            pianoIn.keyButtons[ii]:setValue(true, false)
        end
        pianoOut:setClickable(true)
        learn.enabled = true
        for jj = 1,pianoOut.numberKeys do -- Show out
            jjM = jj + t()
            pianoOut.keyButtons[jj]:setValue(matrixGet(iiM, jjM), false)
        end
    else -- Radio Button Off
        currentIiM = nil
        pianoOut:setClickable(false)
        learn.enabled = false
        for jj = 1,pianoOut.numberKeys do -- Hide out
            pianoOut.keyButtons[jj]:setValue(false, false)
        end
    end
end

for ii = 1,pianoIn.numberKeys do
    pianoIn.keyButtons[ii].changed = function(self)
        if pianoIn.keyButtons[ii].value then
            iiM = ii + t()
            setCurrentIiM(iiM)
        elseif currentIiM == iiM then
            setCurrentIiM(nil)
        end
    end
end

for jj = 1,pianoOut.numberKeys do
    pianoOut.keyButtons[jj].changed = function(self)
        jjM = jj + t()
        matrixSet(currentIiM, jjM, pianoOut.keyButtons[jj].value)
    end
end

-------------------------------------------------------------------------------- KEY

local MATRIX_EXTRA_MEM = 11
local KEYS = {"C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"}
local keyText = {}
for i = 1, 12 do
    keyText[i] = KEYS[i]..' 0'
end
key = Menu{"Key", KEYS, 0, x = 125, y = 153, width = 55}
local keyValue = key.value
function t() -- From piano key index to matrix index
    return  MATRIX_EXTRA_MEM - (keyValue - 1)
end
function formatNote(value)
    local chroma = value % 12
    return tostring(value).." ("..KEYS[chroma + 1]..")"
end

-------------------------------------------------------------------------------- WRAP MATRIX

matrix = {}

MATRIX_MAX = 128 +MATRIX_EXTRA_MEM*2 -- 11 : extra mem added for transpose due to key selection
for iiM = 1, MATRIX_MAX do
    matrix[iiM] = {}
    for jjM = 1, MATRIX_MAX do
        matrix[iiM][jjM] = iiM == jjM
    end
end


function matrixGet(iiM, jjM)
    return matrix[iiM][jjM]
end

function matrixSet(iiM, jjM, value)
    jj = jjM - t()
    ii = iiM - t()
    if (matrix[iiM][jjM] ~= value) then
        matrix[iiM][jjM] = value

        if isOutUIKeyValid(jj) then
            -- Check if pianoOut should be red
            if iiM == currentIiM and pianoOut.keyButtons[jj] ~= value then
                pianoOut.keyButtons[jj]:setValue(value)
            end

            -- Force pianoOut note releasing
            if (pianoOut.isNotePlaying[jj] > 0) then
                pianoOut.isNotePlaying[jj] = 0
                pianoOut:refreshColour(jj)
            end
        end

        if isInUIKeyValid(ii) then
            -- Check if pianoIn should be green
            refreshGreenColour(ii)
        end

    end
end


-------------------------------------------------------------------------------- MISC

-- True if a chord is mapped to this note
function isNoteMapped(iiM)
    for jjM = 1, MATRIX_MAX do -- TODO bon range
        if matrixGet(iiM, jjM) ~= (iiM == jjM) then
            return true
        end
    end
    return false
end

function refreshGreenColour(ii)
    iiM = ii + t()
    if isNoteMapped(iiM) then
        pianoIn:setColourOff(ii, 1)
    else
        pianoIn:setColourOff(ii, 0)
    end
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
                pianoOut.isNotePlaying[jj] = 0 -- Reset play shadow
                pianoOut:refreshColour(jj)
            end
        end
    end
end

-------------------------------------------------------------------------------- KEY (2)

key.changed = function(self)
    prevVal = currentIiM
    setCurrentIiM(nil)
    keyValue = key.value
    setCurrentIiM(prevVal)
    
    self.displayText = formatNote(self.value)
    for ii = 1,pianoIn.numberKeys do
        refreshGreenColour(ii)
    end
end
key:changed()

-------------------------------------------------------------------------------- EVENT CALLBACKS

function onNote(e)
    isPlaying = isPlaying + 1
    noteM = e.note + 1 + t()
    if (learn.value and learn.enabled) then
        playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
        if (isPlaying == 1) then -- New chord played
            for jj = 1,pianoOut.numberKeys do
                jjM = jj + t()
                matrixSet(currentIiM, jjM, false) -- Reset
            end
        end
        matrixSet(currentIiM, noteM, true) -- Add note
    else
        if midiSelect.value then
            setCurrentIiM(noteM)
        end
        pianoIn:onNote(e.note)
        for jjM = 1, MATRIX_MAX do
            if matrixGet(noteM, jjM) then
                note = jjM - 1 - t() -- TODOLouis check si en dessous du midi
                jj = jjM - t()
                playNote(note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
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
    noteM = e.note + 1 + t()
    for jj = 1,pianoOut.numberKeys do
        jjM = jj + t()
        if (matrixGet(noteM, jjM)) then
            pianoOut:onRelease(jj - 1)
        end
    end
end

-------------------------------------------------------------------------------- PRESETS

local presets = {
{"--"},
{"Pachelbel (M)",{36,24,43,52},{37,25,44,53},{38,26,45,53},{39,28,39,40,48,55},{40,28,47,55},{41,29,48,57},{42,31,42,43,52,59},{43,31,50,59},{44,31,43,44,52,60},{45,33,52,60},{46,35,46,52,56,62},{47,35,55,62},{48,36,55,64},{49,37,53,56,65},{50,38,53,57,65},{51,40,51,52,55,60,67},{52,40,55,59,67},{53,41,57,60,67},{54,43,54,55,59,64,67},{55,43,53,55,59,62,67},{56,43,55,56,60,64,67},{57,45,60,64,67},{58,47,58,59,62,64,68},{59,47,62,65,67},{60,48,62,64,67}}, 
{"Love Tonight (M)",{36,55,64,67,72},{37,56,65,68,72},{38,57,65,69,72},{39,55,63,67,72},{40,55,64,67,72},{41,57,65,69,72},{42,42,43,55,62,65,69,72},{43,55,62,65,67,71},{44,43,44,60,64,67,72},{45,57,64,69,72},{46,45,46,57,65,69,72},{47,55,62,67,71},{48,55,60,62,64,67,72},{49,56,61,63,65,68,72},{50,57,60,64,65,69,72},{51,55,60,63,67,72},{52,55,60,64,67,72},{53,57,60,65,69,72},{54,54,55,62,65,69,72,74},{55,62,65,69,71,74},{56,55,56,60,64,67,72,76},{57,60,64,69,72,76},{58,57,58,60,65,69,72,77},{59,62,67,71,74,79},{60,64,67,72,76,79}}, 
{"Sus4 Lover (M)",{36,43,48,52,55,60},{37,36,37,43,48,53,55,60},{38,45,50,53,57,62},{39,46,50,55,58,62},{40,48,52,55,60,64},{41,48,53,57,60,65},{42,41,42,48,53,58,60,65},{43,50,55,58,62,67},{44,43,44,50,55,60,62,67},{45,52,57,60,64,69},{46,53,58,62,65,70},{47,46,47,55,62,67,70},{48,55,60,64,67,72},{49,48,49,55,60,65,67,72},{50,57,62,65,69,74},{51,58,62,67,70,74},{52,60,64,67,72,76},{53,60,65,69,72,77},{54,53,54,60,65,70,72,77},{55,62,67,70,74,79},{56,55,56,62,67,72,74,79},{57,64,69,72,76,81},{58,65,70,74,77,82},{59,58,59,67,74,79,82},{60,67,72,76,79,84}}, 
{"Sus4 Voleur (m)",{36,43,48,51,55,60},{37,36,37,44,48,53,56,60},{38,44,50,53,56,62},{39,46,51,55,58,63},{40,39,40,46,51,56,58,63},{41,48,53,56,60,65},{42,41,42,48,53,58,60,65},{43,50,55,58,62,67},{44,51,56,60,63,68},{45,44,45,53,56,60,65,68},{46,53,58,62,65,70},{47,46,47,53,58,63,65,70},{48,55,60,63,67,72},{49,48,49,56,60,65,68,72},{50,56,62,65,68,74},{51,58,63,67,70,75},{52,51,52,58,63,68,70,75},{53,60,65,68,72,77},{54,53,54,60,65,70,72,77},{55,62,67,70,74,79},{56,63,68,72,75,80},{57,56,57,65,68,72,77,80},{58,65,70,74,77,82},{59,58,59,65,70,75,77,82},{60,67,72,75,79,84}}, 
{"Strong 7th (m)",{36,48,55,63,70},{37,36,37,48,55,63,67},{38,50,58,65,70},{39,51,58,67,70},{40,39,40,51,58,63,67},{41,53,60,65,70},{42,41,42,53,60,65,69},{43,55,62,65,70},{44,60,63,70},{45,44,45,51,70,72},{46,53,62,70},{47,46,47,53,70,74},{48,55,63,70},{49,48,49,55,63,67},{50,58,65,70},{51,58,67,70},{52,51,52,58,63,67},{53,60,65,70},{54,53,54,60,65,69},{55,62,65,70},{56,60,63,70},{57,56,57,63,70,72},{58,62,65,70},{59,58,59,65,70,74},{60,63,67,70}}, 
{"Jazz (m)",{36,55,58,62,65},{37,56,59,63,65,70},{38,56,59,62,67},{39,55,58,62,65,70},{40,39,40,55,58,62,65,67,70,75},{41,58,60,63,67,70,75},{42,61,64,68,71,76},{43,58,62,65,67,70,74,77},{44,56,65,70,72,75,77},{45,60,65,69,72,77},{46,58,65,70,74,77},{47,59,65,68,71,74,77},{48,60,67,72,75,77},{49,59,65,71,75},{50,59,65,68,71,74},{51,58,60,65,67,70,72},{52,51,52,58,62,67,72,79},{53,60,65,68,75,79},{54,61,64,69,76,78},{55,62,65,70,74,77},{56,63,67,72,75,79},{57,65,69,72,77,79},{58,65,70,72,74,77},{59,65,68,74,77,79},{60,67,72,75,77,79}}, 
{"Haunted (m)",{36,43,48,51,55},{37,36,37,44,48,51,56},{38,44,50,53,56},{39,48,51,55,59},{40,39,40,48,51,55,60},{41,48,53,56,60},{42,50,54,56,60},{43,50,55,59,62},{44,51,56,59,63},{45,44,45,51,56,60,63},{46,46,47,55,56,62,65},{47,56,59,62,65},{48,55,60,63,67},{49,48,49,56,60,63,68},{50,56,62,65,68},{51,60,63,67,71},{52,51,52,60,63,67,72},{53,60,65,68,72},{54,62,66,68,72},{55,62,67,71,74},{56,63,68,71,75},{57,56,57,63,68,72,75},{58,58,59,67,68,74,77},{59,68,71,74,77},{60,67,72,75,79}}, 
--{"McCoy Blues (M/m)",{51,51,55,58,61,65,72,77,82},{53,58,63,67,72,77},{56,55,56,61,65,70,75,80},{57,55,57,61,65,70,75,80},{58,56,58,62,67,72,77,82},{59,59,60,65,70,75,80,85},{60,58,60,63,67,74,79,84},{61,60,61,65,70,75,80,85},{63,60,63,65,70,77,82,87},{64,61,64,66,71},{65,62,65,67,72,77,84,89}}, 
}

function onSave()
  return matrix
end

function onLoad(data)
    for iiM = 1, MATRIX_MAX do
        for jjM = 1, MATRIX_MAX do
            matrixSet(iiM, jjM, data[iiM][jjM])
        end
    end
end

function loadPreset(preset)
    -- Reset
    for iiM = 1, MATRIX_MAX do
        for jjM = 1, MATRIX_MAX do
            matrixSet(iiM, jjM, iiM == jjM)
        end
    end
    setCurrentIiM(nil)
    -- Load
    for i = 2, table.getn(preset) do
        for j = 2, table.getn(preset[i]) do -- Recover chord per input note
            iiM = preset[i][1] + MATRIX_EXTRA_MEM + 1
            jjM = preset[i][j] + MATRIX_EXTRA_MEM + 1
            matrixSet(iiM, jjM, not matrix[iiM][jjM])
        end
    end
end

loadPreset(presets[1])

------------------------------------------------

presetNames = {}
for i = 1, table.getn(presets) do
    presetNames[i] = presets[i][1]
end

presetsMenu = Menu{"Chord_Presets", presetNames, x = 5, y = 153, displayName = "Chord Presets"}
presetsMenu.changed = function(self)
    loadPreset(presets[self.value])
end

-------------------------------------------------------------------------------- TRANSPOSE STUFF

function TransposeInput(semiton)
    local start, end_, step
    if (semiton < 0) then
        start = 1
        end_ = MATRIX_MAX
        step = 1
    else
        start = MATRIX_MAX
        end_ = 1
        step = -1
    end

    for iiM = start, end_ + semiton, step do
        if isNoteMapped(iiM - semiton) then -- Only transpose green keys
            for jjM = 1, MATRIX_MAX do
                matrixSet(iiM, jjM, matrixGet(iiM - semiton, jjM))
            end
        else -- Reset
            for jjM = 1, MATRIX_MAX do
                matrixSet(iiM, jjM, iiM == jjM)
            end
        end
    end

    for iiM = end_ + semiton + step, end_, step do -- Reset extrems keys
        for jjM = 1, MATRIX_MAX do
            matrixSet(iiM, jjM, iiM == jjM)
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

    for iiM = 1, MATRIX_MAX do
        if isNoteMapped(iiM) then -- Only transpose green keys
            for jjM=start,end_ + semiton, step do
                matrixSet(iiM, jjM, matrixGet(iiM, jjM - semiton))
            end
            for jjM=end_ + semiton,end_ + semiton, step do -- Disable extrems keys
                matrixSet(iiM, jjM, false)
            end
        end
    end
end

transposeButtonsIn = {}
transposeButtonsOut = {}
local transposeNames = {"Octave_Down", "Octave_Up"}
local transposeDisplay = {"<", ">"}
local transposeValue = {-12, 12}
local transposeX = {25, 50}
for i = 1, 2 do
    transposeButtonsIn[i] = Button{"Input_"..transposeNames[i], displayName = transposeDisplay[i], x = 313 + transposeX[i], y = 67, width = 20, height = 12}
    transposeButtonsOut[i] = Button{"Output_"..transposeNames[i], displayName = transposeDisplay[i], x = 313 + transposeX[i], y = 146, width = 20, height = 12}
    transposeButtonsIn[i].changed = function() TransposeInput(transposeValue[i]) end
    transposeButtonsOut[i].changed = function() TransposeOutput(transposeValue[i]) end
end


-- NOEXPORT

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


-------------------------------------------------------------------------------- INTERNAL SAVE

-- Only save position that are diff from identity matrix, and factorise them

privateSave = Button("Private_Save", false)
privateSave.displayName = "Save On Output"
privateSave.y = 178
privateSave.changed = function(self)
    local out = "{\""..presetNames[presetsMenu.value].."\""
    for iiM = 1,MATRIX_MAX do
        local first = true
        for jjM = 1,MATRIX_MAX do
            if (matrix[iiM][jjM] ~= (iiM == jjM)) then
                if (first) then
                    out = out..",{"..tostring(iiM - MATRIX_EXTRA_MEM - 1)
                    first = false
                end
                out = out..","..tostring(jjM - MATRIX_EXTRA_MEM - 1)
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


