--//

local emblem_dists = {
	{3072, SKINCOLOR_BLUE},
	{2048, SKINCOLOR_EMERALD},
	{1024, SKINCOLOR_YELLOW},
	{512, SKINCOLOR_ORANGE},
	{128, SKINCOLOR_RED}
}

--//

local function getParams(v, xs, xn, tics)
	local alpha = joeFuncs.getAlpha(v, 17 - (tics / 2))
	local easing = joeFuncs.getEase("inoutquad", tics, xs, xn)

	return alpha, easing
end

--//

local function drawEmblem(v, x, y, flags, params)
	local color = SKINCOLOR_SILVER
	local dist = joeFuncs.getDistance(params[1], params[2]) / FRACUNIT

	for i = 1, #emblem_dists do
		if (dist <= emblem_dists[i][1]) then
			color = emblem_dists[i][2]
		end
	end

	if not (params[1].health) then
		color = SKINCOLOR_GREY
	end

	v.drawScaled(x, y, FRACUNIT, v.cachePatch("JOE_HUNT" .. (params[1].health and "A" or "B")), flags, v.getColormap(TC_DEFAULT, color))
end

--//

local function handleTics()
	if (gamestate ~= GS_LEVEL) then return end

	if (leveltime > TICRATE) then
		joeVars.emblemTics = (joeVars.cvars["radar"].value and not ((joeVars.collectedEmblems >= #joeVars.emblemInfo) or G_RingSlingerGametype())) and min($ + 1, TICRATE) or max(0, $ - 1)
	end
end
addHook("ThinkFrame", handleTics)

joeFuncs.addHUD(function(v, player)
	if not (#joeVars.emblemInfo) then return end

	local x, y = (152 * FRACUNIT), (176 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha, anim = getParams(v, (230 * FRACUNIT), y, joeVars.emblemTics)

	if (alpha ~= false) then
		for i, mo in ipairs(joeVars.emblemInfo) do
			local wave = joeFuncs.getWave(i, 15, 4, 3)
			local offs = ((i - 1) * 20) - ((#joeVars.emblemInfo - 1) * 10)

			drawEmblem(v, x + (offs * FRACUNIT), anim + wave, flags | alpha, {mo, player.realmo})
		end
	end
end)

--//