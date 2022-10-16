//

local scoreColors = {
	SKINCOLOR_EMERALD, SKINCOLOR_AQUA, SKINCOLOR_SKY, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_MAGENTA,
	SKINCOLOR_ROSY, SKINCOLOR_RED, SKINCOLOR_ORANGE, SKINCOLOR_GOLD, SKINCOLOR_YELLOW, SKINCOLOR_PERIDOT,
	SKINCOLOR_SEAFOAM, SKINCOLOR_CYAN, SKINCOLOR_WAVE, SKINCOLOR_SAPPHIRE, SKINCOLOR_VAPOR, SKINCOLOR_BUBBLEGUM,
 	SKINCOLOR_VIOLET, SKINCOLOR_RUBY, SKINCOLOR_FLAME, SKINCOLOR_SUNSET, SKINCOLOR_SANDY, SKINCOLOR_LIME
}

//

local function drawScoreRings(v, player)
	//
	
	local x, y = (9 * FRACUNIT), (5 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTOLEFT | V_PERPLAYER | (player.spectator and V_HUDTRANSHALF or V_HUDTRANS)

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, -(640 * FRACUNIT), x)
	
	//

	local score_patch = "JOE_SCORE" ..  ((leveltime / 3) % 12)
	local score_color = scoreColors[((player.score / 100) % #scoreColors) + 1]
	
	local ring_patch = "JOE_RING" .. ((leveltime / 2) % 24)
	local ring_color = ((player.rings <= 0) and ((leveltime / 5) & 1)) and v.getColormap(TC_RAINBOW, SKINCOLOR_FLAME) or nil

	//
	
	v.drawScaled(anim, y, FRACUNIT, v.cachePatch(score_patch), flags, v.getColormap(TC_DEFAULT, score_color))
	joeFuncs.drawNum(v, anim + (24 * FRACUNIT), y + (3 * FRACUNIT), player.score, flags, "JOE_BNUM", "left", 7)

	//

	v.drawScaled(anim, y + (20 * FRACUNIT), FRACUNIT, v.cachePatch(ring_patch), flags, ring_color)
	joeFuncs.drawNum(v, anim + (24 * FRACUNIT), y + (23 * FRACUNIT), player.rings, flags, "JOE_BNUM", "left", 7)

	//
end

local function drawTimer(v, player)
	//
	
	local x, y = (296 * FRACUNIT), (8 * FRACUNIT)
	local flags = V_SNAPTOTOP | V_SNAPTORIGHT | V_HUDTRANS | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (640 * FRACUNIT), x)

	local exitTics = joeVars.autoTimer - leveltime
	local info = joeFuncs.getCountdown(player.realtime)

	local patch = "JOE_TIME" .. (((player.realtime % TICRATE) * 235) / 1000)
	local color = nil

	//

	if ((gametyperules & GTR_FRIENDLY) and (exitTics < (60 * TICRATE)) and ((leveltime / 5) & 1)) or (info.flashing) then
		color = v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
	end

	//

	v.drawScaled(anim, y - (3 * FRACUNIT), FRACUNIT, v.cachePatch(patch), flags, color)

	if (CV_FindVar("timerres").value == 3) then
		joeFuncs.drawNum(v, anim - (8 * FRACUNIT), y, info.tics, flags, "JOE_BNUM", "right", 7)
	else
		joeFuncs.drawNum(v, anim - (51 * FRACUNIT), y, G_TicsToMinutes(info.tics, true), flags, "JOE_BNUM", "right", 7)

		v.drawScaled(anim - (52 * FRACUNIT), y, FRACUNIT, v.cachePatch("JOE_COLON"), flags, nil)
		joeFuncs.drawNum(v, anim - (30 * FRACUNIT), y, G_TicsToSeconds(info.tics), flags, "JOE_BNUM", "right", 7, 2)

		v.drawScaled(anim - (30  * FRACUNIT), y, FRACUNIT, v.cachePatch("JOE_PERIO"), flags | V_HUDTRANS, nil)
		joeFuncs.drawNum(v, anim - (8 * FRACUNIT), y, G_TicsToCentiseconds(info.tics), flags, "JOE_BNUM", "right", 7, 2)
	end

	//
end

local function drawLives(v, player)
	//
	
	local x, y = (299 * FRACUNIT), (29 * FRACUNIT)
	local flags = V_SNAPTORIGHT | V_SNAPTOTOP | V_HUDTRANS | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (640 * FRACUNIT), x)

	local player_lives = ((player.lives == INFLIVES) or (netgame and (CV_FindVar("cooplives").value == 0))) and '\x16' or ("\x82x\x80" .. max(0, min(player.lives, 99)))
	local yoffs = G_GametypeUsesLives() and 1 or 3

	local patch = v.getSprite2Patch(player.skin, SPR2_XTRA, (player.powers[pw_super] > 0), A)
	local scale = FRACUNIT / 3
	
	local colormap = joeFuncs.getSkincolor(v, player, false)
	local health_color = (player.pflags & PF_GODMODE) and 131 or (((player.hp.current <= 5) and 36) or ((player.hp.current <= 10) and 73) or 113)

	//
	
	v.drawScaled(anim, y, scale, v.cachePatch("STLIVEBK"), flags, nil)
	v.drawScaled(anim, y, scale, patch, flags, colormap)

	if (player.hp.enabled) then
		//
		
		v.drawString(anim - (3 * FRACUNIT), y + FRACUNIT, joeFuncs.getPlayerName(player, 1) .. (G_GametypeUsesLives() and ("\x80 | " .. player_lives) or ""), flags | V_ALLOWLOWERCASE, "small-fixed-right")

		v.drawScaled(anim - (30 * FRACUNIT), y + (6 * FRACUNIT), FRACUNIT, v.cachePatch("JOE_HBAR"), flags, nil)
		joeFuncs.drawFill(v, anim - (29 * FRACUNIT), y + (7 * FRACUNIT), player.hp.current * FRACUNIT, FRACUNIT, health_color, flags)
		
		//
	else
		//

		v.drawString(anim - (3 * FRACUNIT), y + (yoffs * FRACUNIT), joeFuncs.getPlayerName(player, 1), flags | V_ALLOWLOWERCASE, "small-fixed-right")

		if G_GametypeUsesLives() then
			v.drawString(anim - (3 * FRACUNIT), y + (5 * FRACUNIT), player_lives, flags | V_ALLOWLOWERCASE, "small-fixed-right") 
		end
		
		//
	end
	
	//
