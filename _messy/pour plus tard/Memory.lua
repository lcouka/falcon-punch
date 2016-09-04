--------------------------------------------------------------------------------
--! Mono
--! Only play the lastest note
--! Author : Louis Couka
--! Date : 29/02/2016
--------------------------------------------------------------------------------

local SIZE = 4 -- Should be pair, should have enough chords
local BUTTON_SIZE = 50
local CHEAT = false
local VELOCITY = 75

--------------------------------------------------------------------- Game State

local pairsDone
local score
local left
local level
local finish
local currentPressed

--------------------------------------------------------------------- Midi Stuff
function onNote(e)
    playNote(e)
end

function playNoteFromUI(note_, vel, dur)
    local id = postEvent({type=Event.NoteOn, note=note_, velocity=vel})
    wait(dur)
    releaseVoice(id)
end

local chords
function playChords(chordIndex, dur, strum)
    chord = chords[chordIndex]
    for i = 1, table.getn(chord) do
        run(playNoteFromUI, chord[i], VELOCITY, dur)
        wait(strum)
    end
end

local buttonsChord = {}
for i = 1, SIZE do
    buttonsChord[i] = {}
end

--------------------------------------------------------------------- Board
function updateInfos()
    scoreLabel.text = "Score: "..tostring(score)
    leftLabel.text = "Left: "..tostring(left)
    levelLabel.text = "Level: "..tostring(level+1)
    if pairsDone == SIZE * SIZE / 2 then
        win()
    elseif left == 0 then
        lose()
    elseif left < 9 then
        leftLabel.textColour = "red"
    else
        leftLabel.textColour = "orange"
    end
end

buttons = {}
local OFFSET_X = 360 - BUTTON_SIZE * SIZE / 2
for i = 1, SIZE do
    buttons[i] = {}
    for j = 1, SIZE do
        buttons[i][j] = Button("Chord")
        buttons[i][j].width = BUTTON_SIZE + 1
        buttons[i][j].height = BUTTON_SIZE + 1
        buttons[i][j].x = OFFSET_X + (i - 1) * BUTTON_SIZE
        buttons[i][j].y = 9 + (j - 1) * BUTTON_SIZE
        buttons[i][j].backgroundColourOn = "darkgrey"
        buttons[i][j].changed = function(self)
            if not seedDone then
                setupSeed()
                setup_()
                seedDone = true
            end
            left = left - 1
            score = score - 1
            if (not currentPressed) then
                buttons[i][j].backgroundColourOff = "green" -- first move color
                buttons[i][j].enabled = false
                currentPressed = {x = i, y = j}
            else
                if (buttonsChord[i][j] == buttonsChord[currentPressed.x][currentPressed.y]) then -- good
                    score = score + 10
                    pairsDone = pairsDone + 1
                    buttons[currentPressed.x][currentPressed.y].backgroundColourOff = "green"
                    buttons[i][j].backgroundColourOff = "green"
                    buttons[i][j].enabled = false
                else -- wrong
                    buttons[currentPressed.x][currentPressed.y].backgroundColourOff = "darkgrey" -- already visited color
                    buttons[currentPressed.x][currentPressed.y].enabled = true
                    buttons[i][j].backgroundColourOff = "darkgrey" -- already visited color
                end
                currentPressed = nil
            end
            updateInfos()
            if not finish then
                if level == 2 then
                    run(playChords, buttonsChord[i][j], 170, 170)
                else
                    run(playChords, buttonsChord[i][j], 600, 0)
                end
            end
        end
        buttons[i][j].displayName = tostring(" ")
    end
end

--------------------------------------------------------------------- Widgets

scoreLabel = Label("Score")
scoreLabel.width = 100
scoreLabel.height = 40
scoreLabel.x = 718 - scoreLabel.width
scoreLabel.y = 14 + BUTTON_SIZE * SIZE - scoreLabel.height - 20
scoreLabel.align = "bottomRight"

