--------------------------------------------------------------------------------
--! Fix Overlaps
--! Kill identical notes interlacing
--! Author : Louis Couka
--! Date : 01/03/2016
--! Version 1.0b
--------------------------------------------------------------------------------

Label{"Fix Overlaps : Kill identical notes that are played at the same time", align = "centred", width = 710}

idNote = {}
isNotePlaying = {}
for i = 1, 128 do
   isNotePlaying[i] = 0
end

function onNote(e)
    i = e.note + 1
    releaseVoice(idNote[i])
    idNote[i] = postEvent(e)
    isNotePlaying[i] = isNotePlaying[i] + 1
end

function onRelease(e)
    i = e.note + 1
    if (isNotePlaying[i] > 0) then
        isNotePlaying[i] = isNotePlaying[i] - 1
    end
    if (isNotePlaying[i] == 0) then
        releaseVoice(idNote[i])
    end
end