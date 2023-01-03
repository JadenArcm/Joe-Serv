//

local function drawList(v, player, x, y, flags, size)
	//

	local minimenu_items = 2
	local minimenu_size = (2 * minimenu_items) + 1

	local itemOn = player.starinfo.menu["itemOn"]

	local top, bottom
	local offs = (14 * FRACUNIT)

	//

	if (#size <= minimenu_size) then
		top = 1
		bottom = #size
	else
		if (itemOn <= minimenu_items) then
			top = 1
			bottom = minimenu_size

		elseif (itemOn >= (#size - minimenu_items)) then
			top = (#size - minimenu_size) + 1
			bottom = #size

		else
			top = itemOn - minimenu_items
			bottom = itemOn + minimenu_items
		end
	end

	//

	if (top ~= 1) then
		v.drawString(x - (7 * FRACUNIT), y - (2 * FRACUNIT) - (((leveltime % 9) / 5) * FRACUNIT), "\x1A", V_YELLOWMAP | V_HUDTRANS | flags, "fixed-center")
	end

	//

	for i = top, bottom do
		if (offs > (100 * FRACUNIT)) then
			break
		end

		local info = size[i]

		local patch = (info.mobj) and (((info.mobj.type == MT_STARPOST) and "JOE_STAR") or ((info.mobj.type == MT_SIGN) and "JOE_SIGN")) or "JOE_SPWN"
		local str = (info.mobj) and (((info.mobj.type == MT_STARPOST) and ("#" .. i)) or ((info.mobj.type == MT_SIGN) and "FIN")) or "SPW"

		local hilicol = ((itemOn == i) and V_YELLOWMAP) or ((info.mobj and not info.mobj.enabled) and V_GRAYMAP) or 0
		local properties = (info.mobj) and ((info.mobj.enabled) and {(info.mobj.type == MT_SIGN) and ColorOpposite(info.mobj.target.color) or SKINCOLOR_RED, V_HUDTRANS} or {SKINCOLOR_SILVER, V_HUDTRANSHALF}) or {SKINCOLOR_BLUE, V_HUDTRANS}

		joeFuncs.drawFill(v, x - (30 * FRACUNIT), (y - (7 * FRACUNIT)) + offs, 43 * FRACUNIT, 14 * FRACUNIT, 31 | flags | V_HUDTRANSHALF)

		v.drawScaled(x, y + offs, FRACUNIT / 2, v.cachePatch(patch), properties[2] | flags, v.getColormap(TC_DEFAULT, properties[1]))
		v.drawString(x - (18 * FRACUNIT), (y - (3 * FRACUNIT)) + offs, str, hilicol | properties[2] | flags, "thin-fixed-center")

		offs = $ + (14 * FRACUNIT)
	end

	//

	if (bottom ~= #size) then
		v.drawString(x - (7 * FRACUNIT), (125 * FRACUNIT) + (((leveltime % 9) / 5) * FRACUNIT), "\x1B", V_YELLOWMAP | V_HUDTRANS | flags, "fixed-center")
	end

	//
end

//

local function drawStarposts(v, player)
	//

	local x, y = (299 * FRACUNIT), (47 * FRACUNIT)
	local flags = V_SNAPTORIGHT | V_PERPLAYER

	local anim = joeFuncs.getEasing("inoutexpo", player.starinfo.tics, (640 * FRACUNIT), x)
	local strings = {
		"[\x82SPIN\x80] - Quit menu.",
		"[\x82JUMP\x80] - Warp to the starpost.",
		"[\x82Move Up/Down\x80] - Move through the options."
	}

	//

	if (player.starinfo.previous_tics > 0) then
		local alpha = (10 - min((player.starinfo.previous_tics / 2) + 1, CV_FindVar("translucenthud").value)) << V_ALPHASHIFT
		v.drawString(160, 192, "Press [\x82TOSSFLAG\x80] to open the starpost menu.", V_ALLOWLOWERCASE | V_SNAPTOBOTTOM | V_PERPLAYER | alpha, "small-center")
	end

	if (player.starinfo.menu_tics > 0) then
		for i = 1, #strings do
			local alpha = (10 - min((player.starinfo.menu_tics / 2) + 1, CV_FindVar("translucenthud").value)) << V_ALPHASHIFT
			v.drawString(160, 192 - ((i - 1) * 5), strings[i], V_ALLOWLOWERCASE | V_SNAPTOBOTTOM | V_PERPLAYER | alpha, "small-center")
		end
	end

	if (player.starinfo.tics > 0) then
		drawList(v, player, anim, y, flags, joeVars.starpostInfo)
	end

	//
end
hud.add(drawStarposts, "game")

//