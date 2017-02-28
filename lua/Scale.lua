--------------------------------------------------------------------------------
--! Scale
--! Author : Louis Couka
--! Date : 05/03/2016
--------------------------------------------------------------------------------

local KEY = {"C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"}
local keysButton = {}
for i = 1, 12 do
    keysButton[i] = OnOffButton{"KeyButton_"..tostring(i), true, width = 42 - 3, x = 102 + (i - 1) * 42, y = 5, height = 39}
end

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
end

function loadScale(scale)
    for i = 1, 12 do
        keysButton[i]:setValue(false)
    end
    for i = 1, table.getn(scale) do
        keysButton[scale[i]+1]:setValue(true)
    end
end

local scaleMenu = Menu{"Scale", scaleNames, showLabel = false, width = rootKey.width, height = rootKey.height, x = rootKey.x, y = 24, persistent = false}
scaleMenu.changed = function(self)
    loadScale(scales[self.value][2])
end
scaleMenu.changed(scaleMenu)


Label{"Key Priority", align = "centred", x = 602, y = 3, width = 110}
local priorityDown = OnOffButton{"Down", x = 606, y = 24, width = 55, height = 20}
local priorityUp = OnOffButton{"Up", x = 660, y = 24, width = 55, height = 20}
priorityDown.changed = function(self)
    priorityDown:setValue(true, false)
    priorityUp:setValue(false, false)
    priorityValue = -1
end
priorityUp.changed = function(self)
    priorityUp:setValue(true, false)
    priorityDown:setValue(false, false)
    priorityValue = 1
end
priorityDown:setValue(true, true)

function onNote(e)
    degree = (e.note - (rootKey.value - 1) + 12) % 12
    degreeDeviation = 0
    while (true) do
        if (keysButton[(degree + degreeDeviation + 12) % 12 + 1].value) then break end
        degreeDeviation = - degreeDeviation
        if (keysButton[(degree + degreeDeviation + 12) % 12 + 1].value) then break end
        degreeDeviation = priorityValue - degreeDeviation
        if (degreeDeviation == priorityValue * 7) then -- no button
            degreeDeviation = 0
            break
        end
    end
    playNote(e.note + degreeDeviation, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
end

function onRelease(e)
end

-- NOEXPORT

privateSave = Button("Private_Save", false)
privateSave.changed = function(self)
    local out = "{\""..tostring(scales[scaleMenu.value][1]).."\",{"
        local first
        for i = 1, 12 do
            if(keysButton[i].value) then
                if first then out = out.."," else first = true end
                out = out..tostring(i-1)
                end
        end
    out = out.."}},"
    print (out)
end
