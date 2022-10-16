//

freeslot("S_COOPEMBLEM", "MT_COOPEMBLEM")

freeslot("sfx_jjoin", "sfx_jleave", "sfx_jkick", "sfx_jfail")
freeslot("sfx_jtip")

freeslot("sfx_jhurt", "sfx_jwarn", "sfx_jheal")

//

states[S_COOPEMBLEM] = {SPR_EMBM, A | (FF_PAPERSPRITE | FF_FULLBRIGHT), -1, nil, 0, 0, S_NULL}

mobjinfo[MT_COOPEMBLEM] = {
	doomednum = -1,
	spawnstate = S_COOPEMBLEM,
	radius = 16 * FRACUNIT,
	height = 30 * FRACUNIT,
	flags = MF_SPECIAL | MF_NOGRAVITY | MF_NOCLIPHEIGHT
}

//

sfxinfo[sfx_jjoin].caption = "Player Joined"
sfxinfo[sfx_jleave].caption = "Player Left"
sfxinfo[sfx_jkick].caption = "Player Kicked"
sfxinfo[sfx_jfail].caption = "Player Sync-Failed"

//

sfxinfo[sfx_jtip].caption = "A tip arrived"

//

sfxinfo[sfx_jhurt].caption = "Hurt"
sfxinfo[sfx_jwarn].caption = "Low on health"
sfxinfo[sfx_jheal].caption = "Heal"

//