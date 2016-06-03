--------------------------------------------------------------------------------
--! Mono Group
--! Only play the lastest note
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

require "Piano"

local min

retrigger = OnOffButton{"Mono_Retrigger", false, displayName="Mono Retrigger", x = 5, y = 75}
rangeWrite = OnOffButton{"Write_Range", false, displayName="Write Range", backgroundColourOn = ("#f11a1a"), x = 605, y = 75}
rangeWrite.changed = function(self)
    if (self.value) then
        min = nil
        self.displayName="Write Range (Min)"
    else
        self.displayName="Write Range"
    end
end

piano = Piano.create("Key")
piano:setY(5)

for i = 1, piano.numberKeys do
    piano.keyButtons[i].changed = function(self)
        if rangeWrite.value then
            if not min then
                piano.keyButtons[i]:setValue(true,false) -- force
                min = i
                rangeWrite.displayName="Write Range (Max)"
            else
                min2 = math.min(min, i)
                max2 = math.max(min, i)
                for j = min2, max2 do
                    piano.keyButtons[j]:setValue(true)
                end
                rangeWrite:setValue(false)
            end
        end
    end
end

local idPlaying
function onNote(e)
    if (e.note < piano.numberKeys and piano.keyButtons[e.note+1].value) then
        if (retrigger.value) then
            releaseVoice(idPlaying)
            idPlaying = playNote(e)
        else
            local previousIdPlaying = idPlaying
            idPlaying = playNote(e)
            releaseVoice(previousIdPlaying)
        end
    else
        playNote(e)
    end
    piano:onNote(e.note)
end

function onRelease(e)
    piano:onRelease(e.note)
end