--------------------------------------------------------------------------------
--! Mono
--! Only play the lastest note
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

Label{"Mono : Only play the lastest note", align = "centred", width = 710}
retrigger = OnOffButton{"Mono_Retrigger", displayName="Mono Retrigger",  x = 305}

local idPlaying
function onNote(e)
    if (retrigger.value) then
        releaseVoice(idPlaying)
        idPlaying = postEvent(e)
    else
        local previousIdPlaying = idPlaying
        idPlaying = postEvent(e)
        releaseVoice(previousIdPlaying)
    end
end