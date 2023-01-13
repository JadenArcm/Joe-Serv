--//

local function drawNotif(v)
	local x, y = (160 * FRACUNIT), (6 * FRACUNIT)
	local flags = V_SNAPTOTOP

	local scaledwidth = (v.width() / v.dupx()) * FRACUNIT
	local anim = joeFuncs.getEase("inoutquart", joeVars.exitTics, -(70 * FRACUNIT), y)

	local notif = string.format("The current level will be \x87skipped\x80 after \x82%d\x80 minutes.", joeVars.cvars["autoexit"].value)

	joeFuncs.drawFill(v, 0, anim - (8 * FRACUNIT), scaledwidth, (22 * FRACUNIT), 31 | V_SNAPTOLEFT | V_20TRANS | flags)
	v.drawString(x, anim, notif, V_ALLOWLOWERCASE | flags, "thin-fixed-center")
end

local function drawTimeover(v)
	local x, y = (160 * FRACUNIT), (100 * FRACUNIT)
	local anim = joeFuncs.getEase("outexpo", joeVars.exitDelay, -(120 * FRACUNIT), x)

	v.drawScaled(anim - (8 * FRACUNIT), y, FRACUNIT, v.cachePatch("SLIDTIME"), 0, nil)
	v.drawScaled((320 * FRACUNIT) - anim, y, FRACUNIT, v.cachePatch("SLIDOVER"), 0, nil)
end

--//

local function handleTickers()
	if (gamestate ~= GS_LEVEL) then return end

	joeVars.exitTics = ((leveltime > TICRATE) and (leveltime < (6 * TICRATE))) and min($ + 1, TICRATE) or max(0, $ - 1)
	joeVars.exitDelay = ((leveltime - joeVars.exitCountdown) >= (2 * TICRATE)) and min($ + 1, TICRATE) or max(0, $ - 1)
end
addHook("ThinkFrame", handleTickers)

joeFuncs.addHUD(function(v, _)
	if not (netgame or multiplayer) then return end
	if not (gametyperules & GTR_ALLOWEXIT) then return end

	drawNotif(v)
	drawTimeover(v)
end)

--//