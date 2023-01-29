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

	local ring_type, ring_amt = ((not player.powers[pw_infinityring]) and -1 or 0), (player.powers[pw_infinityring] or player.rings)
	local ring_patch, weap_patch = v.cachePatch(match_weapons[ring_type].patch), v.cachePatch(match_weapons[selection].patch)

	local has_wep = (not player.powers[match_weapons[selection].power] and (player.ringweapons & match_weapons[selection].weapon))
	local has_max = (player.powers[match_weapons[selection].power] >= match_weapons[selection].max)

	local params = {
		text_color = (has_max and V_YELLOWMAP) or (has_wep and V_ORANGEMAP) or 0,
		patch_alpha = (not (player.ringweapons & match_weapons[selection].weapon) or not (player.powers[match_weapons[selection].power])) and V_60TRANS or 0,

		ring_alpha = (ring_amt <= 0) and V_60TRANS or 0,
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

		if (player.powers[pw_infinityring]) then
			local flash = (((player.rings <= 0) or (player.powers[pw_super] and (player.rings < 20))) and ((leveltime / 5) & 1)) and V_REDMAP or V_YELLOWMAP
			v.drawString(x + (8 * FRACUNIT), y + FRACUNIT, max(0, player.rings), flash, "small-fixed-center")
		end
	else
		v.drawScaled(x, y, scale, weap_patch, flags | params.patch_alpha, nil)
		v.drawString(x + (8 * FRACUNIT), y + (8 * FRACUNIT), player.powers[match_weapons[selection].power], flags | params.patch_alpha | params.text_color, "thin-fixed-center")
	end

	if (player.currentweapon == selection) then
		v.drawScaled(x - (2 * FRACUNIT), (y - (2 * FRACUNIT)) + ((offs[2] / 2) * scale), scale, v.cachePatch("CURWEAP"), flags | alpha, nil)
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

local function drawPowerstones(v, player)
	if not (gametyperules & GTR_POWERSTONES) then return end

	local x, y = (126 * FRACUNIT), (164 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local _, anim = getParams(v, (210 * FRACUNIT), y, player.hudstuff["ringslinger"])

	for i = 0, 6 do
		local patch = v.cachePatch("TEMER" .. (i + 1))
		local alpha = V_HUDTRANSHALF

		if (player.powers[pw_emeralds] & (EMERALD1 << i)) then
			alpha = V_HUDTRANS
		end

		v.drawScaled(x + ((i * FRACUNIT) * 10), anim, FRACUNIT, patch, flags | alpha, nil)
	end
end

local function drawWeapons(v, player)
	local x, y = (152 * FRACUNIT), (177 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local _, anim = getParams(v, (210 * FRACUNIT), y, player.hudstuff["ringslinger"])
	local numweapons = 6

	for type = 0, numweapons do
		local offs = (type * 20) - (numweapons * 10)
		drawWeapon(v, player, x + (offs * FRACUNIT), anim, FRACUNIT, flags, type)
	end

	if ((player.ammoremovaltimer) and (leveltime % 8 < 4)) then
		v.drawString(x + (8 * FRACUNIT), y + (17 * FRACUNIT), "-" .. player.ammoremoval, flags | V_REDMAP, "small-fixed-center")
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end

	drawTimer(v, player)
	drawWeapons(v, player)
	drawPowerstones(v, player)
end)

--//