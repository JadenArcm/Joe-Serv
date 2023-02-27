--//

local function getParams(v, xs, xn, tics)
	local alpha = joeFuncs.getAlpha(v, 17 - (tics / 2))
	local easing = joeFuncs.getEase("inoutexpo", tics, xs, xn)

	return alpha, easing
end

--//

local function drawCoopLayout(v, player)
	local x, y = ((joeVars.cvars["display"].value and 25 or 16) * FU), ((joeVars.cvars["display"].value and 189 or 168) * FU)
	local flags = V_SNAPTOLEFT | V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha, anim = getParams(v, -(50 * FU), x, player.hudstuff["display"])

	local bar_width = 65 * FU
	local color_shift = abs(((leveltime >> 1) % 9) - 4)

	local delay_color = SKINCOLOR_SUPERRUST1 + color_shift
	local delay_bar = FixedMul(FixedDiv(player.survival.delay * FU, (3 * TICRATE) * FU), bar_width)

	local health_color = (player.survival.health <= (player.survival.total_health / 3)) and skincolors[(SKINCOLOR_SUPERPURPLE1 + color_shift)].ramp[8] or 35
	local health_bar = FixedMul(FixedDiv(player.survival.health, player.survival.total_health), bar_width)
	local health_perc = ("%.1f"):format(FixedDiv(player.survival.health * 100, player.survival.total_health)) .. "\x86%"

	if (alpha ~= false) then
		joeFuncs.drawFill(v, anim, y, bar_width + (2 * FU), 6 * FU, 31 | flags | alpha)
		joeFuncs.drawFill(v, anim + FU, y + FU, bar_width, 4 * FU, 27 | flags | alpha)
		joeFuncs.drawFill(v, anim + FU, y + FU, health_bar, 4 * FU, health_color | flags | alpha)

		if (player.survival.delay) then
			joeFuncs.drawFill(v, anim, y + (6 * FU), delay_bar, FU, skincolors[delay_color].ramp[8] | flags | alpha)
		end

		v.drawString(anim + (2 * FU), y + FU, health_perc, flags | alpha | V_ALLOWLOWERCASE, "small-fixed")
	end
end

local function drawMatchLayout(v, player)
	local x, y = (160 * FU), (186 * FU)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha, anim = getParams(v, (225 * FU), y, player.hudstuff["ringslinger"])

	local total_health = ("%.1f"):format(FixedDiv(player.survival.health * 100, player.survival.total_health)) .. "\x82%"
	local delay = (player.survival.delay / TICRATE) .. "." .. ("%02d"):format(G_TicsToCentiseconds(player.survival.delay))

	if (alpha ~= false) then
		v.drawString(x, anim, total_health, flags | alpha, "thin-fixed-center")

		if (player.survival.delay) and (leveltime & 1) then
			v.drawString(x, anim + (8 * FU), delay, V_GRAYMAP | flags | alpha, "small-fixed-center")
		end
	end
end

--//

joeFuncs.addHUD(function(v, player)
	if not (joeVars.cvars["health"].value) then return end
	if not joeFuncs.isValid(player.realmo) then return end

	if not G_IsSpecialStage(gamemap) then
		drawCoopLayout(v, player)
	end

	drawMatchLayout(v, player)
end, true)

--//