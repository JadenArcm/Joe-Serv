--//

addHook("ThinkFrame", function()
	joeVars.sayTimer = max(0, $ - 1)
end)

joeFuncs.addHUD(function(v)
	local x, y = (160 * FRACUNIT), (96 * FRACUNIT)
	local alpha = joeFuncs.getAlpha(v, 17 - min(joeVars.sayTimer / 2, 17))

	if (alpha ~= false) then
		v.drawString(x, y, joeVars.sayText, V_ALLOWLOWERCASE | alpha, "fixed-center")
	end
end)

--//
