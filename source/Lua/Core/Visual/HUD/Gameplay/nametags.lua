--//

joeFuncs.addHUD(function(v, player)
	if not (joeVars.cvars["nametags"].value) then return end
	if not joeFuncs.isValid(player.realmo) then return end

	local maxdist = 2048 * FRACUNIT
	local numtags = 0

	for target in players.iterate do
		if (target == player) then continue end
		if not joeFuncs.isValid(target.mo) then continue end
		if (R_PointToDist2(target.mo.x, target.mo.y, player.realmo.x, player.realmo.y) >= maxdist) then continue end

		if (numtags > joeVars.cvars["maxtags"].value) then continue end

		local player_name = joeFuncs.getPlayerName(target, 1)
		local player_zoffs = P_MobjFlip(target.mo) * (P_GetPlayerHeight(target) + (16 * target.mo.scale))

		local alpha = ((joeFuncs.getDistance(target.mo, player.realmo) >= (maxdist / 2)) or not P_CheckSight(player.realmo, target.mo)) and V_90TRANS or V_20TRANS
		local screen = joeFuncs.worldToScreen(v, player, {target.mo.x, target.mo.y, target.mo.z + player_zoffs})

		if (screen.visible) then
			joeFuncs.drawFill(v, (screen.x - (2 * FRACUNIT)) - ((v.stringWidth(player_name, 0, "thin") / 2) * FRACUNIT), screen.y - (2 * FRACUNIT), (v.stringWidth(player_name, 0, "thin") + 4) * FRACUNIT, 10 * FRACUNIT, 31 | V_30TRANS)
			v.drawString(screen.x, screen.y, player_name, alpha | V_ALLOWLOWERCASE, "thin-fixed-center")

			numtags = $ + 1
		end
	end
end)

--//