--//

local bossNames = {
	[MT_EGGMOBILE] = "Egg Zapper",
	[MT_EGGMOBILE2] = "Egg Slimer",
	[MT_EGGMOBILE3] = "Sea Egg",
	[MT_EGGMOBILE4] = "Egg Colosseum",

	[MT_FANG] = "Fang",
	[MT_METALSONIC_BATTLE] = "Metal Sonic",

	[MT_CYBRAKDEMON] = "Brak Eggman",
	[MT_BLACKEGGMAN] = "Black Eggman"
}

--//

local function drawPlayerTags(v, player)
	if not (joeVars.cvars["nametags"].value) then return end

	local maxdist = 2048 * FU
	local numtags = 0

	for target in players.iterate do
		if (target == player) then continue end
		if not joeFuncs.isValid(target.mo) then continue end
		if (R_PointToDist2(target.mo.x, target.mo.y, player.realmo.x, player.realmo.y) >= maxdist) then continue end

		if (numtags >= joeVars.cvars["maxtags"].value) then continue end

		local player_name = joeFuncs.getPlayerName(target, 1)
		local player_zoffs = P_MobjFlip(target.mo) * (P_GetPlayerHeight(target) + (16 * target.mo.scale))

		local alpha = (joeFuncs.getDistance(target.mo, player.realmo) >= (maxdist / 2)) and V_90TRANS or V_20TRANS
		local screen = joeFuncs.worldToScreen(v, player, {target.mo.x, target.mo.y, target.mo.z + player_zoffs})

		if (screen.visible) then
			joeFuncs.drawFill(v, (screen.x - (2 * FU)) - ((v.stringWidth(player_name, 0, "small") / 2) * FU), screen.y - (2 * FU), (v.stringWidth(player_name, 0, "small") + 4) * FU, 8 * FU, 31 | V_30TRANS)
			v.drawString(screen.x, screen.y, player_name, alpha | V_ALLOWLOWERCASE, "small-fixed-center")

			numtags = $ + 1
		end
	end
end

local function drawBosses(v, player)
	if not joeVars.cvars["bosstags"].value then return end

	local maxdist = 2048 * FU
	local x = {player.realmo.x - maxdist, player.realmo.x + maxdist}
	local y = {player.realmo.y - maxdist, player.realmo.y + maxdist}

	searchBlockmap("objects", function(_, mo)
		if not (mo.flags & MF_BOSS) then return nil end
		if (mo.health == nil) then return nil end
		if not P_CheckSight(player.realmo, mo) then return nil end

		local bar_width = 64 * FU
		local bar_offs = 5 * FU

		local alpha = (joeFuncs.getDistance(mo, player.realmo) >= (maxdist / 2)) and V_70TRANS or V_30TRANS
		local perc = string.format("%.1f", FixedDiv((mo.health * FU) * 100, mo.info.spawnhealth * FU)) .. "\x86%"

		local zoffs = P_MobjFlip(mo) * (mo.height + (42 * mo.scale))
		local screen = joeFuncs.worldToScreen(v, player, {mo.x, mo.y, mo.z + zoffs})

		local total_health = FixedMul(FixedDiv(mo.health * FU, mo.info.spawnhealth * FU), bar_width - bar_offs)
		local health_color = ((mo.flags2 & MF2_FRET) and (leveltime % 2)) and 1 or 36

		if (screen.visible) then
			joeFuncs.drawFill(v, screen.x - (bar_width / 2), screen.y, bar_width, 16 * FU, 31 | alpha)

			joeFuncs.drawFill(v, screen.x - ((bar_width - bar_offs) / 2), screen.y + (8 * FU), bar_width - bar_offs, 6 * FU, 47 | (alpha - V_20TRANS))
			joeFuncs.drawFill(v, screen.x - ((bar_width - bar_offs) / 2), screen.y + (8 * FU), total_health, 6 * FU, health_color | (alpha - V_20TRANS))

			v.drawString(screen.x, screen.y + (2 * FU), bossNames[mo.type] or "Unknown Boss", V_ALLOWLOWERCASE | V_YELLOWMAP | (alpha - V_30TRANS), "small-fixed-center")
			v.drawString(screen.x - (28 * FU), screen.y + (9 * FU), perc, (alpha - V_30TRANS), "small-fixed")
			v.drawString(screen.x + (28 * FU), screen.y + (9 * FU), mo.health .. "\x86/\x80" .. mo.info.spawnhealth, (alpha - V_30TRANS), "small-fixed-right")
		end
	end, player.realmo, x[1], x[2], y[1], y[2])
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end

	drawPlayerTags(v, player)
	drawBosses(v, player)
end)

--//