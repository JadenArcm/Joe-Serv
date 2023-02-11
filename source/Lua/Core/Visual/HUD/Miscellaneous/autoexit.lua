--//

local function handleTickers()
	if (gamestate == GS_LEVEL) then
		joeVars.exitDelay = ((leveltime - joeVars.exitCountdown) >= (2 * TICRATE)) and min($ + 1, TICRATE) or max(0, $ - 1)
	end
end
addHook("ThinkFrame", handleTickers)

joeFuncs.addHUD(function(v, _)
	if not (netgame or multiplayer) then return end
	if not (gametyperules & GTR_ALLOWEXIT) then return end

	local x, y = (160 * FU), (100 * FU)
	local anim = joeFuncs.getEase("outexpo", joeVars.exitDelay, -(120 * FU), x)

	v.drawScaled(anim - (8 * FU), y, FU, v.cachePatch("SLIDTIME"), 0, nil)
	v.drawScaled((320 * FU) - anim, y, FU, v.cachePatch("SLIDOVER"), 0, nil)
end)

--//