//

local emblemProperties = {
	[0] = {C, SKINCOLOR_KETCHUP},
	{E, SKINCOLOR_MINT},
	{F, SKINCOLOR_GOLD},
	{G, SKINCOLOR_ICY},
	{P, SKINCOLOR_RASPBERRY},
	{L, SKINCOLOR_YELLOW}
}

local function spawnSparkles(mo, offs, zoffs, type)
	//

	local mobj = P_SpawnMobjFromMobj(mo, 0, 0, zoffs[2], type)

	mobj.flags = $ & ~(MF_NOGRAVITY) | (MF_NOCLIP)
	mobj.renderflags = $ | (RF_FULLBRIGHT | RF_NOCOLORMAPS)

	mobj.destscale = FRACUNIT + P_RandomFixed()

	mobj.color = mo.color
	mobj.colorized = true

	mobj.blendmode = AST_ADD
	mobj.fuse = 5 * TICRATE

	mobj.momx = P_RandomRange(-offs, offs) * FRACUNIT
	mobj.momy = P_RandomRange(-offs, offs) * FRACUNIT
	P_SetObjectMomZ(mobj, P_RandomRange(0, zoffs[1]) * FRACUNIT, false)

	//
end

//

local function spawnEmblems(nummap)
	//

	for mt in mapthings.iterate do
		//

		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end

		local mo = P_SpawnMobj(mt.x * FRACUNIT, mt.y * FRACUNIT, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (12 * FRACUNIT) or 0

		//

		mo.z = mo.floorz + (mt.z * FRACUNIT) + zoffs
		mo.oldz = mo.z

		mo.orig = mt.angle
		mo.frame = emblemProperties[mt.angle][1] | (FF_PAPERSPRITE | FF_FULLBRIGHT)

		mo.color = emblemProperties[mt.angle][2]
		mo.colorized = true

		//

		joeVars.totalEmblems = $ + 1
		mt.mobj.flags2 = $ | MF2_DONTDRAW

		table.insert(joeVars.emblemInfo, mo)

		//
	end

	//
end
addHook("MapLoad", spawnEmblems)

//

local function emblemThink(mo)
	//

	if not joeFuncs.isValid(mo) then return end

	//

	if not (mo.orig or mo.oldz) then
		if (mo.fuse > 1) then
			P_SetObjectMomZ(mo, (mo.fuse * FRACUNIT) / 12, false)
			P_InstaThrust(mo, mo.angle, (mo.fuse * mo.scale) / 4)

			mo.spritexoffset = P_RandomRange(-4, 4) * FRACUNIT
			mo.spriteyoffset = P_RandomRange(-4, 4) * FRACUNIT

		elseif (mo.fuse == 1) then
			local expl = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
			expl.state = S_STOCKEXPLOSION
			expl.fuse = TICRATE

			for player in players.iterate do
				if (joeFuncs.getDist(mo, player.mo) <= (1024 * FRACUNIT)) then
					P_StartQuake(64 * FRACUNIT, 5)
				end
			end

			S_StartSound(expl, sfx_jexpl, nil)
		end

		mo.frame = P
		mo.color = SKINCOLOR_SILVER
		mo.blendmode = AST_REVERSESUBTRACT
		return
	end

	//

	local bounce = abs(cos((leveltime * 3) * ANG1))

	//

	mo.renderflags = $ | (RF_NOCOLORMAPS)
	mo.shadowscale = (2 * FRACUNIT) / 3

	//

	if (mo.fuse > 1) then
		mo.angle = $ + FixedAngle(mo.fuse * FRACUNIT)
		mo.blendmode = AST_ADD

		P_SetObjectMomZ(mo, (mo.fuse * FRACUNIT) / 25, false)

	elseif (mo.fuse == 1) then
		for i = 1, 8 do
			spawnSparkles(mo, 10, {15, 0}, MT_BOXSPARKLE)
		end

		local expl = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
		expl.state = S_STOCKEXPLOSION
		expl.fuse = TICRATE

		for player in players.iterate do
			if (joeFuncs.getDist(mo, player.mo) <= (512 * FRACUNIT)) then
				P_StartQuake(12 * FRACUNIT, 5)
			end
		end

		S_StartSound(mo, sfx_jmbspk, nil)

		mo.fuse = -1
		mo.flags2 = $ | MF2_DONTDRAW

	else
		mo.angle = $ + FixedAngle(2 * FRACUNIT)
		mo.z = mo.oldz + (16 * bounce)

		if (mo.health) and not (bounce) then
			S_StartSound(mo, sfx_s1c9, nil)

			for i = 1, 4 do
				spawnSparkles(mo, 4, {6, mo.height}, MT_BOXSPARKLE)
			end
		end
	end

	//
end
addHook("MobjThinker", emblemThink, MT_COOPEMBLEM)

//

local function touchedEmblem(mo, toucher)
	//

	if not (joeFuncs.isValid(mo) and mo.health) then return end
	if not joeFuncs.isValid(toucher.player) then return end

	//

	if not (mo.orig or mo.oldz) then
		mo.fuse = TICRATE
		mo.health = 0

		P_InstaThrust(toucher, mo.angle + ANGLE_180, 6 * toucher.scale)
		P_SetObjectMomZ(toucher, 8 * FRACUNIT, false)

		toucher.state = S_PLAY_PAIN
		S_StartSound(toucher, skins[toucher.skin].soundsid[SKSPLDET1], nil)
		return true
	end

	//

	local amount = string.format("\x80(\x87%d\x80 - \x85%d\x80)", joeVars.collectedEmblems + 1, joeVars.totalEmblems)
	local emblem_id = (mo.orig + 1)

	//

	mo.fuse = TICRATE + 17
	mo.angle = R_PointToAngle2(mo.x, mo.y, toucher.x, toucher.y) - FixedAngle(38 * FRACUNIT)

	mo.health = 0
	joeVars.collectedEmblems = $ + 1

	//

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		S_StartSound(nil, sfx_jmball)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found the last emblem! (\x87#" .. emblem_id .. "\x82)")

		P_FlashPal(toucher.player, PAL_WHITE, 8)
		P_AddPlayerScore(toucher.player, 50000)
	else
		S_StartSound(nil, sfx_jmbgot)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found emblem \x87#" .. emblem_id .. "\x82! " .. amount)

		P_AddPlayerScore(toucher.player, 5000)
	end

	//

	return true

	//
end
addHook("TouchSpecial", touchedEmblem, MT_COOPEMBLEM)

//
