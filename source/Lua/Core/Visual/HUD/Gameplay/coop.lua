--//

local scoreColors = {
	SKINCOLOR_EMERALD, SKINCOLOR_AQUA, SKINCOLOR_SKY, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_MAGENTA,
	SKINCOLOR_ROSY, SKINCOLOR_RED, SKINCOLOR_ORANGE, SKINCOLOR_GOLD, SKINCOLOR_YELLOW, SKINCOLOR_PERIDOT
}

--//

local function getParams(v, xs, xn, tics)
	local alpha = joeFuncs.getAlpha(v, 17 - (tics / 2))
	local easing = joeFuncs.getEase("inoutexpo", tics, xs, xn)

	return alpha, easing
end

local function handleBlending(player)
	if (player.realmo.frame & FF_BLENDMASK) then
		return (((player.realmo.frame & FF_BLENDMASK) >> FF_BLENDSHIFT) << V_BLENDSHIFT)
	end

	if (player.realmo.blendmode) then
		return ({[AST_ADD] = V_ADD, [AST_SUBTRACT] = V_SUBSTRACT, [AST_REVERSESUBTRACT] = V_REVERSESUBSTRACT, [AST_MODULATE] = V_MODULATE})[player.realmo.blendmode] or 0
	end

	return 0
end

--//

local function drawScore(v, player)
	local x, y = (296 * FU), (7 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_PERPLAYER

	local alpha, anim = getParams(v, (370 * FU), x, player.hudstuff["display"])

	local patch = "JOE_SCORE" .. ((leveltime / 3) % 12)
	local color = scoreColors[((player.score / 100) % #scoreColors) + 1]

	if (alpha ~= false) then
		v.drawScaled(anim, y, FU, v.cachePatch(patch), flags | alpha, v.getColormap(TC_DEFAULT, color))
		joeFuncs.drawNum(v, anim - (8 * FU), y + (3 * FU), player.score, flags | alpha, {font = "JOE_BNUM", spacing = 7, align = "right"})
	end
end

local function drawTime(v, player)
	local x, y = (9 * FU), (10 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])
	local style = CV_FindVar("timerres")

	local time = joeFuncs.getHUDTime(player.realtime)
	local limit_warn = (gametyperules & GTR_ALLOWEXIT) and ((joeVars.exitCountdown - leveltime) < (60 * TICRATE)) and ((leveltime / 5) & 1)

	local patch = "JOE_TIME" .. (((time.tics % TICRATE) * 235) / 1000)
	local color = (time.warn or limit_warn) and SKINCOLOR_RED or SKINCOLOR_SILVER

	local xadd = (function(n) local d = 0; while (n) do d = (d + 1); n = (n / 10) end; return (d - 1); end)(G_TicsToMinutes(time.tics, true))
	local xoffs = (xadd > 0) and ((xadd * 7) * FU) or 0

	if (alpha ~= false) then
		v.drawScaled(anim, y - (3 * FU), FU, v.cachePatch(patch), flags | alpha, v.getColormap(TC_DEFAULT, color))

		if (style.value < 3) then
			joeFuncs.drawNum(v, anim + (22 * FU), y, G_TicsToMinutes(time.tics, true), flags | alpha, {font = "JOE_BNUM", spacing = 7})

			v.drawScaled(anim + (28 * FU) + xoffs, y, FU, v.cachePatch("JOE_COLON"), flags | alpha, nil)
			joeFuncs.drawNum(v, anim + (36 * FU) + xoffs, y, G_TicsToSeconds(time.tics), flags | alpha, {font = "JOE_BNUM", padding = 2, spacing = 7})

			if (style.value > 0) then
				v.drawScaled(anim + (50 * FU) + xoffs, y, FU, v.cachePatch("JOE_PERIO"), flags | alpha, nil)
				joeFuncs.drawNum(v, anim + (58 * FU) + xoffs, y, G_TicsToCentiseconds(time.tics), flags | alpha, {font = "JOE_BNUM", padding = 2, spacing = 7})
			end
		else
			joeFuncs.drawNum(v, anim + (22 * FU), y, time.tics, flags | alpha, {font = "JOE_BNUM", spacing = 7})
		end
	end
end

local function drawRings(v, player)
	local x, y = (9 * FU), (27 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])
	local should_flash = ((player.powers[pw_super] > 0) and (player.rings < 20)) or (player.rings <= 0)

	local patch = "JOE_RING" .. ((leveltime / 2) % 24)
	local color = (should_flash and ((leveltime / 5) & 1)) and v.getColormap(TC_RAINBOW, SKINCOLOR_SALMON) or nil

	if (alpha ~= false) then
		v.drawScaled(anim, y, FU, v.cachePatch(patch), flags | alpha, color)
		joeFuncs.drawNum(v, anim + (22 * FU), y + (3 * FU), player.rings, flags | alpha, {font = "JOE_BNUM", spacing = 7})
	end
end

local function drawLives(v, player)
	local x, y = (14 * FU), (192 * FU)
	local flags = V_SNAPTOLEFT | V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])

	local patch = v.getSprite2Patch(player.skin, SPR2_LIFE, false, A)
	local colormap = joeFuncs.getSkincolor(v, player, false)

	local name = joeFuncs.getPlayerName(player, 1)
	local lives = "\x82x\x80" .. max(0, min(player.lives, 99))

	local inf_bool = G_GametypeUsesLives() and not ((netgame and (CV_FindVar("cooplives").value == 0)) or (player.lives == INFLIVES))

	if (name:len() > 14) then
		local col = (joeFuncs.getColor(player.skincolor) == "\x80") and "\x86" or "\x80"
		name = name:sub(0, 14) .. col .. "..."
	end

	if (alpha ~= false) then
		v.drawScaled(anim, y, skins[player.skin].highresscale, patch, flags | alpha, colormap)
		v.drawString(anim + (11 * FU), y - ((inf_bool and 11 or 7) * FU), name, flags | alpha | V_ALLOWLOWERCASE, "thin-fixed")

		if (inf_bool) then
			v.drawString(anim + (11 * FU), y - (3 * FU), lives, flags | alpha | V_ALLOWLOWERCASE, "thin-fixed")
		end
	end
