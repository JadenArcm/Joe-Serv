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

joeFuncs.addHUD(function(v, player)
	if not joeVars.cvars["nametags"].value then return end
	if not joeFuncs.isValid(player.realmo) then return end

	local maxdist = 2048 * FRACUNIT
	local x = {player.realmo.x - maxdist, player.realmo.x + maxdist}
	local y = {player.realmo.y - maxdist, player.realmo.y + maxdist}

	searchBlockmap("objects", function(_, mo)
		if not (mo.flags & MF_BOSS) then return nil end
		if (mo.health == nil) then return nil end

		local bar_width = 64 * FRACUNIT
		local bar_offs = 5 * FRACUNIT

		local alpha = (joeFuncs.getDistance(mo, player.realmo) >= (maxdist / 2)) and V_60TRANS or V_40TRANS

		local zoffs = P_MobjFlip(mo) * (mo.height + (40 * mo.scale))
		local screen = joeFuncs.worldToScreen(v, player, {mo.x, mo.y, mo.z + zoffs})

		local total_health = FixedMul(FixedDiv(mo.health * FRACUNIT, mo.info.spawnhealth * FRACUNIT), bar_width - bar_offs)
		local health_color = ((mo.flags2 & MF2_FRET) and (leveltime % 2)) and 1 or (((mo.health <= 3) and 35) or ((mo.health <= (mo.info.spawnhealth / 2)) and 54) or 112)

		if (screen.visible) then
			joeFuncs.drawFill(v, screen.x - (bar_width / 2), screen.y, bar_width, 16 * FRACUNIT, 31 | alpha)

			joeFuncs.drawFill(v, screen.x - ((bar_width - bar_offs) / 2), screen.y + (8 * FRACUNIT), bar_width - bar_offs, 6 * FRACUNIT, 27 | (alpha - V_20TRANS))
			joeFuncs.drawFill(v, screen.x - ((bar_width - bar_offs) / 2), screen.y + (8 * FRACUNIT), total_health, 6 * FRACUNIT, health_color | (alpha - V_20TRANS))

			v.drawString(screen.x, screen.y + (2 * FRACUNIT), bossNames[mo.type] or "Unknown Boss", V_ALLOWLOWERCASE | V_YELLOWMAP, "small-fixed-center")

			v.drawString(screen.x - (28 * FRACUNIT), screen.y + (9 * FRACUNIT), mo.health, 0, "small-fixed")
			v.drawString(screen.x, screen.y + (9 * FRACUNIT), "/", 0, "small-fixed-center")
			v.drawString(screen.x + (28 * FRACUNIT), screen.y + (9 * FRACUNIT), mo.info.spawnhealth, 0, "small-fixed-right")
		end

	end, player.realmo, x[1], x[2], y[1], y[2])
end)

--//