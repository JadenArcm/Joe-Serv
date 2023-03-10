--//

local function initVariables(t, no_reset)
	-- Variables that should not be reset at map change
	if (no_reset) then
		-- Console variables
		t.cvars = {
			["autoexit"] = CV_RegisterVar({"joe_exittimer", "10", CV_NETVAR, {MIN = 5, MAX = 120}}),
			["health"] = CV_RegisterVar({"joe_survival", "Off", CV_NETVAR | CV_CALL | CV_NOINIT, CV_OnOff, function(var)
				joeVars.sayText = "The health system has been" .. ((var.value == 1) and "\x83 enabled" or "\x86 disabled") .. "\x80."
				joeVars.sayTimer = 5 * TICRATE

				S_StartSound(nil, sfx_hidden, nil)
			end}),

			["nametags"] = CV_RegisterVar({"joe_nametags", "On", 0, CV_OnOff}),
			["maxtags"] = CV_RegisterVar({"joe_maxtags", "5", 0, {MIN = 1, MAX = 20}}),
			["bosstags"] = CV_RegisterVar({"joe_bosstags", "On", 0, CV_OnOff}),

			["radar"] = CV_RegisterVar({"joe_emblemradar", "Off", 0, CV_OnOff}),
			["showperms"] = CV_RegisterVar({"joe_showperms", "On", CV_NETVAR, CV_OnOff}),

			["display"] = CV_RegisterVar({"joe_chmain", "On", 0, CV_OnOff}),
			["scores"] = CV_RegisterVar({"joe_chrank", "On", 0, CV_OnOff}),
		}

		-- Display List
		t.displayList = {}

		-- Tips
		t.tipTics = 0
		t.tipTimer = TICRATE
		t.tipDelay = 0
		t.tipText = ""
	end

	-- Chat sounds
	t.chatSounds = {
		normal = sfx_radio,
		failure = sfx_s1b1,
		event = sfx_s25a,
		teams = sfx_s257,
		private = sfx_s3k92,
		csay = sfx_hoop3,
	}

	-- Emblems
	t.collectedEmblems = 0
	t.emblemTics = 0
	t.emblemInfo = {}

	-- Time limit / Autoexit
	t.exitCountdown = t.cvars["autoexit"].value * (60 * TICRATE)
	t.exitDelay = 0

	-- CSay?
	t.sayTimer = 0
	t.sayText = ""

	-- Starwarps
	t.starWarps = {}

	return t
end

--//

addHook("MapChange", function()
	joeVars = initVariables($, false)
end)

addHook("NetVars", function(sync)
	for entry, _ in pairs(joeVars) do
		if (entry == "cvars") then continue end
		if (entry == "displayList") then continue end
		if (entry == "emblemTics") then continue end

		joeVars[entry] = sync($)
	end
end)

--//

joeVars = initVariables($, true)

--//