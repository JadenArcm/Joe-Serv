--//

local function playerEffects(player)
	if not joeFuncs.isValid(player.mo) then return end

	player.pflags = (player.force.god) and ($ | PF_GODMODE) or ($ &~ PF_GODMODE)
	player.pflags = (player.force.noclip) and ($ | PF_NOCLIP) or ($ &~ PF_NOCLIP)

	if (player.force.colorize) and not (player.mo.colorized) then
		player.mo.colorized = true
	end
end
addHook("PlayerThink", playerEffects)

local function realEffects()
	for player in players.iterate do
		if (player.spectator) then continue end
		if not joeFuncs.isValid(player.mo) then continue end

		player.mo.frame = (player.force.noclip) and ($ | FF_TRANS60) or ($ & ~(FF_TRANS60))
		player.mo.frame = (player.force.god) and ($ | FF_ADD) or ($ & ~(FF_ADD))

		if joeFuncs.isValid(player.followmobj) then
			player.followmobj.frame = (player.force.noclip) and ($ | FF_TRANS60) or ($ & ~(FF_TRANS60))
			player.followmobj.frame = (player.force.god) and ($ | FF_ADD) or ($ & ~(FF_ADD))
		end
	end
end
addHook("PostThinkFrame", realEffects)

--//