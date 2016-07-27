--------------------------------------------------------------------------------
--! Note Range
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------


local KEY = {"C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"}
function formatNote(value)
    local chroma = value % 12
    return tostring(value).." ("..KEY[chroma + 1]..tostring((value - chroma) / 12 - 2)..")"
end

mode = Menu("Mode", {"Note Off", "Nearest octave", "Repeat range", "Limit"})
min = Knob("Min", 0, 0, 127, true)
max = Knob("Max", 127, 0, 127, true)
min.changed = function(self)
    self.displayText = formatNote(self.value)
end
max.changed = min.changed
min:changed()
max:changed()

function onNote(e)
    local note
    if (mode.value == 1) then
        if (e.note >= min.value and e.note <= max.value) then
            playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
        end
    else
        if (mode.value == 2) then
            note = e.note
            while (note > max.value) do
                note = note - 12
            end
            while  (note < min.value) do
                note = note + 12
            end
        elseif (mode.value == 3) then
            local diff = max.value - min.value + 1
            if (diff > 0) then
                note = e.note
                if (note > max.value) then
                    note = note - diff
                end
                if  (note < min.value) then
                    note = note + diff
                end
            else
                note = min.value
            end
        else
            if (e.note < min.value) then
                note = min.value
            elseif (e.note > max.value) then
                note = max.value
            else
                note = e.note
            end
        end
        playNote(note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
    end
end

function onRelease(e)
end