leftLabel = Label("Level")
leftLabel.width = scoreLabel.width
leftLabel.height = scoreLabel.height
leftLabel.x = scoreLabel.x
leftLabel.y = scoreLabel.y + 20
leftLabel.align = scoreLabel.align

levelLabel = Label("Level")
levelLabel.width = scoreLabel.width
levelLabel.height = scoreLabel.height
levelLabel.x = 5
levelLabel.y = leftLabel.y
levelLabel.align = "bottomLeft"

finalLabel = Label("Final")
finalLabel.width = 720
finalLabel.height = 9 + BUTTON_SIZE * SIZE
finalLabel.align = "centred"
finalLabel.fontSize = 150

resetButton = Button("Reset")
resetButton.width = scoreLabel.width - 50
resetButton.height = 20
resetButton.x = scoreLabel.x + 46
resetButton.y = scoreLabel.y
resetButton.changed = function(self) setup() end

continueButton = Button("Continue")
continueButton.x = 305
continueButton.y = 9 + BUTTON_SIZE * SIZE / 2 + 27
continueButton.changed = function(self) setup() end

--------------------------------------------------------------------- WIN Animation
function colorShake()
    local colors = {"orange", "red", "orange", "yellow"}
    local i = 0
    while (finalLabel.visible) do
        finalLabel.textColour = colors[i + 1]
        wait(150)
        i = (i + 1) % table.getn(colors)
    end
    finalLabel.textColour = "white"
end

local DELAY_SYNC = 60
function playWinChord(i, i2, dur)
        buttons[place[i2].x][place[i2].y].backgroundColourOff = "yellow"
        wait(DELAY_SYNC)
        run(playChords, i, dur, 0)
        wait(dur - DELAY_SYNC)
        buttons[place[i2].x][place[i2].y].backgroundColourOff = "green"
end

function fiestaPad()
    local i = 1
    local j = 1
    local i2 = 3
    local j2 = 2
    while (finish) do
        i = i + 1
        if (i > SIZE) then
            i = 1
            j = j % SIZE + 1
        end
        
        i2 = i2 + 1
        if (i2 > SIZE) then
            i2 = 1
            j2 = j2 % SIZE + 1
        end
        
        buttons[i2][j2].backgroundColourOff = "yellow"
        buttons[i][j].backgroundColourOff = "green"
        
        wait(80)
    end
end

function playWin()
    if (level == 2 ) then
        finalLabel.fontSize = 100
        finalLabel.visible = true
        finalLabel.text = "You Win\nScore: "..tostring(score)
        run(colorShake)
        run(fiestaPad)
    
        local melody = {48,60,55,69,60,64,64,64,67,71,72,81,53,77,60,74,65,76,69,61,72,80,77,79,50,89,57,76,62,87,65,75,69,77,74,92,55,74,62,85,67,76,71,70,74,83,79,101,52,88,60,68,64,78,67,73,72,80,76,97,53,92,60,87,65,87,69,76,72,93,77,109,55,94,62,91,67,89,71,79,74,90,79,101,60,90,67,78,72,93,76,81,79,98,84,109}
        for i = 1, table.getn(melody) - 2, 2 do
            playNoteFromUI(melody[i], melody[i + 1], VELOCITY)
        end
        playNoteFromUI(melody[table.getn(melody) - 1], melody[table.getn(melody)],800)
    else
        place = {}
        for k = 1, SIZE*SIZE/2 do
            for i = 1, SIZE do
                for j = 1, SIZE do
                    if (buttonsChord[i][j] == k) then
                        place[table.getn(place) + 1] = {x = i, y = j}
                    end
                end
            end
        end
        
        for i = 1, table.getn(chords) do
            playWinChord(i, i*2 - 1, 250)
            playWinChord(i, i*2, 250)
        end
        playWinChord(1, 1, 700)
        
        scoreSaved = score
        level = level + 1
        sendChange()
        
        continueButton.displayName = "Try Next"
        continueButton.visible = true
        finalLabel.fontSize = 50
        finalLabel.visible = true
        run(colorShake)
    end
