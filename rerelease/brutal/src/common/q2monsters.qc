// Quake 2 strogg as equal-tier campaign replacements. Q1 AI weight.

float	Q2M_SOLDIER = 1;
float	Q2M_INFANTRY = 2;
float	Q2M_GUNNER = 3;
float	Q2M_BERSERK = 4;
float	Q2M_GLADIATOR = 5;
float	Q2M_TANK = 6;
float	Q2M_FLYER = 7;
float	Q2M_FLOAT = 8;
float	Q2M_HOVER = 9;
float	Q2M_CHICK = 10;
float	Q2M_MUTANT = 11;
float	Q2M_BRAIN = 12;
float	Q2M_MEDIC = 13;
float	Q2M_GRUNTSTR = 14;
float	Q2M_ENFSTROGG = 15;
float	Q2M_KNTSTROGG = 16;
float	Q2M_HYPERKNT = 17;
float	Q2M_HBERSTROGG = 18;
float	Q2M_OGRE2STR = 19;
float	Q2M_OGRESTR = 20;
float	Q2M_FIENDSTR = 21;
float	Q2M_SHAMSTR = 22;
float	Q2M_SHAMACUD = 23;
float	Q2M_WIZSTROGG = 24;
float	Q2M_WIZCUDA = 25;
float	Q2M_ZOMBSTR = 26;
float	Q2M_DOGSTROGG = 27;
float	Q2M_VORESTR = 28;
float	Q2M_FISHGUN = 29;
float	Q2M_ROTFLYER = 30;
float	Q2M_IRONVORE = 31;
float	Q2M_MUTSPAWN = 32;
float	Q2M_INSANE = 33;

float	Q2M_SLOT_GRUNT = 1;
float	Q2M_SLOT_ENFORCER = 2;
float	Q2M_SLOT_KNIGHT = 3;
float	Q2M_SLOT_HKNIGHT = 4;
float	Q2M_SLOT_OGRE = 5;
float	Q2M_SLOT_FIEND = 6;
float	Q2M_SLOT_SHAMBLER = 7;
float	Q2M_SLOT_SCRAG = 8;
float	Q2M_SLOT_VORE = 9;
float	Q2M_SLOT_DOG = 10;
float	Q2M_SLOT_ZOMBIE = 11;

float	Q2M_ANIM_STAND = 1;
float	Q2M_ANIM_WALK = 2;
float	Q2M_ANIM_RUN = 3;
float	Q2M_ANIM_ATK = 4;
float	Q2M_ANIM_PAIN = 5;
float	Q2M_ANIM_DIE = 6;
float	Q2M_ANIM_MELEE = 7;

void(string gibname, float dm) ThrowGib;

#ifdef BQA_HAS_MONSTERS
void() monster_use;
void() monster_death_use;
void() FoundTarget;
void() ai_stand;
void(float dist) ai_walk;
void(float dist) ai_run;
void() ai_face;
void(float dist) ai_charge;
void(float shotcount, vector dir, vector spread) FireBullets;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() T_MissileTouch;
void() GrenadeExplode;
void() GrenadeTouch;
void() spike_touch;
void() DropBackpack;
void() BecomeExplosion;
void(entity e, float bright) Q2_Muzzle;
void(vector org, vector vel, float color, float count) Q2_Sparks;
void(vector org, float style) Q2_Impact;
void(vector a, vector b) Q2_RailTrail;
void() Q2_BlasterTouch;
void() Q2_BoltThink;
float(entity targ) visible;
float(entity targ) range;
void(float n) SUB_AttackFinished;
float() crandom;
void() SUB_Null;
void() BQA_GibCorpse;
void(entity attacker, float damage) BQA_CorpsePain;
void() BQA_MaybeElite;
#endif

float() Q2M_ModelsOk =
{
	if (cvar("r_md5models") > 0)
		return FALSE;
	if (cvar("brutal_noq2monsters") > 0)
		return FALSE;
	if (cvar("brutal_q2monsters") < 0)
		return FALSE;
	return TRUE;
};

float() Q2M_PoolReplaceOk =
{
	if (deathmatch)
		return FALSE;
	return Q2M_ModelsOk ();
};

void() Q2M_Precache =
{
	if (!Q2M_ModelsOk ())
		return;
	precache_model ("progs/q2gib_arm.mdl");
	precache_model ("progs/q2gib_head.mdl");
	precache_model ("progs/q2gib_sm_meat.mdl");
};

