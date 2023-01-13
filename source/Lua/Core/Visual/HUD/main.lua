--//

local function handleTickers(player)
	if (leveltime < 3) then
		for entry, _ in pairs(player.hudstuff) do
			player.hudstuff[entry] = 0
		end
	end

	if (leveltime > TICRATE) then
		if (player.exiting < 1) and not (G_RingSlingerGametype() or player.spectator) then
			player.hudstuff["display"] = min($ + 1, TICRATE)
		end

		if ((player.exiting > 1) and (player.exiting <= 50)) or (G_RingSlingerGametype() or player.spectator) then
			player.hudstuff["display"] = max(0, $ - 1)
		end

		player.hudstuff["ringslinger"] = (G_RingSlingerGametype() and not (player.spectator)) and min($ + 1, TICRATE) or max(0, $ - 1)
		player.hudstuff["specinfo"] = (player.spectator) and min($ + 1, TICRATE) or max(0, $ - 1)
	end
end
addHook("PlayerThink", handleTickers)

--//

local function handleDrawing(v, player)
	local list_disable = {"score", "time", "rings", "lives", "textspectator", "teamscores", "weaponrings", "powerstones"}

	if not (joeVars.cvars["customhud"].value) then
		for _, entry in ipairs(list_disable) do
			if not hud.enabled(entry) then
				hud.enable(entry)
			end
		end
		return
	end

	for _, entry in ipairs(list_disable) do
		hud.disable(entry)
	end

	for _, draw in ipairs(joeVars.displayList) do
		draw(v, player)
	end
end

--//

hud.add(handleDrawing, "game")

--//