end
-- local str = ""
-- function onNote(e)
--     str = str..tostring(e.note)..","..tostring(e.velocity)..","
--     print(str)
--     playNote(e)
-- end

function win()
    finish = true
    finalLabel.text = "You win"
    resetButton.visible = false
    run(playWin)
end

--------------------------------------------------------------------- LOOSE Animation

function lose()
    finish = true
    finalLabel.fontSize = 50
    finalLabel.text = "You lose"
    finalLabel.visible = true
    continueButton.displayName = "Retry"
    continueButton.visible = true
    resetButton.visible = false
    for i = 0, 20 do -- play a cluster
        run(playNoteFromUI,40 + i, VELOCITY - 30, 500)
    end
end

--------------------------------------------------------------------- Setup

local function shuffleTable( t )
    local rand = math.random 
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function Output(ttable)
    -- output values
    sout = {}
    for _, v in ipairs(ttable) do
        table.insert(sout, v) ;
    end
    table.insert(chords,sout)
end
function Permutation(ttable, n)
    if n == 0 then
        Output(ttable)
    else
        for i = 1, n do
            ttable[n], ttable[i] = ttable[i], ttable[n]
            Permutation(ttable, n - 1)
            ttable[n], ttable[i] = ttable[i], ttable[n]
        end
    end
end

function setup()
    score = scoreSaved
    finish = false
    pairsDone = 0
    
    continueButton.visible = false
    resetButton.visible = true
    finalLabel.visible = false
    
    if (level == 0) then
        left = 30
        chords = {{60},{64},{72},{69},{62},{65},{71},{67},} 
    elseif (level == 1) then
        left = 30
        -- {"Unnamed",{49,56,65,68,73},{50,50,54,61,66,70,73},{51,51,53,61,65,68,73},{52,61,64,68,75},{53,51,53,61,66,70,77},{54,61,66,70,73},{55,55,56,63,66,69,72,75},{56,44,54,56,60,63,68}}, 
        chords = {{48,55,64,67,72},{53,60,65,69,72},{52,60,64,67,72},{51,60,63,67,74},{50,60,65,69,76},{53,60,67,69,72},{55,62,65,68,71,74},{43,53,59,62,67},} 
    else
        left = 30
        chords = {}
        Permutation({60, 64, 67, 72}, 4)
    end 
    
    updateInfos()
    
    for i = 1, SIZE do
        for j = 1, SIZE do
            buttons[i][j].backgroundColourOff = "darkgrey"
            buttons[i][j].enabled = true
        end
    end
    
    setup_()
end

-- Split setup func because we need to set the seed in UI thread
function setup_()
    -- Random pick from our chord list
    local chordsChoosen = {}
    for i = 1, SIZE * SIZE, 2 do
        local isUnique
        local pick
        while not isUnique do
            isUnique = true
            pick = math.random(1,table.getn(chords))
            for k = 1, table.getn(chordsChoosen), 2 do
                if (chordsChoosen[k] == pick) then
                    isUnique = false
                    break
                end
            end
        end
        chordsChoosen[i] = pick
        chordsChoosen[i+1] = pick
    end

    -- Shuffle
    shuffleTable(chordsChoosen)
    
    -- Stock in a matrice for easier manipulation
    for i = 1, SIZE do
        for j = 1, SIZE do
            buttonsChord[i][j] = chordsChoosen[i + (j-1) * SIZE]
            if (CHEAT) then
                buttons[i][j].displayName = tostring(buttonsChord[i][j])
            end
        end
    end

    currentPressed = nil
end

local seedDone
function setupSeed()
    math.randomseed(math.floor(getTime() * 1000000000))
    seedDone = true
end

scoreSaved = 30
level = 0
setup()

-- SERIALIZE
dummy = OnOffButton{"Dummy", visible = false, y = 0}
function sendChange()
    dummy.value = not dummy.value
end

function onSave()
  return {level, scoreSaved}
end

function onLoad(data)
    print(data[1])
    level = data[1]
    scoreSaved = data[2]
    setup()
end

makePerformanceView()