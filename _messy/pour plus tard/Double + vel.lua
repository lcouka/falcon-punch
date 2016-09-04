-- From Falcon Punch 1.0
-- Visit my website for updates at : http://louiscouka.com/

--------------------------------------------------------------------------------
--! Double
--! Author : Louis Couka
--! Date : 19/05/2016
--------------------------------------------------------------------------------

lag = Knob("Lag", 0, 0, 200, false)
pan = Knob{"Pan", 0, -1, 1, false, displayName = "Pan Spread"}
velocity = Knob{"Velocity", 1, 0, 1, false}

function onNote(e)
    playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan - pan.value, e.tune, e.slice)
    wait(lag.value)
    playNote(e.note, e.velocity * velocity.value, -1, e.layer, e.channel, e.input, e.vol, e.pan + pan.value, e.tune, e.slice)
end

function onRelease(e)
end