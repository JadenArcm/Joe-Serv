--//

local function initVariables(t, opts)
	-- Variables that should not be synced or reset at map change
	if (opts) then
		-- Console variables
		t.cvars = {
			["autoexit"] = CV_RegisterVar({"joe_exittimer", "10", CV_NETVAR, {MIN = 5, MAX = 120}}),
			["showperms"] = CV_RegisterVar({"joe_showperms", "On", CV_NETVAR, CV_OnOff}),

			["nametags"] = CV_RegisterVar({"joe_nametags", "On", 0, CV_OnOff}),
			["maxtags"] = CV_RegisterVar({"joe_maxtags", "5", 0, {MIN = 1, MAX = 20}}),
			["bosstags"] = CV_RegisterVar({"joe_bosstags", "On", 0, CV_OnOff}),

			["radar"] = CV_RegisterVar({"joe_emblemradar", "Off", 0, CV_OnOff}),
			["customhud"] = CV_RegisterVar({"joe_customhud", "On", 0, CV_OnOff}),
		}

		-- Display list
		t.displayList = {}
	end

	-- Chat sounds
	t.chatSounds = {
		normal = sfx_radio,
		failure = sfx_s1b1,
		event = sfx_s25a,
		teams = sfx_s257,
		private = sfx_s3k92
	}

	-- Emblems
	t.collectedEmblems = 0
	t.totalEmblems = 0
	t.emblemTics = 0
	t.emblemInfo = {}

	-- Time limit / Autoexit
	t.exitCountdown = t.cvars["autoexit"].value * (60 * TICRATE)
	t.exitTics = 0
	t.exitDelay = 0

	-- CSay?
	t.sayTimer = 0
	t.sayText = ""

	-- Tips
	t.tipTics = 0
	t.tipTimer = 0
	t.tipDelay = 2 * TICRATE
	t.tipText = ""

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