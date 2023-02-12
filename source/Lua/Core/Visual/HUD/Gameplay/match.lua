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

	local has_wep = ((player.powers[match_weapons[selection].power] > 0) and not (player.ringweapons & match_weapons[selection].weapon))
	local has_max = (player.powers[match_weapons[selection].power] >= match_weapons[selection].max)

	local params = {
		text_color = (has_max and V_YELLOWMAP) or (has_wep and V_ORANGEMAP) or 0,
		patch_alpha = (not (player.ringweapons & match_weapons[selection].weapon) or not (player.powers[match_weapons[selection].power])) and V_60TRANS or 0,

		ring_alpha = (ring_amt <= 0) and V_30TRANS or 0,
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
		v.drawString(x + (8 * FU), y + (8 * FU), ring_amt, flags | params.ring_alpha | params.ring_text, "thin-fixed-center")

		if (player.powers[pw_infinityring]) then
			local flash = (((player.rings <= 0) or (player.powers[pw_super] and (player.rings < 20))) and ((leveltime / 5) & 1)) and V_REDMAP or V_YELLOWMAP
			v.drawString(x + (8 * FU), y + FU, max(0, player.rings), flags | flash, "small-fixed-center")
		end
	else
		v.drawScaled(x, y, scale, weap_patch, flags | params.patch_alpha, nil)
		v.drawString(x + (8 * FU), y + (8 * FU), player.powers[match_weapons[selection].power], flags | params.patch_alpha | params.text_color, "thin-fixed-center")
	end

	if (player.currentweapon == selection) then
		v.drawScaled((x - (2 * FU)) + ((offs[2] / 2) * scale), y - (2 * FU), scale, v.cachePatch("CURWEAP"), flags | alpha, nil)
	end

	if (player.ammoremovalweapon == selection) and ((player.ammoremovaltimer) and (leveltime % 8 < 4)) then
		v.drawString(x + (8 * FU), y + FU, "-" .. player.ammoremoval, flags | V_REDMAP, "small-fixed-center")
	end
end

--//

local function drawTimer(v, player)
	local x, y = (6 * FU), (6 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_ALLOWLOWERCASE | V_PERPLAYER

	local alpha, anim = getParams(v, -(80 * FU), x, player.hudstuff["ringslinger"])

	local time = joeFuncs.getHUDTime(player.realtime)
	local timer_type = (time.should_flash) and "Time Left:" or "Time Elapsed:"
	local color_type = (time.warn) and V_REDMAP or V_YELLOWMAP

	if (alpha ~= false) then
		v.drawString(anim, y, timer_type, flags | alpha | color_type, "thin-fixed")
		v.drawString(anim, y + (8 * FU), joeFuncs.getTime(time.tics), flags | alpha, "thin-fixed")
	end
end

local function drawScore(v, player)
	local x, y = (4 * FU), (24 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER

	local alpha, anim = getParams(v, -(80 * FU), x, player.hudstuff["ringslinger"])

	if (alpha ~= false) then
		v.drawScaled(anim, y, FU, v.cachePatch("ICON_TEAM"), flags | alpha, v.getColormap(TC_DEFAULT, player.skincolor))
		v.drawString(anim + (16 * FU), y + (3 * FU), player.score, flags | alpha, "thin-fixed")
	end
end

local function drawPowerstones(v, player)
	if not (gametyperules & GTR_POWERSTONES) then return end

	local x, y = (282 * FU), (96 * FU)
	local flags = V_SNAPTORIGHT | V_PERPLAYER

	local _, anim = getParams(v, (350 * FU), x, player.hudstuff["ringslinger"])

	for i = 0, 6 do
		local alpha = V_HUDTRANSHALF
		local offs = (i * 10) - 30
		if (player.powers[pw_emeralds] & (EMERALD1 << i)) then alpha = V_HUDTRANS end

		v.drawScaled(anim, y + (offs * FU), FU, v.cachePatch("TEMER" .. (i + 1)), flags | alpha, nil)
	end
end

local function drawWeapons(v, player)
	local x, y = (296 * FU), (92 * FU)
	local flags = V_SNAPTORIGHT | V_PERPLAYER

	local _, anim = getParams(v, (330 * FU), x, player.hudstuff["ringslinger"])
	local numweapons = NUM_WEAPONS - 1

	for type = 0, numweapons do
		local offs = (type * 20) - (numweapons * 10)
		drawWeapon(v, player, anim, y + (offs * FU), FU, flags, type)
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end

	drawTimer(v, player)
	drawScore(v, player)
	drawWeapons(v, player)
	drawPowerstones(v, player)
end)

--//