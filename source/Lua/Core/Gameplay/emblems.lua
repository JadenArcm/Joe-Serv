--//

local emblemProperties = {
	{A, SKINCOLOR_ICY},
	{B, SKINCOLOR_RASPBERRY},
	{C, SKINCOLOR_SALMON},
	{D, SKINCOLOR_APRICOT},
	{E, SKINCOLOR_APPLE},
	{F, SKINCOLOR_GOLD},
}

local function spawnSparkles(mo, offs, zoffs, type)
	local mobj = P_SpawnMobjFromMobj(mo, 0, 0, zoffs[2], type)

	mobj.flags = $ & ~(MF_NOGRAVITY) | (MF_NOCLIP)
	mobj.renderflags = $ | RF_FULLBRIGHT

	mobj.color = mo.color
	mobj.colorized = true

	mobj.blendmode = AST_ADD
	mobj.fuse = 5 * TICRATE

	mobj.momx = P_RandomRange(-offs, offs) * FRACUNIT
	mobj.momy = P_RandomRange(-offs, offs) * FRACUNIT
	P_SetObjectMomZ(mobj, P_RandomRange(0, zoffs[1]) * FRACUNIT, false)
end

--//

addHook("MapLoad", function()
	for mt in mapthings.iterate do
		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end

		if joeFuncs.isValid(mt.mobj) then
			mt.mobj.flags2 = $ | MF2_DONTDRAW
		end

		local mo = P_SpawnMobj(mt.x * FRACUNIT, mt.y * FRACUNIT, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (18 * FRACUNIT) or 0

		mo.z = mo.floorz + (mt.z * FRACUNIT) + zoffs
		mo.orig = mt.angle + 1

		mo.frame = emblemProperties[mo.orig][1] | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = emblemProperties[mo.orig][2]
		mo.colorized = true

		joeVars.totalEmblems = $ + 1
		table.insert(joeVars.emblemInfo, mo)
	end
end)

--//

addHook("MobjThinker", function(mo)
	if not joeFuncs.isValid(mo) then return end

	if (mo.orig == nil) then
		if (mo.fuse > 1) then
			P_SetObjectMomZ(mo, (mo.fuse * FRACUNIT) / 12, false)
			P_InstaThrust(mo, mo.angle, (mo.fuse * mo.scale) / 5)

			mo.spritexoffset = P_RandomRange(-4, 4) * FRACUNIT
			mo.spriteyoffset = P_RandomRange(-4, 4) * FRACUNIT

		elseif (mo.fuse == 1) then
			local expl = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
			expl.state = S_STOCKEXPLOSION
			expl.fuse = TICRATE

			for player in players.iterate do
				if (joeFuncs.getDistance(mo, player.realmo) <= (512 * FRACUNIT)) then
					P_StartQuake(64 * FRACUNIT, 7)
					S_StartSoundAtVolume(nil, sfx_emjexp, 200, player)
				end
			end
		end

		mo.frame = P
		mo.color = SKINCOLOR_SILVER
		mo.blendmode = AST_REVERSESUBTRACT
		return
	end

	local bounce = abs(cos((leveltime * 3) * ANG1))
	mo.renderflags = $ | (RF_NOCOLORMAPS)
	mo.shadowscale = (2 * FRACUNIT) / 3

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
			if (joeFuncs.getDistance(mo, player.mo) <= (1024 * FRACUNIT)) then
				P_StartQuake(12 * FRACUNIT, 5)
			end
		end

		S_StartSound(mo, sfx_emjexp, nil)

		mo.fuse = -1
		mo.flags2 = $ | MF2_DONTDRAW

	else
		mo.angle = $ + FixedAngle(2 * FRACUNIT)
		mo.spriteyoffset = (14 * bounce)

		if (mo.health) and not (bounce) then
			S_StartSound(mo, sfx_s1c9, nil)

			for i = 1, 4 do
				spawnSparkles(mo, 4, {6, mo.height}, MT_BOXSPARKLE)
			end
		end
	end
end, MT_COOPEMBLEM)

--//

addHook("TouchSpecial", function(mo, toucher)
	if not (joeFuncs.isValid(mo) and mo.health) then return end
	if not joeFuncs.isValid(toucher.player) then return end

	if (mo.orig == nil) then
		mo.fuse = TICRATE
		mo.health = 0

		P_DoPlayerPain(toucher.player)
		S_StartSound(toucher, skins[toucher.skin].soundsid[SKSPLDET1], nil)
		return true
	end

	local amount = string.format("\x80(\x82%d\x80 - \x82%d\x80)", joeVars.collectedEmblems + 1, joeVars.totalEmblems)

	mo.fuse = TICRATE + 17
	mo.angle = R_PointToAngle2(mo.x, mo.y, toucher.x, toucher.y) - FixedAngle(38 * FRACUNIT)

	mo.health = 0
	joeVars.collectedEmblems = $ + 1

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		S_StartSound(nil, sfx_emjall)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found the last emblem! " .. amount)

		P_FlashPal(toucher.player, PAL_WHITE, 8)
		P_AddPlayerScore(toucher.player, 50000)
	else
		S_StartSound(nil, sfx_emjgot)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found emblem \x84#" .. mo.orig .. "\x82! " .. amount)

		P_AddPlayerScore(toucher.player, 5000)
	end

	return true
end, MT_COOPEMBLEM)

--//