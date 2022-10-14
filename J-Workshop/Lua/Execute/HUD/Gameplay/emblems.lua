//

local emblemDistances = {
	{3072, SKINCOLOR_BLUE},
	{2048, SKINCOLOR_EMERALD},
	{1024, SKINCOLOR_YELLOW},
	{512, SKINCOLOR_ORANGE},
	{256, SKINCOLOR_RED}
}

//

local function drawEmblemIcon(v, x, y, flags, info)
	//

	local color = SKINCOLOR_SILVER
	local distance = FixedHypot(FixedHypot(info[1].x - info[2].x, info[1].y - info[2].y), info[1].z - info[2].z) / FRACUNIT

	//

	for i = 1, #emblemDistances do
		if (distance < emblemDistances[i][1]) then
			color = emblemDistances[i][2]
		end
	end

	if not (info[1].health) then
		color = SKINCOLOR_JET
	end

	//

	v.drawScaled(x, y, FRACUNIT, v.cachePatch("JOE_HUNT"), flags, v.getColormap(TC_DEFAULT, color))

	//
end

//

local function drawEmblemRadar(v, player)
	//
	
	if not joeFuncs.isValid(player.realmo) then return end
	if not (netgame or multiplayer) then return end
	
	if not (joeVars.emblemRadar.value) then return end
	if not (#joeVars.emblemInfo) then return end

	//

	local x, y = (152 * FRACUNIT), (176 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local anim = joeFuncs.getEasing("inback", joeVars.emblemTicker, y, (400 * FRACUNIT))

	//

	if (joeVars.collectedEmblems >= joeVars.totalEmblems) then
		joeVars.emblemTicker = min($ + 1, TICRATE)
	end

	//

	for i, mo in ipairs(joeVars.emblemInfo) do
		local emblem_flags = (mo[1].health) and V_HUDTRANS or V_HUDTRANSHALF
		local offs = ((i - 1) * 20) - ((#joeVars.emblemInfo - 1) * 10)

		drawEmblemIcon(v, x + (offs * FRACUNIT), anim, emblem_flags | flags, {mo[1], player.realmo})
	end

	//
end
hud.add(drawEmblemRadar, "game")

//