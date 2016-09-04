--------------------------------------------------------------------------------
--! Legato Hack Out
--! Author : Louis Couka
--! Date : 05/03/2015
--------------------------------------------------------------------------------

killPortamento = OnOffButton{"Kill_Portamento", displayName = "Kill Portamento When Retrigger", width = 180}

local idPlaying
local playGhost = false
function onNote(e)
    if playGhost then
        if not killPortamento.value then
            playNote(e)
            idPlaying = playNote(e.note, 80, 0, nil, nil, nil, 0)
        else
            idPlaying = playNote(e.note, 80, 0, nil, nil, nil, 0)
            playNote(e)
        end
        playGhost = false
    else
        playNote(e)
    end
end

function onRelease(e)
end

function onController(e)
    if (e.controller == 49 and e.value <= 1) then
        if (e.value == 1) then
            playGhost = true
        else
            releaseVoice(idPlaying)
        end
    else
        postEvent(e)
    end
end