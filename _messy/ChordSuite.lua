--------------------------------------------------------------------------------
--! Mono Bass
--! Play lowest note only
--! Author : Louis Couka
--! Date : 18/12/2015
--------------------------------------------------------------------------------

local do_ = 0
local do_diese = 1
local re_bemol = do_diese
local re = 2
local re_diese = 3
local mi_bemol = re_diese
local mi = 4
local fa = 5
local fa_diese = 6
local sol_bemol = fa_diese
local sol = 7
local sol_diese = 8
local la_bemol = sol_diese
local la = 9
local la_diese = 10
local si_bemol = la_diese
local si = 11

transpose = Knob("Transpose", 0, -24, 24, true)

function onNote(e)
	n = (e.note)%12
	o = 60 + transpose.value
	print(note)
	
	if (n == do_)
		then
			playNote(o + do_, e.velocity)
			playNote(o + sol, e.velocity)
			playNote(o + mi_bemol + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == do_diese)
		then
			playNote(o + do_, e.velocity)
			playNote(o + sol, e.velocity)
			playNote(o + mi_bemol + 12, e.velocity)
			playNote(o + sol + 12, e.velocity)
		end
	if (n == re)
		then
			playNote(o + re, e.velocity)
			playNote(o + si_bemol, e.velocity)
			playNote(o + fa + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == mi_bemol)
		then
			playNote(o + mi_bemol, e.velocity)
			playNote(o + si_bemol, e.velocity)
			playNote(o + sol + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == mi)
		then
			playNote(o + mi_bemol, e.velocity)
			playNote(o + si_bemol, e.velocity)
			playNote(o + mi_bemol + 12, e.velocity)
			playNote(o + sol + 12, e.velocity)
		end
	if (n == fa)
		then
			playNote(o + fa, e.velocity)
			playNote(o + do_ + 12, e.velocity)
			playNote(o + fa + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == fa_diese)
		then
			playNote(o + fa, e.velocity)
			playNote(o + do_ + 12, e.velocity)
			playNote(o + fa + 12, e.velocity)
			playNote(o + la + 12, e.velocity)
		end
	if (n == sol)
		then
			playNote(o + sol, e.velocity)
			playNote(o + re + 12, e.velocity)
			playNote(o + fa + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == la_bemol)
		then
			playNote(o + la_bemol - 12, e.velocity)
			playNote(o + do_ + 12, e.velocity)
			playNote(o + mi_bemol + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == la)
		then
			playNote(o + la_bemol - 12, e.velocity)
			playNote(o + mi_bemol, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
			playNote(o + do_ + 24, e.velocity)
		end
	if (n == si_bemol)
		then
			playNote(o + si_bemol - 12, e.velocity)
			playNote(o + fa, e.velocity)
			playNote(o + re + 12, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
		end
	if (n == si)
		then
			playNote(o + si_bemol - 12, e.velocity)
			playNote(o + fa, e.velocity)
			playNote(o + si_bemol + 12, e.velocity)
			playNote(o + re + 24, e.velocity)
		end
end

function onRelease(e)
end