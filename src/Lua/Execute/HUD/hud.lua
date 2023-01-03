//

local scoreColors = {
	SKINCOLOR_EMERALD, SKINCOLOR_AQUA, SKINCOLOR_SKY, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_MAGENTA,
	SKINCOLOR_ROSY, SKINCOLOR_RED, SKINCOLOR_ORANGE, SKINCOLOR_GOLD, SKINCOLOR_YELLOW, SKINCOLOR_PERIDOT,
	SKINCOLOR_SEAFOAM, SKINCOLOR_CYAN, SKINCOLOR_WAVE, SKINCOLOR_SAPPHIRE, SKINCOLOR_VAPOR, SKINCOLOR_BUBBLEGUM,
 	SKINCOLOR_VIOLET, SKINCOLOR_RUBY, SKINCOLOR_FLAME, SKINCOLOR_SUNSET, SKINCOLOR_SANDY, SKINCOLOR_LIME
}

//

local matchWeapons = {
	[-1] = {max = 9999, patch = "RINGIND"},
	[0]  = {power = pw_infinityring, weapon = 0, max = 800, patch = "INFNIND"},

	{power = pw_automaticring, weapon = RW_AUTO,    max = 400, patch = "AUTOIND"},
	{power = pw_bouncering,    weapon = RW_BOUNCE,  max = 100, patch = "BNCEIND"},
	{power = pw_scatterring,   weapon = RW_SCATTER, max = 50,  patch = "SCATIND"},
	{power = pw_grenadering,   weapon = RW_GRENADE, max = 100, patch = "GRENIND"},
	{power = pw_explosionring, weapon = RW_EXPLODE, max = 50,  patch = "BOMBIND"},
	{power = pw_railring,	   weapon = RW_RAIL, 	max = 50,  patch = "RAILIND"}
}

local function drawWeapon(v, player, x, y, scale, flags, weapon)
	//

	local offs = {player.weapondelay, 0, 16}
	local alpha = max(1, min(offs[1], 6)) << V_ALPHASHIFT

	local ring_selection = (not player.powers[pw_infinityring]) and -1 or 0
	local ring_amount = player.powers[pw_infinityring] or player.rings

	local gflags = {
		text = ((player.powers[matchWeapons[weapon].power] >= matchWeapons[weapon].max) and V_YELLOWMAP) or 0,
		global = (not (player.ringweapons & matchWeapons[weapon].weapon) or not player.powers[matchWeapons[weapon].power]) and V_60TRANS or 0,

		rings = (not ring_amount) and V_60TRANS or 0,
		ring_text = ((ring_amount >= matchWeapons[ring_selection].max) and V_YELLOWMAP) or (((not ring_amount) and (leveltime % 8 < 4)) and V_REDMAP) or 0
	}

	//

	while (offs[1]) do
		if (offs[1] > offs[3]) then
			offs[2] = $ + offs[3]

			offs[1] = $ - offs[3]
			offs[1] = $ / 2

			if (offs[3] > 1) then
				offs[3] = $ / 2
			end
		else
			offs[2] = $ + offs[1]
			break
		end
	end

	//

	if not (weapon) then
		v.drawScaled(x, y, scale, v.cachePatch(matchWeapons[ring_selection].patch), flags | gflags.rings, nil)
		v.drawString(x + (12 * FRACUNIT), y + (FRACUNIT / 2), ring_amount, flags | gflags.rings | gflags.ring_text, "thin-fixed")
	else
		v.drawScaled(x, y, scale, v.cachePatch(matchWeapons[weapon].patch), flags | gflags.global, nil)
		v.drawString(x + (12 * FRACUNIT), y + (FRACUNIT / 2), player.powers[matchWeapons[weapon].power], flags | gflags.global | gflags.text, "thin-fixed")
	end

	//

	if (player.currentweapon == weapon) then
		v.drawScaled((x - FRACUNIT) - FixedMul((offs[2] / 2) * FRACUNIT, scale), y - FRACUNIT, scale, v.cachePatch("CURWEAP"), flags | alpha, nil)

		if (player.ammoremovaltimer) and (leveltime % 8 < 4) then
			v.drawString(x + (4 * FRACUNIT), y + (2 * FRACUNIT), "-" .. player.ammoremoval, flags | V_REDMAP, "small-fixed-center")
		end
	end

	//
end

//

