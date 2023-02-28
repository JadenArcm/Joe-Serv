--//

local damageTypes = {
	[DMG_ELECTRIC] = 15,
	[DMG_WATER] = 12,
	[DMG_FIRE] = 6,

	[DMG_SPIKE] = 8,
	[DMG_NUKE] = 25,

	[DMG_CRUSHED] = UINT8_MAX,
	[DMG_DROWNED] = UINT8_MAX,
	[DMG_DEATHPIT] = UINT8_MAX,
	[DMG_INSTAKILL] = UINT8_MAX,
	[DMG_SPACEDROWN] = UINT8_MAX,
}

local function getDamageInfo(mo, src, inf)
	local angle, speed = 0, 0
	local player = mo.player

	if joeFuncs.isValid(inf) then
		angle = (inf.type == MT_WALLSPIKE) and inf.angle or R_PointToAngle2(inf.x - inf.momx, inf.y - inf.momy, mo.x - mo.momx, mo.y - mo.momy)

		if (inf.flags2 & MF2_SCATTER) and joeFuncs.isValid(src) then
			speed = max(FixedMul(4 * FU, inf.scale), FixedMul(128 * FU, inf.scale) - (joeFuncs.getDistance(src, mo) / 4))

		elseif (inf.flags2 & MF2_EXPLOSION) then
			speed = (inf.flags2 & MF2_RAILRING) and FixedMul(38 * FU, inf.scale) or FixedMul(30 * FU, inf.scale)

		elseif (inf.flags2 & MF2_RAILRING) then
			speed = FixedMul(45 * FU, inf.scale)
		else
			speed = FixedMul(4 * FU, inf.scale)
		end
	else
		angle = ((mo.momx > 0) or (mo.momy > 0)) and R_PointToAngle2(mo.momx, mo.momy, 0, 0) or player.drawangle
		speed = FixedMul(4 * FU, mo.scale)
	end

	return angle, speed
end

--//

local function handleHealth(player)
	if not joeFuncs.isValid(player.mo) then return end
	if not (joeVars.cvars["health"].value) then return end
	if (player.playerstate ~= PST_LIVE) then return end

	if (player.survival.delay) then
		player.survival.delay = max(0, $ - 1)
	end

	if (player.survival.delay < 1) then
		local add = (player.pflags & (PF_GODMODE | PF_FINISHED)) and 3 or 28
		player.survival.health = min($ + (FU / add), player.survival.total_health)
	end
end
addHook("PlayerThink", handleHealth)

local function handleDamage(mo, inf, src, dmg, dmgtype)
	if not joeFuncs.isValid(mo) then return end
	if not (joeVars.cvars["health"].value) then return end

	if (mo.player.powers[pw_shield]) then return false end

	local player = mo.player
	local angle, speed = getDamageInfo(mo, src, inf)

	local damage = damageTypes[dmgtype] or dmg

	if joeFuncs.isValid(src) then
		if (src.flags & MF_BOSS) then
			damage = 15
		end

		if (src.flags & MF_ENEMY) then
			damage = 5
		end
	end

	if (damage) then
		if (player.powers[pw_carry] == CR_ROPEHANG) then mo.tracer = nil end
		if (player.pflags & PF_DIRECTIONCHAR) then player.drawangle = angle + ANGLE_180 end

		P_ResetPlayer(player)
		mo.state = S_PLAY_STUN

		P_SetObjectMomZ(mo, (mo.eflags & MFE_UNDERWATER) and (3 * FU) or (6 * FU), false)
		P_InstaThrust(mo, angle, speed)

		player.survival.health = max(0, $ - (damage * FU))
		player.survival.delay = TICRATE * 3

		player.powers[pw_flashing] = flashingtics - 1
		S_StartSound(mo, sfx_hjhit, nil)

		if (player == displayplayer) then
			P_StartQuake(speed * 2, 10)
		end
	end

	if ((gametyperules & (GTR_TAG | GTR_HIDEFROZEN)) == GTR_TAG) and not (player.pflags & PF_GAMETYPEOVER) and not (player.pflags & PF_TAGIT) then
		player.score = ($ >= 50) and ($ - 50) or 0
	end

	if (player.timeshit ~= UINT8_MAX) then player.timeshit = $ + 1 end
	if not (player.survival.health) then P_KillMobj(mo, inf, src, dmgtype) end

	return true
end
addHook("MobjDamage", handleDamage, MT_PLAYER)

--//

local function resetHealth(player)
	player.survival.health = player.survival.total_health
	player.survival.delay = 0
end
addHook("PlayerSpawn", resetHealth)

--//
