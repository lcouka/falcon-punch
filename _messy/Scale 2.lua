--------------------------------------------------------------------------------
--! Scale
--! Author : Louis Couka
--! Date : 05/03/2016
--------------------------------------------------------------------------------

local KEY = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}

local keysButton = {}
local keysNumBox = {}
local WIDTH = 51
for i = 1, 12 do
    keysNumBox[i] = NumBox{"KeyNumBox_"..tostring(i), i - 1, -24, 24, true, showLabel = false, width = WIDTH + 3, x = 102 + (i - 1) * WIDTH, y = 24}
    keysButton[i] = OnOffButton{"KeyButton_"..tostring(i), true, width = WIDTH + 1, x = keysNumBox[i].x, y = 5}
    keysNumBox[i].changed = function(self)
        if (self.value ~= i - 1) then
            self.textColour = "#333333"
        else
            self.textColour = "#aaaaaa"
        end  
    end
    keysNumBox[i].changed(keysNumBox[i])
end
keysNumBox[12].width = WIDTH + 1

local rootKey = Menu{"Root", KEY, showLabel = false, width = 94, height = 20, x = 5, y = 5}
rootKey.changed = function(self)
    for i = 1, 12 do
        keysButton[i].displayName = KEY[(i + self.value - 2) % 12 + 1]
    end
end
rootKey.changed(rootKey)

scales = {
	{"--", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}},
	{"Major (Ionian)", {0, 2, 4, 5, 7, 9, 11}},
	{"Minor (Aeolion)", {0, 2, 3, 5, 7, 8, 10}},
	{"Harmonic Minor", {0, 2, 3, 5, 7, 8, 11}},
	{"Melodic Minor", {0, 2, 3, 5, 7, 9, 11}},
	{"Major Pentatonic", {0, 2, 4, 7, 9}},
	{"Minor Pentatonic", {0, 3, 5, 7, 10}},
	{"Dorian (D)", {0, 2, 3, 5, 7, 9, 10}},
	{"Phrygian (E)", {0, 1, 3, 5, 7, 8, 10}},
	{"Lydian (F)", {0, 2, 4, 6, 7, 9, 11}},
	{"Mixolydian (G)", {0, 2, 4, 5, 7, 9, 10}},
	{"Locrian (B)", {0, 1, 3, 5, 6, 8, 10}},
	{"Whole Tone", {0, 2, 4, 6, 8, 10}},
	{"1/2 Tone 1 Tone", {0, 1, 3, 4, 6, 7, 9, 10}},
	{"1 Tone 1/2 Tone", {0, 2, 3, 5, 6, 8, 9, 11}},
	{"Altered", {0, 2, 4, 6, 8, 10, 10}},
	{"Hungarian", {0, 2, 3, 6, 7, 8, 10}},
	{"Phrygish", {0, 1, 4, 5, 7, 8, 10}},
	{"Arabic", {0, 1, 4, 5, 7, 8, 11}},
	{"Persian", {0, 1, 4, 5, 7, 10, 11}},
	{"Acoustic (Lydian b7)", {0, 2, 4, 6, 7, 9, 10}},
	{"Harmonic Major", {0, 2, 4, 5, 7, 8, 11}},
}
scaleNames = {}
for i = 1, table.getn(scales) do
    scaleNames[i] = scales[i][1]
    table.insert(scales[i][2], 12) -- Simplify preset loading
end

function nearest(i, a, b)
    if (math.abs(i - a) <= math.abs(i - b)) then
        return a
    else
        return b
    end
end

function loadScale(scale)
    for i = 1, table.getn(scale) - 1 do
        for j = scale[i], scale[i+1] - 1 do
            keysNumBox[j+1]:setValue(nearest(j, scale[i], scale[i+1]))
        end
    end
end

local scaleMenu = Menu{"Scale", scaleNames, showLabel = false, width = rootKey.width, height = rootKey.height, x = rootKey.x, y = 24}
scaleMenu.changed = function(self)
    loadScale(scales[self.value][2])
end
scaleMenu.changed(scaleMenu) -- Refresh at first time

function onNote(e)
    degree = (e.note - (rootKey.value - 1) + 12) % 12
    if (keysButton[degree + 1].value) then
        baseNote = e.note - degree
        playNote(baseNote + keysNumBox[degree + 1].value, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
    end
end

function onRelease(e)
end

-- NOEXPORT

privateSave = Button("Private_Save", false)
privateSave.changed = function(self)
    local out = "{\""..tostring(scales[scaleMenu.value][1]).."\",{"
        local first
        for i = 1, 12 do
            if first then
                out = out..","
            else
                first = true
            end
            if (keysButton[i].value) then
                out = out..tostring(keysNumBox[i].value)
            else
                out = out.."nil"
            end
        end
    out = out.."}},"
    print (out)
end


-- privateSave = Button("left", false)
-- privateSave = Button("right", false)
-- privateSave = Button("random", false)