local function drawScoreRings(v, player)
	//

	local x, y = (9 * FRACUNIT), (5 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER | ((player.spectator) and V_HUDTRANSHALF or V_HUDTRANS)

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, -(640 * FRACUNIT), x)

	//

	local score_patch = "JOE_SCORE" ..  ((leveltime / 3) % 12)
	local score_color = scoreColors[((player.score / 100) % #scoreColors) + 1]

	local ring_patch = "JOE_RING" .. ((leveltime / 2) % 24)
	local ring_color = ((player.rings <= 0) and ((leveltime / 5) & 1)) and v.getColormap(TC_RAINBOW, SKINCOLOR_KETCHUP) or nil

	//

	v.drawScaled(anim, y, FRACUNIT, v.cachePatch(score_patch), flags, v.getColormap(TC_DEFAULT, score_color))
	joeFuncs.drawNum(v, anim + (24 * FRACUNIT), y + (3 * FRACUNIT), player.score, flags, {font = "JOE_BNUM", space = 7})

	//

	if not G_RingSlingerGametype() then
		v.drawScaled(anim, y + (20 * FRACUNIT), FRACUNIT, v.cachePatch(ring_patch), flags, ring_color)
		joeFuncs.drawNum(v, anim + (24 * FRACUNIT), y + (23 * FRACUNIT), player.rings, flags, {font = "JOE_BNUM", space = 7})
	end

	//
end

local function drawTimer(v, player)
	//

	local x, y = (296 * FRACUNIT), (8 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_HUDTRANS | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (640 * FRACUNIT), x)
	local style = CV_FindVar("timerres")

	//

	local exitTics = joeVars.autoTimer - leveltime
	local info = joeFuncs.getCountdown(player.realtime)

	local patch = "JOE_TIME" .. (((player.realtime % TICRATE) * 235) / 1000)
	local color = SKINCOLOR_SILVER

	local xoffs = (style.value == 0) and -22 or 0

	//

	if ((gametyperules & GTR_FRIENDLY) and (exitTics < (60 * TICRATE)) and ((leveltime / 5) & 1)) or (info.flashing) then
		color = SKINCOLOR_RED
	end

	//

	v.drawScaled(anim, y - (3 * FRACUNIT), FRACUNIT, v.cachePatch(patch), flags, v.getColormap(TC_DEFAULT, color))

	if (style.value < 3) then
		joeFuncs.drawNum(v, anim - ((51 + xoffs) * FRACUNIT), y, G_TicsToMinutes(info.tics, true), flags, {font = "JOE_BNUM", space = 7, align = "right"})

		v.drawScaled(anim - ((52 + xoffs) * FRACUNIT), y, FRACUNIT, v.cachePatch("JOE_COLON"), flags, nil)
		joeFuncs.drawNum(v, anim - ((30 + xoffs) * FRACUNIT), y, G_TicsToSeconds(info.tics), flags, {font = "JOE_BNUM", space = 7, pad = 2, align = "right"})

		if (style.value > 0) then
			v.drawScaled(anim - (30  * FRACUNIT), y, FRACUNIT, v.cachePatch("JOE_PERIO"), flags | V_HUDTRANS, nil)
			joeFuncs.drawNum(v, anim - (8 * FRACUNIT), y, G_TicsToCentiseconds(info.tics), flags, {font = "JOE_BNUM", space = 7, pad = 2, align = "right"})
		end
	else
		joeFuncs.drawNum(v, anim - (8 * FRACUNIT), y, info.tics, flags, {font = "JOE_BNUM", space = 7, align = "right"})
	end

	//
end

local function drawLives(v, player)
	//

	local x, y = (299 * FRACUNIT), (29 * FRACUNIT)
	local flags = V_SNAPTORIGHT | V_SNAPTOTOP | V_PERPLAYER | (player.spectator and V_HUDTRANSHALF or V_HUDTRANS)

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (640 * FRACUNIT), x)

	//

	local player_lives = ((player.lives == INFLIVES) or (netgame and (CV_FindVar("cooplives").value == 0))) and '\x16' or ("\x82x\x80" .. max(0, min(player.lives, 99)))
	local yoffs = G_GametypeUsesLives() and FRACUNIT or (3 * FRACUNIT)

	local patch = v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A)
	local scale = FRACUNIT / 3

	local colormap = joeFuncs.getSkincolor(v, player, false)
	local health_color = 113

	//

	if (player.spectator) then
		health_color = (leveltime % TICRATE < 17) and 57 or 24

	elseif (player.pflags & PF_GODMODE) then
		health_color = 131

	elseif (player.hp.current <= (player.hp.max / 4)) then
		health_color = 36

	elseif (player.hp.current <= (player.hp.max / 2)) then
	 	health_color = 73
	end

	//

	v.drawScaled(anim, y, scale, v.cachePatch("STLIVEBK"), flags, nil)
	v.drawScaled(anim, y, scale, patch, flags, colormap)

	if (player.hp.enabled) then
		v.drawString(anim - (3 * FRACUNIT), y + FRACUNIT, joeFuncs.getPlayerName(player, 1) .. (G_GametypeUsesLives() and ("\x80 | " .. player_lives) or ""), flags | V_ALLOWLOWERCASE, "small-fixed-right")

		joeFuncs.drawFill(v, anim - (35 * FRACUNIT), y + (6 * FRACUNIT), player.hp.max + (2 * FRACUNIT), 3 * FRACUNIT, 31 | flags)
		joeFuncs.drawFill(v, anim - (34 * FRACUNIT), y + (7 * FRACUNIT), player.hp.max, FRACUNIT, 24 | flags)
		joeFuncs.drawFill(v, anim - (34 * FRACUNIT), y + (7 * FRACUNIT), player.hp.current, FRACUNIT, health_color | flags)
	else
		v.drawString(anim - (3 * FRACUNIT), y + yoffs, joeFuncs.getPlayerName(player, 1), flags | V_ALLOWLOWERCASE, "small-fixed-right")

		if G_GametypeUsesLives() then
			v.drawString(anim - (3 * FRACUNIT), y + (5 * FRACUNIT), player_lives, flags | V_ALLOWLOWERCASE, "small-fixed-right")
		end
	end

	//
