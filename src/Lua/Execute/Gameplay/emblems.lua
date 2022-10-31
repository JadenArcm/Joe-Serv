//

local emblemInfo = {
	[0] = {A, SKINCOLOR_BLUE},
	{B, SKINCOLOR_LAVENDER},
	{C, SKINCOLOR_RED},
	{D, SKINCOLOR_ORANGE},
	{E, SKINCOLOR_GREEN},
	{F, SKINCOLOR_YELLOW},
	{G, SKINCOLOR_COBALT}
}

//

local function spawnEmblems()
	//

	for mt in mapthings.iterate do
		//

		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end

		//

		local mo = P_SpawnMobj(mt.x * FRACUNIT, mt.y * FRACUNIT, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (18 * FRACUNIT) or 0

		//

		mo.z = mo.floorz + (mt.z * FRACUNIT) + zoffs
		
		mo.oldz = mo.z
		mo.orig = mt.angle

		mo.frame = emblemInfo[mo.orig][1] | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = emblemInfo[mo.orig][2]

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

	mo.shadowscale = (2 * FRACUNIT) / 3
	mo.angle = $ + FixedAngle(2 * FRACUNIT)

	mo.z = mo.oldz + (12 * abs(cos(leveltime * ANG2)))

	//

	if not (mo.health) then
		mo.frame = $ | FF_TRANS50
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

	joeVars.collectedEmblems = $ + 1
	mo.health = 0

	//

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		S_StartSound(toucher, sfx_s3kac)
		P_AddPlayerScore(toucher.player, 50000)

		P_FlashPal(toucher.player, PAL_WHITE, 5)
	else
		S_StartSound(toucher, sfx_nxitem)
		P_AddPlayerScore(toucher.player, 5000)
	end

	//

	return true
	
	//
end
addHook("TouchSpecial", touchedEmblem, MT_COOPEMBLEM)

//