end

local function drawInformation(v, player)
	//

	local x, y = 160, 190
	local flags = V_SNAPTOBOTTOM | V_ALLOWLOWERCASE | V_HUDTRANSHALF | V_PERPLAYER
	
	local players_finished = 0
	local players_needed = G_IsSpecialStage(gamemap) and 4 or CV_FindVar("playersforexit").value

	//

	local function drawText(str)
		v.drawString(x, y, str, flags, "thin-center")
		y = $ - 9
	end

	//

	if (player.exiting) and (players_needed) then
		for stplyr in players.iterate do
			if (stplyr.spectator) or (stplyr.bot) then continue end
			if (stplyr.lives < 0) then continue end
		
			if not (stplyr.exiting) or not (stplyr.pflags & PF_FINISHED) then
				players_finished = $ + 1
			end
		end
		
		if (players_needed ~= 4) then
			players_finished = $ * CV_FindVar("playersforexit").value

			if (players_finished & 3) then
				players_finished = $ + 4
			end

			players_finished = $ / 4
		end
		
		if (players_finished) then
			drawText("\x82" .. players_finished .. "\x80 Player" .. ((players_finished == 1) and "" or "s") .. " left.")
		end
	end

	//

	if (player.spectator) then
		if G_IsSpecialStage(gamemap) then
			drawText("Wait for the stage to end.")

		elseif G_PlatformGametype() and G_GametypeUsesCoopLives() then
			if (player.lives < 0) and (CV_FindVar("cooplives").value == 2) then
				drawText("You'll steal a life on respawn...")
			else
				drawText("Waiting to respawn...")	
			end

		elseif G_GametypeHasSpectators() then
			drawText("[\x82" .. "FIRE" .. "\x80] Join to the game")
		end

		drawText("[\x82" .. "SPIN" .. "\x80] Lower")
		drawText("[\x82" .. "JUMP" .. "\x80] Rise")
	end

	//

	if (gametyperules & GTR_RESPAWNDELAY) and ((player.playerstate == PST_DEAD) and player.lives) then
		local respawntime = CV_FindVar("respawndelay").value - (player.deadtimer / TICRATE)

		if (respawntime > 0) and not (player.spectator)
			drawText("Respawning in \x82" .. respawntime .. "\x80...")
		else
			drawText("[\x82" .. "JUMP" .. "\x80] Respawn")
		end
	end

	//

	if (player.spectator) then
		drawText("\x86" .. "- Spectator Mode -")
	end

	//
end

local function drawFirstPerson(v, player)
	//

	if (player.spectator) or (camera.chase) then return end

	//
 
	
	local x, y = (32 * FRACUNIT), (184 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_SNAPTOLEFT | V_HUDTRANS | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", joeVars.HUDTicker, (400 * FRACUNIT), y)

	local spr2, spr2flip = v.getSprite2Patch(player.skin, player.realmo.sprite2, (player.powers[pw_super] > 0), player.realmo.frame, 8, player.realmo.rollangle)
	local spr, sprflip = v.getSpritePatch(player.realmo.sprite, player.realmo.frame, 8, player.realmo.rollangle)

	local color = joeFuncs.getSkincolor(v, player, false)
	local mode = (player.realmo.sprite == SPR_PLAY) and 1 or 2

	//

	v.drawScaled(x, anim, (skins[player.skin].highresscale / 2), ({spr2, spr})[mode], (({spr2flip, sprflip})[mode] and V_FLIP or 0) | flags, color)

	//
end

//

local function drawHUD(v, player)
	//
	
	if G_IsSpecialStage(gamemap) then return end
	if not joeFuncs.isValid(player.realmo) then return end
	
	//
	
	for _, i in ipairs({"time", "rings", "lives", "score", "textspectator"}) do
		hud.disable(i)
	end

	//

	if (leveltime > 25) and not (joeVars.scoresKey) then
		joeVars.HUDTicker = min($ + 1, TICRATE)
	end

	if (joeVars.scoresKey) then
		joeVars.HUDTicker = max(0, $ - 1)
	end
	
	//

	drawScoreRings(v, player)
	drawTimer(v, player)
	drawLives(v, player)

	drawInformation(v, player)
	drawFirstPerson(v, player)

	//
end
hud.add(drawHUD, "game")

//