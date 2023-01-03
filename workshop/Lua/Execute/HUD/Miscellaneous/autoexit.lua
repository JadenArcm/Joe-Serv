//

local function drawNotification(v)
	//

	local x, y = (160 * FRACUNIT), (6 * FRACUNIT)
	local flags = V_SNAPTOTOP

	local width = (v.width() / v.dupx()) * FRACUNIT
	local anim = joeFuncs.getEasing("outcubic", joeVars.autoTicker, -(400 * FRACUNIT), y)

	//

	joeVars.autoTicker = ((leveltime > TICRATE) and (leveltime <= (5 * TICRATE))) and min($ + 1, TICRATE) or max(0, $ - 1)

	//

	joeFuncs.drawFill(v, 0, anim - (8 * FRACUNIT), width, 22 * FRACUNIT, 31 | V_20TRANS | V_SNAPTOLEFT | flags)
	v.drawString(x, anim, "The current level will \x85" .. "restart" .. "\x80 after \x82" .. joeVars.autoExit.value .. "\x80 minutes.", V_ALLOWLOWERCASE | flags, "thin-fixed-center")

	//
end

local function drawTimeover(v, timer)
	//

	local x, y = 160, 100
	local xoffs = min(6 * (timer - 112), x)

	//

	if (timer >= 112) then
		v.draw(xoffs - 8, y, v.cachePatch("SLIDTIME"), 0, nil)
		v.draw(328 - xoffs, y, v.cachePatch("SLIDOVER"), 0, nil)
	end

	//
end

//

local function drawExitInfo(v)
	//

	if not (netgame or multiplayer) then return end
	if not (gametyperules & GTR_FRIENDLY) then return end

	//

	if (leveltime <= (10 * TICRATE)) then
		drawNotification(v)
	end

	if (leveltime >= joeVars.autoTimer) then
		drawTimeover(v, (leveltime - joeVars.autoTimer))
	end

	//
end
hud.add(drawExitInfo, "game")

//
