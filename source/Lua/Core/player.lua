--//

local death_types = {
	"normal",
	"fire",
	"spikes",
	"electric",
	"drowned",
	"crushed",
	"deathpit",
}

local hud_types = {
	"display",
	"specinfo",
	"ringslinger",

	"selfview.x",
	"selfview.y"
}

--//

local function initPlayer(player)
	if not joeFuncs.isValid(player) then return end

	-- Chat
	player.chat = {}
	player.chat.muted = false
	player.chat.mute_reason = ""

	-- Force stuff
	player.force = {}
	player.force.god = false
	player.force.noclip = false
	player.force.notarget = false
	player.force.colorize = false

	-- Starposts
	player.starwarp = {}
	player.starwarp.tics = 0
	player.starwarp.hover_tics = 0
	player.starwarp.cursor = 1
	player.starwarp.enabled = false

	-- Health
	player.survival = {}
	player.survival.delay = 0
	player.survival.health = 0
	player.survival.total_health = 100 * FU

	-- Deaths
	player.deaths = {}
	for _, types in ipairs(death_types) do
		player.deaths[types] = false
	end

	-- HUD
	player.hudstuff = {}
	for _, types in ipairs(hud_types) do
		player.hudstuff[types] = 0
	end

	-- Other
	player.lastsidemove = 0
	player.jinit = true
end

--//

addHook("PreThinkFrame", function()
	if (gamestate ~= GS_LEVEL) then return end

	for player in players.iterate do
		if (player.jinit == nil) then
			initPlayer(player)
		end
	end
end)

addHook("PlayerSpawn", function(player)
	if (player.jinit == nil) then
		initPlayer(player)
	end
end)

--//