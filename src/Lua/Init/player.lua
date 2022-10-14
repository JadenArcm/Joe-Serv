//

local function playerVars(player)
	//
	
	player.chat = {}
	player.chat.muted = false
	player.chat.reason = ""
	
	//
	
	player.force = {}
	player.force.god = false
	player.force.noclip = false
	player.force.colorize = false
	
	//
	
	player.jinit = true
	
	//
end

//

local function playerInit()
	//
	
	if (gamestate ~= GS_LEVEL) then return end
	
	//
	
	for player in players.iterate do
		if not joeFuncs.isValid(player) then continue end
	
		if (player.jinit == nil) then
			playerVars(player)
		end
	end
	
	//
end
addHook("PreThinkFrame", playerInit)

//