void(float kind) Q2M_PrecacheKind =
{
	if (kind == Q2M_SOLDIER)
	{
		precache_model ("progs/q2_soldier.mdl");
		precache_sound ("soldier/solsght1.wav");
		precache_sound ("soldier/solpain1.wav");
		precache_sound ("soldier/solatck2.wav");
		precache_sound ("soldier/soldeth1.wav");
	}
	else if (kind == Q2M_INFANTRY)
	{
		precache_model ("progs/q2_infantry.mdl");
		precache_sound ("infantry/infsght1.wav");
		precache_sound ("infantry/infpain1.wav");
		precache_sound ("infantry/infatck1.wav");
		precache_sound ("infantry/infdeth1.wav");
	}
	else if (kind == Q2M_GUNNER)
	{
		precache_model ("progs/q2_gunner.mdl");
		precache_sound ("gunner/sight1.wav");
		precache_sound ("gunner/gunpain1.wav");
		precache_sound ("gunner/gunatck1.wav");
		precache_sound ("gunner/gunatck2.wav");
		precache_sound ("gunner/death1.wav");
	}
	else if (kind == Q2M_BERSERK)
	{
		precache_model ("progs/q2_berserk.mdl");
		precache_sound ("berserk/bersrch1.wav");
		precache_sound ("berserk/berpain2.wav");
		precache_sound ("berserk/attack.wav");
		precache_sound ("berserk/death.wav");
	}
	else if (kind == Q2M_GLADIATOR)
	{
		precache_model ("progs/q2_gladiatr.mdl");
		precache_sound ("gladiator/sight.wav");
		precache_sound ("gladiator/gldpain2.wav");
		precache_sound ("gladiator/railgun.wav");
		precache_sound ("gladiator/melee1.wav");
		precache_sound ("gladiator/death.wav");
	}
	else if (kind == Q2M_TANK)
	{
		precache_model ("progs/q2_tank.mdl");
		precache_sound ("tank/sight1.wav");
		precache_sound ("tank/pain.wav");
		precache_sound ("tank/tnkatck3.wav");
		precache_sound ("tank/death.wav");
	}
	else if (kind == Q2M_FLYER)
	{
		precache_model ("progs/q2_flyer.mdl");
		precache_sound ("flyer/flysght1.wav");
		precache_sound ("flyer/flypain1.wav");
		precache_sound ("flyer/flyatck2.wav");
		precache_sound ("flyer/flydeth1.wav");
	}
	else if (kind == Q2M_FLOAT)
	{
		precache_model ("progs/q2_float.mdl");
		precache_sound ("floater/fltsght1.wav");
		precache_sound ("floater/fltpain1.wav");
		precache_sound ("floater/fltatck2.wav");
		precache_sound ("floater/fltdeth1.wav");
	}
	else if (kind == Q2M_HOVER)
	{
		precache_model ("progs/q2_hover.mdl");
		precache_sound ("hover/hovsght1.wav");
		precache_sound ("hover/hovpain1.wav");
		precache_sound ("hover/hovatck1.wav");
		precache_sound ("hover/hovdeth1.wav");
	}
	else if (kind == Q2M_CHICK)
	{
		precache_model ("progs/q2_chick.mdl");
		precache_sound ("chick/chksght1.wav");
		precache_sound ("chick/chkpain1.wav");
		precache_sound ("chick/chkatck2.wav");
		precache_sound ("chick/chkdeth1.wav");
	}
	else if (kind == Q2M_MUTANT)
	{
		precache_model ("progs/q2_mutant.mdl");
		precache_sound ("mutant/mutsght1.wav");
		precache_sound ("mutant/mutpain1.wav");
		precache_sound ("mutant/mutatck1.wav");
		precache_sound ("mutant/mutdeth1.wav");
	}
	else if (kind == Q2M_BRAIN)
	{
		precache_model ("progs/q2_brain.mdl");
		precache_sound ("brain/brnsght1.wav");
		precache_sound ("brain/brnpain1.wav");
		precache_sound ("brain/melee1.wav");
		precache_sound ("brain/brndeth1.wav");
	}
	else if (kind == Q2M_MEDIC)
	{
		precache_model ("progs/q2_medic.mdl");
		precache_sound ("medic/medsght1.wav");
		precache_sound ("medic/medpain1.wav");
		precache_sound ("medic/medatck1.wav");
		precache_sound ("medic/meddeth1.wav");
	}
	else if (kind == Q2M_GRUNTSTR)
	{
		precache_model ("progs/q2_gruntstr.mdl");
		precache_sound ("soldier/sight1.wav");
		precache_sound ("soldier/pain2.wav");
		precache_sound ("soldier/sattck1.wav");
		precache_sound ("soldier/death1.wav");
	}
	else if (kind == Q2M_ENFSTROGG)
	{
		precache_model ("progs/q2_enfstrogg.mdl");
		precache_sound ("enforcer/sight1.wav");
		precache_sound ("enforcer/pain1.wav");
		precache_sound ("enforcer/enfire.wav");
		precache_sound ("enforcer/death1.wav");
		precache_model ("progs/laser.mdl");
	}
	else if (kind == Q2M_KNTSTROGG)
	{
		precache_model ("progs/q2_kntstrogg.mdl");
		precache_sound ("knight/ksight.wav");
		precache_sound ("knight/khurt.wav");
		precache_sound ("knight/sword2.wav");
		precache_sound ("knight/kdeath.wav");
	}
	else if (kind == Q2M_HYPERKNT)
	{
		precache_model ("progs/q2_hyperknt.mdl");
		precache_sound ("hknight/sight1.wav");
		precache_sound ("hknight/pain1.wav");
		precache_sound ("hknight/attack1.wav");
		precache_sound ("hknight/hit.wav");
		precache_sound ("hknight/death1.wav");
		precache_sound ("weapons/spike2.wav");
	}
	else if (kind == Q2M_HBERSTROGG)
	{
		precache_model ("progs/q2_hberstrogg.mdl");
		precache_sound ("hknight/sight1.wav");
		precache_sound ("hknight/pain1.wav");
		precache_sound ("hknight/hit.wav");
		precache_sound ("hknight/death1.wav");
	}
	else if (kind == Q2M_OGRE2STR)
	{
		precache_model ("progs/q2_ogre2str.mdl");
		precache_sound ("ogre/ogwake.wav");
		precache_sound ("ogre/ogpain1.wav");
		precache_sound ("weapons/guncock.wav");
		precache_sound ("ogre/ogdth.wav");
	}
	else if (kind == Q2M_OGRESTR)
	{
		precache_model ("progs/q2_ogrestr.mdl");
		precache_sound ("ogre/ogwake.wav");
		precache_sound ("ogre/ogpain1.wav");
		precache_sound ("weapons/grenade.wav");
		precache_sound ("ogre/ogdth.wav");
	}
	else if (kind == Q2M_FIENDSTR)
	{
		precache_model ("progs/q2_fiendstr.mdl");
		precache_sound ("demon/sight2.wav");
		precache_sound ("demon/dpain1.wav");
		precache_sound ("demon/djump.wav");
		precache_sound ("demon/dhit.wav");
		precache_sound ("demon/ddeath.wav");
	}
	else if (kind == Q2M_SHAMSTR)
	{
		precache_model ("progs/q2_shamstr.mdl");
		precache_sound ("shambler/ssight.wav");
		precache_sound ("shambler/shurt2.wav");
		precache_sound ("shambler/sattck1.wav");
		precache_sound ("shambler/melee1.wav");
		precache_sound ("shambler/sboom.wav");
	}
	else if (kind == Q2M_SHAMACUD)
	{
		precache_model ("progs/q2_shamacud.mdl");
		precache_sound ("shambler/ssight.wav");
		precache_sound ("shambler/shurt2.wav");
		precache_sound ("shambler/sattck1.wav");
		precache_sound ("shambler/melee1.wav");
		precache_sound ("shambler/sboom.wav");
	}
	else if (kind == Q2M_WIZSTROGG)
	{
		precache_model ("progs/q2_wizstrogg.mdl");
		precache_sound ("wizard/wsight.wav");
		precache_sound ("wizard/wpain.wav");
		precache_sound ("wizard/wattack.wav");
		precache_sound ("wizard/wdeath.wav");
	}
	else if (kind == Q2M_WIZCUDA)
	{
		precache_model ("progs/q2_wizcuda.mdl");
		precache_sound ("wizard/wsight.wav");
		precache_sound ("wizard/wpain.wav");
		precache_sound ("wizard/wattack.wav");
		precache_sound ("wizard/wdeath.wav");
	}
	else if (kind == Q2M_ZOMBSTR)
	{
		precache_model ("progs/q2_zombstr.mdl");
		precache_sound ("zombie/z_idle.wav");
		precache_sound ("zombie/z_pain.wav");
		precache_sound ("weapons/grenade.wav");
		precache_sound ("zombie/z_gib.wav");
	}
	else if (kind == Q2M_DOGSTROGG)
	{
		precache_model ("progs/q2_dogstrogg.mdl");
		precache_sound ("dog/dsight.wav");
		precache_sound ("dog/dpain1.wav");
		precache_sound ("dog/dattack1.wav");
		precache_sound ("dog/ddeath.wav");
	}
	else if (kind == Q2M_VORESTR)
	{
		precache_model ("progs/q2_vorestr.mdl");
		precache_model ("progs/q2_vorepod.mdl");
		precache_sound ("shalrath/sight.wav");
		precache_sound ("shalrath/pain.wav");
		precache_sound ("shalrath/attack2.wav");
		precache_sound ("shalrath/death.wav");
	}
	else if (kind == Q2M_FISHGUN)
	{
		precache_model ("progs/q2_fishgun.mdl");
		precache_sound ("gunner/sight1.wav");
		precache_sound ("gunner/gunpain1.wav");
		precache_sound ("gunner/gunatck1.wav");
		precache_sound ("gunner/gunatck2.wav");
		precache_sound ("gunner/death1.wav");
	}
	else if (kind == Q2M_ROTFLYER)
	{
		precache_model ("progs/q2_rotflyer.mdl");
		precache_sound ("flyer/flysght1.wav");
		precache_sound ("flyer/flypain1.wav");
		precache_sound ("flyer/flyatck2.wav");
		precache_sound ("flyer/flydeth1.wav");
	}
	else if (kind == Q2M_IRONVORE)
	{
		precache_model ("progs/q2_ironvore.mdl");
		precache_model ("progs/q2_vorepod.mdl");
		precache_sound ("shalrath/sight.wav");
		precache_sound ("shalrath/pain.wav");
		precache_sound ("shalrath/attack2.wav");
		precache_sound ("shalrath/death.wav");
	}
	else if (kind == Q2M_MUTSPAWN)
	{
		precache_model ("progs/q2_mutspawn.mdl");
		precache_sound ("demon/sight2.wav");
		precache_sound ("demon/dpain1.wav");
		precache_sound ("demon/djump.wav");
		precache_sound ("demon/dhit.wav");
		precache_sound ("demon/ddeath.wav");
	}
	else
	{
		precache_model ("progs/q2_insane.mdl");
		precache_sound ("insanespawn/insane1.wav");
		precache_sound ("insanespawn/hit1.wav");
		precache_sound ("demon/dpain1.wav");
		precache_sound ("demon/dhit.wav");
		precache_sound ("demon/ddeath.wav");
	}
};

void() Q2M_ExtraGibs =
{
	local float r;

	if (!Q2M_ModelsOk ())
		return;
	r = random ();
	if (r < 0.34)
		ThrowGib ("progs/q2gib_arm.mdl", -50);
	else if (r < 0.67)
		ThrowGib ("progs/q2gib_head.mdl", -40);
	else
		ThrowGib ("progs/q2gib_sm_meat.mdl", -30);
};

#ifdef BQA_HAS_MONSTERS

