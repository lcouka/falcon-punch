--------------------------------------------------------------------------------
--! Delay
--! Author : Louis Couka
--! Date : 23/05/2016
--------------------------------------------------------------------------------

lag = Knob("Lag", 0, 0, 200, false)

function onNote(e)
    wait(lag.value)
    playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
end

function onRelease(e)
end