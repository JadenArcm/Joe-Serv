/*
	Joe's Workshop
	By Jaden
*/

rawset(_G, "joeFuncs", {})
rawset(_G, "joeVars", {})

--//

local file_init = {
	-- Initialize things
	{
		"Library",
		{"variables.lua", "miscellaneous.lua", "player.lua", "hud.lua"},
	},
	{
		"Core",
		{"player.lua", "freeslots.lua"},
	},

	-- Execute almost everything
	{
		"Core/Gameplay",
		{"autoexit.lua", "emblems.lua", "commands.lua"},
	},
	{
		"Core/Players",
		{"starwarp.lua", "deaths.lua", "effects.lua"},
	},

	-- Miscellaneous stuff
	{
		"Core/Visual",
		{"sounds.lua", "chat.lua"},
	},

	-- HUD
	{
		"Core/Visual/HUD",
		{"main.lua", "ranks.lua"},
	},
	{
		"Core/Visual/HUD/Gameplay",
		{"coop.lua", "match.lua", "nametags.lua", "bosstags.lua", "radar.lua", "starwarps.lua"},
	},
	{
		"Core/Visual/HUD/Miscellaneous",
		{"spectator.lua", "autoexit.lua", "tips.lua", "echo.lua"},
	},
}

for _, entry in ipairs(file_init) do
	for _, file in ipairs(entry[2]) do
		dofile(entry[1] .. "/" .. file)
	end
end

--//