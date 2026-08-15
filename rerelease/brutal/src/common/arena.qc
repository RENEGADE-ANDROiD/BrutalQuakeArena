// Rocket Arena rules for Brutal Quake (remaster).
// Documented Final Arena 1.20 play: 1v1, winner stays, full loadout, 10s lock.
// New QuakeC; credit crt / PlanetQuake. Do not paste 1997 RA source.

void() W_SetCurrentAmmo;
void() player_stand1;
void(vector org) spawn_tfog;
void() RA_BotThink;
void() RA_ClearBots;
void() RA_SpawnBot;
void() RA_RemoveBots;
void(entity bot) RA_BotOnDied;

float ra_active;
float ra_state;
float ra_lockuntil;
float ra_announced;
entity ra_red;
entity ra_blue;
entity ra_thinker;

float() RA_IsArenaMap =
{
	if (mapname == "arenax") return TRUE;
	if (mapname == "terrain2") return TRUE;
	if (mapname == "xarena3") return TRUE;
	if (mapname == "arenazap") return TRUE;
	if (mapname == "arenarg2") return TRUE;
	if (mapname == "arenrg3a") return TRUE;
	if (mapname == "mayan1") return TRUE;
	if (mapname == "2pyramid") return TRUE;
	if (mapname == "2towers") return TRUE;
	if (mapname == "arenarg4") return TRUE;
	if (mapname == "arenarg5") return TRUE;
	if (mapname == "arenarg6") return TRUE;
	if (mapname == "arma4") return TRUE;
	if (mapname == "crandome") return TRUE;
	if (mapname == "egyptra") return TRUE;
	if (mapname == "hill20") return TRUE;
	if (mapname == "iarena2") return TRUE;
	if (mapname == "pitarena") return TRUE;
	if (mapname == "ra_funkf") return TRUE;
	if (mapname == "rgarden") return TRUE;
	if (mapname == "barena1") return TRUE;
	if (mapname == "bbarena2") return TRUE;
	if (mapname == "dm2arena") return TRUE;
	if (mapname == "marena2") return TRUE;
	if (mapname == "marena3") return TRUE;
	if (mapname == "marena4") return TRUE;
	if (mapname == "rarena3") return TRUE;
	if (mapname == "soyarena") return TRUE;
	if (mapname == "uarena1") return TRUE;
	if (mapname == "23ar-a") return TRUE;
	if (mapname == "arendm1a") return TRUE;
	if (mapname == "basarena") return TRUE;
	if (mapname == "bunmoo3") return TRUE;
	if (mapname == "bunski") return TRUE;
	if (mapname == "chamber1") return TRUE;
	if (mapname == "dom2_1ra") return TRUE;
	if (mapname == "football") return TRUE;
	if (mapname == "gear8") return TRUE;
	if (mapname == "gnurena") return TRUE;
	if (mapname == "id3") return TRUE;
	if (mapname == "lowgrav") return TRUE;
	if (mapname == "nilsrar3") return TRUE;
	if (mapname == "pen2") return TRUE;
	if (mapname == "ptucket") return TRUE;
	if (mapname == "unholy") return TRUE;
	if (mapname == "yard1") return TRUE;
	return FALSE;
};

void(string s) RA_Play =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		sound (e, CHAN_VOICE, s, 1, ATTN_NONE);
		e = find (e, classname, "player");
	}
};

float() RA_PlayerCount =
{
	local entity e;
	local float n;

	n = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (e.ra_role != 4)
			n = n + 1;
		e = find (e, classname, "player");
	}
	return n;
};

float(entity ply) RA_QueuePos =
{
	local entity e;
	local float n;

	n = 1;
	e = find (world, classname, "player");
	while (e)
	{
		if (e.ra_role == 1 && e != ply)
		{
			if (e.ra_qtime < ply.ra_qtime)
				n = n + 1;
		}
		e = find (e, classname, "player");
	}
	return n;
};

entity() RA_NextQueued =
{
	local entity e;
	local entity best;

	best = world;
	e = find (world, classname, "player");
	while (e)
	{
		if ((e.ra_role == 1 || e.ra_role == 3) && e.health > 0)
		{
			if (best == world || e.ra_qtime < best.ra_qtime)
				best = e;
		}
		e = find (e, classname, "player");
	}
	return best;
};

void(entity ply) RA_SetLoadout =
{
	local entity prev;

	prev = self;
	self = ply;
	self.health = 100;
	self.max_health = 100;
	self.armorvalue = 200;
	self.armortype = 0.8;
	self.ammo_shells = 100;
	self.ammo_nails = 200;
	self.ammo_rockets = 100;
	self.ammo_cells = 100;
	self.items = IT_AXE + IT_SHOTGUN + IT_SUPER_SHOTGUN + IT_NAILGUN + IT_SUPER_NAILGUN + IT_GRENADE_LAUNCHER + IT_ROCKET_LAUNCHER + IT_LIGHTNING + IT_SHELLS + IT_NAILS + IT_ROCKETS + IT_CELLS;
	self.weapon = IT_ROCKET_LAUNCHER;
	W_SetCurrentAmmo ();
	self = prev;
};

