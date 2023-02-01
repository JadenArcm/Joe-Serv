--//

local function chatprintEx(player, msg, sound)
	if (player ~= nil) then
		chatprintf(player, msg)
	else
		chatprint(msg)
	end

	if (CV_FindVar("chatnotifications").value) then
		S_StartSound(nil, sound, player)
	end
end

local function chatError(player, msg)
	local err = "\x82* \x85" .. "ERROR: " .. "\x82"
	return chatprintEx(player, err .. msg, joeVars.chatSounds.failure)
end

--//

addHook("PlayerMsg", function(source, type, target, message)
	if (#message > 220) then
		chatError(source, "Messages cannot be above \x85" .. "220" .. "\x82 characters.")
		return true
	end

	if (source.chat.muted) then
		chatError(source, "You are muted, so you can't talk for the time being. (Reason: \x80" .. source.chat.mute_reason .. "\x82)")
		return true
	end

	if (type == 0) then
		if (string.sub(message, 1, 4) == "/me ") then
			chatprintEx(nil, "\x82> " .. joeFuncs.getPlayerName(source, 0) .. "\x80 " .. string.sub(message, 5), joeVars.chatSounds.normal)
			return true
		end

		if (string.sub(message, 1, 1) == "/") then
			COM_BufInsertText(source, string.sub(message, 2, string.len(message)))
			chatprintEx(source, "\x82* \x80" .. "Executed command \x86\"" .. string.sub(message, 2, string.len(message)) .. "\"\x80.", joeVars.chatSounds.event)
			return true
		end

		chatprintEx(nil, joeFuncs.getPlayerName(source, 1|2) .. "\x80: " .. message, joeVars.chatSounds.normal)
		return true
	end

	if (type == 1) then
		if (gamestate ~= GS_LEVEL) then
			chatError(source, "Team messages can only be used on levels.")
			return true
		end

		if (source.spectator) then
			chatError(source, "Team messages are for players, not for spectators.")
			return true
		end

		for targets in players.iterate do
			if (source.ctfteam == targets.ctfteam) then
				chatprintEx(targets, ({"\x85", "\x84"})[source.ctfteam] .. "[TEAM] " .. joeFuncs.getPlayerName(source, 1) .. "\x80: " .. message, joeVars.chatSounds.teams)
			end
		end

		return true
	end

	if (type == 2) then
		if (source == target) then
			chatError(source, "That target, is yourself.")
			return true
		end

		if (target.chat.muted) then
			chatError(source, "The selected target is currently muted.")
			return true
		end

		local player_message = "\x82" .. "[TO] " .. joeFuncs.getPlayerName(target, 0)
		local target_message = "\x82" .. "[FROM] " .. joeFuncs.getPlayerName(source, 0)

		chatprintEx(source, player_message .. "\x80: " .. message, joeVars.chatSounds.private)
		chatprintEx(target, target_message .. "\x80: " .. message, joeVars.chatSounds.private)
		return true
	end

	if (type == 3) then
		if (gamestate ~= GS_LEVEL) then
			chatError(source, "You can only use this on a level.")
			return true
		end

		joeVars.sayText = message
		joeVars.sayTimer = 5 * TICRATE

		S_StartSound(nil, joeVars.chatSounds.csay, nil)
		return true
	end

	return nil
end)

--//