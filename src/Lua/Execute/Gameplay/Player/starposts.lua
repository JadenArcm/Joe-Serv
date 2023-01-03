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

local function M_CheckDist(player, mo)
	if (joeFuncs.getDist(mo, player.realmo) >= mo.radius) then return end

	if not (player.starinfo.menu["enabled"]) then
		player.starinfo.previous_tics = min($ + 2, TICRATE + 1)

		if P_DidPress(player, BT_TOSSFLAG) then
			player.starinfo.menu["enabled"] = true
			S_StartSound(nil, sfx_strpst, player)
		end
	end
end

local function M_SpawnArrow(mo, offset)
	local arrow = P_SpawnMobjFromMobj(mo, 0, 0, offset, MT_CUSTOMARROW)
	arrow.color = SKINCOLOR_GREEN
	arrow.colorized = true

	arrow.renderflags = $ | (RF_FULLBRIGHT | RF_NOCOLORMAPS)
end

//

local function handleStarposts()
	//

	for player in players.iterate do
		if (player.spectator) then continue end
		if (player.playerstate ~= PST_LIVE) then continue end

		local star = player.starinfo

		if (star.menu["enabled"]) then
			if P_MovingThru(player, "down") then
				star.menu["itemOn"] = M_CycleThru($, 1)
				S_StartSound(nil, sfx_menu1, player)
			end

			if P_MovingThru(player, "up") then
				star.menu["itemOn"] = M_CycleThru($, -1)
				S_StartSound(nil, sfx_menu1, player)
			end

			player.powers[pw_nocontrol] = 2
			player.powers[pw_flashing] = 1

			player.realmo.momx, player.realmo.momy = 0, 0
			player.cmd.buttons = $ & (BT_JUMP | BT_SPIN)
		end

		player.lastsidemove = player.cmd.sidemove
		player.lastforwardmove = player.cmd.forwardmove
	end

	//
end
addHook("PreThinkFrame", handleStarposts)

local function handlePlayers(player)
	//

	if (player.spectator) then return end

	if (player.playerstate ~= PST_LIVE) then
		player.starinfo.menu["enabled"] = false
		return
	end

	//

	local star = player.starinfo

	//

	star.previous_tics = max(0, $ - 1)
	star.teleport_tics = max(0, $ - 1)

	star.menu_tics = (star.menu["enabled"] and not star.previous_tics) and min($ + 2, TICRATE) or max(0, $ - 3)
	star.tics = (star.menu["enabled"]) and min($ + 2, TICRATE) or max(0, $ - 1)

	//

	if (star.menu["enabled"]) then
		if P_DidPress(player, BT_SPIN) then
			star.menu["enabled"] = false
			S_StartSound(nil, sfx_addfil, player)
		end

		if P_DidPress(player, BT_JUMP) then
			for i, info in ipairs(joeVars.starpostInfo) do
				if (star.menu["itemOn"] == i) then
					if (info.mobj) and not (info.mobj.enabled) then
						S_StartSound(nil, sfx_adderr, player)
						break
					end

					star.teleport_tics = 2 * TICRATE
					star.previous_mobj = info

					star.menu["enabled"] = false
					S_StartSound(nil, sfx_vwre, player)
				end
			end
		end
	end

	//

	if (star.teleport_tics > 0) then
		player.realmo.state = S_PLAY_SPRING
		player.drawangle = $ + ANG10

		player.powers[pw_nocontrol], player.powers[pw_flashing] = 2, 1

		player.realmo.momx, player.realmo.momy = 0, 0
		P_SetObjectMomZ(player.realmo, FRACUNIT, false)
	end

	if (star.teleport_tics == 1) then
		local info = star.previous_mobj
		local mo = {}

		if (info.type == 1) then
			mo.x, mo.y = (info.x * FRACUNIT), (info.y * FRACUNIT)
			mo.z = P_FloorzAtPos(mo.x, mo.y, info.z * FRACUNIT, player.realmo.height)

			mo.angle = 0
			mo.offset = 72 * FRACUNIT
		else
			mo.x, mo.y, mo.z = info.mobj.x, info.mobj.y, info.mobj.z

			mo.angle = info.mobj.angle + ANGLE_90
			mo.offset = info.mobj.height
		end

		P_TeleportMove(player.realmo, mo.x + (48 * cos(mo.angle)), mo.y + (48 * sin(mo.angle)), mo.z + mo.offset)
		P_FlashPal(player, PAL_WHITE, 5)

		S_StartSound(nil, sfx_mixup, player)
	end

	//
end
addHook("PlayerThink", handlePlayers)

//

local function insertInfo()
	//

	if (titlemapinaction) then return end

	//

	for mt in mapthings.iterate do
		if (mt.type == mobjinfo[MT_STARPOST].doomednum) then
			table.insert(joeVars.starpostInfo, mt)
			M_SpawnArrow(mt.mobj, mt.mobj.height)
		end
	end

	table.sort(joeVars.starpostInfo, function(a, b)
		return ((a.angle + (a.extrainfo * 360)) < (b.angle + (b.extrainfo * 360)))
	end)

	//

	for mt in mapthings.iterate do
		if (mt.type == 1) then
			table.insert(joeVars.starpostInfo, mt)
		end

		if (mt.type == mobjinfo[MT_SIGN].doomednum) then
			table.insert(joeVars.starpostInfo, mt)
			M_SpawnArrow(mt.mobj, mt.mobj.height * 3)
		end
	end

	//

	for player in players.iterate do
		if (player.valid) and (player.jinit) then
			player.starinfo.tics = 0
			player.starinfo.menu_tics = 0
			player.starinfo.previous_tics = 0
			player.starinfo.teleport_tics = 0

			player.starinfo.menu["enabled"] = false
			player.starinfo.menu["itemOn"] = 1
		end
	end

	//
end
addHook("MapLoad", insertInfo)

//

local function arrowThink(mo)
	//

	mo.spriteyoffset = 8 * cos((leveltime * 2) * ANG1)
	mo.angle = $ + FixedAngle(FRACUNIT)

	mo.blendmode = AST_ADD

	//
end
addHook("MobjThinker", arrowThink, MT_CUSTOMARROW)

//

local function starpostThink(mo)
	//

	for player in players.iterate do
		M_CheckDist(player, mo)
	end

	mo.enabled = $ or ((mo.state == S_STARPOST_SPIN) or (mo.state == S_STARPOST_FLASH))

	//
end
addHook("MobjThinker", starpostThink, MT_STARPOST)

//

local function signThink(mo)
	//

	for player in players.iterate do
		M_CheckDist(player, mo)
	end

	mo.enabled = $ or (joeFuncs.isValid(mo.target) and joeFuncs.isValid(mo.target.player))

	//
end
addHook("MobjThinker", signThink, MT_SIGN)

//
