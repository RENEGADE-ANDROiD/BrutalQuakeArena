// Arena dummy-player bots. New QuakeC; not remaster addbot (no .nav on RA maps).

void() W_SetCurrentAmmo;
void() W_Attack;
void() RA_BotThink;
void(entity ply) RA_MakeSpectator;
void(entity ply) RA_Place;
void() RA_TryStart;
void(entity ply) RA_MakePractice;
float() RA_PlayerCount;

float(entity targ) RA_CanSee =
{
	traceline (self.origin + self.view_ofs, targ.origin + targ.view_ofs, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

float() RA_BotCount =
{
	local entity e;
	local float n;

	n = 0;
	e = find (world, classname, "player");
	while (e)
	{
		if (e.ra_bot)
			n = n + 1;
		e = find (e, classname, "player");
	}
	return n;
};

float(float id) RA_ProfileUsed =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (e.ra_bot == id)
			return TRUE;
		e = find (e, classname, "player");
	}
	return FALSE;
};

float() RA_PickProfile =
{
	local float i;
	local float n;
	local float pick;
	local float unused;

	n = 0;
	i = 1;
	while (i <= 17)
	{
		if (!RA_ProfileUsed (i))
			n = n + 1;
		i = i + 1;
	}
	if (n < 1)
		return 0;
	pick = 1 + floor (random () * n);
	if (pick > n)
		pick = n;
	i = 1;
	unused = 0;
	while (i <= 17)
	{
		if (!RA_ProfileUsed (i))
		{
			unused = unused + 1;
			if (unused == pick)
				return i;
		}
		i = i + 1;
	}
	return 0;
};

string(float id) RA_BotName =
{
	if (id == 1) return "Crush";
	if (id == 2) return "Nailer";
	if (id == 3) return "Bolt";
	if (id == 4) return "Hopper";
	if (id == 5) return "Sawbone";
	if (id == 6) return "Vault";
	if (id == 7) return "blunt";
	if (id == 8) return "GrendelKhan";
	if (id == 9) return "Godavine";
	if (id == 10) return "Makavelli";
	if (id == 11) return "Immortal";
	if (id == 12) return "Thresh";
	if (id == 13) return "JohnCarmack";
	if (id == 14) return "JohnRomero";
	if (id == 15) return "DrDeath";
	if (id == 16) return "h0s3r";
	if (id == 17) return "PiLL";
	return "Arena Bot";
};

float(float id) RA_BotSpread =
{
	if (id == 13)
		return 2.5;
	if (id >= 7)
		return 4;
	return 10;
};

void() RA_PromotePractice =
{
	local entity e;

	e = find (world, classname, "player");
	while (e)
	{
		if (e.ra_role == 3 && !e.ra_bot)
		{
			e.ra_role = 1;
			e.ra_qtime = time;
		}
		e = find (e, classname, "player");
	}
};

entity(entity bot) RA_BotEnemy =
{
	if (ra_red == bot)
		return ra_blue;
	if (ra_blue == bot)
		return ra_red;
	return world;
};

float(entity viewer, entity targ) RA_LookingAt =
{
	local vector dir;
	local float d;

	if (viewer == world || targ == world)
		return FALSE;
	makevectors (viewer.v_angle);
	dir = targ.origin - viewer.origin;
	dir = normalize (dir);
	d = dir * v_forward;
	if (d > 0.55)
		return TRUE;
	return FALSE;
};

void() RA_BotAim =
{
	local entity foe;
	local vector dir;
	local vector ang;
	local float spread;

	foe = RA_BotEnemy (self);
	if (foe == world)
		return;
	dir = (foe.origin + '0 0 16') - (self.origin + '0 0 22');
	if (dir == '0 0 0')
		return;
	ang = vectoangles (dir);
	spread = RA_BotSpread (self.ra_bot);
	self.v_angle_x = 0 - ang_x + (random () - 0.5) * spread;
	self.v_angle_y = ang_y + (random () - 0.5) * spread * 2;
	self.v_angle_z = 0;
	self.angles_y = self.v_angle_y;
	self.angles_x = 0;
	self.angles_z = 0;
};