void(entity ply) RA_Place =
{
	local entity spot;

	spot = find (world, classname, "info_player_deathmatch");
	if (spot == world)
		spot = find (world, classname, "info_player_start");
	if (spot == world)
		return;
	if (ply == ra_blue)
	{
		spot = find (spot, classname, "info_player_deathmatch");
		if (spot == world)
			spot = find (world, classname, "info_player_deathmatch");
	}
	setorigin (ply, spot.origin + '0 0 1');
	ply.angles = spot.angles;
	ply.fixangle = TRUE;
	ply.velocity = '0 0 0';
};

void(entity ply) RA_MakeSpectator =
{
	ply.ra_role = 1;
	ply.solid = SOLID_NOT;
	ply.movetype = MOVETYPE_NOCLIP;
	ply.takedamage = DAMAGE_NO;
	ply.items = IT_AXE;
	ply.weapon = IT_AXE;
	ply.weaponmodel = string_null;
	ply.armorvalue = 0;
	ply.armortype = 0;
	ply.ammo_shells = 0;
	ply.ammo_nails = 0;
	ply.ammo_rockets = 0;
	ply.ammo_cells = 0;
	ply.currentammo = 0;
	ply.effects = 0;
};

void(entity ply) RA_MakeFighter =
{
	local entity prev;

	prev = self;
	self = ply;
	ply.ra_role = 2;
	ply.solid = SOLID_SLIDEBOX;
	ply.movetype = MOVETYPE_WALK;
	ply.takedamage = DAMAGE_AIM;
	ply.deadflag = DEAD_NO;
	ply.effects = 0;
	setmodel (ply, "progs/player.mdl");
	setsize (ply, VEC_HULL_MIN, VEC_HULL_MAX);
	ply.view_ofs = '0 0 22';
	RA_SetLoadout (ply);
	RA_Place (ply);
	player_stand1 ();
	makevectors (ply.angles);
	spawn_tfog (ply.origin + v_forward * 20);
	if (ply.ra_bot)
	{
		ply.think = RA_BotThink;
		ply.nextthink = time + 0.1;
	}
	self = prev;
};

void(entity ply) RA_MakePractice =
{
	ply.ra_role = 3;
	ply.solid = SOLID_SLIDEBOX;
	ply.movetype = MOVETYPE_WALK;
	ply.takedamage = DAMAGE_AIM;
	ply.effects = 0;
	RA_SetLoadout (ply);
	centerprint (ply, "Rocket Arena practice\nFull loadout. Invite a friend for 1v1.\n");
};

void() RA_TryStart =
{
	local entity a;
	local entity b;

	if (ra_state == 2 || ra_state == 3)
		return;
	if (RA_PlayerCount () < 2)
		return;

	a = ra_red;
	if (a == world || a.ra_role != 2 || a.health <= 0)
		a = RA_NextQueued ();
	if (a == world)
		return;
	if (a.ra_role == 1)
		a.ra_role = 2;

	b = RA_NextQueued ();
	if (b == world || b == a)
		return;

	ra_red = a;
	ra_blue = b;
	RA_MakeFighter (a);
	RA_MakeFighter (b);
	a.pausetime = time + 10;
	b.pausetime = time + 10;
	a.attack_finished = time + 10;
	b.attack_finished = time + 10;
	ra_state = 2;
	ra_lockuntil = time + 10;
	ra_announced = 0;
	bprint ("Rocket Arena: ");
	bprint (a.netname);
	bprint (" vs ");
	bprint (b.netname);
	bprint ("\n");
	centerprint (a, "Get ready...\n");
	centerprint (b, "Get ready...\n");
};

void() RA_Think =
{
	local float left;

	if (!ra_active)
		return;

	if (ra_state == 2)
	{
		left = ra_lockuntil - time;
		if (left > 2.5 && ra_announced < 1)
		{
			RA_Play ("ra/3.wav");
			ra_announced = 1;
		}
		else if (left > 1.5 && left <= 2.5 && ra_announced < 2)
		{
			RA_Play ("ra/2.wav");
			ra_announced = 2;
		}
		else if (left > 0.4 && left <= 1.5 && ra_announced < 3)
		{
			RA_Play ("ra/1.wav");
			ra_announced = 3;
		}
		else if (left <= 0)
		{
			RA_Play ("ra/fight.wav");
			ra_state = 3;
			if (ra_red != world)
			{
				ra_red.pausetime = 0;
				centerprint (ra_red, "FIGHT!\n");
			}
			if (ra_blue != world)
			{
				ra_blue.pausetime = 0;
				centerprint (ra_blue, "FIGHT!\n");
			}
		}
	}

	if (ra_state < 2)
		RA_TryStart ();

	self.nextthink = time + 0.2;
	self.think = RA_Think;
};

