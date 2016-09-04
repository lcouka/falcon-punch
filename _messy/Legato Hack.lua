--------------------------------------------------------------------------------
--! Legato Hack
--! Bla bla
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

desc = Label("Legato Hack")
desc.align = "centred"
desc.width = 710

local isPlaying = 0
local idPlaying = nil
function onNote(e)
    playNote(e.note, e.velocity)
    isPlaying = isPlaying + 1
    if not idPlaying then
        idPlaying = playNote(50, 100, 0)
    end
end

function onRelease(e)
    if (isPlaying > 0) then
        isPlaying = isPlaying - 1
    end
    if (idPlaying and isPlaying == 0) then
        releaseVoice(idPlaying)
        idPlaying = nil
    end
end