void() RA_BotPickWeapon =
{
	local entity foe;
	local float dist;
	local float id;
	local float weap;

	foe = RA_BotEnemy (self);
	id = self.ra_bot;
	dist = 400;
	if (foe != world)
		dist = vlen (foe.origin - self.origin);

	weap = IT_ROCKET_LAUNCHER;
	if (id == 1)
	{
		if (dist < 200)
			weap = IT_SUPER_SHOTGUN;
		else
			weap = IT_SHOTGUN;
	}
	else if (id == 2)
	{
		if (dist < 400)
			weap = IT_SUPER_NAILGUN;
		else
			weap = IT_NAILGUN;
	}
	else if (id == 3)
	{
		if (dist < 600)
			weap = IT_LIGHTNING;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 4)
	{
		if (dist < 350)
			weap = IT_GRENADE_LAUNCHER;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 5)
	{
		if (dist < 80)
			weap = IT_AXE;
		else
			weap = IT_SHOTGUN;
	}
	else if (id == 7)
	{
		if (dist < 90)
			weap = IT_AXE;
		else
			weap = IT_SUPER_SHOTGUN;
	}
	else if (id == 8)
	{
		if (dist < 400)
			weap = IT_LIGHTNING;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 9)
	{
		if (dist < 500)
			weap = IT_SUPER_NAILGUN;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 10)
	{
		if (dist < 450)
			weap = IT_NAILGUN;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 11)
	{
		if (dist < 500)
			weap = IT_LIGHTNING;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 12)
	{
		if (dist < 180)
			weap = IT_SUPER_SHOTGUN;
		else if (dist < 450)
			weap = IT_LIGHTNING;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 14)
	{
		if (dist < 200)
			weap = IT_SUPER_SHOTGUN;
		else if (dist < 350)
			weap = IT_SHOTGUN;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 15)
	{
		if (dist < 400)
			weap = IT_GRENADE_LAUNCHER;
		else
			weap = IT_ROCKET_LAUNCHER;
	}
	else if (id == 17)
		weap = IT_GRENADE_LAUNCHER;

	if (self.weapon != weap)
	{
		self.weapon = weap;
		W_SetCurrentAmmo ();
	}
};

void() RA_BotMove =
{
	local entity foe;
	local float yaw;
	local float id;
	local float dist;
	local float step;

	foe = RA_BotEnemy (self);
	if (foe == world)
		return;
	id = self.ra_bot;
	dist = vlen (foe.origin - self.origin);
	yaw = self.v_angle_y;
	step = 18;
	if (id == 6 || id == 8 || id == 12)
		step = 22;
	if (id == 5 || id == 7 || id == 14)
		step = 20;

	if (id == 10 || id == 17)
	{
		if (RA_CanSee (foe) && RA_LookingAt (foe, self))
			yaw = yaw + 90;
		else if (!RA_CanSee (foe))
			yaw = yaw + 70;
	}
	else if (id == 6 || id == 8 || id == 11 || id == 12)
	{
		if (random () < 0.5)
			yaw = yaw + 85;
		else
			yaw = yaw - 85;
	}
	else if (id == 1 || id == 5 || id == 7 || id == 14)
	{
		if (dist <= 90)
			yaw = yaw + 50;
	}

	if (!walkmove (yaw, step))
	{
		if (!walkmove (yaw + 90, step))
			walkmove (yaw - 90, step);
	}

	if (id == 4 && (self.flags & FL_ONGROUND) && random () < 0.12)
		self.velocity_z = 200;
};

void() RA_BotRocketJump =
{
	local entity foe;
	local vector dir;

	if (!(self.flags & FL_ONGROUND))
		return;
	if (self.health < 40)
		return;
	if (self.ammo_rockets < 2)
		return;
	if (time < self.ltime)
		return;

	foe = RA_BotEnemy (self);
	self.v_angle_x = 70 + random () * 12;
	if (foe != world)
	{
		dir = foe.origin - self.origin;
		self.v_angle_y = vectoyaw (dir);
	}
	self.weapon = IT_ROCKET_LAUNCHER;
	W_SetCurrentAmmo ();
	makevectors (self.v_angle);
	self.enemy = world;
	W_Attack ();
	self.think = RA_BotThink;
	self.nextthink = time + 0.1;
	self.velocity = v_forward * 40 + v_up * 320;
	if (foe != world)
	{
		dir = normalize (foe.origin - self.origin);
		self.velocity = self.velocity + dir * 260;
	}
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.ltime = time + 1.1 + random () * 0.4;
	self.attack_finished = time + 0.35;
};

void() RA_BotShoot =
{
	local entity foe;
	local entity olden;
	local float id;

	foe = RA_BotEnemy (self);
	if (foe == world)
		return;
	if (time < self.attack_finished)
		return;
	id = self.ra_bot;

	if (id == 10 && !RA_CanSee (foe))
		return;
	if (id == 17 && RA_LookingAt (foe, self) && RA_CanSee (foe))
		return;

	RA_BotPickWeapon ();
	RA_BotAim ();
	if (id == 17)
		self.v_angle_x = self.v_angle_x - 8 - random () * 10;
	makevectors (self.v_angle);
	olden = self.enemy;
	self.enemy = world;
	W_Attack ();
	self.think = RA_BotThink;
	self.nextthink = time + 0.1;
	if (id == 13)
		self.attack_finished = time + 1.15;
	else if (id == 15)
		self.attack_finished = time + 0.75;
	else if (id == 17)
		self.attack_finished = time + 0.85;
	self.enemy = olden;
	if (self.ammo_rockets < 8)
		self.ammo_rockets = 100;
	if (self.ammo_nails < 8)
		self.ammo_nails = 200;
	if (self.ammo_cells < 8)
		self.ammo_cells = 100;
	if (self.ammo_shells < 4)
		self.ammo_shells = 100;
};