void() Q2M_SetRange =
{
	local float k, a;

	k = self.q2_kind;
	a = self.q2_anim;
	self.q2_ffire = -1;
	self.q2_ffire2 = -1;
	if (k == Q2M_SOLDIER)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 45; self.q2_fend = 113; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 114; self.q2_fend = 170; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 33; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 0; self.q2_fend = 17; self.q2_ffire = 6; self.q2_ffire2 = 6; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 18; self.q2_fend = 32; }
		else { self.q2_fstart = 171; self.q2_fend = 206; }
	}
	else if (k == Q2M_INFANTRY)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 70; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 71; self.q2_fend = 90; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 91; self.q2_fend = 98; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 130; self.q2_fend = 152; self.q2_ffire = 138; self.q2_ffire2 = 145; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 99; self.q2_fend = 109; }
		else { self.q2_fstart = 110; self.q2_fend = 129; }
	}
	else if (k == Q2M_GUNNER)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 69; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 70; self.q2_fend = 93; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 94; self.q2_fend = 101; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 102; self.q2_fend = 134; self.q2_ffire = 114; self.q2_ffire2 = 121; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 135; self.q2_fend = 146; }
		else { self.q2_fstart = 147; self.q2_fend = 157; }
	}
	else if (k == Q2M_BERSERK)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 19; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 20; self.q2_fend = 30; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 31; self.q2_fend = 36; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 37; self.q2_fend = 49; self.q2_ffire = 43; self.q2_ffire2 = 43; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 50; self.q2_fend = 61; }
		else { self.q2_fstart = 62; self.q2_fend = 74; }
	}
	else if (k == Q2M_GLADIATOR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 6; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 7; self.q2_fend = 22; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 23; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 46; self.q2_fend = 54; self.q2_ffire = 50; self.q2_ffire2 = 50; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 29; self.q2_fend = 45; self.q2_ffire = 36; self.q2_ffire2 = 36; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 55; self.q2_fend = 60; }
		else { self.q2_fstart = 61; self.q2_fend = 82; }
	}
	else if (k == Q2M_TANK)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 29; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 30; self.q2_fend = 54; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 30; self.q2_fend = 54; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 55; self.q2_fend = 80; self.q2_ffire = 68; self.q2_ffire2 = 68; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 81; self.q2_fend = 94; }
		else { self.q2_fstart = 95; self.q2_fend = 126; }
	}
	else if (k == Q2M_FLYER)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 45; self.q2_fend = 67; self.q2_ffire = 55; self.q2_ffire2 = 55; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 68; self.q2_fend = 76; }
		else { self.q2_fstart = 68; self.q2_fend = 84; }
	}
	else if (k == Q2M_FLOAT)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 52; self.q2_fend = 155; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 52; self.q2_fend = 155; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 52; self.q2_fend = 155; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 0; self.q2_fend = 24; self.q2_ffire = 11; self.q2_ffire2 = 11; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 38; self.q2_fend = 51; }
		else { self.q2_fstart = 25; self.q2_fend = 37; }
	}
	else if (k == Q2M_HOVER)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 29; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 30; self.q2_fend = 64; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 30; self.q2_fend = 64; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 89; self.q2_fend = 96; self.q2_ffire = 92; self.q2_ffire2 = 92; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 65; self.q2_fend = 77; }
		else { self.q2_fstart = 78; self.q2_fend = 88; }
	}
	else if (k == Q2M_CHICK)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 53; self.q2_fend = 112; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 113; self.q2_fend = 139; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 113; self.q2_fend = 139; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 0; self.q2_fend = 24; self.q2_ffire = 14; self.q2_ffire2 = 14; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 37; self.q2_fend = 52; }
		else { self.q2_fstart = 25; self.q2_fend = 36; }
	}
	else if (k == Q2M_MUTANT)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 52; self.q2_fend = 115; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 116; self.q2_fend = 138; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 46; self.q2_fend = 51; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 0; self.q2_fend = 14; self.q2_ffire = 7; self.q2_ffire2 = 7; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 34; self.q2_fend = 45; }
		else { self.q2_fstart = 15; self.q2_fend = 33; }
	}
	else if (k == Q2M_BRAIN)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 107; self.q2_fend = 166; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 0; self.q2_fend = 52; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 0; self.q2_fend = 52; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 53; self.q2_fend = 75; self.q2_ffire = 64; self.q2_ffire2 = 64; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 76; self.q2_fend = 88; }
		else { self.q2_fstart = 89; self.q2_fend = 106; }
	}
	else if (k == Q2M_MEDIC)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 12; self.q2_fend = 101; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 0; self.q2_fend = 11; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 102; self.q2_fend = 107; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 146; self.q2_fend = 169; self.q2_ffire = 157; self.q2_ffire2 = 157; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 108; self.q2_fend = 115; }
		else { self.q2_fstart = 116; self.q2_fend = 145; }
	}
	else if (k == Q2M_GRUNTSTR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 7; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 41; self.q2_fend = 64; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 24; self.q2_fend = 31; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 32; self.q2_fend = 40; self.q2_ffire = 36; self.q2_ffire2 = 36; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 18; self.q2_fend = 23; }
		else { self.q2_fstart = 8; self.q2_fend = 17; }
	}
	else if (k == Q2M_ENFSTROGG)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 6; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 7; self.q2_fend = 22; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 23; self.q2_fend = 30; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 31; self.q2_fend = 40; self.q2_ffire = 36; self.q2_ffire2 = 36; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 55; self.q2_fend = 58; }
		else { self.q2_fstart = 41; self.q2_fend = 54; }
	}
	else if (k == Q2M_KNTSTROGG)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 8; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 31; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 9; self.q2_fend = 16; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 20; self.q2_fend = 30; self.q2_ffire = 25; self.q2_ffire2 = 25; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 17; self.q2_fend = 19; }
		else { self.q2_fstart = 45; self.q2_fend = 54; }
	}
	else if (k == Q2M_HYPERKNT)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 8; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 9; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 29; self.q2_fend = 36; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 64; self.q2_fend = 85; self.q2_ffire = 74; self.q2_ffire2 = 74; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 54; self.q2_fend = 63; self.q2_ffire = 59; self.q2_ffire2 = 59; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 37; self.q2_fend = 41; }
		else { self.q2_fstart = 42; self.q2_fend = 53; }
	}
	else if (k == Q2M_HBERSTROGG)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 8; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 9; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 29; self.q2_fend = 36; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 54; self.q2_fend = 64; self.q2_ffire = 59; self.q2_ffire2 = 59; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 37; self.q2_fend = 41; }
		else { self.q2_fstart = 42; self.q2_fend = 53; }
	}
	else if (k == Q2M_OGRE2STR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 8; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 9; self.q2_fend = 24; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 25; self.q2_fend = 32; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 47; self.q2_fend = 52; self.q2_ffire = 50; self.q2_ffire2 = 50; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 33; self.q2_fend = 46; self.q2_ffire = 40; self.q2_ffire2 = 40; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 53; self.q2_fend = 57; }
		else { self.q2_fstart = 58; self.q2_fend = 71; }
	}
	else if (k == Q2M_OGRESTR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 8; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 9; self.q2_fend = 24; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 25; self.q2_fend = 32; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 47; self.q2_fend = 52; self.q2_ffire = 50; self.q2_ffire2 = 50; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 33; self.q2_fend = 46; self.q2_ffire = 40; self.q2_ffire2 = 40; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 53; self.q2_fend = 57; }
		else { self.q2_fstart = 58; self.q2_fend = 66; }
	}
	else if (k == Q2M_FIENDSTR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 12; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 13; self.q2_fend = 20; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 21; self.q2_fend = 26; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 27; self.q2_fend = 38; self.q2_ffire = 31; self.q2_ffire2 = 31; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 54; self.q2_fend = 68; self.q2_ffire = 61; self.q2_ffire2 = 61; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 39; self.q2_fend = 44; }
		else { self.q2_fstart = 45; self.q2_fend = 53; }
	}
	else if (k == Q2M_SHAMSTR || k == Q2M_SHAMACUD)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 16; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 17; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 29; self.q2_fend = 34; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 47; self.q2_fend = 58; self.q2_ffire = 53; self.q2_ffire2 = 53; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 35; self.q2_fend = 46; self.q2_ffire = 41; self.q2_ffire2 = 41; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 59; self.q2_fend = 64; }
		else { self.q2_fstart = 65; self.q2_fend = 75; }
	}
	else if (k == Q2M_WIZSTROGG || k == Q2M_WIZCUDA)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 14; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 15; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 15; self.q2_fend = 28; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 29; self.q2_fend = 41; self.q2_ffire = 35; self.q2_ffire2 = 35; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 42; self.q2_fend = 45; }
		else { self.q2_fstart = 46; self.q2_fend = 53; }
	}
	else if (k == Q2M_ZOMBSTR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 14; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 15; self.q2_fend = 33; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 34; self.q2_fend = 51; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 52; self.q2_fend = 64; self.q2_ffire = 58; self.q2_ffire2 = 58; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 65; self.q2_fend = 76; }
		else { self.q2_fstart = 77; self.q2_fend = 104; }
	}
	else if (k == Q2M_DOGSTROGG)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 44; self.q2_fend = 52; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 53; self.q2_fend = 60; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 23; self.q2_fend = 34; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 35; self.q2_fend = 43; self.q2_ffire = 39; self.q2_ffire2 = 39; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 0; self.q2_fend = 7; self.q2_ffire = 4; self.q2_ffire2 = 4; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 17; self.q2_fend = 22; }
		else { self.q2_fstart = 8; self.q2_fend = 16; }
	}
	else if (k == Q2M_VORESTR)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 23; self.q2_fend = 34; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 23; self.q2_fend = 34; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 23; self.q2_fend = 34; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 0; self.q2_fend = 10; self.q2_ffire = 6; self.q2_ffire2 = 6; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 11; self.q2_fend = 15; }
		else { self.q2_fstart = 16; self.q2_fend = 22; }
	}
	else if (k == Q2M_FISHGUN)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 69; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 70; self.q2_fend = 93; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 94; self.q2_fend = 101; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 102; self.q2_fend = 134; self.q2_ffire = 114; self.q2_ffire2 = 121; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 135; self.q2_fend = 146; }
		else { self.q2_fstart = 147; self.q2_fend = 157; }
	}
	else if (k == Q2M_ROTFLYER)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 0; self.q2_fend = 44; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 45; self.q2_fend = 67; self.q2_ffire = 55; self.q2_ffire2 = 55; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 45; self.q2_fend = 67; self.q2_ffire = 55; self.q2_ffire2 = 55; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 68; self.q2_fend = 76; }
		else { self.q2_fstart = 68; self.q2_fend = 84; }
	}
	else if (k == Q2M_IRONVORE)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 29; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 30; self.q2_fend = 59; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 30; self.q2_fend = 59; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 60; self.q2_fend = 89; self.q2_ffire = 75; self.q2_ffire2 = 75; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 90; self.q2_fend = 119; self.q2_ffire = 105; self.q2_ffire2 = 105; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 120; self.q2_fend = 139; }
		else { self.q2_fstart = 140; self.q2_fend = 177; }
	}
	else if (k == Q2M_MUTSPAWN)
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 52; self.q2_fend = 115; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 116; self.q2_fend = 138; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 46; self.q2_fend = 51; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 0; self.q2_fend = 14; self.q2_ffire = 7; self.q2_ffire2 = 7; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 0; self.q2_fend = 14; self.q2_ffire = 7; self.q2_ffire2 = 7; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 34; self.q2_fend = 45; }
		else { self.q2_fstart = 15; self.q2_fend = 33; }
	}
	else
	{
		if (a == Q2M_ANIM_STAND) { self.q2_fstart = 0; self.q2_fend = 29; }
		else if (a == Q2M_ANIM_WALK) { self.q2_fstart = 30; self.q2_fend = 59; }
		else if (a == Q2M_ANIM_RUN) { self.q2_fstart = 60; self.q2_fend = 79; }
		else if (a == Q2M_ANIM_ATK) { self.q2_fstart = 80; self.q2_fend = 99; self.q2_ffire = 90; self.q2_ffire2 = 90; }
		else if (a == Q2M_ANIM_MELEE) { self.q2_fstart = 80; self.q2_fend = 99; self.q2_ffire = 90; self.q2_ffire2 = 90; }
		else if (a == Q2M_ANIM_PAIN) { self.q2_fstart = 100; self.q2_fend = 119; }
		else { self.q2_fstart = 120; self.q2_fend = 151; }
	}
};

void() Q2M_PlayIdle =
{
};

void() Q2M_NadeBoom =
{
	Q2_Impact (self.origin, 3);
	GrenadeExplode ();
};

void() Q2M_RocketTouch =
{
	Q2_Impact (self.origin, 3);
	T_MissileTouch ();
};

