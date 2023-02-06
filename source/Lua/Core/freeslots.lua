--//

freeslot("S_COOPEMBLEM", "MT_COOPEMBLEM")
freeslot("S_STOCKEXPLOSION", "SPR_JEXP")

freeslot("sfx_jjoin", "sfx_jleave", "sfx_jkick", "sfx_jfail")
freeslot("sfx_jtip")

freeslot("sfx_emjgot", "sfx_emjall", "sfx_emjexp")
freeslot("sfx_jexpl", "sfx_jslip", "sfx_jsplat", "sfx_jfall")

--//

states[S_COOPEMBLEM] = {SPR_EMBM, A, -1, nil, 0, 0, S_NULL}
mobjinfo[MT_COOPEMBLEM] = {
	doomednum = -1,
	spawnstate = S_COOPEMBLEM,
	seestate = S_COOPEMBLEM,
	radius = 16 * FU,
	height = 30 * FU,
	flags = MF_SPECIAL | MF_NOGRAVITY | MF_NOCLIPHEIGHT
}

--//

states[S_STOCKEXPLOSION] = {SPR_JEXP, A | FF_ANIMATE, 17, nil, 16, 1, S_NULL}

--//

sfxinfo[sfx_jjoin].caption = "Player Joined"
sfxinfo[sfx_jleave].caption = "Player Left"
sfxinfo[sfx_jkick].caption = "Player Kicked"
sfxinfo[sfx_jfail].caption = "Player Sync-Failed"

--//

sfxinfo[sfx_emjgot].caption = "Got an emblem!"
sfxinfo[sfx_emjall].caption = "Got them all!"
sfxinfo[sfx_emjexp].caption = "Explosion"

--//

sfxinfo[sfx_jexpl].caption = "Explosion"
sfxinfo[sfx_jslip].caption = "Cartoon sound"
sfxinfo[sfx_jsplat].caption = "Crushed"
sfxinfo[sfx_jfall].caption = "AAAAAAA"

--//

sfxinfo[sfx_jtip].caption = "Tip"

--//
