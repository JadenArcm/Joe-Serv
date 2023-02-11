--//

local function drawSelectedStarpost(v, player, x, y, flags)
	local warp = joeVars.starWarps[player.starwarp.cursor].mobj

	if joeFuncs.isValid(warp) then
		local params = (not warp.enabled) and {SKINCOLOR_SILVER, V_GRAYMAP} or {SKINCOLOR_RED, V_YELLOWMAP}
		local offs = ((leveltime % 9) / 5)

		v.drawScaled(x, y, FU, v.cachePatch("JOE_STAR"), flags, v.getColormap(TC_DEFAULT, params[1]))
		v.drawString(x, y + (8 * FU), "#" .. player.starwarp.cursor, flags | params[2], "small-fixed-center")

		if (player.starwarp.cursor > 1) then
			v.drawString((x - (19 * FU)) - (offs * FU), y - (3 * FU), "<", flags | V_YELLOWMAP, "thin-fixed")
		end

		if (player.starwarp.cursor < #joeVars.starWarps) then
			v.drawString((x + (15 * FU)) + (offs * FU), y - (3 * FU), ">", flags | V_YELLOWMAP, "thin-fixed")
		end
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if (player.spectator) then return end

	local x, y = (296 * FU), (184 * FU)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local anim = joeFuncs.getEase("inoutquad", player.starwarp.tics, 255 * FU, y)

	local warp_alpha = joeFuncs.getAlpha(v, 17 - (player.starwarp.tics / 2))
	local hover_alpha = joeFuncs.getAlpha(v, 17 - (player.starwarp.hover_tics / 2))

	if (warp_alpha ~= false) then
		drawSelectedStarpost(v, player, x, anim, V_SNAPTORIGHT | flags | warp_alpha)
	end

	if (hover_alpha ~= false) then
		v.drawString(160 * FU, 189 * FU, "Press \x82[TOSSFLAG]\x80 to toggle the \x87StarWarp\x80 menu.", V_ALLOWLOWERCASE | hover_alpha | flags, "small-fixed-center")
	end
end, true)

--//