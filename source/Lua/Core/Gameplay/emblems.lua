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

	mobj.momx = P_RandomRange(-offs, offs) * FU
	mobj.momy = P_RandomRange(-offs, offs) * FU
	P_SetObjectMomZ(mobj, P_RandomRange(0, zoffs[1]) * FU, false)
end

--//

addHook("MapLoad", function()
	if (titlemapinaction) then return end

	for mt in mapthings.iterate do
		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end

		if joeFuncs.isValid(mt.mobj) then
			mt.mobj.flags2 = $ | MF2_DONTDRAW
		end

		local mo = P_SpawnMobj(mt.x * FU, mt.y * FU, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (18 * FU) or 0

		mo.z = mo.floorz + (mt.z * FU) + zoffs
		mo.orig = mt.angle + 1

		mo.frame = emblemProperties[mo.orig][1] | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = emblemProperties[mo.orig][2]
		mo.colorized = true

		table.insert(joeVars.emblemInfo, mo)
	end

	table.sort(joeVars.emblemInfo, function(a, b)
		return (a.orig < b.orig)
	end)
end)

--//

addHook("MobjThinker", function(mo)
	if not joeFuncs.isValid(mo) then return end

	if (mo.orig == nil) then
		if (mo.fuse > 1) then
			P_SetObjectMomZ(mo, (mo.fuse * FU) / 12, false)
			P_InstaThrust(mo, mo.angle, (mo.fuse * mo.scale) / 5)

			mo.spritexoffset = P_RandomRange(-4, 4) * FU
			mo.spriteyoffset = P_RandomRange(-4, 4) * FU

		elseif (mo.fuse == 1) then
			local expl = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
			expl.state = S_STOCKEXPLOSION
			expl.fuse = TICRATE

			for player in players.iterate do
				if (joeFuncs.getDistance(mo, player.realmo) <= (512 * FU)) then
					P_StartQuake(64 * FU, 7)
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
	mo.shadowscale = (2 * FU) / 3

	if (mo.fuse > 1) then
		mo.angle = $ + FixedAngle(mo.fuse * FU)
		mo.blendmode = AST_ADD

		P_SetObjectMomZ(mo, (mo.fuse * FU) / 25, false)

	elseif (mo.fuse == 1) then
		for i = 1, 8 do
			spawnSparkles(mo, 10, {15, 0}, MT_BOXSPARKLE)
		end

		local expl = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
		expl.state = S_STOCKEXPLOSION
		expl.fuse = TICRATE

		for player in players.iterate do
			if (joeFuncs.getDistance(mo, player.mo) <= (1024 * FU)) then
				P_StartQuake(12 * FU, 5)
			end
		end

		S_StartSound(mo, sfx_emjexp, nil)

		mo.fuse = -1
		mo.flags2 = $ | MF2_DONTDRAW

	else
		mo.angle = $ + FixedAngle(2 * FU)
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

	mo.fuse = TICRATE + 17
	mo.angle = R_PointToAngle2(mo.x, mo.y, toucher.x, toucher.y) - FixedAngle(38 * FU)

	mo.health = 0
	joeVars.collectedEmblems = $ + 1

	if (joeVars.collectedEmblems >= #joeVars.emblemInfo) then
		S_StartSound(nil, sfx_emjall)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found the last emblem!")

		P_FlashPal(toucher.player, PAL_WHITE, 8)
		P_AddPlayerScore(toucher.player, 50000)
	else
		S_StartSound(nil, sfx_emjgot)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 found emblem \x84#" .. mo.orig .. "\x82!")

		P_AddPlayerScore(toucher.player, 5000)
	end

	return true
end, MT_COOPEMBLEM)

--//