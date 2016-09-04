--------------------------------------------------------------------------------
--! Chord Suite
--! Note to chords wrapping
--! Author : Louis Couka
--! Date : 25/02/2016
--------------------------------------------------------------------------------



-- Gui Position
local KEYBOARD_LEFT = 5
local KEYBOARD_TOP = 5
local KEY_WIDTH = 8
local KEY_HEIGHT = 72

local notesPlaying = 0
local chromaPlaying = {}
for i=1,24 do
    chromaPlaying[i] = 0
end

local chords = {}
for i=1,24 do
    chords[i] = nil
end

local isFill = {}
for i=1,24 do
    isFill[i] = false
end

local isWhiteKey = true
local xPos = KEYBOARD_LEFT
local KEY = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}

function refreshColour(i)
    if (chromaPlaying[i] > 0) then
        learn[i].backgroundColourOff = ("#999999") -- grey
        if (isFill[i]) then
            learn[i].backgroundColourOn = ("#45ff3c") -- green
        else
            learn[i].backgroundColourOn = ("#f11a1a") -- red
        end
    else
        learn[i].backgroundColourOff = ("#555555") -- grey
        if (isFill[i]) then
            learn[i].backgroundColourOn = ("#31ba2a") -- green
        else
            learn[i].backgroundColourOn = ("#f11a1a") -- red
        end
    end
end

learn = {}
for i=1,24 do -- Setup chroma buttons
    chroma = ((i-1) % 12) + 1
    learn[i] = OnOffButton("K"..tostring(i))
    learn[i].displayName = KEY[chroma]
    refreshColour(i)
    learn[i].changed = function(self)
        if not (self.value) then -- Reset
            chords[i] = nil
            isFill[i] = false
            refreshColour(i)
        end
    end
    learn[i].width = KEY_WIDTH
    learn[i].height = KEY_HEIGHT
    learn[i].x = xPos
    if (isWhiteKey) then
        learn[i].y = KEYBOARD_TOP + KEY_HEIGHT
    else
        learn[i].y = KEYBOARD_TOP
    end
    
    if (chroma ~= 5 and chroma ~= 12) -- E/F and B/C break
    then
        isWhiteKey = not(isWhiteKey)
        xPos = xPos + KEY_WIDTH / 2
    else
        xPos = xPos + KEY_WIDTH
    end
end

--------------------------------------------------------------------------------

presetsMenu = Menu("Presets", {"+3", "+2", "+1", "0", "-1", "-2", "-3"})
presetsMenu.changed = function(self)
print("menu selection changed:", self.value, self.selectedText)
end
presetsMenu.x = 605
presetsMenu.y = 105

--------------------------------------------------------------------------------

doubleRange = OnOffButton("DoubleRange", false)
doubleRange.displayName = "Double Range"

doubleRange.changed = function(self)
    if (self.value) then
        for i=13,24 do
            learn[i].visible = true
        end
    else
        for i=13,24 do
            learn[i].visible = false
        end
    end
end

--------------------------------------------------------------------------------

function autoSelect(splitButton, value)
    if (value == -1) then
        splitButton.backgroundColourOn = ("#f11a1a") -- red
    else
        splitButton.backgroundColourOn = ("#31ba2a") -- green
    end
end

splitNote = OnOffButton("Split", false)
splitNoteValue = -1
splitNote.backgroundColourOn = ("#f11a1a") -- red
splitNote.changed = function(self)
    if (self.value) then
        splitNote.displayName = "Split (learn)"
    else -- Reset
        splitNoteValue = -1
        splitNote.backgroundColourOn = ("#f11a1a")
        splitNote.displayName = "Split"
    end
end

--------------------------------------------------------------------------------

function refreshSplit(splitButton, value)
    if (value == -1) then
        splitButton.backgroundColourOn = ("#f11a1a") -- red
    else
        splitButton.backgroundColourOn = ("#31ba2a") -- green
    end
end

splitNote = OnOffButton("Split", false)
splitNoteValue = -1
splitNote.backgroundColourOn = ("#f11a1a") -- red
splitNote.changed = function(self)
    if (self.value) then
        splitNote.displayName = "Split (learn)"
    else -- Reset
        splitNoteValue = -1
        splitNote.backgroundColourOn = ("#f11a1a")
        splitNote.displayName = "Split"
    end
end

--------------------------------------------------------------------------------

m = Menu("Octave", {"+3", "+2", "+1", "0", "-1", "-2", "-3"})
m.changed = function(self)
 print("menu selection changed:", self.value, self.selectedText)
end
m:setValue(4)
m.x = 605
m.y = 30

--------------------------------------------------------------------------------

keyMenu = Menu("Key", KEY)
keyMenu.changed = function(self)
 print("menu selection changed:", self.value, self.selectedText)
end
keyMenu.x = 485
keyMenu.y = 30

--------------------------------------------------------------------------------


function onNote(e)
    if (splitNote.value and splitNoteValue == -1) then
        splitNoteValue = e.note
        splitNote.backgroundColourOn = ("#31ba2a")
        splitNote.displayName = "Split : "..tostring(e.note)
    else
        notesPlaying = notesPlaying + 1
        if (doubleRange.value) then
            chroma = (e.note)%24 + 1
        else
        chroma = (e.note)%12 + 1
        end
        chromaPlaying[chroma] = chromaPlaying[chroma] + 1
        record = false
        for i=1,24 do
            if (learn[i].value and not isFill[i]) then -- Learning
                chords[i] = {next = chords[i], value = e.note}
                record = true
            end
        end

        if (record) then
            playNote(e.note, e.velocity)
        else
            refreshColour(chroma)
            local it = chords[chroma]
            while it do
                playNote(it.value, e.velocity)
                it = it.next
            end
        end
    end
end


function onRelease(e)
    notesPlaying = notesPlaying - 1
    if (doubleRange.value) then
        chroma = (e.note)%24 + 1
    else
	   chroma = (e.note)%12 + 1
    end
    chromaPlaying[chroma] = chromaPlaying[chroma] - 1
    if (notesPlaying == 0) then
        for i=1,24 do
            if (learn[i].value) then -- Stop learning
                isFill[i] = true
                refreshColour(i)
            end
        end
    end
    
    if (chromaPlaying[chroma] == 0) then
        refreshColour(chroma)
    end
end