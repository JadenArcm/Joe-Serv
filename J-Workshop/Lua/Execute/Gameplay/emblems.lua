//

local emblemColors = {SKINCOLOR_MINT, SKINCOLOR_RUBY, SKINCOLOR_JET, SKINCOLOR_SUNSET, SKINCOLOR_LIME, SKINCOLOR_VAPOR, SKINCOLOR_ICY, SKINCOLOR_RASPBERRY}

//

local function spawnEmblems()
	//
	
	for mt in mapthings.iterate do
		//
		
		if (mt.type ~= mobjinfo[MT_EMBLEM].doomednum) then continue end
		
		//
		
		local mo = P_SpawnMobj(mt.x * FRACUNIT, mt.y * FRACUNIT, 0, MT_COOPEMBLEM)
		local zoffs = (mt.options & MTF_AMBUSH) and (24 * FRACUNIT) or 0
		
		//
		
		mo.frame = P_RandomRange(0, 19) | (FF_PAPERSPRITE | FF_FULLBRIGHT)
		mo.color = emblemColors[P_RandomRange(1, #emblemColors)]
		
		mo.z = mo.floorz + (mt.z * FRACUNIT) + zoffs
		mo.oldz = mo.z
		
		//
		
		joeVars.totalEmblems = $ + 1
		table.insert(joeVars.emblemInfo, {mo, mt})
		
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
	
	mo.z = mo.oldz + (12 * cos(ANG2 * leveltime))
	
	//
	
	if not (mo.health) then
		mo.frame = $ | (FF_TRANS50)
	end
	
	//
end
addHook("MobjThinker", emblemThink, MT_COOPEMBLEM)

//

local function touchedEmblem(mo, toucher)
	//
	
	if not (joeFuncs.isValid(mo) and mo.health) then return end
	
	//
	
	local player = toucher.player
	
	if joeFuncs.isValid(player) then
		joeVars.collectedEmblems = $ + 1
		mo.health = 0
		
		if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
			S_StartSound(toucher, sfx_nxdone)
			P_AddPlayerScore(player, 50000)
			P_FlashPal(player, PAL_WHITE, 5)
		else
			S_StartSound(toucher, sfx_ncitem)
			P_AddPlayerScore(player, 5000)
		end

		return true
	end
	
	//
end
addHook("TouchSpecial", touchedEmblem, MT_COOPEMBLEM)

//