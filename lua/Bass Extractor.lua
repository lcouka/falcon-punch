--------------------------------------------------------------------------------
--! Extract Bass
--! Only play the lowest note
--! Author : Louis Couka
--! Date : 18/12/2015
--------------------------------------------------------------------------------

Label{"Extract Bass : Only play the lowest note", align = "centred", width = 710}
retrigger = OnOffButton{"Mono_Retrigger", displayName="Mono Retrigger",  x = 305}

local idPlaying
local note = 128
function onNote(e)
    if (e.note < note) then
        if (retrigger.value) then
            releaseVoice(idPlaying)
            idPlaying = postEvent(e)
            note = e.note
        else
            local previousIdPlaying = idPlaying
            idPlaying = postEvent(e)
            note = e.note
            releaseVoice(previousIdPlaying)
        end
    end
end

function onRelease(e)
    if (idPlaying == e.id) then note = 128 end
    postEvent(e)
end