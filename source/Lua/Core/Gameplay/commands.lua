--//

local function inLevel(player)
	if (gamestate == GS_LEVEL) then
		return true
	end

	CONS_Printf(player, "This can only be used on a \x82level\x80.")
	return false
end

--//

local function teleportMobjToMobj(source, target)
	P_TeleportMove(source, target.x, target.y, target.z)
	source.momx, source.momy, source.momz = target.momx, target.momy, target.momz
end

local function killPlayer(target, source)
	if (target.pflags & PF_GODMODE) then target.pflags = $ & ~(PF_GODMODE) end
	P_KillMobj(target.mo, source, source)
end

--//

local function printHelp(player, args, msg)
	local help = "\x82" .. args .. "\x80: "
	return CONS_Printf(player, help .. msg)
end

local function printError(player, msg)
	local err = "\x85" .. "ERROR:" .. "\x80 "
	return CONS_Printf(player, err .. msg)
end

--//

local command_info = {
	{
		name = "addbot",
		admin = true,

		func = function(player)
			if not inLevel(player) then return end

			local skin = P_RandomRange(0, #skins - 1)
			local color = P_RandomRange(1, SKINCOLOR_SUPERSILVER1 - 1)

			local bot_name = skins[skin].realname .. " " .. P_RandomByte()
			local skin_name = skins[skin].name

			G_AddPlayer(skin_name, color, bot_name, BOT_MPAI)
		end
	},

	{
		name = "dofor",
		admin = true,

		func = function(player, node, command)
			if not (node) then
				printHelp(player, "dofor <name/node> <command>", "Executes a command on the selected player.")
				return
			end

			if (command == nil) then
				printError(player, "You forgot the \x82" .. "command" .. "\x80 parameter. Pretty weird.")
				return
			end

			if (node == "server") then
				COM_BufInsertText(server, command)
				return
			end

			local target = joeFuncs.getPlayer(node)

			if (target == -1) then
				printError(player, "That player doesn't exist. Please double-check.")
				return
			end

			COM_BufInsertText(target, command)
		end
	},

	{
		name = "muteplayer",
		admin = true,

		func = function(player, node, reason)
			if not (node) then
				printHelp(player, "muteplayer <name/node> \x86[reason]", "Toggles muting for the selected player.")
				return
			end

			local target = joeFuncs.getPlayer(node)

			if (target == -1) then
				printError(player, "That player doesn't exist. Please double-check.")
				return
			end

			if joeFuncs.hasPermissions(target) then
				printError(player, "That player is either an admin or the server itself.")
				return
			end

			target.chat.muted = not $
			target.chat.mute_reason = reason or "No reason given"

			if (target.chat.muted) then
				chatprint("\x82* " .. joeFuncs.getPlayerName(player, 1) .. "\x82 has muted " .. joeFuncs.getPlayerName(target, 0) .. "\x82. (\x80" .. target.chat.mute_reason .. "\x82)", true)
			else
				chatprint("\x82* " .. joeFuncs.getPlayerName(player, 1) .. "\x82 has un-muted " .. joeFuncs.getPlayerName(target, 0) .. "\x82.", true)
			end
		end
	},

	//

	{
		name = "god",
		admin = true,

		func = function(player)
			if not inLevel(player) then return end

			player.force.god = not $
			CONS_Printf(player, "God-Mode \x82" .. ((player.force.god) and "enabled" or "disabled") .. "\x80.")
		end
	},

	{
		name = "noclip",
		admin = true,

		func = function(player)
			if not inLevel(player) then return end

			player.force.noclip = not $
			CONS_Printf(player, "No-clipping \x82" .. ((player.force.noclip) and "enabled" or "disabled") .. "\x80.")
		end
	},

	{
		name = "getammo",
		admin = true,

		func = function(player)
			if not inLevel(player) then return end

			local weapons = {
				{pw_automaticring, RW_AUTO, 400},
				{pw_bouncering, RW_BOUNCE, 100},
				{pw_scatterring, RW_SCATTER, 50},
				{pw_grenadering, RW_GRENADE, 100},
				{pw_explosionring, RW_EXPLODE, 50},
				{pw_railring, RW_RAIL, 50},
			}

			for i = 1, #weapons do
				player.ringweapons = $ | (weapons[i][2])
				player.powers[weapons[i][1]] = weapons[i][3]
			end

			CONS_Printf(player, "You now have \x82" .. "every" .. "\x80 weapon!")
		end
	},

	//

	{
		name = "summon",
		admin = true,

		func = function(player, object)
			if not inLevel(player) then return end

			if not (object) then
				printHelp(player, "summon <object>", "Spawns a object via \x82" .. "MT_*" .. "\x80.")
				return
			end

			local object_valid, object_tospawn = pcall(do return _G["MT_" .. string.upper(object)] end, object)

			if not (object_valid) then
				printError(player, "That object doesn't exist. Please double-check.")
				return
			end

			local mo = P_SpawnMobjFromMobj(player.realmo, 0, 0, 0, object_tospawn)
			mo.angle = player.realmo.angle
		end
	},

	{
		name = "setgravity",
		admin = true,

		func = function(player, grav)
			if not inLevel(player) then return end

			if not (grav) then
				printHelp(player, "setgravity <gravity>", "Changes the current gravity. Negative values are valid too!")
				return
			end

			if (grav == "-default") then
				gravity = FRACUNIT / 2
				print("The gravity has been changed to the\x82 default\x80.")
				return
			end

			grav = joeFuncs.float2Fixed($)

			if (grav == nil) then
				printError(player, "Seems like you entered a string, and not a number.")
				return
			end

			print("The gravity has been changed to \x82" .. string.format("%.1f", grav) .. "\x80.")
			gravity = grav
		end
	},

	{
		name = "goto",
		admin = true,

		func = function(player, node)
			if not inLevel(player) then return end

			if not (node) then
				printHelp(player, "goto <name/node>", "Teleports you to the selected player.")
				return
			end

			if not (player.mo) then
				printError(player, "Seems like that you're dead. Sorry!")
				return
			end

			local target = joeFuncs.getPlayer(node)

			if (target == -1) then
				printError(player, "That player doesn't exist. Please double-check.")
				return
			end

			if not (target.mo) then
				printError(player, "Seems like that player is dead. Sorry!")
				return
			end

			teleportMobjToMobj(player.mo, target.mo)
		end
	},

	{
		name = "bring",
		admin = true,

		func = function(player, node)
			if not inLevel(player) then return end

			if not (node) then
				printHelp(player, "bring <name/node>", "Teleports the selected player to your location.")
				return
			end

			if not (player.mo) then
				printError(player, "Seems like that you're dead. Sorry!")
				return
			end

			if (node == "all") then
				for targets in players.iterate do
					if not joeFuncs.isValid(targets.mo) then continue end

					if (targets ~= player) then
						teleportMobjToMobj(targets.mo, player.mo)
					end
				end

				print(joeFuncs.getPlayerName(player, 1) .. "\x80 teleported everyone to his location.")
				return
			end

			local target = joeFuncs.getPlayer(node)

			if (target == -1) then
				printError(player, "That player doesn't exist. Please double-check.")
				return
			end

			if not joeFuncs.isValid(target.mo) then
				printError(player, "Seems like that player is dead. Sorry!")
				return
			end

			teleportMobjToMobj(target.mo, player.mo)
		end
	},

	{
		name = "kill",
		admin = true,

		func = function(player, ...)
			if not inLevel(player) then return end

			local args = {...}
			local types = {
				{"@a", "Kills all players, including yourself."},
				{"@e", "Kills every enemy, boss, and so on."},
				{"@s", "You simply commit suicide. That's all."},
				{"@x", "Kills a player in specific. Name/node are valid for selection."},
			}

			if not (#args) then
				printHelp(player, "kill <mode> <...>", "Self-explanatory. Works just like Minecraft does.")
				CONS_Printf(player, "Available modes:")
				for i = 1, #types do
					CONS_Printf(player, "[\x87" .. types[i][1] .. "\x80]: " .. types[i][2])
				end
				return
			end

			if not joeFuncs.isValid(player.mo) then
				printError(player, "Hey! You need to do this alive.")
				return
			end

			if (args[1] == "@a") then
				for targets in players.iterate do
					if not joeFuncs.isValid(targets.mo) or (targets.playerstate == PST_DEAD) then continue end
					killPlayer(targets, player.mo)
				end

				print(joeFuncs.getPlayerName(player, 1) .. "\x80 killed everyone. Yay!")
				return
			end

			if (args[1] == "@e") then
				for mobj in mobjs.iterate() do
					if not (mobj.flags & (MF_BOSS | MF_ENEMY)) then continue end
					if (mobj.health <= 0) then continue end

					P_KillMobj(mobj, player.mo, player.mo)
				end

				print(joeFuncs.getPlayerName(player, 1) .. "\x80 killed every enemy. Awesome!")
				return
			end

			if (args[1] == "@s") then
				if not joeFuncs.isValid(player.mo) or (player.playerstate == PST_DEAD) then
					printError(player, "You are already dead.")
					return
				end

				killPlayer(player, nil)
				return
			end

			if (args[1] == "@x") then
				if not (args[2]) then
					printError(player, "Hey! Don't forget about the player!")
					return
				end

				local target = joeFuncs.getPlayer(args[2])

				if (target == -1) then
					printError(player, "That player doesn't exist. Please double-check.")
					return
				end

				if not joeFuncs.isValid(target.mo) or (target.playerstate == PST_DEAD) then
					printError(player, "Seems like that player is already dead. Sorry!")
					return
				end

				killPlayer(target, player.mo)
				CONS_Printf(target, joeFuncs.getPlayerName(player, 1) .. "\x80 killed you. That is cool, i guess.")
				return
			end
		end
	},

	//

	{
		name = "setmusic",
		admin = true,

		func = function(player, tune)
			if not (tune) then
				printHelp(player, "setmusic <tune>", "Changes the music, but for everyone. Works just like \x82tunes\x80 does.")
				return
			end

			if (tune == "-default") then
				for targets in players.iterate do
					COM_BufInsertText(targets, "tunes -default")
				end

				chatprint("\x82* " .. joeFuncs.getPlayerName(player, 0) .. "\x82 has changed the music to the level default.", true)
				return
			end

			if (tune == "-none") then
				for targets in players.iterate do
					COM_BufInsertText(targets, "tunes -none")
				end

				chatprint("\x82* " .. joeFuncs.getPlayerName(player, 0) .. "\x82 has stopped the music player. So cool.", true)
				return
			end

			local music_name = string.upper(tune)

			if not S_MusicExists(music_name) then
				printError(player, "That tune doesn't exist. Make sure it has less than 6 characters. Otherwise, double-check.")
				return
			end

			for targets in players.iterate do
				COM_BufInsertText(targets, "tunes " .. music_name)
			end

			chatprint("\x82* " .. joeFuncs.getPlayerName(player, 0) .. "\x82 has changed the music to \x86" .. music_name .. "\x82.", true)
		end
	},

	{
		name = "toggleemeralds",
		admin = false,

		func = function(player)
			emeralds = (not All7Emeralds($)) and 127 or 0
			S_StartSound(nil, All7Emeralds(emeralds) and sfx_s3k9c or sfx_s3k37)

			print(joeFuncs.getPlayerName(player, 1) .. "\x80 " .. (All7Emeralds(emeralds) and "spawned" or "returned") .. " all of the \x83" .. "Chaos Emeralds" .. "\x80.")
		end
	},

	//
	//
	//

	{
		name = "colorize",
		admin = false,

		func = function(player)
			if not inLevel(player) then return end

			player.force.colorize = not $
			player.realmo.colorized = not $

			CONS_Printf(player, "You are no" .. ((player.force.colorize) and "w\x82 colorized" or " longer\x82 colorized") .. "\x80.")
		end
	},

	{
		name = "togglesuper",
		admin = false,

		func = function(player)
			if not inLevel(player) then return end

			if (gametyperules & GTR_RINGSLINGER) and (player.rings < 120) then
				printError(player, "You need more than \x82" .. "120 rings" .. "\x80 to use this.")
				return
			end

			if (gametyperules & GTR_FRIENDLY) and not All7Emeralds(emeralds) then
				printError(player, "You need all of the \x83" .. "Chaos Emeralds" .. "\x80 to use this.")
				return
			end

			if not (player.mo) then
				printError(player, "Seems like you aren't alive to do this. Sorry!")
				return
			end

			if not (player.powers[pw_super]) then
				player.rings = $ + 50
				player.charflags = $ | SF_SUPER

				P_DoSuperTransformation(player, false)

				P_FlashPal(player, PAL_WHITE, 5)
				S_StartSound(player.mo, sfx_supert)
			else
				player.rings = 0
				player.powers[pw_flashing] = TICRATE

				P_FlashPal(player, PAL_WHITE, 10)
				S_StartSound(player.mo, sfx_s3k66)
			end
		end
	},

	{
		name = "setscale",
		admin = false,

		func = function(player, scale, node)
			if not inLevel(player) then return end

			if not (scale) then
				printHelp(player, "setscale <scale> \x87[name/node]", "Changes your current scale.")
				return
			end

			scale = joeFuncs.float2Fixed($)

			if (scale == nil) then
				printError(player, "Seems like you entered a string, and not a number.")
				return
			end

			if (node) then
				if not joeFuncs.hasPermissions(player) then
					printError(player, "Only admins or hosts can use this.")
					return
				end

				local target = joeFuncs.getPlayer(node)

				if (target == -1) then
					printError(player, "That player doesn't exist. Please double-check.")
					return
				end

				if not (target.mo) then
					printError(player, "Seems like that player is dead. Sorry!")
					return
				end

				target.mo.destscale = scale
				return
			end

			if not (player.mo) then
				printError(player, "Seems like you aren't alive to do this. Sorry!")
				return
			end

			CONS_Printf(player, "Your scale is now \x82" .. string.format("%.1f", scale) .. "\x80.")
			player.mo.destscale = scale
		end
	},

	{
		name = "setrings",
		admin = false,

		func = function(player, amount)
			if not inLevel(player) then return end

			if not (amount) then
				printHelp(player, "setrings <amount>", "Replace your current rings. Just as simple.")
				return
			end

			if (gametyperules & GTR_RINGSLINGER) and not joeFuncs.hasPermissions(player) then
				printError(player, "You can't use this in this gametype. Sorry!")
				return
			end

			amount = tonumber($)

			if (amount == nil) then
				printError(player, "A number was expected, but you wrote a string.")
				return
			end

			amount = max(0, min($, 9999))
			player.rings = amount
		end
	},

	{
		name = "setlives",
		admin = false,

		func = function(player, amount)
			if not inLevel(player) then return end

			if not (amount) then
				printHelp(player, "setlives <amount>", "Replace your current lives.")
				return
			end

			if not G_GametypeUsesLives() and not joeFuncs.hasPermissions(player) then
				printError(player, "You can't use this in this gametype. Sorry!")
				return
			end

			amount = tonumber($)

			if (amount == nil) then
				printError(player, "A number was expected, but you wrote a string.")
				return
			end

			amount = max(0, min($, 99))
			player.lives = amount
		end
	},
}

--//

for _, cmd in ipairs(command_info) do
	COM_AddCommand(cmd.name, cmd.func, (cmd.admin) and COM_ADMIN or 0)
end

--//
