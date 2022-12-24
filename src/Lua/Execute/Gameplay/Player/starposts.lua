//

local function P_DidPress(player, button)
	return (player.cmd.buttons & button) and not (player.lastbuttons & button)
end

local function P_MovingThru(player, dir)
	local limit = 30
	local directions = {
		["left"] = (player.cmd.sidemove < -limit) and not (player.lastsidemove < -limit),
		["right"] = (player.cmd.sidemove > limit) and not (player.lastsidemove > limit),

		["up"] = (player.cmd.forwardmove > limit) and not (player.lastforwardmove > limit),
		["down"] = (player.cmd.forwardmove < -limit) and not (player.lastforwardmove < -limit)
	}

	return directions[dir]
end

//

local function M_CycleThru(value, increment)
	value = $ + increment

	if (value > #joeVars.starpostInfo) then
		value = 1
	elseif (value < 1) then
		value = #joeVars.starpostInfo
	end

	return value
end

//

local function handleStarposts()
	//

	for player in players.iterate do
		if (player.spectator) then continue end
		if (player.playerstate ~= PST_LIVE) then continue end

		local star = player.starinfo

		star.prevtics = max(0, $ - 1)
		star.menutics = (star.menu["enabled"] and not star.prevtics) and min($ + 2, TICRATE) or max(0, $ - 3)

		star.tics = (star.menu["enabled"]) and min($ + 2, TICRATE) or max(0, $ - 1)

		if (star.menu["enabled"]) then
			if P_MovingThru(player, "down") then
				star.menu["itemOn"] = M_CycleThru($, 1)
				S_StartSound(nil, sfx_menu1, player)
			end

			if P_MovingThru(player, "up") then
				star.menu["itemOn"] = M_CycleThru($, -1)
				S_StartSound(nil, sfx_menu1, player)
			end

			if P_DidPress(player, BT_SPIN) then
				star.menu["enabled"] = false
				S_StartSound(nil, sfx_addfil, player)
			end

			if P_DidPress(player, BT_JUMP) then
				for i, mo in ipairs(joeVars.starpostInfo) do
					if (star.menu["itemOn"] == i) then
						if not (mo.enabled) then
							S_StartSound(nil, sfx_adderr, player)
							break
						end

						P_TeleportMove(player.realmo, mo.x + FixedMul(-(mo.radius - FRACUNIT), cos(mo.angle + ANGLE_90)), mo.y + FixedMul(-(mo.radius - FRACUNIT), sin(mo.angle + ANGLE_90)), mo.z + mo.height)
						P_FlashPal(player, PAL_WHITE, 5)
						S_StartSound(nil, sfx_mixup, player)

						player.realmo.state = S_PLAY_FALL
						player.drawangle = mo.angle

						player.pflags = $ | PF_THOKKED
						star.menu["enabled"] = false
					end
				end
			end

			player.powers[pw_nocontrol] = 2
			player.powers[pw_flashing] = 2

			player.cmd.buttons = $ & (BT_JUMP | BT_SPIN)
		end

		player.lastsidemove = player.cmd.sidemove
		player.lastforwardmove = player.cmd.forwardmove
	end

	//
end
addHook("PreThinkFrame", handleStarposts)

//

local function insertInfo()
	//

	for mo in mobjs.iterate() do
		if (mo.type == MT_STARPOST) then
			table.insert(joeVars.starpostInfo, mo)
		end
	end

	table.sort(joeVars.starpostInfo, function(a, b)
		return ((a.spawnpoint.angle + (a.spawnpoint.extrainfo * 360)) < (b.spawnpoint.angle + (b.spawnpoint.extrainfo * 360)))
	end)

	//

	for player in players.iterate do
		if (player.valid) and (player.jinit) then
			player.starinfo.tics = 0
			player.starinfo.prevtics = 0
			player.starinfo.menutics = 0

			player.starinfo.menu["enabled"] = false
			player.starinfo.menu["itemOn"] = 1
		end
	end

	//
end
addHook("MapLoad", insertInfo)

local function starpostThink(mo)
	//

	for player in players.iterate do
		if (joeFuncs.getDist(mo, player.realmo) >= mo.height) then continue end

		if not (player.starinfo.menu["enabled"]) then
			player.starinfo.prevtics = min($ + 2, TICRATE + 1)

			if P_DidPress(player, BT_TOSSFLAG) then
				player.starinfo.menu["enabled"] = true
				S_StartSound(nil, sfx_strpst, player)
			end
		end
	end

	//

	local arrow = P_SpawnMobjFromMobj(mo, 0, 0, mo.height, MT_THOK)
	arrow.angle = mo.angle + ANGLE_90
	arrow.fuse = -1

	arrow.sprite = SPR_LCKN
	arrow.frame = $ | (FF_PAPERSPRITE | FF_ADD)

	arrow.renderflags = $ | (RF_FULLBRIGHT | RF_NOCOLORMAPS)
	arrow.color = SKINCOLOR_RED

	//

	mo.enabled = $ or ((mo.state == S_STARPOST_SPIN) or (mo.state == S_STARPOST_FLASH))

	//
end
addHook("MobjThinker", starpostThink, MT_STARPOST)

//