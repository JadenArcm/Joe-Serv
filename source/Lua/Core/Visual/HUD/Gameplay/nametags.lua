--//

joeFuncs.addHUD(function(v, player)
	if not (joeVars.cvars["nametags"].value) then return end
	if not joeFuncs.isValid(player.realmo) then return end

	local maxdist = 2048 * FRACUNIT

	for target in players.iterate do
		if (target == player) then continue end
		if not joeFuncs.isValid(target.mo) then continue end
		if (R_PointToDist2(target.mo.x, target.mo.y, player.realmo.x, player.realmo.y) >= maxdist) then continue end

		local player_name = joeFuncs.getPlayerName(target, 1)
		local player_zoffs = P_MobjFlip(target.mo) * (P_GetPlayerHeight(target) + (16 * target.mo.scale))

		local alpha = P_CheckSight(player.realmo, target.mo) and V_10TRANS or V_70TRANS
		local screen = joeFuncs.worldToScreen(v, player, {target.mo.x, target.mo.y, target.mo.z + player_zoffs})

		if (screen.visible) then
			joeFuncs.drawFill(v, (screen.x - (2 * FRACUNIT)) - ((v.stringWidth(player_name, 0, "small") / 2) * FRACUNIT), screen.y - FRACUNIT, (v.stringWidth(player_name, 0, "small") + 4) * FRACUNIT, 6 * FRACUNIT, 31 | V_30TRANS)
			v.drawString(screen.x, screen.y, player_name, alpha | V_ALLOWLOWERCASE, "small-fixed-center")
		end
	end
end)

--//