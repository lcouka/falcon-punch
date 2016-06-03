--------------------------------------------------------------------------------
--! Bass Extractor
--! Only play the lowest note
--! Author : Louis Couka
--! Date : 18/12/2015
--------------------------------------------------------------------------------

Label{"Bass Extractor : Only play the lowest note", align = "centred", width = 710}

local allEvents = {} -- Sorted by note
local eventPlaying
local idPlaying

function playVoice()
    local len = table.getn(allEvents)
    if (len == 0) then 
        releaseVoice(idPlaying)
    else -- Play
        if (idPlaying ~= allEvents[1].id) then
            eventPlaying = allEvents[1]
            idPlayingLast = idPlaying
            idPlaying = postEvent(eventPlaying)
            releaseVoice(idPlayingLast)
        end
    end
end

function onNote(e)
    insert = true
    for i, event in ipairs(allEvents) do
        if (e.note < event.note) then
            table.insert(allEvents, i, e)
            insert = false
            break
        end
    end
    if insert then table.insert(allEvents, e) end
    playVoice()
end

local sustain = false
local onReleaseStack = {} 
function onRelease(e)
    if (sustain) then
        table.insert(onReleaseStack, e) -- Stack release events when cc64
    else
        for i, event in ipairs(allEvents) do
            if (e.note == event.note) then -- doesn't work with id :( ?
                table.remove(allEvents, i)
                break
            end
        end
        playVoice()
    end
end

function onController(e)
	if e.controller == 64 then -- Note that cc64 will be filtered, which is not really desired.
        sustain = e.value > 64
        if not sustain then
            for i, event in ipairs(onReleaseStack) do
                onRelease(event)
            end
            onReleaseStack = {}
        end
    else
		postEvent(e)
    end
end