void() Q2M_VoreHome =
{
	local vector dir;

	if (self.enemy == world || self.enemy.health < 1)
	{
		remove (self);
		return;
	}
	dir = normalize ((self.enemy.origin + '0 0 10') - self.origin);
	self.velocity = dir * 250;
	self.nextthink = time + 0.2;
	self.think = Q2M_VoreHome;
};

void() Q2M_VoreTouch =
{
	if (other == self.owner)
		return;
	T_RadiusDamage (self, self.owner, 40, world);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	remove (self);
};

void() Q2M_FireShot =
{
	local vector dir, org;
	local float n, dist;
	local entity skip;

	if (self.health <= 0)
		return;
	if (self.q2_anim == Q2M_ANIM_DIE)
		return;
	ai_face ();
	makevectors (self.angles);
	org = self.origin + self.view_ofs;
	if (self.enemy != world)
		dir = normalize ((self.enemy.origin + '0 0 16') - org);
	else
		dir = v_forward;
	if ((self.q2_kind == Q2M_GUNNER || self.q2_kind == Q2M_FISHGUN || self.q2_kind == Q2M_OGRESTR || self.q2_kind == Q2M_ZOMBSTR) && self.q2_alt)
	{
		if (self.frame == self.q2_ffire)
		{
			Q2_Muzzle (self, 0);
			if (self.q2_kind == Q2M_GUNNER || self.q2_kind == Q2M_FISHGUN)
				sound (self, CHAN_WEAPON, "gunner/gunatck1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
			n = 2 + floor (random () * 3);
			while (n > 0)
			{
				newmis = spawn ();
				newmis.owner = self;
				newmis.movetype = MOVETYPE_BOUNCE;
				newmis.solid = SOLID_BBOX;
				newmis.classname = "grenade";
				newmis.touch = GrenadeTouch;
				newmis.think = Q2M_NadeBoom;
				newmis.nextthink = time + 2.5;
				newmis.effects = EF_DIMLIGHT;
				setmodel (newmis, "progs/grenade.mdl");
				setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
				setorigin (newmis, org);
				newmis.velocity = dir * (500 + random () * 150) + v_right * (crandom () * 80) + '0 0 180';
				newmis.avelocity = '300 300 300';
				n = n - 1;
			}
		}
		return;
	}
	Q2_Muzzle (self, 0);
	if (self.q2_kind == Q2M_SOLDIER)
	{
		sound (self, CHAN_WEAPON, "soldier/solatck2.wav", 1, ATTN_NORM);
		n = 0;
		while (n < 4)
		{
			traceline (org, org + (dir + v_right * crandom () * 0.1 + v_up * crandom () * 0.1) * 2048, FALSE, self);
			if (trace_ent.takedamage)
				T_Damage (trace_ent, self, self, 4);
			if (trace_fraction < 1)
				Q2_Impact (trace_endpos, 0);
			n = n + 1;
		}
	}
	else if (self.q2_kind == Q2M_INFANTRY)
	{
		sound (self, CHAN_WEAPON, "infantry/infatck1.wav", 1, ATTN_NORM);
		traceline (org, org + dir * 2048, FALSE, self);
		if (trace_ent.takedamage)
			T_Damage (trace_ent, self, self, 3);
		if (trace_fraction < 1)
			Q2_Impact (trace_endpos, 0);
	}
	else if (self.q2_kind == Q2M_GUNNER || self.q2_kind == Q2M_FISHGUN)
	{
		sound (self, CHAN_WEAPON, "gunner/gunatck2.wav", 1, ATTN_NORM);
		traceline (org, org + (dir + v_right * crandom () * 0.08) * 2048, FALSE, self);
		if (trace_ent.takedamage)
			T_Damage (trace_ent, self, self, 4);
		if (trace_fraction < 1)
			Q2_Impact (trace_endpos, 0);
	}
	else if (self.q2_kind == Q2M_OGRE2STR)
	{
		sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
		n = 0;
		while (n < 6)
		{
			traceline (org, org + (dir + v_right * crandom () * 0.12 + v_up * crandom () * 0.12) * 2048, FALSE, self);
			if (trace_ent.takedamage)
				T_Damage (trace_ent, self, self, 4);
			if (trace_fraction < 1)
				Q2_Impact (trace_endpos, 0);
			n = n + 1;
		}
	}
	else if (self.q2_kind == Q2M_GRUNTSTR || self.q2_kind == Q2M_HYPERKNT)
	{
		sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.touch = spike_touch;
		newmis.classname = "spike";
		setmodel (newmis, "progs/spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (newmis, org);
		newmis.velocity = dir * 1000;
		newmis.angles = vectoangles (newmis.velocity);
	}
	else if (self.q2_kind == Q2M_ENFSTROGG)
	{
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "q2_blaster";
		newmis.touch = Q2_BlasterTouch;
		newmis.effects = EF_DIMLIGHT;
		newmis.ltime = time + 6;
		newmis.think = Q2_BoltThink;
		newmis.nextthink = time + 0.05;
		setmodel (newmis, "progs/laser.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (newmis, org);
		newmis.velocity = dir * 1000;
		newmis.angles = vectoangles (newmis.velocity);
	}
	else if (self.q2_kind == Q2M_SHAMSTR || self.q2_kind == Q2M_SHAMACUD)
	{
		sound (self, CHAN_WEAPON, "shambler/sattck1.wav", 1, ATTN_NORM);
		traceline (org, org + dir * 600, FALSE, self);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);
		if (trace_ent.takedamage)
			T_Damage (trace_ent, self, self, 10);
		if (trace_fraction < 1)
			Q2_Impact (trace_endpos, 2);
	}
	else if (self.q2_kind == Q2M_VORESTR || self.q2_kind == Q2M_IRONVORE)
	{
		if (self.enemy == world)
			return;
		sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "vore_ball";
		newmis.touch = Q2M_VoreTouch;
		newmis.enemy = self.enemy;
		newmis.think = Q2M_VoreHome;
		dist = vlen (self.enemy.origin - self.origin) * 0.002;
		if (dist < 0.1)
			dist = 0.1;
		newmis.nextthink = time + dist;
		setmodel (newmis, "progs/q2_vorepod.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (newmis, org);
		newmis.velocity = dir * 400;
		newmis.avelocity = '300 300 300';
	}
	else if (self.q2_kind == Q2M_GLADIATOR)
	{
		sound (self, CHAN_WEAPON, "gladiator/railgun.wav", 1, ATTN_NORM);
		Q2_Muzzle (self, 1);
		skip = self;
		n = 0;
		while (n < 4)
		{
			traceline (org, org + dir * 8192, FALSE, skip);
			if (trace_ent.takedamage)
			{
				T_Damage (trace_ent, self, self, 50);
				org = trace_endpos + dir * 8;
				skip = trace_ent;
				n = n + 1;
			}
			else
				n = 4;
		}
		Q2_RailTrail (self.origin + self.view_ofs, trace_endpos);
		if (trace_fraction < 1)
			Q2_Impact (trace_endpos, 2);
	}
	else if (self.q2_kind == Q2M_TANK || self.q2_kind == Q2M_CHICK)
	{
		dist = 1000;
		if (self.enemy != world)
			dist = vlen (self.enemy.origin - self.origin);
		if (self.q2_kind == Q2M_TANK && (dist <= 125 || (dist <= 250 && random () < 0.5)))
		{
			sound (self, CHAN_WEAPON, "tank/tnkatck3.wav", 1, ATTN_NORM);
			newmis = spawn ();
			newmis.owner = self;
			newmis.movetype = MOVETYPE_FLYMISSILE;
			newmis.solid = SOLID_BBOX;
			newmis.classname = "q2_blaster";
			newmis.touch = Q2_BlasterTouch;
			newmis.effects = EF_DIMLIGHT;
			newmis.ltime = time + 6;
			newmis.think = Q2_BoltThink;
			newmis.nextthink = time + 0.05;
			setmodel (newmis, "progs/s_spike.mdl");
			setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
			setorigin (newmis, org);
			newmis.velocity = dir * 1000;
		}
		else
		{
			if (self.q2_kind == Q2M_TANK)
				sound (self, CHAN_WEAPON, "tank/tnkatck3.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_WEAPON, "chick/chkatck2.wav", 1, ATTN_NORM);
			newmis = spawn ();
			newmis.owner = self;
			newmis.movetype = MOVETYPE_FLYMISSILE;
			newmis.solid = SOLID_BBOX;
			newmis.classname = "missile";
			newmis.touch = Q2M_RocketTouch;
			newmis.think = SUB_Remove;
			newmis.nextthink = time + 6;
			newmis.effects = EF_DIMLIGHT;
			setmodel (newmis, "progs/missile.mdl");
			setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
			setorigin (newmis, org);
			newmis.velocity = dir * 600;
			newmis.angles = vectoangles (newmis.velocity);
		}
	}
	else if (self.q2_kind == Q2M_MEDIC)
	{
		sound (self, CHAN_WEAPON, "medic/medatck1.wav", 1, ATTN_NORM);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "q2_blaster";
		newmis.touch = Q2_BlasterTouch;
		newmis.effects = EF_DIMLIGHT;
		newmis.ltime = time + 6;
		newmis.think = Q2_BoltThink;
		newmis.nextthink = time + 0.05;
		setmodel (newmis, "progs/spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (newmis, org);
		newmis.velocity = dir * 1000;
	}
	else
	{
		if (self.q2_kind == Q2M_FLYER || self.q2_kind == Q2M_ROTFLYER)
			sound (self, CHAN_WEAPON, "flyer/flyatck2.wav", 1, ATTN_NORM);
		else if (self.q2_kind == Q2M_FLOAT)
			sound (self, CHAN_WEAPON, "floater/fltatck2.wav", 1, ATTN_NORM);
		else if (self.q2_kind == Q2M_WIZSTROGG || self.q2_kind == Q2M_WIZCUDA)
			sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "hover/hovatck1.wav", 1, ATTN_NORM);
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "q2_blaster";
		newmis.touch = Q2_BlasterTouch;
		newmis.effects = EF_DIMLIGHT;
		newmis.ltime = time + 6;
		newmis.think = Q2_BoltThink;
		newmis.nextthink = time + 0.05;
		setmodel (newmis, "progs/s_spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		setorigin (newmis, org);
		newmis.velocity = dir * 900;
	}
};

void() Q2M_FireMelee =
{
	local float dmg;

	if (self.health <= 0)
		return;
	if (self.q2_anim == Q2M_ANIM_DIE)
		return;
	ai_charge (10);
	if (self.enemy == world)
		return;
	if (vlen (self.enemy.origin - self.origin) > 80)
		return;
	if (self.q2_kind == Q2M_BERSERK || self.q2_kind == Q2M_HBERSTROGG)
	{
		sound (self, CHAN_WEAPON, "berserk/attack.wav", 1, ATTN_NORM);
		dmg = 25;
	}
	else if (self.q2_kind == Q2M_MUTANT || self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_MUTSPAWN)
	{
		sound (self, CHAN_WEAPON, "demon/dhit.wav", 1, ATTN_NORM);
		dmg = 35;
	}
	else if (self.q2_kind == Q2M_BRAIN || self.q2_kind == Q2M_SHAMSTR || self.q2_kind == Q2M_SHAMACUD)
	{
		sound (self, CHAN_WEAPON, "shambler/melee1.wav", 1, ATTN_NORM);
		dmg = 40;
	}
	else if (self.q2_kind == Q2M_DOGSTROGG)
	{
		sound (self, CHAN_WEAPON, "dog/dattack1.wav", 1, ATTN_NORM);
		dmg = 10;
	}
	else if (self.q2_kind == Q2M_KNTSTROGG)
	{
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
		dmg = 20;
	}
	else if (self.q2_kind == Q2M_HYPERKNT)
	{
		sound (self, CHAN_WEAPON, "hknight/hit.wav", 1, ATTN_NORM);
		dmg = 25;
	}
	else if (self.q2_kind == Q2M_ROTFLYER)
	{
		sound (self, CHAN_WEAPON, "flyer/flyatck2.wav", 1, ATTN_NORM);
		dmg = 15;
	}
	else if (self.q2_kind == Q2M_INSANE)
	{
		sound (self, CHAN_WEAPON, "insanespawn/hit1.wav", 1, ATTN_NORM);
		dmg = 35;
	}
	else
	{
		sound (self, CHAN_WEAPON, "gladiator/melee1.wav", 1, ATTN_NORM);
		dmg = 30;
	}
	T_Damage (self.enemy, self, self, dmg);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_GUNSHOT);
	WriteCoord (MSG_BROADCAST, self.enemy.origin_x);
	WriteCoord (MSG_BROADCAST, self.enemy.origin_y);
	WriteCoord (MSG_BROADCAST, self.enemy.origin_z);
};

void() Q2M_BeginAnim;

void() Q2M_Melee;
void() Q2M_Missile;
void() Q2M_Leap;
void() Q2M_BecomeCorpse;
void() Q2M_HoverBoom;

float() Q2M_CheckAttack =
{
	local float r, chance, sk;
	local vector spot1, spot2;

	if (self.health <= 0)
		return FALSE;
	if (self.q2_anim == Q2M_ANIM_DIE)
		return FALSE;
	if (self.enemy == world)
		return FALSE;
	if (time < self.attack_finished)
		return FALSE;
	if (!visible (self.enemy))
		return FALSE;
	r = range (self.enemy);
	if (r == RANGE_FAR)
		return FALSE;
	spot1 = self.origin + self.view_ofs;
	spot2 = self.enemy.origin + self.enemy.view_ofs;
	traceline (spot1, spot2, FALSE, self);
	if (trace_ent != self.enemy)
		return FALSE;
	if (r == RANGE_MELEE)
	{
		if (self.q2_kind == Q2M_BERSERK || self.q2_kind == Q2M_BRAIN || self.q2_kind == Q2M_GLADIATOR || self.q2_kind == Q2M_KNTSTROGG || self.q2_kind == Q2M_HBERSTROGG || self.q2_kind == Q2M_HYPERKNT || self.q2_kind == Q2M_SHAMSTR || self.q2_kind == Q2M_SHAMACUD || self.q2_kind == Q2M_OGRE2STR || self.q2_kind == Q2M_OGRESTR || self.q2_kind == Q2M_IRONVORE || self.q2_kind == Q2M_ROTFLYER)
		{
			Q2M_Melee ();
			SUB_AttackFinished (0.5);
			return TRUE;
		}
		if (self.q2_kind == Q2M_MUTANT || self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_MUTSPAWN || self.q2_kind == Q2M_INSANE || self.q2_kind == Q2M_DOGSTROGG)
		{
			Q2M_Leap ();
			SUB_AttackFinished (1);
			return TRUE;
		}
		self.q2_alt = 0;
		Q2M_Missile ();
		SUB_AttackFinished (0.5);
		return TRUE;
	}
	chance = 0.1;
	if (r == RANGE_NEAR)
		chance = 0.4;
	sk = cvar ("skill");
	if (sk == 0)
		chance = chance * 0.5;
	else if (sk >= 2)
		chance = chance * 2;
	if (random () >= chance)
		return FALSE;
	if (self.q2_kind == Q2M_MUTANT || self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_MUTSPAWN || self.q2_kind == Q2M_INSANE || self.q2_kind == Q2M_DOGSTROGG)
	{
		Q2M_Leap ();
		SUB_AttackFinished (1);
		return TRUE;
	}
	if (self.q2_kind == Q2M_BERSERK || self.q2_kind == Q2M_BRAIN || self.q2_kind == Q2M_KNTSTROGG || self.q2_kind == Q2M_HBERSTROGG)
		return FALSE;
	if ((self.q2_kind == Q2M_GLADIATOR || self.q2_kind == Q2M_HYPERKNT) && vlen (self.enemy.origin - self.origin) <= 112)
	{
		Q2M_Melee ();
		SUB_AttackFinished (0.5);
		return TRUE;
	}
	if (self.q2_kind == Q2M_GUNNER || self.q2_kind == Q2M_FISHGUN)
	{
		if (random () < 0.5)
			self.q2_alt = 1;
		else
			self.q2_alt = 0;
	}
	if (self.q2_kind == Q2M_OGRESTR || self.q2_kind == Q2M_ZOMBSTR)
		self.q2_alt = 1;
	Q2M_Missile ();
	SUB_AttackFinished (0.5 + random ());
	return TRUE;
};

void() Q2M_Think =
{
	if (self.health <= 0 && self.q2_anim != Q2M_ANIM_DIE)
	{
		self.q2_anim = Q2M_ANIM_DIE;
		Q2M_BecomeCorpse ();
		return;
	}
	if (self.q2_anim == Q2M_ANIM_DIE)
	{
		if (self.frame < self.q2_fend)
			self.frame = self.frame + 1;
		if (self.frame >= self.q2_fend)
		{
			self.frame = self.q2_fend;
			Q2M_BecomeCorpse ();
			if (self.q2_kind == Q2M_HOVER)
			{
				self.think = Q2M_HoverBoom;
				self.nextthink = time + 1;
			}
			return;
		}
		self.nextthink = time + 0.1;
		self.think = Q2M_Think;
		return;
	}
	if (self.frame < self.q2_fend)
		self.frame = self.frame + 1;
	else
	{
		if (self.q2_anim == Q2M_ANIM_ATK && (self.q2_kind == Q2M_GUNNER || self.q2_kind == Q2M_FISHGUN) && !self.q2_alt && visible (self.enemy) && random () < 0.5)
		{
			self.frame = self.q2_ffire;
		}
		else if (self.q2_anim == Q2M_ANIM_PAIN || self.q2_anim == Q2M_ANIM_ATK || self.q2_anim == Q2M_ANIM_MELEE)
		{
			self.q2_anim = Q2M_ANIM_RUN;
			Q2M_SetRange ();
			self.frame = self.q2_fstart;
		}
		else
			self.frame = self.q2_fstart;
	}
	self.nextthink = time + 0.1;
	self.think = Q2M_Think;
	if (self.q2_anim == Q2M_ANIM_STAND)
	{
		ai_stand ();
		if (random () < 0.01)
			Q2M_PlayIdle ();
	}
	else if (self.q2_anim == Q2M_ANIM_WALK)
		ai_walk (8);
	else if (self.q2_anim == Q2M_ANIM_RUN)
	{
		if (self.health <= 0)
			return;
		if (self.q2_runspeed)
			ai_run (self.q2_runspeed);
		else
			ai_run (12);
	}
	else if (self.q2_anim == Q2M_ANIM_ATK)
	{
		if (self.health <= 0)
			return;
		ai_face ();
		if (self.frame >= self.q2_ffire && self.frame <= self.q2_ffire2)
			Q2M_FireShot ();
	}
	else if (self.q2_anim == Q2M_ANIM_MELEE)
	{
		if (self.health <= 0)
			return;
		if (self.frame >= self.q2_ffire && self.frame <= self.q2_ffire2)
			Q2M_FireMelee ();
		else
			ai_charge (12);
	}
};

void() Q2M_BecomeCorpse =
{
	if (self.q2_kind == Q2M_TANK)
		setsize (self, '-16 -16 -16', '16 16 0');
	else if (self.q2_kind == Q2M_CHICK)
		setsize (self, '-16 -16 0', '16 16 0');
	else
		setsize (self, '-16 -16 -24', '16 16 -8');
	self.movetype = MOVETYPE_TOSS;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.flags = self.flags | FL_ONGROUND;
	self.takedamage = DAMAGE_YES;
	self.health = 60;
	self.th_die = BQA_GibCorpse;
	self.th_pain = BQA_CorpsePain;
	self.th_melee = SUB_Null;
	self.th_missile = SUB_Null;
	self.th_run = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_stand = SUB_Null;
	self.touch = SUB_Null;
	self.think = SUB_Null;
	self.nextthink = -1;
	self.enemy = world;
	self.solid = SOLID_CORPSE;
	self.allowPathFind = FALSE;
	self.flags = self.flags - (self.flags & FL_MONSTER);
};

void() Q2M_HoverBoom =
{
	sound (self, CHAN_VOICE, "hover/hovdeth1.wav", 1, ATTN_NORM);
	BecomeExplosion ();
};

void() Q2M_LeapTouch =
{
	if (other == self)
		return;
	if (self.health <= 0)
		return;
	if (other.takedamage)
	{
		T_Damage (other, self, self, 40);
		Q2_Impact (other.origin, 0);
	}
};

void() Q2M_LeapThink =
{
	if (self.health <= 0)
	{
		self.touch = SUB_Null;
		self.movetype = MOVETYPE_STEP;
		if (self.q2_anim != Q2M_ANIM_DIE)
		{
			self.q2_anim = Q2M_ANIM_DIE;
			Q2M_BecomeCorpse ();
		}
		return;
	}
	if ((self.flags & FL_ONGROUND) || time > self.attack_finished)
	{
		self.touch = SUB_Null;
		self.movetype = MOVETYPE_STEP;
		self.think = Q2M_Think;
		self.q2_anim = Q2M_ANIM_RUN;
		Q2M_BeginAnim ();
		return;
	}
	self.nextthink = time + 0.1;
	self.think = Q2M_LeapThink;
};

void() Q2M_Leap =
{
	local vector d;

	if (self.health <= 0)
		return;
	if (self.q2_anim == Q2M_ANIM_DIE)
		return;
	if (self.enemy == world)
		return;
	if (self.q2_kind == Q2M_DOGSTROGG)
		sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_MUTANT)
		sound (self, CHAN_VOICE, "mutant/mutatck1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
	if (self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_DOGSTROGG)
		self.q2_anim = Q2M_ANIM_ATK;
	else
		self.q2_anim = Q2M_ANIM_MELEE;
	Q2M_SetRange ();
	self.frame = self.q2_fstart;
	d = normalize (self.enemy.origin - self.origin);
	self.velocity = d * 420 + '0 0 260';
	self.movetype = MOVETYPE_TOSS;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.touch = Q2M_LeapTouch;
	self.attack_finished = time + 1.2;
	self.think = Q2M_LeapThink;
	self.nextthink = time + 0.1;
};

void() Q2M_BeginAnim =
{
	Q2M_SetRange ();
	self.frame = self.q2_fstart;
	self.think = Q2M_Think;
	self.nextthink = time + 0.1;
};

void() Q2M_Stand =
{
	self.q2_anim = Q2M_ANIM_STAND;
	Q2M_BeginAnim ();
};

void() Q2M_Walk =
{
	self.q2_anim = Q2M_ANIM_WALK;
	Q2M_BeginAnim ();
};

void() Q2M_Run =
{
	self.q2_anim = Q2M_ANIM_RUN;
	Q2M_BeginAnim ();
};

void() Q2M_Missile =
{
	self.q2_anim = Q2M_ANIM_ATK;
	Q2M_BeginAnim ();
};

void() Q2M_Melee =
{
	self.q2_anim = Q2M_ANIM_MELEE;
	Q2M_BeginAnim ();
};

void(entity attacker, float damage) Q2M_Pain =
{
	if (self.health <= 0)
		return;
	if (time < self.pain_finished)
		return;
	if (self.q2_anim == Q2M_ANIM_ATK || self.q2_anim == Q2M_ANIM_MELEE || self.q2_anim == Q2M_ANIM_DIE)
		return;
	self.pain_finished = time + 3;
	if (self.q2_kind == Q2M_SOLDIER)
		sound (self, CHAN_VOICE, "soldier/solpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_INFANTRY)
		sound (self, CHAN_VOICE, "infantry/infpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GUNNER)
		sound (self, CHAN_VOICE, "gunner/gunpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_BERSERK)
		sound (self, CHAN_VOICE, "berserk/berpain2.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GLADIATOR)
		sound (self, CHAN_VOICE, "gladiator/gldpain2.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_TANK)
		sound (self, CHAN_VOICE, "tank/pain.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FLYER)
		sound (self, CHAN_VOICE, "flyer/flypain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FLOAT)
		sound (self, CHAN_VOICE, "floater/fltpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_HOVER)
		sound (self, CHAN_VOICE, "hover/hovpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_CHICK)
		sound (self, CHAN_VOICE, "chick/chkpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_MUTANT)
		sound (self, CHAN_VOICE, "mutant/mutpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_BRAIN)
		sound (self, CHAN_VOICE, "brain/brnpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GRUNTSTR)
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ENFSTROGG)
		sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_KNTSTROGG)
		sound (self, CHAN_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_HYPERKNT || self.q2_kind == Q2M_HBERSTROGG)
		sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_OGRE2STR || self.q2_kind == Q2M_OGRESTR)
		sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_MUTSPAWN)
		sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_SHAMSTR || self.q2_kind == Q2M_SHAMACUD)
		sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_WIZSTROGG || self.q2_kind == Q2M_WIZCUDA)
		sound (self, CHAN_VOICE, "wizard/wpain.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ZOMBSTR)
		sound (self, CHAN_VOICE, "zombie/z_pain.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_DOGSTROGG)
		sound (self, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_VORESTR || self.q2_kind == Q2M_IRONVORE)
		sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FISHGUN)
		sound (self, CHAN_VOICE, "gunner/gunpain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ROTFLYER)
		sound (self, CHAN_VOICE, "flyer/flypain1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_INSANE)
		sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "medic/medpain1.wav", 1, ATTN_NORM);
	self.q2_anim = Q2M_ANIM_PAIN;
	Q2M_BeginAnim ();
};

void() Q2M_Die =
{
	local float gib;

	self.takedamage = DAMAGE_NO;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.flags = self.flags | FL_ONGROUND;
	gib = FALSE;
	if (self.q2_kind == Q2M_FLYER || self.q2_kind == Q2M_FLOAT)
		gib = TRUE;
	else if (self.health <= self.q2_gibhealth)
		gib = TRUE;
	if (gib)
	{
		if (self.q2_kind == Q2M_FLYER || self.q2_kind == Q2M_FLOAT)
		{
			if (self.q2_kind == Q2M_FLYER)
				sound (self, CHAN_VOICE, "flyer/flydeth1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "floater/fltdeth1.wav", 1, ATTN_NORM);
			self.think = SUB_Null;
			self.solid = SOLID_NOT;
			BecomeExplosion ();
			return;
		}
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		Q2M_ExtraGibs ();
		Q2M_ExtraGibs ();
		self.solid = SOLID_NOT;
		self.think = SUB_Null;
		setmodel (self, string_null);
		if (self.q2_kind == Q2M_SOLDIER || self.q2_kind == Q2M_INFANTRY)
		{
			self.ammo_shells = 5;
			DropBackpack ();
		}
		return;
	}
	if (self.q2_kind == Q2M_SOLDIER)
		sound (self, CHAN_VOICE, "soldier/soldeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_INFANTRY)
		sound (self, CHAN_VOICE, "infantry/infdeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GUNNER)
		sound (self, CHAN_VOICE, "gunner/death1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_BERSERK)
		sound (self, CHAN_VOICE, "berserk/death.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GLADIATOR)
		sound (self, CHAN_VOICE, "gladiator/death.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_TANK)
		sound (self, CHAN_VOICE, "tank/death.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FLOAT)
		sound (self, CHAN_VOICE, "floater/fltdeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_HOVER)
		sound (self, CHAN_VOICE, "hover/hovdeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_CHICK)
		sound (self, CHAN_VOICE, "chick/chkdeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_MUTANT)
		sound (self, CHAN_VOICE, "mutant/mutdeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_BRAIN)
		sound (self, CHAN_VOICE, "brain/brndeth1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_GRUNTSTR)
		sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ENFSTROGG)
		sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_KNTSTROGG)
		sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_HYPERKNT || self.q2_kind == Q2M_HBERSTROGG)
		sound (self, CHAN_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_OGRE2STR || self.q2_kind == Q2M_OGRESTR)
		sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FIENDSTR || self.q2_kind == Q2M_MUTSPAWN || self.q2_kind == Q2M_INSANE)
		sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_SHAMSTR || self.q2_kind == Q2M_SHAMACUD)
		sound (self, CHAN_VOICE, "shambler/sboom.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_WIZSTROGG || self.q2_kind == Q2M_WIZCUDA)
		sound (self, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ZOMBSTR)
		sound (self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_DOGSTROGG)
		sound (self, CHAN_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_VORESTR || self.q2_kind == Q2M_IRONVORE)
		sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_FISHGUN)
		sound (self, CHAN_VOICE, "gunner/death1.wav", 1, ATTN_NORM);
	else if (self.q2_kind == Q2M_ROTFLYER)
		sound (self, CHAN_VOICE, "flyer/flydeth1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "medic/meddeth1.wav", 1, ATTN_NORM);
	if (self.q2_kind == Q2M_SOLDIER || self.q2_kind == Q2M_INFANTRY)
	{
		self.ammo_shells = 5;
		DropBackpack ();
	}
	self.q2_anim = Q2M_ANIM_DIE;
	Q2M_BeginAnim ();
	self.th_stand = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_run = SUB_Null;
	self.th_missile = SUB_Null;
	self.th_melee = SUB_Null;
	self.th_pain = SUB_Null;
	self.allowPathFind = FALSE;
	self.touch = SUB_Null;
	self.th_die = BQA_GibCorpse;
	self.takedamage = DAMAGE_YES;
	self.health = 60;
	self.flags = self.flags - (self.flags & FL_MONSTER);
};

void(float kind) Q2M_Setup =
{
	local string mdl;

	Q2M_PrecacheKind (kind);
	self.q2_kind = kind;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.th_stand = Q2M_Stand;
	self.th_walk = Q2M_Walk;
	self.th_run = Q2M_Run;
	self.th_pain = Q2M_Pain;
	self.th_die = Q2M_Die;
	self.allowPathFind = TRUE;
	self.combat_style = CS_RANGED;
	self.q2_runspeed = 12;
	self.q2_gibhealth = -40;
	mdl = "progs/q2_soldier.mdl";
	if (kind == Q2M_SOLDIER)
	{
		mdl = "progs/q2_soldier.mdl";
		self.classname = "monster_q2soldier";
		self.noise = "soldier/solsght1.wav";
		self.health = 30;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -30;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_INFANTRY)
	{
		mdl = "progs/q2_infantry.mdl";
		self.classname = "monster_q2infantry";
		self.noise = "infantry/infsght1.wav";
		self.health = 80;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -40;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_GUNNER)
	{
		mdl = "progs/q2_gunner.mdl";
		self.classname = "monster_q2gunner";
		self.noise = "gunner/sight1.wav";
		self.health = 200;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -70;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_BERSERK)
	{
		mdl = "progs/q2_berserk.mdl";
		self.classname = "monster_q2berserk";
		self.noise = "berserk/bersrch1.wav";
		self.health = 75;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -60;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MELEE;
	}
	else if (kind == Q2M_GLADIATOR)
	{
		mdl = "progs/q2_gladiatr.mdl";
		self.classname = "monster_q2gladiator";
		self.noise = "gladiator/sight.wav";
		self.health = 250;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -175;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_TANK)
	{
		mdl = "progs/q2_tank.mdl";
		self.classname = "monster_q2tank";
		self.noise = "tank/sight1.wav";
		self.health = 600;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -200;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_FLYER)
	{
		mdl = "progs/q2_flyer.mdl";
		self.classname = "monster_q2flyer";
		self.noise = "flyer/flysght1.wav";
		self.health = 80;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -40;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_FLOAT)
	{
		mdl = "progs/q2_float.mdl";
		self.classname = "monster_q2floater";
		self.noise = "floater/fltsght1.wav";
		self.health = 80;
		self.q2_runspeed = 8;
		self.q2_gibhealth = -80;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_HOVER)
	{
		mdl = "progs/q2_hover.mdl";
		self.classname = "monster_q2hover";
		self.noise = "hover/hovsght1.wav";
		self.health = 80;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -100;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_CHICK)
	{
		mdl = "progs/q2_chick.mdl";
		self.classname = "monster_q2chick";
		self.noise = "chick/chksght1.wav";
		self.health = 400;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -70;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_MUTANT)
	{
		mdl = "progs/q2_mutant.mdl";
		self.classname = "monster_q2mutant";
		self.noise = "mutant/mutsght1.wav";
		self.health = 300;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -120;
		self.th_melee = Q2M_Melee;
		self.th_missile = Q2M_Leap;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_BRAIN)
	{
		mdl = "progs/q2_brain.mdl";
		self.classname = "monster_q2brain";
		self.noise = "brain/brnsght1.wav";
		self.health = 600;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -150;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MELEE;
	}
	else if (kind == Q2M_MEDIC)
	{
		mdl = "progs/q2_medic.mdl";
		self.classname = "monster_q2medic";
		self.noise = "medic/medsght1.wav";
		self.health = 400;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -130;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_GRUNTSTR)
	{
		mdl = "progs/q2_gruntstr.mdl";
		self.classname = "monster_q2gruntstr";
		self.noise = "soldier/sight1.wav";
		self.health = 30;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -30;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_ENFSTROGG)
	{
		mdl = "progs/q2_enfstrogg.mdl";
		self.classname = "monster_q2enfstrogg";
		self.noise = "enforcer/sight1.wav";
		self.health = 80;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -40;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_KNTSTROGG)
	{
		mdl = "progs/q2_kntstrogg.mdl";
		self.classname = "monster_q2kntstrogg";
		self.noise = "knight/ksight.wav";
		self.health = 75;
		self.q2_runspeed = 10;
		self.q2_gibhealth = -40;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MELEE;
	}
	else if (kind == Q2M_HYPERKNT)
	{
		mdl = "progs/q2_hyperknt.mdl";
		self.classname = "monster_q2hyperknt";
		self.noise = "hknight/sight1.wav";
		self.health = 250;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -40;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_HBERSTROGG)
	{
		mdl = "progs/q2_hberstrogg.mdl";
		self.classname = "monster_q2hberstrogg";
		self.noise = "hknight/sight1.wav";
		self.health = 250;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -40;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MELEE;
	}
	else if (kind == Q2M_OGRE2STR)
	{
		mdl = "progs/q2_ogre2str.mdl";
		self.classname = "monster_q2ogre2str";
		self.noise = "ogre/ogwake.wav";
		self.health = 200;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -80;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_OGRESTR)
	{
		mdl = "progs/q2_ogrestr.mdl";
		self.classname = "monster_q2ogrestr";
		self.noise = "ogre/ogwake.wav";
		self.health = 200;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -80;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_FIENDSTR)
	{
		mdl = "progs/q2_fiendstr.mdl";
		self.classname = "monster_q2fiendstr";
		self.noise = "demon/sight2.wav";
		self.health = 300;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -80;
		self.th_melee = Q2M_Melee;
		self.th_missile = Q2M_Leap;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_SHAMSTR)
	{
		mdl = "progs/q2_shamstr.mdl";
		self.classname = "monster_q2shamstr";
		self.noise = "shambler/ssight.wav";
		self.health = 600;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -60;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_SHAMACUD)
	{
		mdl = "progs/q2_shamacud.mdl";
		self.classname = "monster_q2shamacud";
		self.noise = "shambler/ssight.wav";
		self.health = 600;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -60;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_WIZSTROGG)
	{
		mdl = "progs/q2_wizstrogg.mdl";
		self.classname = "monster_q2wizstrogg";
		self.noise = "wizard/wsight.wav";
		self.health = 80;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -40;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_WIZCUDA)
	{
		mdl = "progs/q2_wizcuda.mdl";
		self.classname = "monster_q2wizcuda";
		self.noise = "wizard/wsight.wav";
		self.health = 80;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -40;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_ZOMBSTR)
	{
		mdl = "progs/q2_zombstr.mdl";
		self.classname = "monster_q2zombstr";
		self.noise = "zombie/z_idle.wav";
		self.health = 60;
		self.q2_runspeed = 8;
		self.q2_gibhealth = -40;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_DOGSTROGG)
	{
		mdl = "progs/q2_dogstrogg.mdl";
		self.classname = "monster_q2dogstrogg";
		self.noise = "dog/dsight.wav";
		self.health = 25;
		self.q2_runspeed = 16;
		self.q2_gibhealth = -35;
		self.th_melee = Q2M_Melee;
		self.th_missile = Q2M_Leap;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_VORESTR)
	{
		mdl = "progs/q2_vorestr.mdl";
		self.classname = "monster_q2vorestr";
		self.noise = "shalrath/sight.wav";
		self.health = 400;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -90;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_FISHGUN)
	{
		mdl = "progs/q2_fishgun.mdl";
		self.classname = "monster_q2fishgun";
		self.noise = "gunner/sight1.wav";
		self.health = 200;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -70;
		self.th_missile = Q2M_Missile;
	}
	else if (kind == Q2M_ROTFLYER)
	{
		mdl = "progs/q2_rotflyer.mdl";
		self.classname = "monster_q2rotflyer";
		self.noise = "flyer/flysght1.wav";
		self.health = 80;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -40;
		self.movetype = MOVETYPE_FLY;
		self.flags = self.flags | FL_FLY;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_IRONVORE)
	{
		mdl = "progs/q2_ironvore.mdl";
		self.classname = "monster_q2ironvore";
		self.noise = "shalrath/sight.wav";
		self.health = 400;
		self.q2_runspeed = 12;
		self.q2_gibhealth = -90;
		self.th_missile = Q2M_Missile;
		self.th_melee = Q2M_Melee;
		self.combat_style = CS_MIXED;
	}
	else if (kind == Q2M_MUTSPAWN)
	{
		mdl = "progs/q2_mutspawn.mdl";
		self.classname = "monster_q2mutspawn";
		self.noise = "demon/sight2.wav";
		self.health = 300;
		self.q2_runspeed = 20;
		self.q2_gibhealth = -80;
		self.th_melee = Q2M_Melee;
		self.th_missile = Q2M_Leap;
		self.combat_style = CS_MIXED;
	}
	else
	{
		mdl = "progs/q2_insane.mdl";
		self.classname = "monster_q2insane";
		self.noise = "insanespawn/insane1.wav";
		self.health = 300;
		self.q2_runspeed = 16;
		self.q2_gibhealth = -80;
		self.th_melee = Q2M_Melee;
		self.th_missile = Q2M_Leap;
		self.combat_style = CS_MIXED;
	}
	self.max_health = self.health;
	setmodel (self, mdl);
	if (kind == Q2M_TANK || kind == Q2M_MUTANT || kind == Q2M_SHAMSTR || kind == Q2M_SHAMACUD || kind == Q2M_FIENDSTR || kind == Q2M_MUTSPAWN || kind == Q2M_INSANE || kind == Q2M_VORESTR || kind == Q2M_IRONVORE)
		setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	else if (kind == Q2M_CHICK)
		setsize (self, '-16 -16 0', '16 16 56');
	else
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
};

float(float slot) Q2M_PickKind =
{
	local float r;

	r = random ();
	if (slot == Q2M_SLOT_GRUNT)
	{
		if (r < 0.5)
			return Q2M_SOLDIER;
		return Q2M_GRUNTSTR;
	}
	if (slot == Q2M_SLOT_ENFORCER)
	{
		if (r < 0.5)
			return Q2M_INFANTRY;
		return Q2M_ENFSTROGG;
	}
	if (slot == Q2M_SLOT_KNIGHT)
	{
		if (r < 0.5)
			return Q2M_BERSERK;
		return Q2M_KNTSTROGG;
	}
	if (slot == Q2M_SLOT_HKNIGHT)
	{
		if (r < 0.34)
			return Q2M_GLADIATOR;
		if (r < 0.67)
			return Q2M_HYPERKNT;
		return Q2M_HBERSTROGG;
	}
	if (slot == Q2M_SLOT_OGRE)
	{
		if (r < 0.25)
			return Q2M_GUNNER;
		if (r < 0.5)
			return Q2M_OGRESTR;
		if (r < 0.75)
			return Q2M_OGRE2STR;
		return Q2M_FISHGUN;
	}
	if (slot == Q2M_SLOT_FIEND)
	{
		if (r < 0.25)
			return Q2M_MUTANT;
		if (r < 0.5)
			return Q2M_FIENDSTR;
		if (r < 0.75)
			return Q2M_MUTSPAWN;
		return Q2M_INSANE;
	}
	if (slot == Q2M_SLOT_SHAMBLER)
	{
		if (r < 0.25)
			return Q2M_TANK;
		if (r < 0.5)
			return Q2M_BRAIN;
		if (r < 0.75)
			return Q2M_SHAMSTR;
		return Q2M_SHAMACUD;
	}
	if (slot == Q2M_SLOT_SCRAG)
	{
		if (r < 0.17)
			return Q2M_FLYER;
		if (r < 0.34)
			return Q2M_FLOAT;
		if (r < 0.5)
			return Q2M_HOVER;
		if (r < 0.67)
			return Q2M_WIZSTROGG;
		if (r < 0.84)
			return Q2M_WIZCUDA;
		return Q2M_ROTFLYER;
	}
	if (slot == Q2M_SLOT_VORE)
	{
		if (r < 0.25)
			return Q2M_CHICK;
		if (r < 0.5)
			return Q2M_MEDIC;
		if (r < 0.75)
			return Q2M_VORESTR;
		return Q2M_IRONVORE;
	}
	if (slot == Q2M_SLOT_DOG)
		return Q2M_DOGSTROGG;
	return Q2M_ZOMBSTR;
};

float(float slot) Q2M_TryReplace =
{
	if (!Q2M_PoolReplaceOk ())
		return FALSE;
	if (random () >= 0.5)
		return FALSE;
	Q2M_Setup (Q2M_PickKind (slot));
	return TRUE;
};

float() Q2M_HordeMaybe =
{
	local float slot;

	slot = 0;
	if (self.classname == "monster_army")
		slot = Q2M_SLOT_GRUNT;
	else if (self.classname == "monster_enforcer")
		slot = Q2M_SLOT_ENFORCER;
	else if (self.classname == "monster_knight")
		slot = Q2M_SLOT_KNIGHT;
	else if (self.classname == "monster_hell_knight")
		slot = Q2M_SLOT_HKNIGHT;
	else if (self.classname == "monster_ogre")
		slot = Q2M_SLOT_OGRE;
	else if (self.classname == "monster_demon1")
		slot = Q2M_SLOT_FIEND;
	else if (self.classname == "monster_shambler")
		slot = Q2M_SLOT_SHAMBLER;
	else if (self.classname == "monster_wizard")
		slot = Q2M_SLOT_SCRAG;
	else if (self.classname == "monster_shalrath")
		slot = Q2M_SLOT_VORE;
	else if (self.classname == "monster_dog")
		slot = Q2M_SLOT_DOG;
	else if (self.classname == "monster_zombie")
		slot = Q2M_SLOT_ZOMBIE;
	if (slot == 0)
		return FALSE;
	return Q2M_TryReplace (slot);
};

void() Q2M_StartGo =
{
	if (self.flags & FL_FLY)
	{
		if (!walkmove (0, 0))
		{
			dprint ("q2 flymonster in wall at: ");
			dprint (vtos (self.origin));
			dprint ("\n");
		}
	}
	else
	{
		self.origin_z = self.origin_z + 1;
		droptofloor ();
		if (!walkmove (0, 0))
		{
			dprint ("q2 monster in wall at: ");
			dprint (vtos (self.origin));
			dprint ("\n");
		}
	}
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;
	self.flags = self.flags | FL_MONSTER;
	if (self.target != string_null)
	{
		self.goalentity = self.movetarget = find (world, targetname, self.target);
		if (self.movetarget != world)
			self.ideal_yaw = vectoyaw (self.goalentity.origin - self.origin);
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	BQA_MaybeElite ();
	self.nextthink = self.nextthink + random () * 0.5;
};

void() Q2M_Start =
{
	self.nextthink = time + 0.1 + random () * 0.5;
	self.think = Q2M_StartGo;
	total_monsters = total_monsters + 1;
};

void() monster_q2soldier = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_SOLDIER); Q2M_Start (); };
void() monster_q2infantry = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_INFANTRY); Q2M_Start (); };
void() monster_q2gunner = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_GUNNER); Q2M_Start (); };
void() monster_q2berserk = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_BERSERK); Q2M_Start (); };
void() monster_q2gladiator = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_GLADIATOR); Q2M_Start (); };
void() monster_q2tank = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_TANK); Q2M_Start (); };
void() monster_q2flyer = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_FLYER); Q2M_Start (); };
void() monster_q2floater = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_FLOAT); Q2M_Start (); };
void() monster_q2hover = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_HOVER); Q2M_Start (); };
void() monster_q2chick = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_CHICK); Q2M_Start (); };
void() monster_q2mutant = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_MUTANT); Q2M_Start (); };
void() monster_q2brain = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_BRAIN); Q2M_Start (); };
void() monster_q2medic = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_MEDIC); Q2M_Start (); };
void() monster_q2gruntstr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_GRUNTSTR); Q2M_Start (); };
void() monster_q2enfstrogg = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_ENFSTROGG); Q2M_Start (); };
void() monster_q2kntstrogg = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_KNTSTROGG); Q2M_Start (); };
void() monster_q2hyperknt = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_HYPERKNT); Q2M_Start (); };
void() monster_q2hberstrogg = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_HBERSTROGG); Q2M_Start (); };
void() monster_q2ogre2str = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_OGRE2STR); Q2M_Start (); };
void() monster_q2ogrestr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_OGRESTR); Q2M_Start (); };
void() monster_q2fiendstr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_FIENDSTR); Q2M_Start (); };
void() monster_q2shamstr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_SHAMSTR); Q2M_Start (); };
void() monster_q2shamacud = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_SHAMACUD); Q2M_Start (); };
void() monster_q2wizstrogg = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_WIZSTROGG); Q2M_Start (); };
void() monster_q2wizcuda = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_WIZCUDA); Q2M_Start (); };
void() monster_q2zombstr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_ZOMBSTR); Q2M_Start (); };
void() monster_q2dogstrogg = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_DOGSTROGG); Q2M_Start (); };
void() monster_q2vorestr = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_VORESTR); Q2M_Start (); };
void() monster_q2fishgun = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_FISHGUN); Q2M_Start (); };
void() monster_q2rotflyer = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_ROTFLYER); Q2M_Start (); };
void() monster_q2ironvore = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_IRONVORE); Q2M_Start (); };
void() monster_q2mutspawn = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_MUTSPAWN); Q2M_Start (); };
void() monster_q2insane = { if (deathmatch) { remove(self); return; } Q2M_Setup (Q2M_INSANE); Q2M_Start (); };

