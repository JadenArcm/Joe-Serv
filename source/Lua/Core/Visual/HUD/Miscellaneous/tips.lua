--//

local CMD_COLOR = "\x82"
local CVAR_COLOR = "\x87"

local tipTexts = {
	"You can type " .. CMD_COLOR .. "colorize" .. "\x80 on your console to become, well, colorized!",
	"No rings? Get some with " .. CMD_COLOR .. "setrings" .. "\x80!",
	{"Wanna be super for some reason? Use " .. CMD_COLOR .. "togglesuper" .. "\x80!", "(You also need some \x83" .. "emeralds" .. "\x80...)"},
	{"You died? Got 1 life? No problem! " .. CMD_COLOR .. "setlives" .. "\x80 is your solution.", "(You won't be reborn if you \x85" .. "Game Over" .. "\x80'd.)"},

	{"Be respectful to others, please.", "If doing otherwise, you will be either \x85" .. "muted" .. "\x80, \x85" .. "kicked" .. "\x80 or \x85" .. "banned" .. "\x80."},

	"You can use commands on the chat! Just use the \x86" .. "/<command>" .. "\x80 prefix, and call it a day.",
	{"Wanna search some \x83" .. "emblems" .. "\x80?", "Toggle " .. CVAR_COLOR .. "joe_emblemradar" .. "\x80 and go for all of those emblems!"},
	{"You don't really like names on top of every player? Disable it with " .. CVAR_COLOR .. "joe_nametags" .. "\x80.",  "(and " .. CVAR_COLOR .. "joe_maxtags" .. "\x80 to see a few according to your preference.)"},
	{"You can see how the bosses are!", "With " .. CVAR_COLOR .. "joe_bosstags" .. "\x80, you can see the amount of health they have."},
	{"You don't like the HUD display? Don't worry! Just can use " .. CVAR_COLOR .. "joe_chmain" .. "\x80 to disable it.", "Also, " .. CVAR_COLOR .. "joe_chrank" .. "\x80 exists for the player list, too."},

	"\x85" .. "Joe" .. "\x80 is watching you everywhere. No matter what. ALL HAIL \x85" .. "JOE" .. "\x80!",
	"\x85" .. "among us" .. "\x80. are you the \x85" .. "among us" .. "\x80? all hail \x85" .. "among us" .. "\x80.",
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
end
addHook("ThinkFrame", handleTickers)

--//

joeFuncs.addHUD(function(v)
	if not (netgame or multiplayer) then return end

	local x, y = (160 * FU), (187 * FU)
	local flags = V_SNAPTOBOTTOM

	local scaledwidth = (v.width() / v.dupx()) * FU
	local anim = joeFuncs.getEase("outquint", joeVars.tipTics, (256 * FU), y)

	joeFuncs.drawFill(v, 0, anim - (8 * FU), scaledwidth, 22 * FU, 31 | V_20TRANS | V_SNAPTOLEFT | flags)

	if (type(joeVars.tipText) == "table") then
		for i = 1, #joeVars.tipText do
			v.drawString(x, (anim - (7 * FU)) + ((5 * FU) * i), joeVars.tipText[i], V_ALLOWLOWERCASE | flags, "small-fixed-center")
		end
	else
		v.drawString(x, anim, joeVars.tipText, V_ALLOWLOWERCASE | flags, "small-fixed-center")
	end
end)

--//