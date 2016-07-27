--------------------------------------------------------------------------------
--! Analyzer
--! Note to chords wrapping
--! Author : Louis Couka
--! Date : 25/02/2016
--------------------------------------------------------------------------------

require "Piano"

-------------------------------------------------------------------------------- PIANO WIDGETS

piano = Piano.create("Key")
piano:setClickable(false)
piano:setY(5)

-------------------------------------------------------------------------------- LABELS

l = {}
for i = 1, 11 do
    l[i] = Label("")
    l[i].text = tostring(i - 3)
    l[i].align = "centred"
    l[i].width = 18
    l[i].x = 11 + (i - 1) * 70 - l[i].width / 2
    l[i].y = 48
    l[i].textColour = "#333333"
    l[i].fontSize = 12
end

-------------------------------------------------------------------------------- EVENT CALLBACKS

local KEY = {"C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "}
function formatNote(value)
    local chroma = value % 12
    return KEY[chroma + 1]..tostring((value - chroma) / 12 - 2)
end

function onNote(e)
    playNote(e)
    piano:onNote(e.note)
    print("Note "..tostring(e.note).." ("..formatNote(e.note)..") ".." Vel "..tostring(e.velocity))
end

function onRelease(e)
    piano:onRelease(e.note)
end

function onController(e)
    print("CC "..tostring(e.controller).."         "..tostring(e.value))
    postEvent(e)
end