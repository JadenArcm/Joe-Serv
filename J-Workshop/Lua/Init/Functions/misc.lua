//

joeFuncs.isValid = function(mo)
	return (mo and mo.valid)
end

//

joeFuncs.getEasing = function(func, ticker, m, x)
	//

	local tics = (FRACUNIT / TICRATE) * max(0, min(ticker, TICRATE))
	return ease[func](tics, m, x)

	//
end

//

joeFuncs.getTimer = function(tics)
	//
	
	local mins = G_TicsToMinutes(tics, true)
	local secs = G_TicsToSeconds(tics)
	local cent = G_TicsToCentiseconds(tics)

	return string.format("%d:%02d.%02d", mins, secs, cent)
	
	//
end

//

joeFuncs.getCountdown = function(tics)
	//
	
	local timer, flashing;
	local countdown_timer = mapheaderinfo[gamemap].countdown * TICRATE
	
	local timelimit_mins = (timelimit > 0) and (timelimit * (60 * TICRATE)) or 0
	local hidetime = CV_FindVar("hidetime").value * TICRATE
	
	//
	
	if G_TagGametype() then
		timelimit_mins = $ + hidetime
	end
	
	//
	
	if (gametyperules & GTR_STARTCOUNTDOWN) and (tics <= hidetime) then
		timer = (hidetime - tics) + 34
		flashing = true
	else
		if (gametyperules & GTR_TIMELIMIT) and (timelimit) then
			timer = (timelimit_mins > tics) and ((timelimit_mins - tics) + 34) or 0
			flashing = true
		elseif (gametyperules & GTR_STARTCOUNTDOWN) then
			timer = tics - hidetime	
		elseif (mapheaderinfo[gamemap].countdown) then
			timer = countdown_timer - tics
			flashing = true
		else
			timer = tics
			flashing = false
		end
	end
	
	//
	
	local show = flashing and (timer < (30 * TICRATE)) and ((leveltime / 5) & 1) and not (stoppedclock)
	
	//
	
	return {tics = timer, countdown = flashing, flashing = show}
	
	//
end

//