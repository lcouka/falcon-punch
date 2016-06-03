--------------------------------------------------------------------------------
--! Transpose
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

local MIN_TIME = 5

time = Knob("Time", 500, MIN_TIME, 3000, false)
randomize = Knob("Randomize", 0, 0, 1, false)
noteDuration = Knob{"Note_Duration", 0.8, 0, 10, false, displayName = "Note Dur."}
mode = Menu{"Multiple_Notes", {"Free", "Link", "Random Arp"}, displayName = "Multiple Notes"}

isEventPlaying = {}

function getTimeVal()
    return time.value + (time.value - MIN_TIME) * randomize.value*(math.random() * 2 - 1)
end

-- MODE FREE

function free(e)
    while isEventPlaying[e.id] do
        local timeVal = getTimeVal()
        playNote(e.note, e.velocity, noteDuration.value * timeVal, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
        wait(timeVal)
    end
end

-- MODE LINK

local linkLaunched
local timeFoo
function link()
    local active = true
    while active do
        active = false
        local timeVal = getTimeVal()
        timeFoo = getTime() + noteDuration.value * timeVal
        for k, e in pairs(isEventPlaying) do
            playNote(e.note, e.velocity, noteDuration.value * timeVal, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
            active = true
        end
        if active then
            wait(timeVal)
        end
    end
    timeFoo = nil
    linkLaunched = false
end

-- MODE ARP

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
local arpLaunched
function arp()
    while true do
        len = tableLength(isEventPlaying)
        if (len == 0) then break end
        
        randomI = math.random(1, len) 
        local timeVal = getTimeVal()
        local i = 1
        for k, e in pairs(isEventPlaying) do
            if (i == randomI) then
                playNote(e.note, e.velocity, noteDuration.value * timeVal, e.layer, e.channel, e.input, e.vol, e.pan, e.tune, e.slice)
                wait(timeVal)
                break
            end
            i = i + 1
        end
    end
    timeFoo = nil
    arpLaunched = false
end

-- CALLBACKS

local idsPlaying
function onNote(e)
    isEventPlaying[e.id] = e
    if (mode.value == 1) then
        run(free, e)
    elseif (mode.value == 2) then
        if linkLaunched then
            if (timeFoo) then -- Not sure it is thread safe or what
                local timeVal = timeFoo - getTime()
                if (timeVal > 0 and timeVal < time.max * 2) then -- Check for coherence
                    playNote(e.note, e.velocity, timeVal)
                end
            end
        else
            linkLaunched = true
            run(link, e)
        end
    else--if (mode.value == 3) then
        if not arpLaunched then
            arpLaunched = true
            run(arp, e)
        end
    end
end

function onRelease(e)
    isEventPlaying[e.id] = nil
end