void() RA_Init =
{
	ra_active = FALSE;
	ra_state = 0;
	ra_red = world;
	ra_blue = world;
	RA_ClearBots ();
	if (!RA_IsArenaMap ())
		return;

	ra_active = TRUE;
	precache_sound ("ra/1.wav");
	precache_sound ("ra/2.wav");
	precache_sound ("ra/3.wav");
	precache_sound ("ra/fight.wav");
	precache_sound ("ra/flawless.wav");
	precache_sound ("ra/excelent.wav");

	ra_thinker = spawn ();
	ra_thinker.classname = "ra_thinker";
	ra_thinker.nextthink = time + 0.5;
	ra_thinker.think = RA_Think;
};

void() RA_OnSpawn =
{
	if (!ra_active)
		return;

	if (self.ra_role == 2 && self.health > 0)
	{
		RA_SetLoadout (self);
		return;
	}

	if (!deathmatch || RA_PlayerCount () <= 1)
	{
		RA_MakePractice (self);
		return;
	}

	self.ra_role = 1;
	self.ra_qtime = time;
	RA_MakeSpectator (self);
	sprint (self, "In line. Impulse 69 = position, 70 = break, 68 = stats.\n");
	RA_TryStart ();
};

void(entity attacker) RA_PlayerDied =
{
	local entity winner;
	local entity loser;

	if (!ra_active)
		return;
	if (self.ra_role != 2)
		return;

	loser = self;
	if (attacker != world && attacker != loser && attacker.classname == "player" && attacker.ra_role == 2)
		winner = attacker;
	else if (ra_red == loser)
		winner = ra_blue;
	else
		winner = ra_red;

	loser.ra_losses = loser.ra_losses + 1;
	loser.ra_role = 1;
	loser.ra_qtime = time;

	if (winner != world && winner != loser)
	{
		winner.ra_wins = winner.ra_wins + 1;
		bprint (winner.netname);
		bprint (" stays. ");
		bprint (loser.netname);
		bprint (" to the back of the line.\n");
		if (winner.health >= 100)
			RA_Play ("ra/flawless.wav");
		else
			RA_Play ("ra/excelent.wav");
		RA_SetLoadout (winner);
		ra_red = winner;
		ra_blue = world;
	}
	else
	{
		ra_red = world;
		ra_blue = world;
	}

	ra_state = 1;
	RA_BotOnDied (loser);
	RA_TryStart ();
};

void() RA_ClientDisconnect =
{
	if (!ra_active)
		return;
	if (self.ra_role == 2)
	{
		if (ra_red == self)
			ra_red = world;
		if (ra_blue == self)
			ra_blue = world;
		ra_state = 1;
		RA_TryStart ();
	}
	self.ra_role = 0;
};

float() RA_Impulse =
{
	local float pos;
	local float skillpct;

	if (!ra_active)
		return FALSE;

	if (self.ra_role == 1 || self.ra_role == 4)
	{
		self.button0 = 0;
		if (self.impulse != 68 && self.impulse != 69 && self.impulse != 70 && self.impulse != 71 && self.impulse != 72)
		{
			self.impulse = 0;
			return TRUE;
		}
	}

	if (self.impulse == 68)
	{
		if (self.ra_wins + self.ra_losses > 0)
			skillpct = self.ra_wins * 100 / (self.ra_wins + self.ra_losses);
		else
			skillpct = 0;
		sprint (self, "RA wins ");
		sprint (self, ftos (self.ra_wins));
		sprint (self, "  losses ");
		sprint (self, ftos (self.ra_losses));
		sprint (self, "  skill ");
		sprint (self, ftos (skillpct));
		sprint (self, "\n");
		return TRUE;
	}
	if (self.impulse == 69)
	{
		if (self.ra_role == 2)
			sprint (self, "You are in the arena.\n");
		else if (self.ra_role == 3)
			sprint (self, "Practice. Waiting for a second player.\n");
		else if (self.ra_role == 4)
			sprint (self, "On break. Impulse 70 to return.\n");
		else
		{
			pos = RA_QueuePos (self);
			sprint (self, "Position in line: ");
			sprint (self, ftos (pos));
			sprint (self, "\n");
		}
		return TRUE;
	}
	if (self.impulse == 70)
	{
		if (self.ra_role == 2)
			sprint (self, "You cannot take a break in the arena.\n");
		else if (self.ra_role == 4)
		{
			self.ra_role = 1;
			self.ra_qtime = time;
			sprint (self, "Back in line.\n");
			RA_TryStart ();
		}
		else
		{
			self.ra_role = 4;
			RA_MakeSpectator (self);
			self.ra_role = 4;
			sprint (self, "Break. Impulse 70 when you are back.\n");
		}
		return TRUE;
	}
	if (self.impulse == 71)
	{
		RA_SpawnBot ();
		return TRUE;
	}
	if (self.impulse == 72)
	{
		RA_RemoveBots ();
		return TRUE;
	}
	return FALSE;
};
