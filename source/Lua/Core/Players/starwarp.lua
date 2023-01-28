--//

local function P_PressedButton(player, button)
	return (player.cmd.buttons & button) and not (player.lastbuttons & button)
end

local function P_WasMoving(player, dir)
	local maxdir = 30
	local directions = {
		["left"] = (player.cmd.sidemove < -maxdir) and not (player.lastsidemove < -maxdir),
		["right"] = (player.cmd.sidemove > maxdir) and not (player.lastsidemove > maxdir),
	}

	return directions[dir]
end

local function P_CheckDist(ref, player)
	if (joeFuncs.getDistance(ref, player.realmo) >= ref.radius) then return end

	if not (player.starwarp.enabled) then
		player.starwarp.hover_tics = min($ + 2, TICRATE)

		if P_PressedButton(player, BT_TOSSFLAG) then
			player.starwarp.enabled = true
			S_StartSound(nil, sfx_strpst, player)
		end
	end
end

--//

local function handleMenu()
	if (gamestate ~= GS_LEVEL) then return end

	for player in players.iterate do
		if (player.spectator) then continue end

		if (leveltime < 3) then
			player.starwarp.enabled = false
			player.starwarp.cursor = 1
			player.starwarp.tics = 0
		end

		if (player.starwarp.enabled) then
			if P_WasMoving(player, "left") and (player.starwarp.cursor > 1) then
				player.starwarp.cursor = $ - 1
				S_StartSound(nil, sfx_menu1, player)
			end

			if P_WasMoving(player, "right") and (player.starwarp.cursor < #joeVars.starWarps) then
				player.starwarp.cursor = $ + 1
				S_StartSound(nil, sfx_menu1, player)
			end

			player.powers[pw_nocontrol] = 5
			player.realmo.momx, player.realmo.momy = 0, 0
		end

		player.lastsidemove = player.cmd.sidemove
	end
end
addHook("PreThinkFrame", handleMenu)

local function handleWarp(player)
	if (player.spectator) then return end

	player.starwarp.tics = (player.starwarp.enabled) and min($ + 1, TICRATE) or max(0, $ - 1)

	if (player.starwarp.hover_tics > 0) then
		player.starwarp.hover_tics = max(0, $ - 1)
	end

	if (player.starwarp.enabled) then
		local mo = player.realmo
		local warp = joeVars.starWarps[player.starwarp.cursor].mobj

		if P_PressedButton(player, BT_SPIN) then
			player.starwarp.enabled = false
			S_StartSound(nil, sfx_addfil, player)
		end

		if P_PressedButton(player, BT_JUMP) then
			if not (warp.enabled) then
				S_StartSound(nil, sfx_adderr, player)
				return
			end

			if joeFuncs.isValid(warp) then
				P_TeleportMove(mo, warp.x + (42 * cos(warp.angle - ANGLE_90)), warp.y + (42 * sin(warp.angle - ANGLE_90)), warp.z)
				P_ResetPlayer(player)

				S_StartSound(nil, sfx_mixup, player)
				P_FlashPal(player, PAL_WHITE, 7)

				mo.angle = warp.angle
				mo.scale = warp.scale
				player.drawangle = mo.angle

				mo.state = S_PLAY_FALL
				mo.flags2 = $ | (warp.flags2 & MF2_TWOD)

				player.starwarp.enabled = false
			end
		end
	end
end
addHook("PlayerThink", handleWarp)

--//

local function insertInfo()
	if (titlemapinaction) then return end

	for mt in mapthings.iterate do
		if (mt.type == mobjinfo[MT_STARPOST].doomednum) then
			table.insert(joeVars.starWarps, mt)
		end
	end

	table.sort(joeVars.starWarps, function(a, b)
		return (a.mobj.health < b.mobj.health)
	end)
end
addHook("MapLoad", insertInfo)

local function handleDist(mo)
	for player in players.iterate do
		P_CheckDist(mo, player)
	end

	mo.enabled = (mo.state == S_STARPOST_SPIN) or (mo.state == S_STARPOST_FLASH)
end
addHook("MobjThinker", handleDist, MT_STARPOST)

--//