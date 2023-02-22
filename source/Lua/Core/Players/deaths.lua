--//

local blackListedSkins = {
	"adventuresonic", "jellytails",
	"tailsdoll", "bowser",
	"speccy", "milne",
	"iclyn", "kiryu",

	"frank", "dummie",
	"kirby", "metaknight",
}

for _, v in ipairs(blackListedSkins) do
	blackListedSkins[v] = true
end

--//

local function resetVars(player)
	if not joeFuncs.isValid(player) then return end

	for types, _ in pairs(player.deaths) do
		player.deaths[types] = false
	end
end
addHook("PlayerSpawn", resetVars)

--//

local function deathLogic(player)
	if not joeFuncs.isValid(player.mo) then return end

	if (player.playerstate ~= PST_DEAD) then return end
	if (blackListedSkins[player.mo.skin] == true) then return end

	local mo = player.mo

	if player.deaths["fire"] then
		if not P_IsObjectOnGround(mo) then
			mo.rollangle = $ + ANG15

			if (mo.flags & MF_NOCLIPHEIGHT) then
				mo.flags = $ &~ MF_NOCLIPHEIGHT
			end
		end

		if (P_PlayerTouchingSectorSpecial(player, 1, 3) and P_IsObjectOnGround(mo)) then
			mo.flags = $ | (MF_NOCLIPHEIGHT)
			mo.momx, mo.momy = 0, 0

			P_SetObjectMomZ(mo, -(FU / 3), false)
		end

		mo.state = S_PLAY_PAIN

		if not P_RandomRange(0, 5) then
			S_StartSound(mo, sfx_s1c8, nil)
		end

		if not (leveltime % 25) then
			local fire = P_SpawnMobjFromMobj(mo, P_RandomRange(-40, 40) * FU, P_RandomRange(-40, 40) * FU, P_RandomRange(-40, 40) * FU, MT_THOK)
			fire.fuse = 20
			fire.flags = $ | (MF_NOGRAVITY)

			fire.state = S_SPINDUST_FIRE1
			fire.blendmode = AST_ADD

			P_SetScale(fire, mo.scale / 2)
			P_SetObjectMomZ(fire, FU / 2, true)
		end
	end

	if player.deaths["spikes"] then
		mo.spritexoffset = P_RandomRange(-2, 2) * FU
		mo.spriteyoffset = P_RandomRange(-2, 2) * FU

		mo.state = S_PLAY_DRWN
		mo.rollangle = FixedAngle(P_RandomRange(-8, 8) * FU)
	end

	if player.deaths["electric"] then
		if (mo.fuse > 1) then
			mo.spritexoffset = P_RandomRange(-12, 12) * FU
			mo.spriteyoffset = P_RandomRange(-8, 8) * FU

			mo.color = ({SKINCOLOR_YELLOW, SKINCOLOR_JET, SKINCOLOR_ORANGE, SKINCOLOR_ICY})[P_RandomRange(1, 4)]
			mo.rollangle = FixedAngle(P_RandomRange(-15, 15) * FU)

			if not P_RandomRange(0, 6) then
				S_StartSound(mo, sfx_s3k79, nil)
			end
		end

		if (mo.fuse == 1) then
			mo.spritexoffset, mo.spriteyoffset = 0, 0

			mo.state = S_PLAY_PAIN
			mo.color = SKINCOLOR_CARBON
			mo.fuse = -1

			P_SetObjectMomZ(mo, 10 * FU, false)
			P_InstaThrust(mo, (mo.angle + ANGLE_180) + FixedAngle(P_RandomRange(-50, 50) * FU), -12 * mo.scale)

			if (player == displayplayer) then
				P_StartQuake(12 * FU, 10)
			end

			S_StartSound(mo, sfx_s3k51, nil)
		end
	end

	if player.deaths["drowned"] then
		P_SetObjectMomZ(mo, FU, false)

		mo.state = S_PLAY_DRWN
		mo.rollangle = $ + ANG1
	end

	if player.deaths["crushed"] then
		mo.state = S_PLAY_DEAD
		mo.spriteyscale = FU / 6
	end

	if player.deaths["deathpit"] then
		P_SetObjectMomZ(mo, -FU, true)

		mo.state = S_PLAY_PAIN
		player.drawangle = $ + (ANG10 * 5)
	end

	if player.deaths["normal"] then
		if (mo.fuse > 1) then
			P_InstaThrust(mo, (mo.angle + ANGLE_180), -10 * mo.scale)

			mo.state = S_PLAY_PAIN
			mo.rollangle = $ + ANG15
			player.drawangle = $ + ANG10
		end

		if (mo.fuse == 1) then
			local explosion = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
			explosion.state = S_STOCKEXPLOSION
			explosion.fuse = TICRATE

			mo.state = S_INVISIBLE
			mo.momx, mo.momy, mo.momz = 0, 0, 0

			S_StartSound(mo, sfx_jexpl, nil)

			if (player == displayplayer) then
				P_FlashPal(player, PAL_WHITE, 5)
				P_StartQuake(8 * FU, 10)
			end
		end
	end
