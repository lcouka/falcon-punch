--------------------------------------------------------------------------------
--! Note Single
--! Author : Louis Couka
--! Date : 26/05/2016
--------------------------------------------------------------------------------


local KEY = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
function formatNote(value)
    local chroma = value % 12
    return tostring(value).." ("..KEY[chroma + 1]..tostring((value - chroma) / 12 - 2)..")"
end

note = Knob("Note", 60, 0, 127, true)
note.changed = function(self)
    self.displayText = formatNote(self.value)
end
note:changed()

function onNote(e)
    playNote(note.value, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
end

function onRelease(e)
end