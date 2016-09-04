--------------------------------------------------------------------------------
-- Chord Recognition
--------------------------------------------------------------------------------

-- TODO complete with missing ninth chords, eleventh chords, thirteenth chords, sus
-- http://jguitar.com/chorddictionary.jsp

ChordRec = {}

ChordRec.triads = 
{
  ["100010010000"] = "M",   -- Major
  ["100010000000"] = "M",   -- Major without 5th
  ["100100010000"] = "m",   -- minor
  ["100100000000"] = "m",   -- minor without 5th
  ["100010001000"] = "aug",   -- augmented
  ["100100100000"] = "dim",   -- diminshed
  ["100010100000"] = "Mb5",   -- Major b5
  ["100101000000"] = "mbb5",   -- minor bb5
}

ChordRec.fourNotesChords = 
{
  ["100010010001"] = "M7",  -- major seventh
  ["100010010010"] = "7",   -- major minor-seventh
  ["100100010010"] = "m7",  -- minor seventh
  
  ["100010000001"] = "M7",  -- major seventh without 5th
  ["100010000010"] = "7",   -- major minor-seventh without 5th
  ["100100000010"] = "m7",  -- minor seventh without 5th
  ["100100010001"] = "mM7", -- minor major seventh
  ["100100000001"] = "mM7", -- minor major seventh without 5th
  ["100100100001"] = "mM7b5", -- minor major seventh b5
  ["100101000001"] = "mM7bb5", -- minor major seventh bb5
  ["100100001001"] = "mM7#5", -- minor major seventh #5
  
  ["100100100010"] = "m7b5",  	-- half-diminished7
  ["100010100010"] = "7b5",  	--  dominant diminished
  ["100100100100"] = "dim7",	-- diminished7
  ["100010001001"] = "M7#5", 	-- augmented major seventh
  ["100010001010"] = "7#5",  	-- augmented seventh
  ["100010100001"] = "M7b5", 	-- diminished major seventh

  -- add 7sus2, M7sus4
}

ChordRec.fifthChords = 
{
  ["100000010000"] = "5",   -- power chord
  --["100000001000"] = "5+",  -- augmented // actually it's a major chord inversion
  ["100000100000"] = "5-",  -- diminished
}

ChordRec.sixthChords = 
{
  ["100010010100"] = "6",  -- Major 6
  ["100100010100"] = "m6", -- Minor 6
}

ChordRec.suspended = 
{
  ["101000010000"] = "sus2",      -- suspended2
  ["100001010000"] = "sus4",      -- suspended4
  ["101001010000"] = "sus2sus4",  -- suspended 2 and 4
  ["101000000000"] = "sus2",      -- suspended2 without 5th
  ["100001000000"] = "sus4",      -- suspended4 without 5th
  ["101001000000"] = "sus2sus4",  -- suspended 2 and 4 without 5th
  --["101000010010"] = "7sus2",     -- suspended2 with 7
  ["101000010001"] = "M7sus2",    -- suspended2 with M7
  ["100001010010"] = "7sus4",     -- suspended4 with 7
  ["100001010001"] = "M7sus4",    -- suspended4 with M7
  ["101001010010"] = "7sus2sus4",  -- suspended 2 and 4 with 7
  ["101001010001"] = "M7sus2sus4",  -- suspended 2 and 4 with M7
  ["101000000010"] = "7sus2",     -- suspended2 with 7 without 5
  ["101000000001"] = "M7sus2",    -- suspended2 with M7 without 5
  ["100001000010"] = "7sus4",     -- suspended4 with 7 no 5
  ["100001000001"] = "M7sus4",    -- suspended4 with M7 nbo 5
  ["101001000010"] = "7sus2sus4",  -- suspended 2 and 4 with 7 no 5
  ["101001000001"] = "M7sus2sus4",  -- suspended 2 and 4 with M7 no 5
  ["101000001000"] = "sus2#5",      -- suspended2 #5  
}

