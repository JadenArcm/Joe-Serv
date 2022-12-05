//

local scroller = {delay = TICRATE, pos = 0, direction = 1}
local MAXSCROLLV = (FRACUNIT / 4) + (FRACUNIT / 2)

local handleTAB = {
	//

	Down = function(key)
		if (key.num == input.gameControlToKeyNum(GC_SCORES)) then
			joeVars.scoresKey = true
			return true
		end
	end,

	//

	Up = function(key)
		if (key.num == input.gameControlToKeyNum(GC_SCORES)) then
			joeVars.scoresKey = false
			return true
		end
	end

	//
}
addHook("KeyUp", handleTAB.Up)
addHook("KeyDown", handleTAB.Down)

//

local function getPingPatch(v, player)
	//

	if (player.bot) then
		return v.cachePatch("JOE_BOT")
	end

	//

	local ping_values = {3, 5, 7, 9}
	local patch = 0

	//

	for i = 1, #ping_values do
		if (player.cmd.latency >= ping_values[i]) then
			patch = min(i + 1, 3)
		end
	end

	if (player.quittime > 0) then
		patch = 4
	end

	//

	return v.cachePatch("JOE_PING" .. patch)

	//
end

//

local function drawPlayers(v)
	//

	local x, y = (306 * FRACUNIT), (14 * FRACUNIT)
	local flags = V_SNAPTORIGHT | V_SNAPTOTOP

	local player_list = {}
	local anim = joeFuncs.getEasing("outexpo", joeVars.scoresTicker, (640 * FRACUNIT), x)

	local scaledwidth = v.width() / v.dupx()
	local scaledheight = v.height() / v.dupy()

	//

	for player in players.iterate do
		if (player.spectator) then continue end
		table.insert(player_list, player)
	end

	table.sort(player_list, function(a, b)
		if (gametyperules & GTR_RACE) then
			return (circuitmap) and (a.laps > b.laps) or (a.realtime < b.realtime)
		end

		return (a.score == b.score) and (a.name < b.name) or (a.score > b.score)
	end)

	//

	for i, player in ipairs(player_list) do
		//

		local py = (y - (scroller.pos >> 1)) + ((i - 1) * (20 * FRACUNIT))
		local gflags = (((player.playerstate == PST_DEAD) or (player.quittime > 0)) and V_TRANSLUCENT or 0) | flags

		local score_string = player.score
		local life_string = ""

		//

		if (gametyperules & GTR_RACE) then
			if (player.exiting) then
				score_string = "\x83" .. "FIN" .. "\x80"
			else
				if (circuitmap) then
					score_string = "Lap " .. (player.laps + 1)
				else
					score_string = joeFuncs.getTimer(player.realtime)
				end
			end
		end

		if G_GametypeUsesLives() then
			if (player.lives == INFLIVES) or (CV_FindVar("cooplives").value == 0) then
				life_string = ""
			else
				life_string = string.format(" | \x82x\x80%02d", max(0, min(player.lives, 99)))
			end
		end

		//

		v.drawString(anim - (12 * FRACUNIT), py - (10 * FRACUNIT), string.sub(joeFuncs.getPlayerName(player, 1), 0, 15), V_ALLOWLOWERCASE | gflags, "thin-fixed-right")
		v.drawScaled(anim, py, skins[player.skin].highresscale, v.getSprite2Patch(player.skin, SPR2_LIFE, false, A), gflags, joeFuncs.getSkincolor(v, player, true))

		v.drawString(anim - (12 * FRACUNIT), py - (2 * FRACUNIT), score_string .. life_string, V_ALLOWLOWERCASE | gflags, "small-fixed-right")

		//

		if G_TagGametype() and (player.pflags & PF_TAGIT) then
			v.drawScaled(anim + (2 * FRACUNIT), py - (2 * FRACUNIT), FRACUNIT / 2, v.cachePatch("ICON_TAG"), flags, nil)
		elseif (player.pflags & PF_FINISHED) then
			v.drawScaled(anim + (2 * FRACUNIT), py - (2 * FRACUNIT), FRACUNIT / 2, v.cachePatch("ICON_FIN"), flags, nil)
		end

		v.drawScaled(anim - (10 * FRACUNIT), py - (12 * FRACUNIT), FRACUNIT / 2, getPingPatch(v, player), flags, nil)

		//
	end

	//

	if (scroller.delay) then
		scroller.delay = $ - 1
	elseif (scroller.direction > 0) then
		if (scroller.pos < (((#player_list * 20) - scaledheight) * FRACUNIT) << 1) then
			scroller.pos = $ + MAXSCROLLV
		else
			scroller.delay = TICRATE
			scroller.direction = -1
		end
	else
		if (scroller.pos > 0) then
			scroller.pos = $ - MAXSCROLLV
		else
			scroller.delay = TICRATE
			scroller.direction = 1
		end
	end

	//
end

//

local function drawNetInfo(v)
	//

	local x, y = (10 * FRACUNIT), (8 * FRACUNIT)
	local flags = V_SNAPTOLEFT

	local player_amount = 0
	local timer_format = ""

	local anim = joeFuncs.getEasing("outexpo", joeVars.scoresTicker, -(640 * FRACUNIT), x)

	//

	local timer = {
		hours = G_TicsToHours(joeVars.serverLife),
		minutes = G_TicsToMinutes(joeVars.serverLife, false),
		seconds = G_TicsToSeconds(joeVars.serverLife)
	}

	if (joeVars.serverLife) then
		if (timer.seconds > 0) then
			timer_format = timer.seconds .. " " .. joeFuncs.getPlural(timer.seconds, "second") .. "."
		end

		if (timer.minutes > 0) then
			timer_format = (timer.minutes .. " " .. joeFuncs.getPlural(timer.minutes, "minute") .. ((timer.seconds == 0) and "." or ", and ")) + $
		end

		if (timer.hours > 0) then
			timer_format = (timer.hours .. " " .. joeFuncs.getPlural(timer.hours, "hour") .. ((timer.minutes == 0) and ", and " or ", ")) + $
		end
	end

	//

	for player in players.iterate do
		player_amount = $ + 1
	end

	//

	v.drawString(anim, y, CV_FindVar("servername").string, V_ALLOWLOWERCASE | V_SNAPTOTOP | flags, "thin-fixed")
	v.drawString(anim, y + (8 * FRACUNIT), string.format("\x82Server Lifetime:\x80 %s", timer_format), V_ALLOWLOWERCASE | V_SNAPTOTOP | flags, "small-fixed")
	v.drawString(anim, y + (13 * FRACUNIT), string.format("\x82Players:\x80 %d of %d.", player_amount, CV_FindVar("maxplayers").value), V_ALLOWLOWERCASE | V_SNAPTOTOP | flags, "small-fixed")

	//

	if (gametyperules & GTR_RINGSLINGER) then
		//

		local info = joeFuncs.getCountdown(leveltime)

		local timer_option = (info.countdown) and "Left" or "Elapsed"
		local timer_color = (info.flashing) and 0x85 or 0x82

		if (pointlimit) then
			v.drawString(anim, (175 * FRACUNIT), "\x82Point Limit: \x80" .. pointlimit, V_ALLOWLOWERCASE, "thin-fixed")
		end

		v.drawString(anim, (185 * FRACUNIT), string.format("%cTime %s: \x80%s", timer_color, timer_option, joeFuncs.getTimer(info.tics)), V_ALLOWLOWERCASE, "thin-fixed")

		//
	else
		//

		for i = 0, 6 do
			local patch = v.cachePatch("TEMER" .. (i + 1))
			local alpha = V_60TRANS

			if (emeralds & (1 << i)) then
				alpha = 0
			end

			v.drawScaled(anim + ((10 * FRACUNIT) * i), 173 * FRACUNIT, FRACUNIT, patch, V_SNAPTOBOTTOM | flags | alpha, nil)
		end

		//

		if rawget(_G, "solchars") and joeFuncs.isValid(consoleplayer) then
			for i = 0, 6 do
				local patch = v.cachePatch("TSEM" .. (i + 1))
				local alpha = V_60TRANS

				if (consoleplayer.solemeralds and (consoleplayer.solemeralds & (1 << i))) then
					alpha = 0
				end

				v.drawScaled((anim + (7 * FRACUNIT)) + ((9 * FRACUNIT) * i), 169 * FRACUNIT, FRACUNIT, patch, V_SNAPTOBOTTOM | flags | alpha, nil)
			end
		end

		//

		if (joeVars.totalEmblems > 0) and (#joeVars.emblemInfo > 0) then
			table.sort(joeVars.emblemInfo, function(a, b) return (a.orig < b.orig) end)

			for i, mo in ipairs(joeVars.emblemInfo) do
				local patch = v.cachePatch("GOTIT" .. R_Frame2Char(mo.frame & FF_FRAMEMASK))
				local alpha = (mo.health) and V_60TRANS or 0

				local bop_calc = cos(FixedAngle((leveltime + (16 * i)) * (6 * FRACUNIT)))
				local bop = (joeVars.collectedEmblems >= joeVars.totalEmblems) and bop_calc or 0

				v.drawScaled(anim + ((14 * FRACUNIT) * (i - 1)), (184 * FRACUNIT) + bop, FRACUNIT / 2, patch, V_SNAPTOBOTTOM | alpha | flags, v.getColormap(TC_RAINBOW, mo.color))
			end
		else
			v.drawScaled(anim, (184 * FRACUNIT), FRACUNIT / 2, v.cachePatch("GOTITX"), V_SNAPTOBOTTOM | flags, v.getColormap(TC_RAINBOW, SKINCOLOR_JET))
			v.drawString(anim + (16 * FRACUNIT), (186 * FRACUNIT), "No emblems?", V_SNAPTOBOTTOM | V_ALLOWLOWERCASE | flags, "small-fixed")
		end

		//
	end

	//

	drawPlayers(v)

	//
end

//

local function drawCoopInfo(v)
	//

	local x, y, fa = 0, 0, 0
	local spin = (leveltime % 360) * FRACUNIT

	local anim = joeFuncs.getEasing("outcubic", joeVars.scoresTicker, (400 * FRACUNIT), 0)

	//

	for i = 0, 6 do
		local patch = v.cachePatch("CHAOS" .. (i + 1))
		local flags = V_TRANSLUCENT

		fa = FixedAngle(spin)
		x = (305 << 15) + (48 * cos(fa))
		y = (186 << 15) + (48 * sin(fa))

		spin = $ + ((360 * FRACUNIT) / 7)

		if (emeralds & (EMERALD1 << i)) then
			flags = 0
		end

		v.drawScaled(x, y + anim, FRACUNIT, patch, flags, nil);
	end

	//
end

//

local function drawScores(v)
	//

	if (leveltime <= 50) then return end

	//

	joeVars.scoresTicker = (joeVars.scoresKey) and min($ + 2, TICRATE) or max(0, $ - 2)

	//

	v.fadeScreen(0xFA00, min(joeVars.scoresTicker / 2, 10))

	if (netgame or multiplayer) then
		drawNetInfo(v)
	else
		drawCoopInfo(v)
	end

	//
end
hud.add(drawScores, "titlecard")

//
