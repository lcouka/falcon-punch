--------------------------------------------------------------------------------
--! Legato Hack In
--! Author : Louis Couka
--! Date : 05/03/2015
--------------------------------------------------------------------------------

desc = Label("Legato Hack : Sandwish an Arp or whatever sequential and use legato mode for automation drawing (only works with polyphonic modes)")
desc.align = "centred"
desc.width = 710

local notesPlaying = 0
function onNote(e)
    if notesPlaying == 0 then
        controlChange(49, 1)
    end
    notesPlaying = notesPlaying + 1
    playNote(e)
end

function onRelease(e)
    if (notesPlaying > 0) then
        notesPlaying = notesPlaying - 1
    end
    if notesPlaying == 0 then
        controlChange(49, 0)
    end
end

function onController(e)
    if not(e.controller == 49 and e.value <= 1) then
		postEvent(e)
	end
end