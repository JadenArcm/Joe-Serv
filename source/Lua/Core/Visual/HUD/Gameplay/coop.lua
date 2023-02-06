--//

local scoreColors = {
	SKINCOLOR_EMERALD, SKINCOLOR_AQUA, SKINCOLOR_SKY, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_MAGENTA,
	SKINCOLOR_ROSY, SKINCOLOR_RED, SKINCOLOR_ORANGE, SKINCOLOR_GOLD, SKINCOLOR_YELLOW, SKINCOLOR_PERIDOT,
}

local function getParams(v, xs, xn, tics)
	local alpha = joeFuncs.getAlpha(v, 17 - (tics / 2))
	local easing = joeFuncs.getEase("inoutcubic", tics, xs, xn)

	return alpha, easing
end

--//

local function drawScore(v, player)
	local x, y = (9 * FU), (25 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])

	local patch = "JOE_SCORE" .. ((leveltime / 3) % 12)
	local color = scoreColors[((player.score / 100) % #scoreColors) + 1]

	if (alpha ~= false) then
		v.drawScaled(anim, y, FU, v.cachePatch(patch), flags | alpha, v.getColormap(TC_DEFAULT, color))
		joeFuncs.drawNum(v, anim + (22 * FU), y + (3 * FU), player.score, flags | alpha, {font = "JOE_BNUM", space = 7})
	end
end

local function drawRings(v, player)
	local x, y = (296 * FU), (25 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_PERPLAYER

	local alpha, anim = getParams(v, (400 * FU), x, player.hudstuff["display"])
	local should_flash = ((player.powers[pw_super] > 0) and (player.rings < 20)) or (player.rings <= 0)

	local patch = "JOE_RING" .. ((leveltime / 2) % 24)
	local color = (should_flash and ((leveltime / 5) & 1)) and v.getColormap(TC_RAINBOW, SKINCOLOR_SALMON) or nil

	if (alpha ~= false) then
		v.drawScaled(anim, y, FU, v.cachePatch(patch), flags | alpha, color)
		joeFuncs.drawNum(v, anim - (8 * FU), y + (3 * FU), player.rings, flags | alpha, {font = "JOE_BNUM", space = 7, align = "right"})
	end
end

local function drawLives(v, player)
	local x, y = (9 * FU), (5 * FU)
	local flags = V_SNAPTOLEFT | V_SNAPTOTOP | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])

	local scale = FU / 2
	local patch = v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A)
	local colormap = joeFuncs.getSkincolor(v, player, true)

	local lives = ((player.lives == INFLIVES) or (netgame and (CV_FindVar("cooplives").value == 0))) and {pos = 4, str = ""} or {pos = 1, str = ("\x82x\x80" .. max(0, min(player.lives, 99)))}

	if (alpha ~= false) then
		v.drawScaled(anim, y, scale, v.cachePatch("STLIVEBK"), flags | alpha, nil)
		v.drawScaled(anim, y, scale, patch, flags | alpha, colormap)

		v.drawString(anim + (19 * FU), y + (lives.pos * FU), joeFuncs.getPlayerName(player, 1), flags | alpha | V_ALLOWLOWERCASE, "thin-fixed")
		if G_GametypeUsesLives() and (string.len(lives.str) > 0) then
			v.drawString(anim + (19 * FU), y + (9 * FU), lives.str, flags | alpha | V_ALLOWLOWERCASE, "thin-fixed")
		end
	end
end

local function drawTime(v, player)
	local x, y = (296 * FU), (8 * FU)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_PERPLAYER

	local alpha, anim = getParams(v, (400 * FU), x, player.hudstuff["display"])

	local style = CV_FindVar("timerres")
	local xoffs = (style.value == 0) and -22 or 0

	local time = joeFuncs.getHUDTime(player.realtime)
	local limit_warn = (gametyperules & GTR_ALLOWEXIT) and ((joeVars.exitCountdown - leveltime) < (60 * TICRATE)) and ((leveltime / 5) & 1)

	local patch = "JOE_TIME" .. (((time.tics % TICRATE) * 235) / 1000)
	local color = (time.warn or limit_warn) and SKINCOLOR_RED or SKINCOLOR_SILVER

	if (alpha ~= false) then
		v.drawScaled(anim, y - (3 * FU), FU, v.cachePatch(patch), flags | alpha, v.getColormap(TC_DEFAULT, color))

		if (style.value < 3) then
			joeFuncs.drawNum(v, anim - ((51 + xoffs) * FU), y, G_TicsToMinutes(time.tics, true), flags | alpha, {font = "JOE_BNUM", space = 7, align = "right"})

			v.drawScaled(anim - ((52 + xoffs) * FU), y, FU, v.cachePatch("JOE_COLON"), flags | alpha, nil)
			joeFuncs.drawNum(v, anim - ((30 + xoffs) * FU), y, G_TicsToSeconds(time.tics), flags | alpha, {font = "JOE_BNUM", space = 7, pad = 2, align = "right"})

			if (style.value > 0) then
				v.drawScaled(anim - (30  * FU), y, FU, v.cachePatch("JOE_PERIO"), flags | alpha, nil)
				joeFuncs.drawNum(v, anim - (8 * FU), y, G_TicsToCentiseconds(time.tics), flags | alpha, {font = "JOE_BNUM", space = 7, pad = 2, align = "right"})
			end
		else
			joeFuncs.drawNum(v, anim - (8 * FU), y, time.tics, flags | alpha, {font = "JOE_BNUM", space = 7, align = "right"})
		end
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not joeFuncs.isValid(player.realmo) then return end
	if G_IsSpecialStage(gamemap) then return end

	drawScore(v, player)
	drawTime(v, player)
	drawRings(v, player)
	drawLives(v, player)
end)

--//