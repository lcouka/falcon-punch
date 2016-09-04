--------------------------------------------------------------------------------
--! Mono Bass
--! Only play the lowest note
--! Author : Louis Couka
--! Date : 18/12/2015
--------------------------------------------------------------------------------

indexLabel = Label{"Index", x = 5, width = 45}
index = NumBox{"index", 1, 1, 99, true, displayName = "Index", x = 45, width = 20, showLabel = false}
fromLabel = Label{"From", x = 75, y = 5, width = 40}
from = Menu{"From", {"Bass", "High"}, x = 115, width = 50, showLabel = false, height = 20}
exceedLabel = Label{"If Exceed", x = 175, width = 70}
exceed = Menu{"If_Exceed", {"Note Off", "Limit Index"},  x = 236, width = 85, showLabel = false, height = 20}

local allEvents = {} -- Sorted by note
local eventPlaying
local idPlaying

function playVoice()
    local len = table.getn(allEvents)
    if (len == 0 or (exceed.value == 1 and len < index.value)) then 
        releaseVoice(idPlaying)
    else -- Play
        local indexChoosen = math.min(len, index.value)
        if (from.value == 2) then indexChoosen = len - indexChoosen + 1 end
        if (indexChoosen and idPlaying ~= allEvents[indexChoosen].id) then
            eventPlaying = allEvents[indexChoosen]
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
    print(table.getn(allEvents))
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