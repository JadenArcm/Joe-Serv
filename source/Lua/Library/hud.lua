--//

function joeFuncs.addHUD(func)
	table.insert(joeVars.displayList, func)
end

function joeFuncs.getWave(interval, diff, speed, range)
	return sin(FixedAngle((leveltime + (diff * interval)) * (speed * FU))) * range
end

--//

function joeFuncs.getPingPatch(v, player)
	if (player.bot) then
		return v.cachePatch("ICON_BOT")
	end

	if (player.quittime > 0) then
		local values = {0, 0, 0, 0, 0, 0, 1, 2, 3, 4}
		return v.cachePatch("JOE_OUTG" .. values[((leveltime / 7) % #values) + 1])
	end

	local values = {3, 5, 7, 9}
	local patch_num = 0

	for i = 1, #values do
		if (player.cmd.latency >= values[i]) then
			patch_num = min(i + 1, 3)
		end
	end

	return v.cachePatch("JOE_PING" .. patch_num)
end

function joeFuncs.getSkincolor(v, player, real_color)
	local dashmode = (player.dashmode > (3 * TICRATE)) and ((leveltime % 4) < 2)
	local map = (((player.charflags & SF_MACHINE) and (dashmode)) and TC_DASHMODE) or (((player.realmo.colorized) or (dashmode)) and TC_RAINBOW) or player.skin
	local color = (real_color) and player.realmo.color or player.skincolor

	return v.getColormap(map, color)
end

function joeFuncs.getAlpha(v, num)
	local shift = min((v.localTransFlag() >> V_ALPHASHIFT) + num, 10)

	if (shift >= 10) then
		return false
	end

	return (shift << V_ALPHASHIFT)
end

--//

function joeFuncs.drawFill(v, x, y, width, height, col)
	local patch = string.format("~%03d", max(0, min((col & 255), 255)))
	local flags = col

	if (width < 0) then width = 0 end
	if (height < 0) then height = 0 end

	v.drawCropped(x, y, width, height, v.cachePatch(patch), flags, nil, 0, 0, FU, FU)
end

function joeFuncs.drawNum(v, x, y, num, flags, params)
	local rx, ax = x, 0

	local font  	= (params) and params.font  or "STTNUM"
	local spacing	= (params) and params.space or 0
	local pad   	= (params) and params.pad   or 0
	local scale		= (params) and params.scale or FU
	local alignment = (params) and params.align or "left"

	num = tostring($)
	if (pad and tonumber(pad)) then
		num = string.format("%0" .. pad .. "d", $)
	end

	-- Number width for alignments
	for w = 1, string.len(num) do
		local bit = string.sub(num, w, w)
		local patch = v.cachePatch(font .. bit)
		local width = spacing or patch.width

		if joeFuncs.isValid(patch) then
			ax = $ + FixedMul(width * FU, scale)
		end
	end

	if (alignment == "right") then
		rx = x - ax
	elseif (alignment == "center") then
		rx = x - (ax / 2)
	end

	-- Draw numbers
	for i = 1, string.len(num) do
		local bit = string.sub(num, i, i)
		local patch = v.cachePatch(font .. bit)
		local width = spacing or patch.width

		v.drawScaled(rx, y, scale, patch, flags, nil)

		if joeFuncs.isValid(patch) then
			rx = $ + FixedMul(width * FU, scale)
		end
	end
end

--//

function joeFuncs.worldToScreen(v, player, mobj)
	local cam = {x = player.realmo.x, y = player.realmo.y, z = player.viewz, ang = player.realmo.angle, aim = player.aiming}
	local mo = {x = mobj[1], y = mobj[2], z = mobj[3]}

	if (player.awayviewtics) then
		cam = {x = player.awayviewmobj.x, y = player.awayviewmobj.y, z = player.awayviewmobj.z, ang = player.awayviewmobj.angle, aim = player.awayviewaiming}
	elseif (camera.chase) then
		cam = {x = camera.x, y = camera.y, z = camera.z, ang = camera.angle, aim = camera.aiming}
	end

	local sx = cam.ang - R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
	local sy = 0
	local sv = true

	local dist = max(1, cos(sx))
	local ydist = max(1, FixedMul(dist, R_PointToDist2(cam.x, cam.y, mo.x, mo.y)))

	local res = (v.width() * 100) / v.height()
	local adj = 0

	local fov = (FixedInt(CV_FindVar("fov").value) * res) / 90
	local rfv = (res * 2) - fov

	if (res == fov) then
		if (res < 160) then
			adj = (160 - res)
		elseif (res > 160) then
			adj = (res - 160)
		end
	end

	if (sx > ANGLE_90) or (sx < ANGLE_270) then
		sv = false
	end

	local calc = (rfv + adj)
	sx = FixedMul(tan($), calc * FU) + (160 * FU)
	sy = (FixedDiv(cam.z - mo.z, ydist) * calc) + (100 * FU) + (tan(cam.aim) * calc)

	return {x = sx, y = sy, visible = sv}
end

--//