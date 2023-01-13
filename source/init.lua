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
		f = "Library",
		l = {"variables.lua", "miscellaneous.lua", "player.lua", "hud.lua"},
	},
	{
		f = "Core",
		l = {"player.lua", "freeslots.lua"},
	},

	-- Execute almost everything
	{
		f = "Core/Gameplay",
		l = {"autoexit.lua", "emblems.lua", "commands.lua"},
	},
	{
		f = "Core/Players",
		l = {"starwarp.lua", "deaths.lua", "effects.lua"},
	},

	-- Miscellaneous stuff
	{
		f = "Core/Visual",
		l = {"sounds.lua", "chat.lua"},
	},

	-- HUD
	{
		f = "Core/Visual/HUD",
		l = {"main.lua"},
	},
	{
		f = "Core/Visual/HUD/Gameplay",
		l = {"coop.lua", "match.lua", "nametags.lua", "radar.lua", "starwarps.lua"},
	},
	{
		f = "Core/Visual/Hud/Miscellaneous",
		l = {"spectator.lua", "devbug.lua", "autoexit.lua"},
	},
}

for _, entry in ipairs(file_init) do
	for _, file in ipairs(entry.l) do
		dofile(entry.f .. "/" .. file)
	end
end

--//