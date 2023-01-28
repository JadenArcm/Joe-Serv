--//

local CMD_COLOR = "\x82"
local CVAR_COLOR = "\x87"

local tipTexts = {
	"You can type " .. CMD_COLOR .. "colorize" .. "\x80 on your console to become, well, colorized!",
	"No rings? Get some with " .. CMD_COLOR .. "setrings" .. "\x80!",
	{"You died? Got 1 life? No problem! " .. CMD_COLOR .. "setlives" .. "\x80 is your solution.", "(You won't be reborn if you \x85" .. "Game Over" .. "\x80'd.)"},

	{"Be respectful to others, please.", "If doing otherwise, you will be either \x85" .. "muted" .. "\x80, \x85" .. "kicked" .. "\x80 or \x85" .. "banned" .. "\x80."},

	{"You don't really like names on top of every player? Disable it with " .. CVAR_COLOR .. "joe_nametags" .. "\x80.",  "(and " .. CVAR_COLOR .. "joe_maxtags" .. "\x80 to see a few according to your preference.)"},
	"You can see how the bosses are! With " .. CVAR_COLOR .. "joe_bosstags" .. "\x80, you can see the amount of health they have.",
	"You can use commands on the chat! Just use the \x86" .. "/<command>" .. "\x80 prefix, and call it a day.",
}

--//

local function handleTickers()
	if (gamestate ~= GS_LEVEL) then return end
	if not (netgame or multiplayer) then return end

	joeVars.tipDelay = max(0, $ - 1)
	joeVars.tipTimer = max(0, $ - 1)

	joeVars.tipTics = (joeVars.tipDelay > 0) and min($ + 1, TICRATE) or max(0, $ - 1)

	if not (joeVars.tipTimer) then
		joeVars.tipDelay = 6 * TICRATE
		joeVars.tipTimer = 180 * TICRATE

		joeVars.tipText = tipTexts[P_RandomRange(1, #tipTexts)]
		S_StartSound(nil, sfx_jtip, nil)
	end

	print("delay: " .. joeVars.tipDelay, "tics: " .. joeVars.tipTics, "timer: " .. joeVars.tipTimer)
end
addHook("ThinkFrame", handleTickers)

--//

joeFuncs.addHUD(function(v)
	if not (netgame or multiplayer) then return end

	local x, y = (160 * FRACUNIT), (187 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM

	local scaledwidth = (v.width() / v.dupx()) * FRACUNIT
	local anim = joeFuncs.getEase("outquint", joeVars.tipTics, (256 * FRACUNIT), y)

	joeFuncs.drawFill(v, 0, anim - (8 * FRACUNIT), scaledwidth, 22 * FRACUNIT, 31 | V_20TRANS | V_SNAPTOLEFT | flags)

	if (type(joeVars.tipText) == "table") then
		for i = 1, #joeVars.tipText do
			v.drawString(x, (anim - (7 * FRACUNIT)) + ((5 * FRACUNIT) * i), joeVars.tipText[i], V_ALLOWLOWERCASE | flags, "small-fixed-center")
		end
	else
		v.drawString(x, anim, joeVars.tipText, V_ALLOWLOWERCASE | flags, "small-fixed-center")
	end
end)

--//