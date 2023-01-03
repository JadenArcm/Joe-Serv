//

local function playerEffects(player)
	//

	if not joeFuncs.isValid(player.mo) then return end

	//

	player.pflags = (player.force.god) and ($ | PF_GODMODE) or ($ &~ PF_GODMODE)
	player.pflags = (player.force.noclip) and ($ | PF_NOCLIP) or ($ &~ PF_NOCLIP)

	//

	if (player.force.colorize) and not (player.mo.colorized) then
		player.mo.colorized = true
	end
	
	//
end
addHook("PlayerThink", playerEffects)

//