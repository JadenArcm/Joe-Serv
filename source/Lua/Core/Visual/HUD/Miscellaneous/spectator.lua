--//

joeFuncs.addHUD(function(v, player)
	local x, y = (160 * FRACUNIT), (188 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_ALLOWLOWERCASE | V_PERPLAYER

	local anim = joeFuncs.getEase("inoutquad", player.hudstuff["specinfo"], (220 * FRACUNIT), y)
	local alpha = joeFuncs.getAlpha(v, 17 - (player.hudstuff["specinfo"] / 2))

	local text = ""
	local playersingame = 0

	if G_IsSpecialStage() then
		text = "Wait for the stage to end..."

	elseif G_GametypeUsesLives() then
		if (CV_FindVar("cooplives").value == 2) then
			for targets in players.iterate do
				if (targets == player) then continue end
				if (targets.spectator) then continue end

				playersingame = $ + 1
			end

			text = (playersingame > 0) and "You'll steal a live on respawn..." or "Wait to respawn..."
		else
			text = "Wait to respawn..."
		end

	elseif G_GametypeHasSpectators() then
		text = "\x87" .. "FIRE:\x80 Enter game."
	end

	if (alpha ~= false) then
		v.drawString(x, anim - (8 * FRACUNIT), "- Spectator -", flags | alpha | V_GRAYMAP, "thin-fixed-center")
		v.drawString(x, anim, text, flags | alpha, "thin-fixed-center")
	end
end)

--//