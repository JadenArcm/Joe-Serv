--//

local function handleTimeLimit()
	if (gamestate ~= GS_LEVEL) then return end
	if not (netgame or multiplayer) then return end
	if not (gametyperules & GTR_ALLOWEXIT) then return end

	local limittime = (leveltime - joeVars.exitCountdown)

	if (leveltime >= joeVars.exitCountdown) then
		if (limittime == 1) then
			S_ChangeMusic("_gover", false, player, 0, 0, 2 * MUSICRATE)
			S_StartSound(nil, sfx_s3k9b, nil)
			P_StartQuake(64 * FRACUNIT, 8)

			stoppedclock = true

		elseif (limittime > (10 * TICRATE)) then
			G_SetCustomExitVars(nil, 2)
			G_ExitLevel()
		end

		for player in players.iterate do
			if not joeFuncs.isValid(player.mo) then continue end

			player.mo.momx, player.mo.momy, player.mo.momz = 0, 0, 0

			player.mo.state = S_PLAY_DRWN
			player.mo.rollangle = $ + ANG2

			player.exiting = 5
			player.powers[pw_nocontrol] = 2
		end
	end
end
addHook("PreThinkFrame", handleTimeLimit)

--//