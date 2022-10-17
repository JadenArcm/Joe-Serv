//

local damagetypes = {
	[DMG_NUKE] = 25,
	[DMG_WATER] = 10,
	[DMG_FIRE] = 7,
	[DMG_ELECTRIC] = 5,
	[DMG_SPIKE] = 3,

	[DMG_INSTAKILL] = INT8_MAX,
	[DMG_DROWNED] = INT8_MAX,
	[DMG_SPACEDROWN] = INT8_MAX,
	[DMG_CRUSHED] = INT8_MAX,
	[DMG_DEATHPIT] = INT8_MAX
}
//

local function handleHealth(player)
	//

	if not (player.hp.enabled) then return end
	
	if not joeFuncs.isValid(player.mo) then return end
	if (player.playerstate ~= PST_LIVE) or (player.spectator) then return end
	if (player.pflags & PF_GODMODE) then return end

	//

	player.hp.delay = max(0, $ - 1)

	if not (player.hp.delay) and ((leveltime % (TICRATE * 3)) == 0) then
		player.hp.current = min($ + 1, player.hp.max)
		
		if not (player.hp.current >= player.hp.max) then
			S_StartSoundAtVolume(nil, sfx_jheal, 90, player)
		end
	end

	//
end
addHook("PlayerThink", handleHealth)

//

local function getDamaged(mo, _, src, dmg, dmgtype)
	//

	local player = mo.player
	local damage = damagetypes[dmgtype] or dmg

	//
	
	if not (player.hp.enabled) then return end
	
	if not joeFuncs.isValid(mo) then return end
	if (player.playerstate ~= PST_LIVE) or (player.spectator) then return end
	if (player.pflags & PF_GODMODE) then return end
	
	if (player.powers[pw_super] > 0) or (player.powers[pw_flashing] > 0) or (player.powers[pw_invulnerability] > 0) then return false end
	
	if (dmgtype == DMG_INSTAKILL) or (dmgtype == DMG_DROWNED) or (dmgtype == DMG_SPACEDROWN) or (dmgtype == DMG_DEATHPIT) or (dmgtype == DMG_CRUSHED) then return true end
	if player.powers[pw_shield] then return nil end
	
	//
	
	if (damage) then
		player.hp.current = max(0, $ - damage)	
		player.hp.delay = TICRATE * 5

		P_ResetPlayer(player)
		mo.state = S_PLAY_PAIN

		P_SetObjectMomZ(mo, (mo.eflags & MFE_UNDERWATER) and (3 * FRACUNIT) or (6 * FRACUNIT), false)
		P_InstaThrust(mo, mo.angle + ANGLE_180, 10 * mo.scale)

		player.powers[pw_flashing] = P_RandomRange(TICRATE, TICRATE * 2)
		
		if (player.hp.current) then
			S_StartSound(mo, sfx_jhurt)

			if (player == displayplayer) then
				P_StartQuake(12 * FRACUNIT, 8)
			end
		end
	end

	if (player.hp.current == (player.hp.max / 4)) then
		S_StartSound(nil, sfx_jwarn, player)
	end

	//

	if not (player.hp.current) then
		P_KillMobj(mo)
	end
	
	//
	
	return false
	
	//
end
addHook("ShouldDamage", getDamaged, MT_PLAYER)

//

local function setHealth(player)
	//

	if (player.hp.enabled) then
		player.hp.current = player.hp.max
		player.hp.delay = 0
	end

	//
end
addHook("PlayerSpawn", setHealth)

//