-- NOEXPORT
function onNote(e)
    playNote(e.note, e.velocity, -1, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
end

function onRelease(e)
end