end

local function drawRingslingerWeapons(v, player)
	//

	local x, y = (13 * FRACUNIT), (29 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.RingTicker, -(640 * FRACUNIT), x)
	local scale = FRACUNIT / 2

	//

	for i = 0, 6 do
		drawWeapon(v, player, anim, y + ((i * FRACUNIT) * 11), scale, flags, i)
	end

	//
end

local function drawPowerstones(v, player)
	//

	local x, y = (275 * FRACUNIT), (42 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.RingTicker, (640 * FRACUNIT), x)

	//

	for i = 0, 6 do
		local patch = v.cachePatch("TEMER" .. (i + 1))
		local colormap = nil
		local alpha = V_HUDTRANSHALF

		if (player.powers[pw_emeralds] & (1 << i)) then
			alpha = V_HUDTRANS
		end

		if player.powers[pw_super] or (player.powers[pw_invulnerability] and (player.powers[pw_sneakers] == player.powers[pw_invulnerability])) then
			alpha = V_HUDTRANS
			colormap = v.getColormap(TC_RAINBOW, skins[player.skin].supercolor + abs(((leveltime >> 1) % 9) - 4))
		end

		v.drawScaled(anim + ((5 * FRACUNIT) * i), y, FRACUNIT / 2, patch, flags | alpha, colormap)
	end

	//
end

local function drawDebugInfo(v, player)
	//

	if not joeVars.ownDebug.value then return end
	if not joeFuncs.isValid(player.realmo) then return end

	//

	local x, y = (14 * FRACUNIT), (156 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTOLEFT | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, -(640 * FRACUNIT), x)
	local spec = (player.spectator) and V_60TRANS or 0

	//

	local vals = {
		string.format("%cX:%c %.2f", 0x82, 0x80, player.realmo.x),
		string.format("%cY:%c %.2f", 0x82, 0x80, player.realmo.y),
		string.format("%cX:%c %.2f", 0x82, 0x80, player.realmo.z),

		string.format("%cANG:%c %.1f", 0x83, 0x80, AngleFixed(player.realmo.angle)),
		string.format("%cAIM:%c %.1f", 0x83, 0x80, AngleFixed(player.aiming)),
		string.format("%cSPD:%c %.1f", 0x87, 0x80, FixedHypot(player.speed, player.realmo.momz))
	}

	//

	joeFuncs.drawFill(v, anim - (2 * FRACUNIT), y, 48 * FRACUNIT, 35 * FRACUNIT, 31 | V_20TRANS | flags)

	for i = 1, #vals do
		local opts = (i > 3) and {2 * FRACUNIT, spec} or {0, 0}
		local dumb = -(3 * FRACUNIT) + opts[1]

		v.drawString(anim, (y + dumb) + ((i * 5) * FRACUNIT), vals[i], flags | opts[2], "small-fixed")
	end

	//
end

//

local function drawHUD(v, player)
	//

	if G_IsSpecialStage(gamemap) then return end
	if not joeFuncs.isValid(player.realmo) then return end

	//

	for _, i in ipairs({"time", "rings", "lives", "score", "weaponrings", "textspectator"}) do
		hud.disable(i)
	end

	//

	if (leveltime > 20) and not (joeVars.scoresKey) then
		joeVars.HUDTicker = min($ + 1, TICRATE)
		joeVars.RingTicker = (player.spectator) and max(0, $ - 1) or min($ + 1, TICRATE)
	end

	if (joeVars.scoresKey) then
		if (joeVars.RingTicker > 0) then
			joeVars.RingTicker = max(0, $ - 1)
		end

		joeVars.HUDTicker = max(0, $ - 1)
	end

	//

	drawScoreRings(v, player)
	drawTimer(v, player)
	drawLives(v, player)

	//

	if G_RingSlingerGametype() or (G_TagGametype() and (player.pflags & PF_TAGIT)) then
		drawRingslingerWeapons(v, player)
	end

	if (gametyperules & GTR_POWERSTONES) then
		drawPowerstones(v, player)
	end

	drawDebugInfo(v, player)

	//
end
hud.add(drawHUD, "game")

//
