-- NOEXPORT
-------------------------------------------------------------------------------- PIANO CLASS

Piano = {}
Piano.__index = Piano

function Piano:refreshColour(i)
    local colourOff
    local colourOn
    if (isWhite(i-1)) then
        if (self.isNotePlaying[i] > 0) then
            if (self.colourOff[i] == 0) then
                colourOff = "#999999"
            else
                colourOff = "#00bb00"
            end
            colourOn = "#bb0000"
        else
            if (self.colourOff[i] == 0) then
                colourOff = "#ffffff"
            else
                colourOff = "#00ff00"
            end
            colourOn = "#ff0000"
        end
    else
        if (self.isNotePlaying[i] > 0) then
            if (self.colourOff[i] == 0) then
                colourOff = "#000000"
            else
                colourOff = "#009900"
            end
            colourOn = "#990000"
        else
            if (self.colourOff[i] == 0) then
                colourOff = "#444444"
            else
                colourOff = "#00dd00"
            end
            colourOn = "#dd0000"
        end
    end
    self.keyButtons[i].backgroundColourOff = colourOff
    self.keyButtons[i].backgroundColourOn = colourOn
end

function Piano.create(name)
    local piano = {} -- our new object
    setmetatable(piano,Piano) -- make Piano handle lookup
    piano.name = name
    piano.keyButtons = {}
    
    -- Gui Position
    piano.y = 5
    local KEYBOARD_LEFT = 5
    local KEY_WIDTH = 11
    local KEY_BLACK_WIDTH = 6
    local KEY_HEIGHT = 60
    local KEY_BLACK_HEIGHT = 39
    piano.numberKeys = 121
    local FIRST_KEY = 0 -- C-2
    local FIRST_KEY_RANGE = -2
   
    piano.isNotePlaying = {}
    piano.colourOff = {}
    for i = 1,piano.numberKeys do
        piano.isNotePlaying[i] = 0
        piano.colourOff[i] = 0 -- 0 : normal ; 1 : green
    end
  
    -- White Keys
    local note = 0
    local xPos = KEYBOARD_LEFT
    while (note < piano.numberKeys) do
        chroma = note % 12
        i = note + 1
        piano.keyButtons[i] = OnOffButton(name.."_"..tostring(note))
        piano.keyButtons[i].displayName = " "
        piano.keyButtons[i].x = xPos
        piano.keyButtons[i].y = piano.y
        piano.keyButtons[i].width = KEY_WIDTH
        piano.keyButtons[i].height = KEY_HEIGHT
        piano:refreshColour(i)
        if (chroma ~= 4 and chroma ~= 11) then -- E/F and B/C break
            note = note + 2
        else
            note = note + 1
        end
        xPos = xPos + KEY_WIDTH - 1
    end

    -- Black Keys
    local note = 1
    local xPos = KEYBOARD_LEFT + KEY_WIDTH - KEY_BLACK_WIDTH / 2
    while (note < piano.numberKeys) do -- Black
        chroma = note % 12
        i = note + 1
        piano.keyButtons[i] = OnOffButton(name.."_"..tostring(note))
        piano.keyButtons[i].displayName = "1"
        if (chroma == 1 or chroma == 6) then -- Piano asymetries
            piano.keyButtons[i].x = xPos - 1
        elseif (chroma == 10) then
            piano.keyButtons[i].x = xPos + 1
        else
            piano.keyButtons[i].x = xPos
        end
        piano.keyButtons[i].y = piano.y
        piano.keyButtons[i].width = KEY_BLACK_WIDTH
        piano.keyButtons[i].height = KEY_BLACK_HEIGHT
        piano:refreshColour(i)
        if (chroma ~= 3 and chroma ~= 10) then -- E/F and B/C break
            note = note + 2
        else
            note = note + 3
            xPos = xPos + KEY_WIDTH - 1
        end
        xPos = xPos + KEY_WIDTH - 1
    end
    
    piano.stopMouseEventLayer = Label(" ")
    piano.stopMouseEventLayer.x = KEYBOARD_LEFT
    piano.stopMouseEventLayer.y = piano.y
    piano.stopMouseEventLayer.width = 710
    piano.stopMouseEventLayer.height = KEY_HEIGHT
    piano.stopMouseEventLayer.visible = false
    
    return piano
end

function isWhite(note)
    chroma = note % 12
    return chroma ~= 1 and chroma ~= 3 and chroma ~= 6 and chroma ~= 8 and chroma ~= 10
end
    
function Piano:isNoteVisible(note)
    return note < self.numberKeys
end
    
function Piano:setY(y)
    self.y = y
    for i=1, self.numberKeys do
        self.keyButtons[i].y = y
    end
    self.stopMouseEventLayer.y = y
end

function Piano:onNote(note)
    if (note < self.numberKeys) then
        self.isNotePlaying[note+1] = self.isNotePlaying[note+1] + 1
        self:refreshColour(note+1)
    end
end

function Piano:onRelease(note)
    if (note < self.numberKeys and self.isNotePlaying[note+1] > 0) then
        self.isNotePlaying[note+1] = self.isNotePlaying[note+1] - 1
        self:refreshColour(note+1)
    end
end

function Piano:setClickable(isClickable)
    self.stopMouseEventLayer.visible = not isClickable
end

function Piano:setColourOff(i, colourId)
    self.colourOff[i] = colourId
    self:refreshColour(i)
end