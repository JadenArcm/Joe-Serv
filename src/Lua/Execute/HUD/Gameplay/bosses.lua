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

local function bossSpawn(mo)
	//

	if (mo.flags & MF_BOSS) then
		mo.deathticker = 0
		mo.deathtoggle = false

		table.insert(joeVars.bossInfo, mo)
	end

	//
end
addHook("MobjSpawn", bossSpawn)

local function bossThink(mo)
	//

	if (mo.deathticker > 0) then
		mo.deathticker = max(0, $ - 1)
	end

	if (mo.deathtoggle) and not (mo.deathticker) then
		for i = 1, #joeVars.bossInfo do
			if (joeVars.bossInfo[i] == mo) then
				table.remove(joeVars.bossInfo, i)
				break
			end
		end
	end

	//
end
addHook("BossThinker", bossThink)

local function bossDeath(mo)
	//

	if (#joeVars.bossInfo > 0) and (mo.flags & MF_BOSS) then
		mo.deathticker = (3 * TICRATE) + 17
		mo.deathtoggle = true
	end

	//
end
addHook("MobjDeath", bossDeath)

//

local function drawBosses(v, player)
	//

	if not joeFuncs.isValid(player.realmo) then return end
	if not #joeVars.bossInfo then return end

	//

	local x, y = (316 * FRACUNIT), (188 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTORIGHT

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (640 * FRACUNIT), x)

	//

	local bar_width = (64 * FRACUNIT)
	local bar_height = (10 * FRACUNIT)

	local boss_pos = {anim - bar_width, y}
	local boss_str = string.format("%cAnd %c%d%c %s left...", 0x82, 0x86, (#joeVars.bossInfo - 4), 0x82, joeFuncs.getPlural(#joeVars.bossInfo - 3, "boss"))

	//

	for i, mo in ipairs(joeVars.bossInfo) do
		if (i > 4) then
			v.drawString(anim, 130 * FRACUNIT, boss_str, V_ALLOWLOWERCASE | V_HUDTRANS | flags, "thin-fixed-right")
			break
		end

		if (joeFuncs.getDist(mo, player.realmo) <= 2048 * FRACUNIT) then
			local bar_color = ((mo.flags2 & MF2_FRET) and (leveltime % 2)) and 1 or 37
			local bar_alpha = (not mo.health) and ((10 - min((mo.deathticker / 2) + 1, 10)) << V_ALPHASHIFT) or 0

			local boss_health = FixedMul(FixedDiv(mo.health * FRACUNIT, mo.info.spawnhealth * FRACUNIT), bar_width - (4 * FRACUNIT))
			local boss_info = {bossNames[mo.type] or "Unknown Boss", mo.health .. " / " .. mo.info.spawnhealth}

			joeFuncs.drawFill(v, boss_pos[1], boss_pos[2] - (2 * FRACUNIT), bar_width, bar_height, 31 | bar_alpha | flags)
			joeFuncs.drawFill(v, boss_pos[1] + (2 * FRACUNIT), boss_pos[2], bar_width - (4 * FRACUNIT), bar_height - (4 * FRACUNIT), 46 | bar_alpha | flags)
			joeFuncs.drawFill(v, boss_pos[1] + (2 * FRACUNIT), boss_pos[2], boss_health, bar_height - (4 * FRACUNIT), bar_color | bar_alpha | flags)

			v.drawString(anim, boss_pos[2] - (7 * FRACUNIT), boss_info[1], V_ALLOWLOWERCASE | V_YELLOWMAP | bar_alpha | flags, "small-fixed-right")
			v.drawString(anim - (3 * FRACUNIT), boss_pos[2], boss_info[2], bar_alpha | flags, "thin-fixed-right")

			boss_pos[2] = $ - (20 * FRACUNIT)
		end
	end

	//
end
hud.add(drawBosses, "game")

//