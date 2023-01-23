--//

function joeFuncs.hasPermissions(player)
	return (player == server) or IsPlayerAdmin(player)
end

--//

function joeFuncs.getPlayer(node)
	if (node == nil) then
		return -1
	end

	if tonumber(node) then
		local num = tonumber(node)

		if (num < 0) or (num > #players) then
			return -1
		end

		if joeFuncs.isValid(players[num]) then
			return players[num]
		end
	end

	for target in players.iterate do
		if not joeFuncs.isValid(target) then continue end

		local found_name = string.lower(node)
		local target_name = string.lower(target.name)

		if (target_name == found_name) then
			return target
		end
	end

	return -1
end

function joeFuncs.getPlayerName(player, params)
	local player_color = joeFuncs.getColor(player.skincolor)
	local badge_color = joeFuncs.getColor(ColorOpposite(player.skincolor))

	local badge, status = "", ""

	if (params & 1) and (joeVars.cvars["showperms"].value) then
		if (player == server) then
			badge = badge_color .. "~"
		elseif IsPlayerAdmin(player) then
			badge = badge_color .. "@"
		end
	end

	if (params & 2) and (gamestate == GS_LEVEL) then
		if G_GametypeHasTeams() then
			status = ({"\x85[RED] ", "\x84[BLUE] "})[player.ctfteam]
		end

		if G_TagGametype() and (player.pflags & PF_TAGIT) then
			status = "\x87[IT] "
		end

		if (player.spectator) then
			status = "\x86[SPEC] "
		end
	end

	return status .. badge .. player_color .. player.name
end

--//