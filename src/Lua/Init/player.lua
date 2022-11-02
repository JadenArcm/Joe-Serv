//

local function playerVars(player)
	//

	player.chat = {}
	player.chat.muted = false
	player.chat.reason = ""

	//
	
	player.deaths = {}
	player.deaths["normal"] = false
	
	player.deaths["fire"] = false
	player.deaths["spikes"] = false
	player.deaths["electric"] = false

	player.deaths["drowned"] = false
	player.deaths["crushed"] = false
	player.deaths["deathpit"] = false

	//

	player.hp = {}
	player.hp.max = 30
	player.hp.enabled = false
	player.hp.current = player.hp.max
	
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

local function spawnInit(player)
	//

	if not joeFuncs.isValid(player) then return end

	//

	if (player.jinit == nil) then
		playerVars(player)
	end

	//
end
addHook("PlayerSpawn", spawnInit)

//