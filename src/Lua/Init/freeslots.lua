//

freeslot(
	"S_COOPEMBLEM", "MT_COOPEMBLEM",
	"S_STOCKEXPLOSION", "SPR_JEXP",

	"sfx_jjoin", "sfx_jleave", "sfx_jkick", "sfx_jfail",
	"sfx_jtip",

	"sfx_jhurt", "sfx_jwarn",
	"sfx_jmbgot", "sfx_jmball", "sfx_jmbspk",

	"sfx_jexpl", "sfx_jslip", "sfx_jsplat", "sfx_jfall"
)

//

states[S_COOPEMBLEM] = {SPR_EMBM, A | (FF_PAPERSPRITE | FF_FULLBRIGHT), -1, nil, 0, 0, S_NULL}

mobjinfo[MT_COOPEMBLEM] = {
	doomednum = -1,
	spawnstate = S_COOPEMBLEM,
	seestate = S_COOPEMBLEM,
	radius = 16 * FRACUNIT,
	height = 30 * FRACUNIT,
	flags = MF_SPECIAL | MF_NOGRAVITY | MF_NOCLIPHEIGHT
}

//

states[S_STOCKEXPLOSION] = {SPR_JEXP, A | FF_ANIMATE, 17, nil, 16, 1, S_NULL}

//

sfxinfo[sfx_jjoin].caption = "Player Joined"
sfxinfo[sfx_jleave].caption = "Player Left"
sfxinfo[sfx_jkick].caption = "Player Kicked"
sfxinfo[sfx_jfail].caption = "Player Sync-Failed"

//

sfxinfo[sfx_jhurt].caption = "Hurt"
sfxinfo[sfx_jwarn].caption = "Low on health"

//

sfxinfo[sfx_jmbgot].caption = "Got an emblem!"
sfxinfo[sfx_jmball].caption = "Got them all!"
sfxinfo[sfx_jmbspk].caption = "Explosion"

//

sfxinfo[sfx_jexpl].caption = "Explosion"
sfxinfo[sfx_jslip].caption = "Cartoon sound"
sfxinfo[sfx_jsplat].caption = "Crushed"
sfxinfo[sfx_jfall].caption = "AAAAAAA"

//

sfxinfo[sfx_jtip].caption = "A tip arrived"
sfxinfo[sfx_s1c9] = {caption = "/", flags = SF_X2AWAYSOUND}

//
