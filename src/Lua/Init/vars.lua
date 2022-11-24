//

joeVars.scoresKey = false
joeVars.scoresTicker = 0

//

joeVars.tipText = ""
joeVars.tipTimer = (TICRATE * 15)
joeVars.tipDelay = 0
joeVars.tipTicker = 0

//

joeVars.autoTicker = 0
joeVars.autoTimer = 0

//

joeVars.HUDTicker = 0
joeVars.RingTicker = 0

//

joeVars.totalEmblems = 0
joeVars.collectedEmblems = 0
joeVars.emblemTicker = 0
joeVars.emblemInfo = {}

//

joeVars.chatSounds = {
	normal = sfx_radio,
	failure = sfx_s1b1,
	event = sfx_s25a,
	teams = sfx_s257,
	private = sfx_s3k92
}

//

joeVars.autoExit = CV_RegisterVar({name = "joe_autoexit", defaultvalue = "5", flags = CV_NETVAR, possiblevalue = {MIN = 5, MAX = 60}})
joeVars.nameTags = CV_RegisterVar({name = "joe_nametags", defaultvalue = "Off", flags = 0, possiblevalue = CV_OnOff})
joeVars.emblemRadar = CV_RegisterVar({name = "joe_emblemradar", defaultvalue = "Off", flags = 0, possiblevalue = CV_OnOff})

joeVars.ownDebug = CV_RegisterVar({name = "joe_owndebug", defaultvalue = "Off", flags = 0, possiblevalue = CV_OnOff})

//

local function resetVars()
	//

	joeVars.scoresKey = false
	joeVars.scoresTicker = 0

	//

	joeVars.autoTicker = 0
	joeVars.autoTimer = joeVars.autoExit.value * (60 * TICRATE)

	//

	joeVars.HUDTicker = 0
	joeVars.RingTicker = 0

	//

	joeVars.totalEmblems = 0
	joeVars.collectedEmblems = 0
	joeVars.emblemTicker = 0
	joeVars.emblemInfo = {}

	//
end
addHook("MapLoad", resetVars)

//

local function syncVars(net)
	//

	joeVars.tipText = net($)
	joeVars.tipTimer = net($)
	joeVars.tipDelay = net($)
	joeVars.tipTicker = net($)

	//

	joeVars.autoTicker = net($)
	joeVars.autoTimer = net($)

	//

	joeVars.totalEmblems = net($)
	joeVars.collectedEmblems = net($)
	joeVars.emblemTicker = net($)
	joeVars.emblemInfo = net($)

	//
end
addHook("NetVars", syncVars)

//
