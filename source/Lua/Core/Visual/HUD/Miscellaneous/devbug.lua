--//

joeFuncs.addHUD(function(v, player)
	if not (joeVars.cvars["devbug"].value) then return end
	if not joeFuncs.isValid(player.realmo) then return end

	local x, y = (14 * FRACUNIT), (156 * FRACUNIT)
	local flags = V_SNAPTOLEFT | V_SNAPTOBOTTOM | V_PERPLAYER

	local alpha = (player.spectator) and V_60TRANS or 0
	local poscol, othcol = 0x82, 0x83

	local info = {
		string.format("%cX:\x80 %.2f", poscol, player.realmo.x),
		string.format("%cY:\x80 %.2f", poscol, player.realmo.y),
		string.format("%cZ:\x80 %.2f", poscol, player.realmo.z),

		string.format("%cANG:\x80 %.1f", othcol, AngleFixed(player.realmo.angle)),
		string.format("%cAIM:\x80 %.1f", othcol, AngleFixed(player.aiming)),
		string.format("%cSPD:\x80 %.1f", othcol, FixedHypot(player.speed, player.realmo.momz))
	}

	joeFuncs.drawFill(v, x - (2 * FRACUNIT), y, 48 * FRACUNIT, ((#info * 6) - 1) * FRACUNIT, 31 | V_20TRANS)
	for i = 1, #info do
		local opts = (i > 3) and {2 * FRACUNIT, alpha} or {0, 0}
		local dumb = -(3 * FRACUNIT) + opts[1]

		v.drawString(x, (y + dumb) + ((i * 5) * FRACUNIT), info[i], flags | opts[2], "small-fixed")
	end
end)

--//