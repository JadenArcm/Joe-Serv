--//

local function drawSelectedStarpost(v, player, x, y, flags)
	local warp = joeVars.starWarps[player.starwarp.cursor].mobj

	if joeFuncs.isValid(warp) then
		local params = (not warp.enabled) and {SKINCOLOR_SILVER, V_GRAYMAP} or {SKINCOLOR_RED, V_YELLOWMAP}
		local offs = ((leveltime % 9) / 5)

		v.drawScaled(x, y, FRACUNIT, v.cachePatch("JOE_STAR"), flags, v.getColormap(TC_DEFAULT, params[1]))
		v.drawString(x, y + (8 * FRACUNIT), "#" .. player.starwarp.cursor, flags | params[2], "small-fixed-center")

		if (player.starwarp.cursor > 1) then
			v.drawString((x - (19 * FRACUNIT)) - (offs * FRACUNIT), y - (3 * FRACUNIT), "\x1C", flags | V_YELLOWMAP, "thin-fixed")
		end

		if (player.starwarp.cursor < #joeVars.starWarps) then
			v.drawString((x + (12 * FRACUNIT)) + (offs * FRACUNIT), y - (3 * FRACUNIT), "\x1D", flags | V_YELLOWMAP, "thin-fixed")
		end
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if (player.spectator) then return end

	local x, y = (296 * FRACUNIT), (184 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER

	local anim = joeFuncs.getEase("inoutquad", player.starwarp.tics, 255 * FRACUNIT, y)
	local alpha = joeFuncs.getAlpha(v, 17 - (player.starwarp.tics / 2))

	if (player.starwarp.tics > 0) and (alpha ~= false) then
		drawSelectedStarpost(v, player, x, anim, flags | alpha)
	end
end)

--//