//

joeFuncs.getSkincolor = function(v, player, style)
	local has_dashmode = (player.dashmode > (3 * TICRATE)) and ((leveltime / 2) % 2)
	local colorized = (((player.charflags & SF_MACHINE) and has_dashmode) and TC_DASHMODE) or ((player.realmo.colorized or has_dashmode) and TC_RAINBOW) or player.skin
	local color = (style) and player.skincolor or player.realmo.color

	return v.getColormap(colorized, color)
end

//

joeFuncs.drawFill = function(v, x, y, width, height, color, flags)
	//

	local colors = max(0, min(color, 255))
	local patch = v.cachePatch(string.format("~%03d", colors))

	//

	v.drawCropped(x, y, width, height, patch, flags, nil, 0, 0, FRACUNIT, FRACUNIT)

	//
end

//

joeFuncs.drawNum = function(v, x, y, number, flags, font, align, space, pad)
	//

	font = $ or "STTNUM"
	flags = $ or 0
	space = $ or 0
	pad = $ or 0

	local newx = x
	local alignx = 0

	//

	number = tostring($)

	if (pad and tonumber(pad)) then
		number = string.format("%0" .. pad .. "d", $)
	end

	//

	for i = 1, string.len(number) do
		local bit = string.sub(number, i, i)
		local patch = v.cachePatch(font .. bit)

		if joeFuncs.isValid(patch) then
			alignx = $ + ((space or patch.width) * FRACUNIT)
		end
	end

	if (align == "right") then
		newx = x - alignx
	elseif (align == "center") then
		newx = x - (alignx / 2)
	end

	//

	for i = 1, string.len(number) do
		local bit = string.sub(number, i, i)
		local patch = v.cachePatch(font .. bit)

		v.drawScaled(newx, y, FRACUNIT, patch, flags, nil)

		if joeFuncs.isValid(patch) then
			newx = $ + ((space or patch.width) * FRACUNIT)
		end
	end

	//
end

//

joeFuncs.mapToScreen = function(v, player, mo)
	//

	local cam = (camera.chase) and {camera.x, camera.y, camera.z, camera.angle, camera.aiming} or {player.realmo.x, player.realmo.y, player.viewz, player.realmo.angle, player.aiming}

	//

	local sx = cam[4] - R_PointToAngle2(cam[1], cam[2], mo[1], mo[2])
	local sy = 0
	local sf = 0
	local sv = true

	local distance = max(1, cos(sx))
	local y_distance = max(1, FixedMul(distance, R_PointToDist2(cam[1], cam[2], mo[1], mo[2])))

	local resolution = (v.width() * 100) / v.height()
	local adjustment = 0

	local fov = (CV_FindVar("fov").value / FRACUNIT) * resolution / 90
	local resolution_fov = (resolution * 2) - fov

	//

	if (resolution == fov) then
		if (resolution < 160) then
			adjustment = 160 - resolution
		elseif (resolution > 160) then
			adjustment = resolution - 160
		end
	end

	if (sx > ANGLE_90) or (sx < ANGLE_270) then
		sv = false
	end

	//

	local calculation = (resolution_fov + adjustment)
	sx = FixedMul(tan($), calculation * FRACUNIT) + (160 * FRACUNIT)
	sy = (FixedDiv(cam[3] - mo[3], y_distance) * calculation) + (100 * FRACUNIT) + (tan(cam[5]) * calculation)

	local t_distance = max(0, R_PointToDist(mo[1], mo[2]) - (2048 * FRACUNIT / 2)) * 20
	sf = min(9, (t_distance / FRACUNIT) / 2048) << V_ALPHASHIFT

	//

	return {x = sx, y = sy, flags = sf, visible = sv}

	//
end

//