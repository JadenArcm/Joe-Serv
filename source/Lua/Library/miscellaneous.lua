--//

function joeFuncs.isValid(mo)
	return (mo and mo.valid)
end

function joeFuncs.getDistance(ref, mo)
	return FixedHypot(FixedHypot(ref.x - mo.x, ref.y - mo.y), ref.z - mo.z)
end

function joeFuncs.getColor(color)
	if not (color) then
		return "\x80"
	end

	local c = 0x80 + (skincolors[color].chatcolor >> V_CHARCOLORSHIFT)
	return string.char(c)
end

--//

function joeFuncs.getEase(type, tics, l, m)
	local timer = (FRACUNIT / TICRATE) * max(0, min(tics, TICRATE))
	return ease[type](timer, l, m)
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
	if not (float and string.len(float)) then
		return nil
	end

	local decPos = string.find(float, "%.")
	if (decPos == nil) then
		return (tonumber(float) * FRACUNIT)
	end

	local num = tonumber(string.sub(float, 0, decPos - 1)) * FRACUNIT
	local frac, i = 0, 1

	for c in string.gmatch(string.sub(float, decPos + 1, string.len(float)), "%d+") do
		frac = $ + (tonumber(c) * FRACUNIT) / (10 ^ i)
		i = $ + 1

		if (i == 7) then
			break
		end
	end

	return (num + frac)
end

--//