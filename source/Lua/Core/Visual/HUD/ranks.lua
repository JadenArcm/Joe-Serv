--//

local function drawPeopleInTeams(v, x, y, people)
	local numformsg = 16
	local offs = (x >= 160) and 320 or 160
	local roffs = (offs - 10) - x

	for amount, player in ipairs(people) do
		if (amount == numformsg) and (#people > numformsg) then
			v.drawString(x - 16, y + 3, "\x86" .. "And \x82" .. (#people - amount) .. "\x86 more...", V_ALLOWLOWERCASE, "thin")
			break
		end

		local alpha = ((player.quittime > 0) or (player.playerstate == PST_DEAD)) and V_TRANSLUCENT or 0
		local name = joeFuncs.getPlayerName(player, 1)

		if (name:len() > 12) then
			local col = (joeFuncs.getColor(player.skincolor) == "\x80") and "\x86" or "\x80"
			name = name:sub(0, 12) .. col .. "..."
		end

		v.drawScaled(x * FRACUNIT, y * FRACUNIT, FRACUNIT / 3, v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A), alpha, joeFuncs.getSkincolor(v, player, true))
		v.drawString(x + 13, y + 2, name, V_ALLOWLOWERCASE | alpha, "thin")
		v.draw(x - 19, y - 1, joeFuncs.getPingPatch(v, player), 0, nil)

		if (player.gotflag) then
			local color = (player.gotflag & GF_REDFLAG) and skincolor_redteam or skincolor_blueteam
			v.draw(x + roffs - 10, y - 1, v.cachePatch("ICON_FLAG"), 0, v.getColormap(TC_DEFAULT, color))
		else
			v.drawString(x + roffs, y + 2, player.score, alpha, "thin-right")
		end

		y = $ + 10
	end
end

local function drawServerInformation(v)
	local x, y = 10, 5

	local numplayers = 0
	for _ in players.iterate do numplayers = $ + 1 end

	v.drawString(x, y, CV_FindVar("servername").string, V_ALLOWLOWERCASE | V_SNAPTOLEFT, "thin")
	v.drawString(320 - x, y, numplayers .. "\x82 - \x80" .. CV_FindVar("maxplayers").value, V_SNAPTORIGHT, "thin-right")
end

local function drawSpecificInformation(v)
	if (gametyperules & GTR_RINGSLINGER) then
		local y = 185
		local xoffs = (pointlimit) and 32 or 0

		local time = joeFuncs.getHUDTime(leveltime)
		local time_col = (time.warn) and V_REDMAP or V_YELLOWMAP
		local time_str = (time.should_flash) and "Time Left:" or "Time Elapsed:"

		v.drawString(160 + xoffs, y + 2, time_str, V_ALLOWLOWERCASE | time_col, "small-center")
		v.drawString(160 + xoffs, y + 7, joeFuncs.getTime(time.tics), 0, "small-center")

		if (pointlimit) then
			v.drawString(160 - xoffs, y + 2, "Point Limit:", V_ALLOWLOWERCASE | V_YELLOWMAP, "small-center")
			v.drawString(160 - xoffs, y + 7, pointlimit, 0, "small-center")
		end

		if G_GametypeHasTeams() then
			local rdf_x, blf_x = 5, 302
			local patch = (gametyperules & GTR_TEAMFLAGS) and "ICON_FLAG" or "ICON_TEAM"

			v.draw(rdf_x, y, v.cachePatch(patch), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, skincolor_redteam))
			v.drawString(rdf_x + 18, y + 3, redscore, V_SNAPTOLEFT, "thin")

			v.draw(blf_x, y, v.cachePatch(patch), V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, skincolor_blueteam))
			v.drawString(blf_x - 4, y + 3, bluescore, V_SNAPTORIGHT, "thin-right")
		end
	else
		local emr_x, emb_x = 238, 10
		local y = 187

		for i = 0, 6 do
			local alpha = V_60TRANS
			if (emeralds & (1 << i)) then alpha = 0 end

			v.draw(emr_x + (10 * i), y, v.cachePatch("TEMER" .. (i + 1)), alpha | V_SNAPTORIGHT, nil)
		end

		if (#joeVars.emblemInfo > 0) then
			for i, emblem in ipairs(joeVars.emblemInfo) do
				local patch = v.cachePatch("GOTIT" .. R_Frame2Char(emblem.frame & FF_FRAMEMASK))
				local alpha = (emblem.health) and V_60TRANS or 0

				v.drawScaled((emb_x + (14 * (i - 1))) * FRACUNIT, y * FRACUNIT, FRACUNIT / 2, patch, alpha | V_SNAPTOLEFT,  v.getColormap(TC_RAINBOW, emblem.color))
			end
		else
			v.drawScaled(emb_x * FRACUNIT, y * FRACUNIT, FRACUNIT / 2, v.cachePatch("GOTITX"), V_SNAPTOLEFT, v.getColormap(TC_RAINBOW, SKINCOLOR_SILVER))
			v.drawString(emb_x + 16, y + 2, "No Emblems?", V_ALLOWLOWERCASE | V_SNAPTOLEFT, "small")
		end
	end
end

--//

local function drawGenericPeople(v, people)
	local x, y = 24, 20

	local numforcolumn = 16
	local roffs = 300 - 15
	local compact_mode = (#people > numforcolumn) or (CV_FindVar("compactscoreboard").value)

	v.drawFill(0, 18, v.width(), 1, V_SNAPTOLEFT)
	v.drawFill(0, 200 - 18, v.width(), 1, V_SNAPTOLEFT)

	if (compact_mode) then
		v.drawFill(160, 18, 1, 200 - 36, 0)
		roffs = (160 - 10) - x
	end

	for amount, player in ipairs(people) do
		local alpha = ((player.quittime > 0) or (player.playerstate == PST_DEAD) or (player.spectator)) and V_TRANSLUCENT or 0

		local score = player.score
		local name = joeFuncs.getPlayerName(player, 1)
		local icon_patch = nil

		if (gametyperules & GTR_RACE) then
			if (player.exiting) then
				score = "\x83" .. "FIN"
			else
				score = (circuitmap) and ("Laps " .. (player.laps + 1)) or joeFuncs.getTime(player.realtime)
			end
		end

		if (compact_mode) and (name:len() > 12) then
			local col = (joeFuncs.getColor(player.skincolor) == "\x80") and "\x86" or "\x80"
			name = $:sub(0, 12) .. col .. "..."
		end

		v.drawScaled(x * FRACUNIT, y * FRACUNIT, FRACUNIT / 3, v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A), alpha, joeFuncs.getSkincolor(v, player, true))
		v.drawString(x + 13, y + 2, name, V_ALLOWLOWERCASE | alpha, "thin")

		v.draw(x - 19, y - 1, joeFuncs.getPingPatch(v, player), 0, nil)

		if (player.spectator) then
			icon_patch = v.cachePatch("ICON_SPEC")

		elseif G_TagGametype() and (player.pflags & PF_TAGIT) then
			icon_patch = v.cachePatch("ICON_TAG")

		elseif (player.pflags & PF_FINISHED) or (player.exiting > 1) then
			icon_patch = v.cachePatch("ICON_FIN")
		end

		if (icon_patch ~= nil) then
			v.draw(x + roffs - 10, y - 1, icon_patch, 0, nil)
		end

		if not (player.spectator) then
			v.drawString(x + roffs + ((icon_patch ~= nil) and -icon_patch.width or 0), y + 2, score, alpha, "thin-right")
		end

		y = $ + 10
		if (amount == numforcolumn) then
			x = $ + 160
			y = 20
		end
	end
end

local function drawTeams(v, team_people)
	local x, y = 24, 20

	v.drawFill(0, 18, v.width(), 1, V_SNAPTOLEFT)
	v.drawFill(0, 200 - 18, v.width(), 1, V_SNAPTOLEFT)
	v.drawFill(160, 18, 1, 200 - 36, 0)

	drawPeopleInTeams(v, x, y, team_people["red"])
	x = $ + 160
	drawPeopleInTeams(v, x, y, team_people["blue"])
end

--//

local function drawSpectators(v)
	local y = 195
	local flags = V_TRANSLUCENT | V_ALLOWLOWERCASE

	local length, total_length = 8, 0

	local screen_adjust = v.width() / v.dupx()
	local screen_width = (screen_adjust - 320) / 2

	for player in players.iterate do
		if (player.spectator) then
			total_length = $ + (v.stringWidth(player.name, flags, "small") + 8)
		end
	end

	length = $ - (leveltime % (total_length + (screen_adjust + 8)))
	length = $ + screen_adjust

	for player in players.iterate do
		if not (player.spectator) then return end

		local len = v.stringWidth(player.name, flags, "small") + 8
		if (length >= -len) then
			v.drawString(length - screen_width, y, joeFuncs.getColor(player.skincolor) .. player.name, flags, "small")
		end

		length = $ + len
		if (length >= (screen_adjust + 8)) then
			break
		end
	end
end

--//

local function handleDraw(v)
	local item_list = {"rankings", "coopemeralds", "tokens"}
	local people_list = (gametyperules & GTR_RINGSLINGER) and "match" or "coop"

	if not (joeVars.cvars["scores"].value) then
		for _, entry in ipairs(item_list) do
			if not hud.enabled(entry) then hud.enable(entry) end
		end
		return
	end

	for _, entry in ipairs(item_list) do
		hud.disable(entry)
	end

	v.fadeScreen(0xFA00, 7)
	drawServerInformation(v)
	drawSpecificInformation(v)

	if G_GametypeHasTeams() then
		drawTeams(v, joeFuncs.getPlayerLists()["teams"])
	else
		drawGenericPeople(v, joeFuncs.getPlayerLists()[people_list])
	end

	if G_GametypeHasSpectators() then
		drawSpectators(v)
	end
end
addHook("HUD", handleDraw, "scores")

--//