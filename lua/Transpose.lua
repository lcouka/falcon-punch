--------------------------------------------------------------------------------
--! Transpose
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

transpose = Knob("Transpose", 0, -48, 48, true)

function onNote(e)
    playNote(e.note + transpose.value, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
end

function onRelease(e)
end