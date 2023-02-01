--//

function joeFuncs.hasPermissions(player)
	return (player == server) or IsPlayerAdmin(player)
end

--//

function joeFuncs.getPlayerLists()
	local coop, match = {}, {}
	local teams = {["red"] = {}, ["blue"] = {}}

	local function getSorting(a, b)
		return (a.score == b.score) and (#a < #b) or (a.score > b.score)
	end

	for player in players.iterate do
		if not (player.spectator) then
			table.insert(coop, player)
			table.insert(match, player)

			if G_GametypeHasTeams() then
				if (player.ctfteam == 1) then table.insert(teams["red"], player)
				elseif (player.ctfteam == 2) then table.insert(teams["blue"], player)
				end
			end
		end
	end

	table.sort(coop, function(a, b)
		if (gametyperules & GTR_RACE) then
			return (circuitmap) and (a.laps > b.laps) or (a.realtime < b.realtime)
		end

		return getSorting(a, b)
	end)

	for player in players.iterate do
		if (player.spectator) then table.insert(coop, player) end
	end

	table.sort(match, getSorting)
	table.sort(teams["red"], getSorting)
	table.sort(teams["blue"], getSorting)

	return {
		["coop"] = coop,
		["match"] = match,
		["teams"] = teams,
	}
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
	local badge_color = (player_color == "\x83") and "\x82" or "\x83"

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