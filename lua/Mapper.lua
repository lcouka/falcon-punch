--------------------------------------------------------------------------------
--! Velocity Mapper
--! Author : Louis Couka
--! Date : 20/05/2016
--------------------------------------------------------------------------------

WIDGET_SIZE = 128
WIDGET_X = (720 - WIDGET_SIZE)/2
WIDGET_Y = 15

t = Table{"table", 128, 0, 0, 127, false, width = WIDGET_SIZE, height = WIDGET_SIZE, backgroundColour = "#00000000", x = WIDGET_X, y = WIDGET_Y}
t.changed = function(self, index) end

min = Slider{"Min", 0, 0, 127, true, true, height = 128, width = 10, x = WIDGET_X - 12, y = WIDGET_Y, showLabel = false}
min.changed = function(self) refreshTable() end
max = Slider{"Max", 127, 0, 127, true, true, height = 128, width = 10, x = WIDGET_X + WIDGET_SIZE + 1, y = WIDGET_Y, showLabel = false}
max.changed = function(self) refreshTable() end


minX = Slider{"MinX", 0, 0, 127, true, false, width = 128, height = 10, x = WIDGET_X, y = WIDGET_Y + WIDGET_SIZE + 1, showLabel = false}
minX.changed = function(self) refreshTable() end
maxX = Slider{"MaxX", 127, 0, 127, true, false, width = 128, height = 10, x = WIDGET_X, y = WIDGET_Y - 11, showLabel = false}
maxX.changed = function(self) refreshTable() end

curve = Knob{"Curve", 0, -1, 1, false, x = 442, y = 109}
curve.changed = function(self) refreshTable() end

function curveMapper(a, x)
    if a >= 1 then
        return (1-(1-x)^a)^(1/a)
    elseif a < 1 then
        return 1-(1-x^(1/a))^a
    end
end

function refreshTable()
    for i = 0, minX.value do
        t.setValue(t, i+1, min.value, true)
    end
    for i = maxX.value, 127 do
        t.setValue(t, i+1, max.value, true)
    end
    for i = 0, 127 do
        x = minX.value + i * (maxX.value - minX.value) / 127
        y = curveMapper(1.2^(curve.value*10), (i/127)) * 127
        y = min.value + y * (max.value - min.value) / 127
        t.setValue(t, x+1, y, true)
        if (x < 10) then  print(x.." "..t.getValue(t, x + 1)) end
    end
end
refreshTable()

choices = {}
choices[1] = "Velocity"
choices[2] = "Poly Aftertouch"
choices[3] = "Channel Aftertouch"
for i = 0, 128 do
    choices[i+4] = "MIDI CC "..tostring(i)
end
target = Menu{"Target", choices, x = 93, y = 49}

--------------------------------- CALLBACKS

function onNote(e)
    if (target.value == 1) then
        e.velocity = t.getValue(t, e.velocity+1)
    end
    postEvent(e)
end

function onPolyAfterTouch(e)
    if (target.value == 2) then
        e.value = t.getValue(t, e.value+1)
    end
    postEvent(e)
end

function onAfterTouch(e)
    if (target.value == 3) then
        e.value = t.getValue(t, e.value+1)
    end
    postEvent(e)
end

function onController(e)
    if (target.value-4 == e.controller) then
        e.value = t.getValue(t, e.value+1)
    end
    postEvent(e)
end