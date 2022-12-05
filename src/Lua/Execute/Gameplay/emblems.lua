//

local function spawnSparkles(mo, offs, zoffs, type)
	//

	local mobj = P_SpawnMobjFromMobj(mo, 0, 0, 0, type)

	mobj.flags = $ & ~(MF_NOGRAVITY) | (MF_NOCLIP)
	mobj.scale = FRACUNIT + P_RandomFixed()

	mobj.color = mo.color
	mobj.colorized = true

	mobj.blendmode = AST_ADD
	mobj.fuse = 5 * TICRATE

	mobj.momx = P_RandomRange(-offs, offs) * FRACUNIT
	mobj.momy = P_RandomRange(-offs, offs) * FRACUNIT
	P_SetObjectMomZ(mobj, P_RandomRange(0, zoffs) * FRACUNIT, false)

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

		mo.frame = P_RandomRange(0, 19) | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = P_RandomRange(1, FIRSTSUPERCOLOR - 1)
		mo.colorized = true

		//

		joeVars.totalEmblems = $ + 1
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

	if (mo.fuse > 1) then
		mo.angle = $ + FixedAngle((mo.fuse * FRACUNIT) / 2)
		mo.blendmode = AST_ADD

		P_SetObjectMomZ(mo, (mo.fuse * FRACUNIT) / 26, false)

	elseif (mo.fuse == 1) then
		for i = 1, 8 do
			spawnSparkles(mo, 10, 5, MT_BOXSPARKLE)
		end

		S_StartSound(mo, sfx_s1c9, nil)

		mo.fuse = -1
		mo.flags2 = $ | MF2_DONTDRAW

	else
		mo.angle = $ + FixedAngle(2 * FRACUNIT)
		mo.z = mo.oldz + (16 * abs(cos((leveltime * 3) * ANG1)))
	end

	mo.shadowscale = (2 * FRACUNIT) / 3

	//
end
addHook("MobjThinker", emblemThink, MT_COOPEMBLEM)

//

local function touchedEmblem(mo, toucher)
	//

	if not (joeFuncs.isValid(mo) and mo.health) then return end
	if not joeFuncs.isValid(toucher.player) then return end

	//

	local amount = string.format("\x80(\x82%d\x80 / \x87%d\x80)", joeVars.collectedEmblems + 1, joeVars.totalEmblems)
	local emblem_id = (mo.orig + 1)

	//

	mo.fuse = TICRATE + 17
	mo.angle = R_PointToAngle2(mo.x, mo.y, toucher.x, toucher.y) - FixedAngle(60 * FRACUNIT)

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
