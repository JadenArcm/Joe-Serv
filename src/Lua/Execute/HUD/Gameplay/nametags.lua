//

local function drawNametags(v, player)
	//

	if not joeVars.nameTags.value then return end
	if not joeFuncs.isValid(player.realmo) then return end

	//

	local mo = player.realmo
	local searchDist = 2048 * FRACUNIT

	//

	for target in players.iterate do
		if (target.spectator) then continue end
		if (target == player) then continue end

		if (R_PointToDist2(mo.x, mo.y, target.mo.x, target.mo.y) > searchDist) then continue end
		
		local zoffs = P_MobjFlip(target.mo) * (P_GetPlayerHeight(target) + (16 * target.mo.scale))
		local screen = joeFuncs.mapToScreen(v, player, {target.mo.x, target.mo.y, target.mo.z + zoffs})

		if (screen.visible) then
			v.drawString(screen.x, screen.y, joeFuncs.getPlayerName(target, 1), screen.flags | V_ALLOWLOWERCASE, "thin-fixed-center")
		end
	end

	//
end
hud.add(drawNametags, "game")

//