//

local function joinSounds()
	S_StartSound(nil, sfx_jjoin)
end
addHook("PlayerJoin", joinSounds)

//

local function leaveSounds(_, reason)
	//
	
	if (reason == KR_LEAVE) then
		S_StartSound(nil, sfx_jleave)
	end
	
	//
	
	if (reason == KR_SYNCH) or (reason == KR_TIMEOUT) or (reason == KR_PINGLIMIT) then
		S_StartSound(nil, sfx_jfail)
	end
	
	if (reason == KR_KICK) or (reason == KR_BAN) then
		S_StartSound(nil, sfx_jkick)
	end
	
	//
end
addHook("PlayerQuit", leaveSounds)

//