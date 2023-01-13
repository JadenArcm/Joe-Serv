--//

local match_weapons = {
	[-1] = {max = 9999, patch = "RINGIND"},
	[0]  = {power = pw_infinityring, weapon = 0, max = 800, patch = "INFNIND"},

	{power = pw_automaticring, weapon = RW_AUTO,    max = 400, patch = "AUTOIND"},
	{power = pw_bouncering,    weapon = RW_BOUNCE,  max = 100, patch = "BNCEIND"},
	{power = pw_scatterring,   weapon = RW_SCATTER, max = 50,  patch = "SCATIND"},
	{power = pw_grenadering,   weapon = RW_GRENADE, max = 100, patch = "GRENIND"},
	{power = pw_explosionring, weapon = RW_EXPLODE, max = 50,  patch = "BOMBIND"},
	{power = pw_railring,	   weapon = RW_RAIL, 	max = 50,  patch = "RAILIND"}
}

--//

local function getParams(v, xs, xn, tics)
	local alpha = joeFuncs.getAlpha(v, 17 - (tics / 2))
	local easing = joeFuncs.getEase("inoutback", tics, xs, xn)

	return alpha, easing
end

local function drawWeapon(v, player, x, y, scale, flags, selection)
	local offs = {player.weapondelay, 0, 16}
	local alpha = max(1, min(offs[1], 8)) << V_ALPHASHIFT

	local ring_type = (not player.powers[pw_infinityring]) and -1 or 0
	local ring_amt = player.powers[pw_infinityring] or player.rings

	local ring_patch = v.cachePatch(match_weapons[ring_type].patch)
	local weap_patch = v.cachePatch(match_weapons[selection].patch)

	local params = {
		text_color = (player.powers[match_weapons[selection].power] >= match_weapons[selection].max) and V_YELLOWMAP or 0,
		patch_alpha = (not (player.ringweapons & match_weapons[selection].weapon) or not (player.powers[match_weapons[selection].power])) and V_60TRANS or 0,

		ring_alpha = (not ring_amt) and V_60TRANS or 0,
		ring_text = ((ring_amt >= match_weapons[ring_type].max) and V_YELLOWMAP) or (((not ring_amt) and ((leveltime / 5) & 1)) and V_REDMAP) or 0
	}

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

	if (selection == 0) then
		v.drawScaled(x, y, scale, ring_patch, flags | params.ring_alpha, nil)
		v.drawString(x + (8 * FRACUNIT), y + (8 * FRACUNIT), ring_amt, flags | params.ring_alpha | params.ring_text, "thin-fixed-center")
	else
		v.drawScaled(x, y, scale, weap_patch, flags | params.patch_alpha, nil)
		v.drawString(x + (8 * FRACUNIT), y + (8 * FRACUNIT), player.powers[match_weapons[selection].power], flags | params.patch_alpha | params.text_color, "thin-fixed-center")
	end

	if (player.currentweapon == selection) then
		v.drawScaled(x - (2 * FRACUNIT), (y - (2 * FRACUNIT)) + FixedMul((offs[2] / 2) * FRACUNIT, scale), scale, v.cachePatch("CURWEAP"), flags | alpha, nil)

		if (player.ammoremovaltimer) and (leveltime % 8 < 4) then
			v.drawString(x + (8 * FRACUNIT), y + (2 * FRACUNIT), "-" .. player.ammoremoval, flags | V_REDMAP, "small-fixed-center")
		end
	end
end

--//

local function drawTimer(v, player)
	if G_IsSpecialStage(gamemap) then return end

	local x, y = (160 * FRACUNIT), (5 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_ALLOWLOWERCASE | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FRACUNIT), y, player.hudstuff["ringslinger"])

	local time = joeFuncs.getHUDTime(player.realtime)
	local timer_type = (time.should_flash) and "Time Left:" or "Time Elapsed:"
	local color_type = (time.warn) and V_REDMAP or V_YELLOWMAP

	if (alpha ~= false) then
		v.drawString(x, anim, timer_type, flags | alpha | color_type, "thin-fixed-center")
		v.drawString(x, anim + (8 * FRACUNIT), joeFuncs.getTime(time.tics), flags | alpha, "thin-fixed-center")
	end
end

local function drawPlayer(v, player)
	local x, y = (10 * FRACUNIT), (162 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTOLEFT | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FRACUNIT), x, player.hudstuff["ringslinger"])

	local name_str = ""
	local scale = FRACUNIT / 3

	local patch = v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A)
	local colormap = joeFuncs.getSkincolor(v, player, true)

	if G_GametypeUsesLives() and ((CV_FindVar("cooplives").value ~= 0) or (player.lives ~= INFLIVES)) then
		name_str = ("\x80 / \x82x\x80" .. max(0, min(player.lives, 99)))
	end

	if (alpha ~= false) then
		v.drawScaled(anim, y, scale, v.cachePatch("STLIVEBK"), flags | alpha, nil)
		v.drawScaled(anim, y, scale, patch, flags | alpha, colormap)

		v.drawString(anim + (13 * FRACUNIT), y + (2 * FRACUNIT), joeFuncs.getPlayerName(player, 1) .. name_str, flags | alpha | V_ALLOWLOWERCASE, "thin-fixed")
	end
end

local function drawPowerstones(v, player)
	if not (gametyperules & GTR_POWERSTONES) then return end

	local x, y = (10 * FRACUNIT), (155 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTOLEFT | V_PERPLAYER

	local _, anim = getParams(v, -(120 * FRACUNIT), x, player.hudstuff["ringslinger"])

	for i = 0, 6 do
		local patch = v.cachePatch("TEMER" .. (i + 1))
		local alpha = V_HUDTRANSHALF

		if (player.powers[pw_emeralds] & (EMERALD1 << i)) then
			alpha = V_HUDTRANS
		end

		v.drawScaled(anim + ((i * FRACUNIT) * 5), y, FRACUNIT / 2, patch, flags | alpha, nil)
	end
end

local function drawWeapons(v, player)
	local x, y = (10 * FRACUNIT), (177 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTOLEFT | V_PERPLAYER

	local _, anim = getParams(v, (335 * FRACUNIT), y, player.hudstuff["ringslinger"])

	for type = 0, 6 do
		drawWeapon(v, player, x + ((type * FRACUNIT) * 20), anim, FRACUNIT, flags, type)
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end

	drawTimer(v, player)
	drawPlayer(v, player)
	drawWeapons(v, player)
	drawPowerstones(v, player)
end)

--//