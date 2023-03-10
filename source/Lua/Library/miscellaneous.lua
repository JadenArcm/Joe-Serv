--//

function joeFuncs.isValid(mo)
	return (mo and mo.valid)
end

function joeFuncs.getDistance(ref, mo)
	return FixedHypot(FixedHypot(ref.x - mo.x, ref.y - mo.y), ref.z - mo.z)
end

function joeFuncs.getColor(color)
	if (color <= SKINCOLOR_NONE) or (color == nil) then
		return "\x80"
	end

	local c = 0x80 + (skincolors[color].chatcolor >> V_CHARCOLORSHIFT)
	return string.char(c)
end

--//

function joeFuncs.getEase(type, tics, minimum, maximum)
	local timer = (FU / TICRATE) * max(0, min(tics, TICRATE))
	return ease[type](timer, minimum, maximum)
end

function joeFuncs.getTime(time)
	local min, sec, cen = G_TicsToMinutes(time, true), G_TicsToSeconds(time), G_TicsToCentiseconds(time)
	return string.format("%d:%02d.%02d", min, sec, cen)
end

function joeFuncs.getPlural(str, val)
	return (val == 1) and str or (str .. "s")
end

--//

function joeFuncs.getHUDTime(time)
	local timer, flash = 0, false
	local countdown_time = mapheaderinfo[gamemap].countdown * TICRATE

	local hidetime = CV_FindVar("hidetime").value * TICRATE
	local timelimit_mins = ((timelimit > 0) and (timelimit * (60 * TICRATE)) or 0) + (G_TagGametype() and hidetime or 0)

	if (gametyperules & GTR_STARTCOUNTDOWN) and (time <= hidetime) then
		timer = (hidetime - time) + (TICRATE - 1)
		flash = true
	else
		if (gametyperules & GTR_TIMELIMIT) and (timelimit > 0) then
			timer = (timelimit_mins > time) and ((timelimit_mins - time) + (TICRATE - 1)) or 0
			flash = true

		elseif (gametyperules & GTR_STARTCOUNTDOWN) then
			timer = time - hidetime

		elseif (mapheaderinfo[gamemap].countdown) then
			timer = countdown_time - time
			flash = true

		else
			timer = time
			flash = false
		end
	end

	local warn = (flash) and (timer < (30 * TICRATE)) and ((leveltime / 5) & 1) and not (stoppedclock)
	return {tics = timer, should_flash = flash, warn = warn}
end

--//

function joeFuncs.float2Fixed(float)
	if (float == nil) then
		return nil
	end

	local decimalPos = float:find("%.")
	if (decimalPos == nil) then
		return tonumber(float) and (tonumber(float) * FU) or nil
	end

	local intVal = tonumber(float:sub(0, decimalPos - 1)) * FU

	local fracStr = float:sub(decimalPos + 1, float:len())
	local fracVal = tonumber(fracStr) * FU

	for _ = 1, fracStr:len() do
		fracVal = FixedDiv($, 10 * FU)
	end

	return float:find("^-") and (intVal - fracVal) or (intVal + fracVal)
end

--//