/*
	Joe's Workshop - v1.0
	By Jaden
*/

//

rawset(_G, "joeFuncs", {})
rawset(_G, "joeVars", {})

local version = "v1.0b"
local date 	  = "October 10th, 2022"
local helpers = "-Scorbun- and Furry"

//

local folder = ""
local function dofolder(file)
	dofile(folder .. "/" .. file)
end

//

folder = "Init"
dofolder("freeslots.lua")
dofolder("player.lua")
dofolder("vars.lua")

folder = "Init/Functions"
dofolder("player.lua")
dofolder("misc.lua")
dofolder("hud.lua")

//

folder = "Execute"
dofolder("chat.lua")
dofolder("sounds.lua")

folder = "Execute/Gameplay"
dofolder("commands.lua")
dofolder("emblems.lua")
dofolder("autoexit.lua")

folder = "Execute/Gameplay/Player"
dofolder("effects.lua")
dofolder("health.lua")
dofolder("deaths.lua")

//

folder = "Execute/HUD"
dofolder("rankings.lua")
dofolder("hud.lua")

folder = "Execute/HUD/Gameplay"
dofolder("bosses.lua")
dofolder("nametags.lua")
dofolder("emblems.lua")

folder = "Execute/HUD/Miscellaneous"
dofolder("autoexit.lua")
dofolder("tips.lua")

//

print(string.format("\n" .. "Welcome to Joe's Workshop, \x82%s\x80." .. "\n" .. "Made by \x87Jaden\x80, with help of \x82%s\x80." .. "\n" .. "Made in \x85%s\x80." .. "\n", version, helpers, date))

//