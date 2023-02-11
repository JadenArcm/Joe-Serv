--//

local function addFlag(field, condition, flag)
	field = (condition) and ($ | flag) or ($ & ~(flag))
	return field
end

--//

local function playerEffects(player)
	if not joeFuncs.isValid(player.mo) then return end

	player.pflags = addFlag($, player.force.god, PF_GODMODE)
	player.pflags = addFlag($, player.force.noclip, PF_NOCLIP)
	player.pflags = addFlag($, player.force.notarget, PF_INVIS)

	if (player.force.colorize) and not (player.mo.colorized) then
		player.mo.colorized = true
	end
end
addHook("PlayerThink", playerEffects)

local function realEffects()
	for player in players.iterate do
		if (player.spectator) then continue end
		if not joeFuncs.isValid(player.mo) then continue end

		player.mo.frame = addFlag($, player.force.noclip, FF_TRANS60)
		player.mo.frame = addFlag($, player.force.god, FF_ADD)
		player.mo.frame = addFlag($, player.force.notarget, FF_MODULATE)

		if joeFuncs.isValid(player.followmobj) then
			player.followmobj.frame = addFlag($, player.force.noclip, FF_TRANS60)
			player.followmobj.frame = addFlag($, player.force.god, FF_ADD)
			player.followmobj.frame = addFlag($, player.force.notarget, FF_MODULATE)
		end
	end
end
addHook("PostThinkFrame", realEffects)

--//