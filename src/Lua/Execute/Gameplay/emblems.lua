//

local emblemInfo = {
	[0] = {A, SKINCOLOR_BLUE},
	{B, SKINCOLOR_LAVENDER},
	{C, SKINCOLOR_RED},
	{D, SKINCOLOR_ORANGE},
	{E, SKINCOLOR_EMERALD},
	{F, SKINCOLOR_GOLD},
	{G, SKINCOLOR_CERULEAN},

	{L, SKINCOLOR_YELLOW},
	{M, SKINCOLOR_COBALT},
	{P, SKINCOLOR_KETCHUP}
}

local MAXSPINV = (2 * FRACUNIT)

//

local function spawnEmblems(nummap)
	//

	for mt in mapthings.iterate do
		//

		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end

		local mo = P_SpawnMobj(mt.x * FRACUNIT, mt.y * FRACUNIT, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (18 * FRACUNIT) or 0
		local frame = (mapheaderinfo[nummap].typeoflevel & TOL_NIGHTS) and (mt.angle + 7) or mt.angle

		//

		mo.z = mo.floorz + (mt.z * FRACUNIT) + zoffs

		mo.oldz = mo.z
		mo.orig = mt.angle
		mo.spinang = 0

		mo.frame = emblemInfo[frame][1] | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = emblemInfo[frame][2]

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

	if (mo.spinang > 0) then
		mo.spinang = max(MAXSPINV, $ - (FRACUNIT / 4))
	end

	if not (mo.health) then
		mo.frame = $ | FF_TRANS50
	end

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		mo.frame = $ & ~(FF_TRANS50)
		mo.blendmode = AST_ADD
	end

	//

	mo.shadowscale = (2 * FRACUNIT) / 3
	mo.angle = $ + FixedAngle((mo.spinang > 0) and mo.spinang or MAXSPINV)

	mo.z = mo.oldz + (16 * abs(cos((leveltime * 3) * ANG1)))

	//
end
addHook("MobjThinker", emblemThink, MT_COOPEMBLEM)

//

local function touchedEmblem(mo, toucher)
	//

	if not (joeFuncs.isValid(mo) and mo.health) then return end
	if not joeFuncs.isValid(toucher.player) then return end

	//

	local amount = string.format("(\x84%d\x82 / \x8A%d\x82)", joeVars.collectedEmblems + 1, joeVars.totalEmblems)
	local emblem_id = (mo.orig + 1)

	//

	joeVars.collectedEmblems = $ + 1

	mo.health = 0
	mo.spinang = TICRATE * FRACUNIT

	P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_SPARK)

	//

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		S_StartSound(nil, sfx_jmball)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 collected the last emblem! (\x87#" .. emblem_id .. "\x82)")

		P_AddPlayerScore(toucher.player, 50000)
	else
		S_StartSound(nil, sfx_jmbgot)
		chatprint("\x82* " .. joeFuncs.getPlayerName(toucher.player, 0) .. "\x82 collected emblem \x87#" .. emblem_id .. "\x82. " .. amount)

		P_AddPlayerScore(toucher.player, 5000)
	end

	//

	return true

	//
end
addHook("TouchSpecial", touchedEmblem, MT_COOPEMBLEM)

//
