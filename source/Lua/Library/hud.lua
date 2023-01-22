--//

function joeFuncs.addHUD(func)
	table.insert(joeVars.displayList, func)
end

function joeFuncs.getWaving(i, mn, mx, tics)
	return sin(FixedAngle((tics + (mn * i)) * (mx * FRACUNIT)))
end

--//

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

	v.drawCropped(x, y, width, height, v.cachePatch(patch), flags, nil, 0, 0, FRACUNIT, FRACUNIT)
end

function joeFuncs.drawNum(v, x, y, num, flags, params)
	local rx, ax = x, 0

	local font  	= (params) and params.font  or "STTNUM"
	local spacing	= (params) and params.space or 0
	local pad   	= (params) and params.pad   or 0
	local scale		= (params) and params.scale or FRACUNIT
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
			ax = $ + FixedMul(width * FRACUNIT, scale)
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
			rx = $ + FixedMul(width * FRACUNIT, scale)
		end
	end
end

--//

---@param player player_t
function joeFuncs.worldToScreen(v, player, mo)
	local cam = {player.realmo.x, player.realmo.y, player.viewz, player.realmo.angle, player.aiming}

	if (camera.chase) then
		cam = {camera.x, camera.y, camera.z, camera.angle, camera.aiming}
	elseif (player.awayviewmobj) then
		cam = {player.awayviewmobj.x, player.awayviewmobj.y, player.awayviewmobj.z, player.awayviewmobj.angle, player.awayviewaiming}
	end

	local sx = cam[4] - R_PointToAngle2(cam[1], cam[2], mo[1], mo[2])
	local sy = 0
	local sv = true

	local dist = max(1, cos(sx))
	local ydist = max(1, FixedMul(dist, R_PointToDist2(cam[1], cam[2], mo[1], mo[2])))

	local res = (v.width() * 100) / v.height()
	local adj = 0

	local fov = (CV_FindVar("fov").value / FRACUNIT) * res / 90
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
	sx = FixedMul(tan($), calc * FRACUNIT) + (160 * FRACUNIT)
	sy = (FixedDiv(cam[3] - mo[3], ydist) * calc) + (100 * FRACUNIT) + (tan(cam[5]) * calc)

	return {x = sx, y = sy, visible = sv}

	//
end

--//