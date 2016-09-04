--------------------------------------------------------------------------------
--! Release Trigger
--! Author : Louis Couka
--! Date : 09/08/2016
--------------------------------------------------------------------------------

Label{"Release Trigger : Play note on release", align = "centred", width = 710}
noteDuration = Knob{"Note_Duration", 1000, 0, 2000, true, displayName = "Note Dur.", y = 5}
noteDuration.changed = function(self)
    self.displayText = self.value == 2000 and "Max" or tostring(self.value).." ms"
end
noteDuration.changed(noteDuration)

onNoteEvents = {}

function onNote(e)
    onNoteEvents[e.id] = e
end

function onRelease(e)
    e0 = onNoteEvents[e.id]
    if e0 then
        playNote(e0.note, e0.velocity, noteDuration.value == 2000 and -1 or noteDuration.value, e0.layer, e0.channel, e0.input, e0.vol, e0.pan, e0.tune, e0.slice)
        onNoteEvents[e.id] = nil
    end
end