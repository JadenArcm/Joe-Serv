//

local tipTexts = {
	"You can type \x82" .. "colorize" .. "\x80 on the console to be, well, colorized!",
	"You can get rings by using the \x82" .. "setrings" .. "\x80 command. Values are capped up to 9999.",
	"Going to die? No lives? Easy! Just use \x82" .. "setlives" .. "\x80!",
	"Wanna be super for no reason? Use \x82" .. "togglesuper" .. "\x80. You also need some \x83" .. "emeralds" .. "\x80.",
	"You can be bigger (or smaller) than normal! Just use \x82" .. "setscale" .. "\x80. You can use decimals too.",
	"You don't like losing rings? \x82" .. "togglehealth" .. "\x80 is the solution!",

	"Be respectful to others. You will be either \x85" .. "muted" .. "\x80, \x85" .. "kicked" .. "\x80, or \x85" .. "banned" .. "\x80 if doing otherwise.",
	"There's a time limit on every level. It \x85" .. "restarts" .. "\x80 the level, so be quick!",

	"You don't like names on top of players? Disable it with \x87" .. "joe_nametags" .. "\x80.",
	"Are you bored? Don't know what to do? Search some emblems with \x87" .. "joe_emblemradar" .. "\x80!",
	"Want to be \x82" .. "\"debuggy\"" .. "\x80? Just enable \x87" .. "joe_owndebug" .. "\x80!",
	"You can use commands in chat! Just use the \x87" .. "/cmd <command>" .. "\x80 prefix and call it a day.",

	"\x85" .. "Joe" .. "\x80 is watching you everywhere. No matter what. ALL HAIL \x85" .. "JOE" .. "\x80!",
	"\x85" .. "Among Us" .. "\x80, is basically life. If you don't like it, you will \x85" .. "SUFFER" .. "\x80.",
	"Hi guys! I am \x8A" .. "Sans" .. "\x80 Undertale."
}

//

local function handleTips()
	//

	if not (netgame or multiplayer) then return end

	//

	joeVars.tipTimer = max(0, $ - 1)
	joeVars.tipDelay = max(0, $ - 1)

	//

	if not (joeVars.tipTimer) then
		joeVars.tipText = tipTexts[P_RandomKey(#tipTexts) + 1]
		joeVars.tipDelay = (6 * TICRATE)
		joeVars.tipTimer = (150 * TICRATE)

		S_StartSound(nil, sfx_jtip)
	end

	//
end
addHook("ThinkFrame", handleTips)

//

local function drawTips(v)
	//

	if not (netgame or multiplayer) then return end

	//

	local x, y = (160 * FRACUNIT), (187 * FRACUNIT)
	local flags = V_SNAPTOBOTTOM

	local width = (v.width() / v.dupx()) * FRACUNIT
	local anim = joeFuncs.getEasing("outquint", joeVars.tipTicker, (400 * FRACUNIT), y)

	//

	joeVars.tipTicker = (joeVars.tipDelay > 0) and min($ + 2, TICRATE) or max(0, $ - 1)

	//

	joeFuncs.drawFill(v, 0, anim - (8 * FRACUNIT), width, 22 * FRACUNIT, 31 | V_20TRANS | V_SNAPTOLEFT | flags)
	v.drawString(x, anim, joeVars.tipText, V_ALLOWLOWERCASE | flags, "small-fixed-center")

	//
end
hud.add(drawTips, "game")

//