void() RA_BotThink =
{
	local entity foe;
	local float delay;

	if (!self.ra_bot)
		return;

	self.nextthink = time + 0.1;
	self.think = RA_BotThink;
	self.button0 = 0;
	self.impulse = 0;

	if (self.ra_role != 2)
		return;
	if (self.health <= 0 || self.deadflag)
		return;
	if (ra_state == 2 || self.pausetime > time)
		return;

	delay = 0.12;
	if (self.ra_bot >= 7)
		delay = 0.06;
	if (self.ra_bot == 10)
		delay = 0.22;
	if (self.ra_bot == 13)
		delay = 0.16;
	if (time < ra_lockuntil + delay)
		return;

	foe = RA_BotEnemy (self);
	if (foe != world)
		self.enemy = foe;

	if (self.ra_bot == 16 && random () < 0.35)
		RA_BotRocketJump ();
	else
	{
		RA_BotAim ();
		RA_BotMove ();
		RA_BotShoot ();
	}

	self.nextthink = time + 0.1;
	self.think = RA_BotThink;
};

void() RA_ClearBots =
{
	local entity e;
	local entity n;

	e = find (world, classname, "player");
	while (e)
	{
		n = find (e, classname, "player");
		if (e.ra_bot)
			remove (e);
		e = n;
	}
};

void() RA_SpawnBot =
{
	local entity e;
	local float id;

	if (!ra_active)
	{
		sprint (self, "Arena bots only work on Rocket Arena maps.\n");
		return;
	}
	if (RA_BotCount () >= 3)
	{
		sprint (self, "Already have 3 Arena bots.\n");
		return;
	}
	id = RA_PickProfile ();
	if (id < 1)
	{
		sprint (self, "No unused bot names left.\n");
		return;
	}

	e = spawn ();
	e.classname = "player";
	e.netname = RA_BotName (id);
	e.ra_bot = id;
	e.flags = FL_CLIENT + FL_ISBOT;
	e.th_die = PlayerDie;
	e.th_pain = player_pain;
	e.health = 100;
	e.max_health = 100;
	e.deadflag = DEAD_NO;
	e.air_finished = time + 99999;
	e.view_ofs = '0 0 22';
	e.colormap = 1;
	setmodel (e, "progs/player.mdl");
	setsize (e, VEC_HULL_MIN, VEC_HULL_MAX);
	e.ra_role = 1;
	e.ra_qtime = time;
	RA_MakeSpectator (e);
	RA_Place (e);
	e.think = RA_BotThink;
	e.nextthink = time + 0.2;

	RA_PromotePractice ();
	bprint ("Arena bot ");
	bprint (e.netname);
	bprint (" joined the line.\n");
	RA_TryStart ();
};

void() RA_RemoveBots =
{
	local entity e;
	local entity n;
	local float fighting;

	if (!ra_active)
		return;

	fighting = FALSE;
	e = find (world, classname, "player");
	while (e)
	{
		n = find (e, classname, "player");
		if (e.ra_bot)
		{
			if (e.ra_role == 2)
				fighting = TRUE;
			if (ra_red == e)
				ra_red = world;
			if (ra_blue == e)
				ra_blue = world;
			remove (e);
		}
		e = n;
	}

	if (fighting)
		ra_state = 1;

	e = find (world, classname, "player");
	while (e)
	{
		if (!e.ra_bot && e.ra_role != 4)
		{
			if (RA_PlayerCount () <= 1)
				RA_MakePractice (e);
		}
		e = find (e, classname, "player");
	}

	sprint (self, "Arena bots removed.\n");
	RA_TryStart ();
};

void(entity bot) RA_BotOnDied =
{
	if (!bot.ra_bot)
		return;
	bot.health = 100;
	bot.max_health = 100;
	bot.deadflag = DEAD_NO;
	bot.movetype = MOVETYPE_NOCLIP;
	bot.solid = SOLID_NOT;
	bot.takedamage = DAMAGE_NO;
	bot.think = RA_BotThink;
	bot.nextthink = time + 0.3;
};
