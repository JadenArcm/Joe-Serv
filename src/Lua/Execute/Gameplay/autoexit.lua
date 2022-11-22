//

local function exitLogic()
	//

	if not (netgame or multiplayer) then return end
	if not (gametyperules & GTR_FRIENDLY) then return end

	//

	local exitTime = (leveltime - joeVars.autoTimer)

	//

	if (leveltime >= joeVars.autoTimer) then
		if (exitTime == 1) then
			S_StartSound(nil, sfx_s3k9b)
			S_ChangeMusic("_gover", false, nil, 0, 0, MUSICRATE * 3)

			P_StartQuake(64 * FRACUNIT, 8)

			stoppedclock = true
		end

		if (exitTime >= (11 * TICRATE)) then
			G_SetCustomExitVars(gamemap, 2)
			G_ExitLevel()
		end

		for player in players.iterate do
			if not joeFuncs.isValid(player.mo) then continue end

			player.mo.momx, player.mo.momy, player.mo.momz = 0, 0, 0
			player.mo.state = S_PLAY_PAIN

			player.powers[pw_nocontrol] = 2
		end
	end

	//
end
addHook("PostThinkFrame", exitLogic)

//
