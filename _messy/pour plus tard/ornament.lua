--------------------------------------------------------------------------------
-- "ornamentation" from vstLua
-- rewritten for MachFiveScript
--------------------------------------------------------------------------------

ornaments = 
{
    octAttack = {{12,20}, {0,0}},    
    bigOctAttack = {{24,20},{12,20}, {0,0}},    
    hugeOctAttack = {{36,20},{24,20},{12,20}, {0,0}},    
    fifthAttack = {{7,20}, {0,0}},    
    majorAttack = {{0,20}, {4,20}, {7,20}, {0,40}, {4,40}, {7,40},{0,0}},    
    minorAttack = {{0,20}, {3,20}, {7,20}, {12,40}, {15,40}, {19,40},{0,0}},  
}

ornament_names = {}
for k,v in pairs(ornaments) do
  table.insert(ornament_names, k)
end

menu = Menu("ornament", ornament_names)

function onNote(e)
  local ornament = ornaments[menu.selectedText]
  for i, orn in pairs(ornament) do        
    local v = orn[1]
    local td = orn[2]
    if(td>0) then
      playNote(e.note+v, e.velocity, td)
      wait(td)
    else
      playNote(e.note+v, e.velocity)
    end
  end
end