end

local function drawSelfDisplay(v, player)
	if (player.spectator) or (player.awayviewtics) or (camera.chase) then return end

	local x, y = (29 * FU), (167 * FU)
	local flags = V_SNAPTOLEFT | V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha = ((player.realmo.frame & FF_TRANSMASK) >> FF_TRANSSHIFT) << V_ALPHASHIFT
	local blend = handleBlending(player)

	local anim_x = joeFuncs.getEase("inoutexpo", player.hudstuff["selfview.x"], -(50 * FU), x)
	local anim_y = joeFuncs.getEase("inoutquart", player.hudstuff["selfview.y"], y, y + (18 * FU))

	local scale = (skins[player.skin].highresscale / 2)
	local scale_x, scale_y = FixedMul(player.realmo.spritexscale, scale), FixedMul(player.realmo.spriteyscale, scale)

	local patch, flip = v.getSprite2Patch(player.skin, player.realmo.sprite2, (player.powers[pw_super] > 0), player.realmo.frame, 8, player.realmo.rollangle)

	local shadow_patch = v.cachePatch("DSHADOW")
	local shadow_scale_x = (player.realmo.radius / shadow_patch.width) + (FU / 26)

	if (player.realmo.sprite ~= SPR_PLAY) then
		patch, flip = v.getSpritePatch(player.realmo.sprite, player.realmo.frame, 8, player.realmo.rollangle)
	end

	if not joeFuncs.isValid(patch) then
		patch, flip = v.getSpritePatch(SPR_UNKN, A)
	end

	if not (((player.powers[pw_flashing] > 1) and (player.powers[pw_flashing] < flashingtics)) and (leveltime & 1)) then
		if (CV_FindVar("shadow").value) then
			v.drawStretched(anim_x - ((shadow_patch.width / 2) * shadow_scale_x), anim_y - FU, shadow_scale_x, FU / 16, shadow_patch, V_20TRANS | flags, nil)
		end

		v.drawStretched(anim_x, anim_y, scale_x, scale_y, patch, flags | alpha | blend | (flip and V_FLIP or 0), joeFuncs.getSkincolor(v, player, true))
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end

	if not G_IsSpecialStage(gamemap) then
		drawScore(v, player)
		drawTime(v, player)
		drawRings(v, player)
		drawLives(v, player)
	end

	drawSelfDisplay(v, player)
end)

--//