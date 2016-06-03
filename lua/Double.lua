--------------------------------------------------------------------------------
--! Double
--! Author : Louis Couka
--! Date : 19/05/2016
--------------------------------------------------------------------------------

lag = Knob("Lag", 0, 0, 200, false)
pan = Knob{"Pan", 0, -1, 1, false, displayName = "Pan Spread"}

function onNote(e)
    playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan - pan.value, e.tune, e.slice)
    wait(lag.value)
    playNote(e.note + 12, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan + pan.value, e.tune, e.slice)
end

function onRelease(e)
end