end
addHook("PlayerThink", deathLogic)

local function deathToggles(mo, _, _, dmgtype)
	if not joeFuncs.isValid(mo) then return end
	if (blackListedSkins[mo.skin] == true) then return end

	local player = mo.player

	if (dmgtype == DMG_SPIKE) then
		player.deaths["spikes"] = true

		mo.fuse = -1
		mo.flags = $ | (MF_NOGRAVITY)

		mo.momx, mo.momy = $1 / 4, $2 / 4
		P_SetObjectMomZ(mo, FU * 7, false)

		S_StartSound(mo, sfx_spkdth, nil)
	end

	if (dmgtype == DMG_FIRE) then
		player.deaths["fire"] = true

		mo.fuse = -1
		mo.flags = $ | (MF_NOGRAVITY)

		mo.colorized = true
		mo.color = SKINCOLOR_CARBON

		mo.momx, mo.momy = $1 / 4, $2 / 4
		P_SetObjectMomZ(mo, FU * 8, false)

		if (player == displayplayer) then
			P_StartQuake(5 * FU, 10)
		end

		S_StartSound(mo, sfx_thok, nil)
	end

	if (dmgtype == DMG_ELECTRIC) then
		player.deaths["electric"] = true

		mo.fuse = TICRATE + 15
		mo.flags = $ | (MF_NOGRAVITY)

		mo.colorized = true
	end

	if (dmgtype == DMG_DROWNED) or (dmgtype == DMG_SPACEDROWN) then
		player.deaths["drowned"] = true

		mo.fuse = -1
		mo.flags = $ | (MF_NOGRAVITY | MF_NOCLIPHEIGHT)

		mo.momx, mo.momy = 0, 0

		S_StartSound(mo, (player.charflags & SF_MACHINE) and sfx_fizzle or sfx_s1b2, nil)
	end

	if (dmgtype == DMG_CRUSHED) then
		player.deaths["crushed"] = true

		mo.fuse = -1
		mo.height, mo.shadowscale = 0, $2 / 2

		S_StartSound(mo, sfx_jsplat, nil)
	end

	if (dmgtype == DMG_DEATHPIT) then
		player.deaths["deathpit"] = true

		mo.fuse = TICRATE * 2
		mo.flags = $ | (MF_NOGRAVITY | MF_NOCLIPHEIGHT)

		mo.momx, mo.momy = 0, 0

		S_StartSound(mo, sfx_jfall, nil)
	end

	if (dmgtype == DMG_INSTAKILL) or (dmgtype == DMG_WATER) or (dmgtype == DMG_NUKE) or (dmgtype == 0) then
		player.deaths["normal"] = true

		mo.flags = $ | (MF_NOGRAVITY) &~ (MF_NOCLIP | MF_NOCLIPHEIGHT)
		mo.fuse = TICRATE - 5

		mo.momx, mo.momy = $1 / 4, $2 / 4
		P_SetObjectMomZ(mo, 14 * FU, false)

		S_StartSound(mo, sfx_jslip, nil)
	end

	if G_GametypeUsesLives() and not (player.bot or player.spectator) and (player.lives ~= INFLIVES) then
		if not (player.pflags & PF_FINISHED) then
			player.lives = max(0, $ - 1)
		end
	end

	if (player.starwarp.enabled) then
		player.starwarp.enabled = false
	end

	return true
end
addHook("MobjDeath", deathToggles, MT_PLAYER)

--//

addHook("NetVars", function(net)
	blackListedSkins = net($)
end)

--//