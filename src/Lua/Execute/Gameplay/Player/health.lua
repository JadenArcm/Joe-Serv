//

local damagetypes = {
	[DMG_WATER]	   = 10,
	[DMG_FIRE]	   = 7,
	[DMG_ELECTRIC] = 5,
	[DMG_SPIKE]    = 3,
	[DMG_NUKE]	   = 25,

	[DMG_INSTAKILL]  = INT8_MAX,
	[DMG_DROWNED]    = INT8_MAX,
	[DMG_SPACEDROWN] = INT8_MAX,
	[DMG_DEATHPIT] 	 = INT8_MAX,
	[DMG_CRUSHED]    = INT8_MAX
}

//

local function healHealth(player)
	//

	if not joeFuncs.isValid(player) then return end
	if not (player.hp.enabled) then return end

	//

	if (player.hp.delay) and (player.hp.health) then
		player.hp.delay = max(0, $ - 1)
	end

	if not (player.hp.soundp) and (player.hp.current <= (player.hp.max / 4)) then
		S_StartSound(nil, sfx_jwarn, player)
		player.hp.soundp = true
	end

	//

	if (leveltime % 2) and not (player.hp.delay) then
		player.hp.current = min($ + (FRACUNIT / 24), player.hp.max)
	end

	//
end
addHook("PlayerThink", healHealth)

//

local function getDamaged(mo, _, src, dmg, dmgtype)
	//

	local player = mo.player
	local damage = damagetypes[dmgtype] or dmg

	//

	if not (player.hp.enabled) then return end

	if not joeFuncs.isValid(mo) then return end
	if (player.playerstate ~= PST_LIVE) or (player.spectator) then return end

	if (player.pflags & PF_GODMODE) then return false end

	for _, types in ipairs({DMG_CRUSHED, DMG_DROWNED, DMG_DEATHPIT, DMG_INSTAKILL, DMG_SPACEDROWN}) do
		if (dmgtype == types) then
			player.hp.current = 0
			return true
		end
	end

	for _, powers in ipairs({pw_super, pw_invulnerability, pw_flashing}) do
		if (player.powers[powers] > 0) then return false end
	end

	if player.powers[pw_shield] then return nil end

	//

	if (damage) then
		player.hp.current = max(0, $ - (damage * FRACUNIT))
		player.hp.delay = 5 * TICRATE

		P_SetObjectMomZ(mo, (mo.eflags & MFE_UNDERWATER) and (3 * FRACUNIT) or (6 * FRACUNIT), false)
		P_InstaThrust(mo, mo.angle + ANGLE_180, 10 * mo.scale)

		P_ResetPlayer(player)
		mo.state = S_PLAY_PAIN

		player.powers[pw_flashing] = TICRATE + (TICRATE / 2)

		if (player.hp.current >= (player.hp.max / 4)) then
			player.hp.soundp = false
		end

		if (player.hp.current) then
			S_StartSound(mo, sfx_jhurt)

			if (player == displayplayer) then
				P_StartQuake(12 * FRACUNIT, 8)
			end
		end
	end

	//

	if not (player.hp.current) then
		P_KillMobj(mo, nil, nil, dmgtype)
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
		player.hp.delay = TICRATE
	end

	//
end
addHook("PlayerSpawn", setHealth)

//
