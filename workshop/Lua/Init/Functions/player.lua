//

joeFuncs.isServerOrAdmin = function(player)
	return (player == server) or IsPlayerAdmin(player)
end

//

joeFuncs.getPlayer = function(node)
	//

	if (node == nil) then
		return -1
	end

	//

	if tonumber(node) then
		local num = tonumber(node)

		if (num < 0) or (num >= (#players - 1)) then
			return -1
		end

		if joeFuncs.isValid(players[num]) then
			return players[num]
		end
	end

	//

	for target in players.iterate do
		if not joeFuncs.isValid(target) then continue end

		local found_name = string.lower(node)
		local target_name = string.lower(target.name)

		if (target_name == found_name) then
			return target
		end
	end

	//

	return -1

	//
end

//

joeFuncs.getPlayerName = function(player, flags)
	//

	if (player == server) and not (player.realmo) then
		return "\x82" .. "[SERVER]"
	end

	//

	local function colorCode(color)
		if not (color) then
			return "\x80"
		end

		local code = (color - V_MAGENTAMAP) >> 12
		return string.char(code + 129)
	end

	//

	local player_color = skincolors[max(1, player.skincolor)].chatcolor
	local badge, stats = "", ""

	local badge_color = (player_color == V_GREENMAP) and "\x82" or "\x83"

	//

	if (flags & 1) then
		if (player == server) then
			badge = badge_color .. "~"
		elseif IsPlayerAdmin(player) then
			badge = badge_color .. "@"
		end
	end

	if (flags & 2) and (gamestate == GS_LEVEL) then
		if G_GametypeHasTeams() then
			stats = ({"\x85" .. "[RED] ", "\x84" .. "[BLUE] "})[player.ctfteam]
		end

		if G_TagGametype() and (player.pflags & PF_TAGIT) then
			stats = "\x87" .. "[IT] "
		end

		if (player.spectator) then
			stats = "\x86" .. "[SPEC] "
		end
	end

	//

	return stats .. badge .. colorCode(player_color) .. player.name

	//
end

//
