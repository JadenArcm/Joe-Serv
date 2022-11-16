//

local bossNames = {
	[MT_EGGMOBILE] = "Egg Mobile",
	[MT_EGGMOBILE2] = "Egg Slimer",
	[MT_EGGMOBILE3] = "Sea Egg",
	[MT_EGGMOBILE4] = "Egg Colosseum",

	[MT_FANG] = "Fang",
	[MT_METALSONIC_BATTLE] = "Metal Sonic",

	[MT_CYBRAKDEMON] = "Black Eggman",
	[MT_BLACKEGGMAN] = "Brak Eggman"
}

//

local function drawBosses(v, player)
	//

	if not joeFuncs.isValid(player.realmo) then return end

	//

	local mo = player.realmo
	local searchDist = 2048 * FRACUNIT

	local x = {mo.x - searchDist, mo.x + searchDist}
	local y = {mo.y - searchDist, mo.y + searchDist}

	//

	local bar_width = (68 * FRACUNIT)
	local bar_height = (10 * FRACUNIT)

	//

	searchBlockmap("objects", function(_, boss)
		//

		if not (boss.flags & MF_BOSS) then return nil end

		if (boss.health ~= nil) then
			local bar_health = FixedMul(FixedDiv(boss.health * FRACUNIT, boss.info.spawnhealth * FRACUNIT), bar_width - (4 * FRACUNIT))
			local bar_flash = ((boss.flags2 & MF2_FRET) and (leveltime % 2)) and 1 or 36

			local boss_name = bossNames[boss.type] or "Unknown Boss"
			local boss_health = boss.health .. " / " .. boss.info.spawnhealth

			local zoffs = P_MobjFlip(boss) * (boss.height + (40 * boss.scale))
			local screen = joeFuncs.mapToScreen(v, player, {boss.x, boss.y, boss.z + zoffs})

			if (screen.visible) then
				joeFuncs.drawFill(v, screen.x - (bar_width / 2), screen.y - (2 * FRACUNIT), bar_width, bar_height, 31 | screen.flags)
				joeFuncs.drawFill(v, (screen.x + (2 * FRACUNIT)) - (bar_width / 2), screen.y, bar_health, bar_height - (4 * FRACUNIT), bar_flash | screen.flags)

				v.drawString(screen.x, screen.y - (7 * FRACUNIT), boss_name, screen.flags | V_ALLOWLOWERCASE | V_YELLOWMAP, "small-fixed-center")
				v.drawString(screen.x, screen.y, boss_health, screen.flags, "thin-fixed-center")
			end
		end

		//
	end, mo, x[1], x[2], y[1], y[2])

	//
end
hud.add(drawBosses, "game")

//