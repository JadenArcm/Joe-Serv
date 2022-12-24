/*
	Joe's Workshop
	By Jaden
*/

//

rawset(_G, "joeFuncs", {})
rawset(_G, "joeVars", {})

//

local version = {1, 0, "d"}
local date 	  = "November 27th, 2022"
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
dofolder("starposts.lua")

//

folder = "Execute/HUD"
dofolder("rankings.lua")
dofolder("hud.lua")

folder = "Execute/HUD/Gameplay"
dofolder("bosses.lua")
dofolder("nametags.lua")
dofolder("emblems.lua")
dofolder("starposts.lua")

folder = "Execute/HUD/Miscellaneous"
dofolder("autoexit.lua")
dofolder("tips.lua")

//

local print_message = [[

  Welcome to Joe's Workshop!
  %c*%c We are currently on %cv%d.%d%s%c.

  Made by %cJaden%c, with help of %c%s%c.
  %c*%c Compiled on %c%s%c.

  Have fun!
]]

print(print_message:format(0x82, 0x80, 0x85, version[1], version[2], version[3], 0x80, 0x87, 0x80, 0x82, helpers, 0x80, 0x82, 0x80, 0x83, date, 0x80))

//