ChordRec.extendedChords = 
{
  ["101010010000"] = "Madd9", -- Major + 9
  ["101010000000"] = "Madd9", -- Major + 9 without 5th
  ["101100010000"] = "madd9", -- Minor + 9
  ["101100000000"] = "madd9", -- Minor + 9 without 5th
  ["110010010000"] = "Maddb9",   -- Major + b9
  ["110100010000"] = "maddb9",   -- Minor + b9
  ["110010000000"] = "Maddb9",   -- Major + b9 without 5
  ["110100000000"] = "maddb9",   -- Minor + b9 without 5
  ["100110010000"] = "Madd#9",   -- Major + #9
  ["100110000000"] = "Madd#9",   -- Major + #9 no 5
  
  ["101010100010"] = "9b5",  	--  C7b5 + 9  
  ["101010001010"] = "9#5",  	-- augmented seventh + 9
  ["101010001001"] = "M9#5", 	-- augmented major seventh + 9

  ["101010010001"] = "M9", -- CM7 + 9
  ["101010010010"] = "9",  -- C7 + 9 
  ["101100010010"] = "m9", -- Cm7 + 9
  ["101100010001"] = "mM9", -- CmM7 + 9
  ["101010000001"] = "M9", -- CM7 + 9 no 5th
  ["101010000010"] = "9",  -- C7 + 9 no 5th
  ["101100000010"] = "m9", -- Cm7 + 9 no 5th
  ["101100000001"] = "mM9", -- CmM7 + 9 no 5
  ["110010010010"] = "7b9",  -- C7 + b9 
  ["110010000010"] = "7b9",  -- C7 + b9 no 5
  ["110010010001"] = "M7b9",  -- C7M + b9 
  ["110010000001"] = "M7b9",  -- CM7 + b9 no 5
  ["110100010010"] = "m7b9",  -- Cm7 + b9 
  ["110100000010"] = "m7b9",  -- Cm7 + b9 no 5
  ["100110010010"] = "7#9",  -- C7 + #9 
  ["100110000010"] = "7#9",  -- C7 + #9  no 5
  ["100110010001"] = "M7#9",  -- CM7 + #9 
  ["100110000001"] = "M7#9",  -- CM7 + #9  no 5

  ["101011010001"] = "M11", -- CM9 + 11
  ["101011010010"] = "11",  -- C9 + 11
  ["101101010010"] = "m11", -- Cm9 + 11
  ["101101010001"] = "mM11", -- CmM9 + 11
  ["101010110001"] = "M#11", -- CM9 + #11
  ["101011000001"] = "M11", -- CM9 + 11 no 5th
  ["101011000010"] = "11",  -- C9 + 11 no 5th
  ["101101000010"] = "m11", -- Cm9 + 11 no 5th
  ["101101000001"] = "mM11", -- CmM9 + 11 no 5
  ["101010100001"] = "M#11", -- CM9 + #11 no 5
    
  ["101011010101"] = "M13", -- CM11 + 13 
  ["101011010110"] = "13",  -- C11 + 13
  ["101101010110"] = "m13", -- Cm11 + 13
  ["101101010101"] = "mM13", -- CmM11 + 13
  ["101011000101"] = "M13", -- CM11 + 13 no 5th
  ["101011000110"] = "13",  -- C11 + 13 no 5th
  ["101101000110"] = "m13", -- Cm11 + 13 no 5th
  ["101101000101"] = "mM13", -- CmM11 + 13 no 5th
	
  ["101010010100"] = "6/9", -- Major + 6 + 9
  ["101010000100"] = "6/9", -- Major + 6 + 9 no 5th
  ["101100010100"] = "m6/9", -- minor + 6 + 9
  ["101100000100"] = "m6/9", -- minor + 6 + 9 no 5th
}

-- chord dicts in order of likeliness
ChordRec.Chords = 
{
  ChordRec.triads, 
  ChordRec.sixthChords,
  ChordRec.fourNotesChords, 
  ChordRec.fifthChords, 
  ChordRec.suspended, 
  ChordRec.extendedChords
}

function ChordRec.getChroma(root, notes)
  local chroma = {0,0,0,0,0,0,0,0,0,0,0,0}
  for i,note in ipairs(notes) do
    local n = note-root
    while n<0 do n = n+12 end
    n = 1+n%12
    chroma[n] = 1 
  end
  return chroma
end

function ChordRec.getChromaString(chroma)
	return table.concat(chroma)
end

--------------------------------------------------------------------------------
-- attempt to recognise the chord on the keyboard and return its symbolic representation
-- @param notes table/array of notes in chord
-- @return root, kind, basse 
function ChordRec.chordKind(notes)
  local bass = notes[1]%12
  -- try permutations
  for i=1,#notes do
    -- try chord dicts
    for k,chordDict in pairs(ChordRec.Chords) do
      local root = notes[i]%12
      local chroma = ChordRec.getChroma(root, notes)
      local pattern = ChordRec.getChromaString(chroma)
      local kind = chordDict[pattern]
      if kind then
        return root,kind,bass
      end
    end
  end
 end
