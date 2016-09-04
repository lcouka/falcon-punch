--------------------------------------------------------------------------------
--! Key Color
--! only for UI purpose
--! Author : Louis Couka
--! Date : 27/07/2016
--------------------------------------------------------------------------------

require "Piano"

local min

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

colorsHex = {"#0266C8", "#F90101", "#F2B50F", "#00933B"}

color = 1
colorButtons = {}
for i = 1, 4 do
    colorButtons[i] = OnOffButton{"c"..tostring(i), false, backgroundColourOff = (colorsHex[i]), backgroundColourOn = (colorsHex[i]), width = 20, height = 20, x = i * 25 - 20, y = 75}
    colorButtons[i].changed = function(self)
        self:setValue(false, false) -- TODO, when Button bug will be fixed by UVI, change OnOffButton by Button and remove this line
        color = i
        for i = 1, 4 do
            if i == color then
                colorButtons[i].displayName = "."
            else
                colorButtons[i].displayName = " "
            end 
        end 
    end
end
colorButtons[1].changed(colorButtons[1])

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
        if piano.keyButtons[i].value then
            setKeyColour(i - 1, colorsHex[color])
        else
            setKeyColour(i - 1, "")
        end            
    end
end