#else

float(float slot) Q2M_TryReplace =
{
	return FALSE;
};

float() Q2M_HordeMaybe =
{
	return FALSE;
};

void() Q2M_Start =
{
};

void() monster_q2soldier = { remove(self); };
void() monster_q2infantry = { remove(self); };
void() monster_q2gunner = { remove(self); };
void() monster_q2berserk = { remove(self); };
void() monster_q2gladiator = { remove(self); };
void() monster_q2tank = { remove(self); };
void() monster_q2flyer = { remove(self); };
void() monster_q2floater = { remove(self); };
void() monster_q2hover = { remove(self); };
void() monster_q2chick = { remove(self); };
void() monster_q2mutant = { remove(self); };
void() monster_q2brain = { remove(self); };
void() monster_q2medic = { remove(self); };
void() monster_q2gruntstr = { remove(self); };
void() monster_q2enfstrogg = { remove(self); };
void() monster_q2kntstrogg = { remove(self); };
void() monster_q2hyperknt = { remove(self); };
void() monster_q2hberstrogg = { remove(self); };
void() monster_q2ogre2str = { remove(self); };
void() monster_q2ogrestr = { remove(self); };
void() monster_q2fiendstr = { remove(self); };
void() monster_q2shamstr = { remove(self); };
void() monster_q2shamacud = { remove(self); };
void() monster_q2wizstrogg = { remove(self); };
void() monster_q2wizcuda = { remove(self); };
void() monster_q2zombstr = { remove(self); };
void() monster_q2dogstrogg = { remove(self); };
void() monster_q2vorestr = { remove(self); };
void() monster_q2fishgun = { remove(self); };
void() monster_q2rotflyer = { remove(self); };
void() monster_q2ironvore = { remove(self); };
void() monster_q2mutspawn = { remove(self); };
void() monster_q2insane = { remove(self); };

#endif
