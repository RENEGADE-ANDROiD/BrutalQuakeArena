// Brutal Quake Arena extras that work in remaster QuakeC

void(string gibname, float dm) ThrowGib;
void(string gibname, float dm) ThrowHead;
vector(float dm) VelocityForDamage;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void(vector org, vector vel) SpawnMeatSpray;
float(entity e, float healamount, float ignore) T_Heal;
void() W_SetCurrentAmmo;
void() SUB_Remove;
void() SUB_Null;
void() BecomeExplosion;
void() s_explode1;
void() BQA_ProxTouch;
void() BQA_ProxThink;
void() BQA_ProxExplode;
void() BQA_ExplosionFX;
void() BQA_ResetSlowmo;
void() BQA_ClearSlowmo;
void(entity atk) BQA_PulseSlowmo;
void() BQA_AxeTouch;
void() BQA_CarnageTouch;
void() BQA_DropCarnageVial;

float() BQA_PackMelee =
{
	local float p;

	p = 0;
	if (self.has_chainsaw)
		p = p + 1;
	if (self.has_mjolnir)
		p = p + 2;
	return p;
};

void(float p) BQA_UnpackMelee =
{
	self.has_chainsaw = 0;
	self.has_mjolnir = 0;
	self.q2weap = 0;
	self.q2_held = 0;
	if (p & 1)
		self.has_chainsaw = 1;
	if (p & 2)
		self.has_mjolnir = 1;
};

entity	bqa_gibs;
entity	bqa_lastgib;
float	bqa_numgibs;
entity	bqa_splats;
entity	bqa_lastsplat;
float	bqa_numsplats;
entity	bqa_holes;
entity	bqa_lasthole;
float	bqa_numholes;
entity	bqa_dnums;
entity	bqa_lastdnum;
float	bqa_numdnums;

void() BQA_PrecacheGore =
{
	precache_model ("progs/s_bullet.spr");
	precache_model ("progs/bqa_splat1.spr");
	precache_model ("progs/bqa_splat2.spr");
	precache_model ("progs/bqa_splat3.spr");
	precache_model ("progs/bqa_splat4.spr");
	precache_model ("progs/bqa_splat5.spr");
	precache_model ("progs/bqa_splat6.spr");
	precache_model ("progs/bqa_splat7.spr");
	precache_model ("progs/bqa_splat8.spr");
	precache_model ("progs/bqa_splat9.spr");
	precache_model ("progs/bqa_splat10.spr");
	precache_model ("progs/bqa_splat11.spr");
	precache_model ("progs/bqa_splat12.spr");
	precache_model ("progs/bqa_splat13.spr");
	precache_model ("progs/bqa_splat14.spr");
	precache_model ("progs/bqa_pool.spr");
	precache_model ("progs/bqa_drip.spr");
	precache_model ("progs/bqa_organ1.spr");
	precache_model ("progs/bqa_organ2.spr");
	precache_model ("progs/bqa_organ3.spr");
	precache_model ("progs/bqa_organ4.spr");
	precache_model ("progs/bqa_organ5.spr");
	precache_model ("progs/bqa_eye.spr");
	precache_model ("progs/bqa_brain.spr");
	precache_model ("progs/bqa_heart.spr");
	precache_model ("progs/bqa_dnum.spr");
	precache_model ("progs/bqa_chain.spr");
};

void(entity g) BQA_UnlinkGib =
{
	local entity e;
	local entity prev;

	prev = world;
	e = bqa_gibs;
	while (e != world)
	{
		if (e == g)
		{
			if (prev == world)
				bqa_gibs = g.bqa_next;
			else
				prev.bqa_next = g.bqa_next;
			if (bqa_lastgib == g)
				bqa_lastgib = prev;
			bqa_numgibs = bqa_numgibs - 1;
			g.bqa_next = world;
			return;
		}
		prev = e;
		e = e.bqa_next;
	}
};

void(entity g) BQA_UnlinkSplat =
{
	local entity e;
	local entity prev;

	prev = world;
	e = bqa_splats;
	while (e != world)
	{
		if (e == g)
		{
			if (prev == world)
				bqa_splats = g.bqa_next;
			else
				prev.bqa_next = g.bqa_next;
			if (bqa_lastsplat == g)
				bqa_lastsplat = prev;
			bqa_numsplats = bqa_numsplats - 1;
			g.bqa_next = world;
			return;
		}
		prev = e;
		e = e.bqa_next;
	}
};

void(entity g) BQA_UnlinkHole =
{
	local entity e;
	local entity prev;

	prev = world;
	e = bqa_holes;
	while (e != world)
	{
		if (e == g)
		{
			if (prev == world)
				bqa_holes = g.bqa_next;
			else
				prev.bqa_next = g.bqa_next;
			if (bqa_lasthole == g)
				bqa_lasthole = prev;
			bqa_numholes = bqa_numholes - 1;
			g.bqa_next = world;
			return;
		}
		prev = e;
		e = e.bqa_next;
	}
};

void(entity g) BQA_UnlinkDnum =
{
	local entity e;
	local entity prev;

	prev = world;
	e = bqa_dnums;
	while (e != world)
	{
		if (e == g)
		{
			if (prev == world)
				bqa_dnums = g.bqa_next;
			else
				prev.bqa_next = g.bqa_next;
			if (bqa_lastdnum == g)
				bqa_lastdnum = prev;
			bqa_numdnums = bqa_numdnums - 1;
			g.bqa_next = world;
			return;
		}
		prev = e;
		e = e.bqa_next;
	}
};

void() BQA_GibThink =
{
	if (time > self.ltime)
	{
		BQA_UnlinkGib (self);
		remove (self);
		return;
	}
	if (self.flags & FL_ONGROUND)
	{
		traceline (self.origin, self.origin - '0 0 48', TRUE, self);
		if (trace_fraction == 1 || (self.origin_z - trace_endpos_z) > 8)
			self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	self.nextthink = time + 0.25;
};

void(entity g) BQA_TrackGib =
{
	local entity e;

	if (g == world)
		return;
	g.classname = "gib";
	g.bqa_next = world;
	if (bqa_numgibs >= 48)
	{
		e = bqa_gibs;
		if (e != world)
		{
			BQA_UnlinkGib (e);
			remove (e);
		}
	}
	if (bqa_gibs == world)
		bqa_gibs = g;
	else
		bqa_lastgib.bqa_next = g;
	bqa_lastgib = g;
	bqa_numgibs = bqa_numgibs + 1;
};

void() BQA_SplatExpire =
{
	BQA_UnlinkSplat (self);
	remove (self);
};

void() BQA_SplatAnimThink =
{
	if (self.delay == 1)
	{
		self.cnt = self.cnt + 1;
		if (self.cnt < 7)
			self.frame = self.cnt;
		self.scale = self.scale + 0.08;
		if (self.scale > 1)
			self.scale = 1;
		if (self.cnt >= 10)
		{
			self.delay = 0;
			self.think = BQA_SplatExpire;
			self.nextthink = time + 89;
			return;
		}
		self.nextthink = time + 0.1;
		return;
	}
	if (self.delay == 2)
	{
		self.scale = self.scale + 0.04;
		if (self.scale >= 1)
		{
			self.scale = 1;
			self.delay = 0;
			self.think = BQA_SplatExpire;
			self.nextthink = time + 89;
			return;
		}
		self.nextthink = time + 0.1;
		return;
	}
	BQA_SplatExpire ();
};

void() BQA_HoleThink =
{
	BQA_UnlinkHole (self);
	remove (self);
};

void() BQA_DripThink;
void(vector pos) BQA_SpawnDrip;
void(vector pos) BQA_PlacePool;

void(entity g) BQA_LinkSplat =
{
	local entity e;

	g.bqa_next = world;
	if (bqa_numsplats >= 24)
	{
		e = bqa_splats;
		if (e != world)
		{
			BQA_UnlinkSplat (e);
			remove (e);
		}
	}
	if (bqa_splats == world)
		bqa_splats = g;
	else
		bqa_lastsplat.bqa_next = g;
	bqa_lastsplat = g;
	bqa_numsplats = bqa_numsplats + 1;
};

void(vector pos) BQA_PlaceSplat =
{
	local entity new;
	local vector norm;
	local float r;
	local float nz;
	local string mdl;

	new = spawn ();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bqa_splat";
	nz = trace_plane_normal_z;
	if (nz < 0)
		nz = 0 - nz;
	r = random ();
	if (nz > 0.7)
	{
		if (r < 0.125)
			mdl = "progs/bqa_splat1.spr";
		else if (r < 0.25)
			mdl = "progs/bqa_splat2.spr";
		else if (r < 0.375)
			mdl = "progs/bqa_splat3.spr";
		else if (r < 0.5)
			mdl = "progs/bqa_splat4.spr";
		else if (r < 0.625)
			mdl = "progs/bqa_splat7.spr";
		else if (r < 0.75)
			mdl = "progs/bqa_splat8.spr";
		else if (r < 0.875)
			mdl = "progs/bqa_splat9.spr";
		else
			mdl = "progs/bqa_splat10.spr";
	}
	else
	{
		if (r < 0.166)
			mdl = "progs/bqa_splat5.spr";
		else if (r < 0.333)
			mdl = "progs/bqa_splat6.spr";
		else if (r < 0.5)
			mdl = "progs/bqa_splat11.spr";
		else if (r < 0.666)
			mdl = "progs/bqa_splat12.spr";
		else if (r < 0.833)
			mdl = "progs/bqa_splat13.spr";
		else
			mdl = "progs/bqa_splat14.spr";
	}
	setmodel (new, mdl);
	setsize (new, '0 0 0', '0 0 0');
	norm = trace_plane_normal;
	norm_x = 0 - norm_x;
	norm_y = 0 - norm_y;
	new.angles = vectoangles (norm);
	makevectors (new.angles);
	setorigin (new, pos - (v_forward * 0.2));
	if (nz <= 0.7)
	{
		new.scale = 0.6;
		new.delay = 2;
		new.think = BQA_SplatAnimThink;
		new.nextthink = time + 0.1;
		if (random () < 0.4)
			BQA_SpawnDrip (pos);
	}
	else
	{
		new.scale = 1;
		new.delay = 0;
		new.think = BQA_SplatExpire;
		new.nextthink = time + 90;
	}
	BQA_LinkSplat (new);
};

void() BQA_DripThink =
{
	local vector dest;

	dest = self.origin;
	dest_z = dest_z - 8;
	traceline (self.origin, dest, TRUE, self);
	if (trace_fraction < 1)
	{
		BQA_UnlinkSplat (self);
		if (trace_plane_normal_z > 0.5)
			BQA_PlaceSplat (trace_endpos);
		remove (self);
		return;
	}
	setorigin (self, dest);
	self.cnt = self.cnt + 1;
	if (self.cnt >= 10)
	{
		BQA_UnlinkSplat (self);
		remove (self);
		return;
	}
	self.nextthink = time + 0.1;
};

void(vector pos) BQA_SpawnDrip =
{
	local entity new;

	new = spawn ();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bqa_drip";
	setmodel (new, "progs/bqa_drip.spr");
	setsize (new, '0 0 0', '0 0 0');
	setorigin (new, pos);
	new.cnt = 0;
	new.delay = 3;
	new.think = BQA_DripThink;
	new.nextthink = time + 0.1;
	BQA_LinkSplat (new);
};

void(vector pos) BQA_PlacePool =
{
	local entity new;
	local vector norm;

	new = spawn ();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bqa_splat";
	setmodel (new, "progs/bqa_pool.spr");
	setsize (new, '0 0 0', '0 0 0');
	new.frame = 0;
	new.scale = 0.35;
	new.cnt = 0;
	new.delay = 1;
	norm = trace_plane_normal;
	norm_x = 0 - norm_x;
	norm_y = 0 - norm_y;
	new.angles = vectoangles (norm);
	makevectors (new.angles);
	setorigin (new, pos - (v_forward * 0.2));
	new.think = BQA_SplatAnimThink;
	new.nextthink = time + 0.1;
	BQA_LinkSplat (new);
};

void(vector org, vector dir, float heavy) BQA_SplatterAt =
{
	local vector end;
	local vector right;
	local float nz;

	traceline (org + '0 0 8', org - '0 0 96', TRUE, self);
	if (trace_fraction < 1)
	{
		nz = trace_plane_normal_z;
		if (nz < 0)
			nz = 0 - nz;
		if (heavy && nz > 0.7)
			BQA_PlacePool (trace_endpos);
		else
			BQA_PlaceSplat (trace_endpos);
	}

	end = dir;
	if (vlen (end) < 0.1)
		end = '0 0 -1';
	else
		end = normalize (end);
	traceline (org, org + (end * 80), TRUE, self);
	if (trace_fraction < 1)
	{
		nz = trace_plane_normal_z;
		if (nz < 0)
			nz = 0 - nz;
		if (heavy && nz > 0.7)
			BQA_PlacePool (trace_endpos);
		else
			BQA_PlaceSplat (trace_endpos);
	}

	if (heavy)
	{
		right_x = 0 - end_y;
		right_y = end_x;
		right_z = 0;
		if (vlen (right) < 0.1)
			right = '0 1 0';
		else
			right = normalize (right);
		traceline (org, org + (right * 64), TRUE, self);
		if (trace_fraction < 1)
			BQA_PlaceSplat (trace_endpos);
		traceline (org, org - (right * 64), TRUE, self);
		if (trace_fraction < 1)
			BQA_PlaceSplat (trace_endpos);
	}
};

void(float dm) BQA_ThrowViscera =
{
	local entity new;
	local float r;
	local string mdl;

	r = random ();
	if (r < 0.125)
		mdl = "progs/bqa_organ1.spr";
	else if (r < 0.25)
		mdl = "progs/bqa_organ2.spr";
	else if (r < 0.375)
		mdl = "progs/bqa_organ3.spr";
	else if (r < 0.5)
		mdl = "progs/bqa_organ4.spr";
	else if (r < 0.625)
		mdl = "progs/bqa_organ5.spr";
	else if (r < 0.75)
		mdl = "progs/bqa_eye.spr";
	else if (r < 0.875)
		mdl = "progs/bqa_brain.spr";
	else
		mdl = "progs/bqa_heart.spr";

	new = spawn ();
	new.origin = self.origin + '0 0 16';
	setmodel (new, mdl);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random () * 400;
	new.avelocity_y = random () * 400;
	new.avelocity_z = random () * 400;
	new.think = BQA_GibThink;
	new.ltime = time + 90 + random () * 20;
	new.nextthink = time + 0.25;
	new.frame = 0;
	new.flags = 0;
	BQA_TrackGib (new);
};

void(vector pos) BQA_PlaceBulletHole =
{
	local entity new;
	local entity e;
	local vector norm;

	new = spawn ();
	new.movetype = MOVETYPE_NONE;
	new.solid = SOLID_NOT;
	new.classname = "bqa_hole";
	setmodel (new, "progs/s_bullet.spr");
	setsize (new, '0 0 0', '0 0 0');
	norm = trace_plane_normal;
	norm_x = 0 - norm_x;
	norm_y = 0 - norm_y;
	new.angles = vectoangles (norm);
	makevectors (new.angles);
	setorigin (new, pos - (v_forward * 0.2));
	new.think = BQA_HoleThink;
	new.nextthink = time + 90;
	new.bqa_next = world;
	if (bqa_numholes >= 16)
	{
		e = bqa_holes;
		if (e != world)
		{
			BQA_UnlinkHole (e);
			remove (e);
		}
	}
	if (bqa_holes == world)
		bqa_holes = new;
	else
		bqa_lasthole.bqa_next = new;
	bqa_lasthole = new;
	bqa_numholes = bqa_numholes + 1;
};

void() BQA_GibCorpse =
{
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowGib ("progs/gib1.mdl", -60);
	ThrowGib ("progs/gib2.mdl", -60);
	ThrowGib ("progs/gib3.mdl", -60);
	if (Q2M_ModelsOk ())
		Q2M_ExtraGibs ();
	BQA_SplatterAt (self.origin, '0 0 -1', TRUE);
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_TOSS;
	setmodel (self, string_null);
	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
};

void() BQA_FleshSplat =
{
	local float r;

	if (self.health <= 0)
		return;
	if (!((self.flags & FL_MONSTER) || (self.flags & FL_CLIENT)))
		return;

	r = random ();
	if (r < 0.25)
		ThrowGib ("progs/gib1.mdl", -20);
	else if (r < 0.5)
		ThrowGib ("progs/gib2.mdl", -20);
	else if (r < 0.75)
		ThrowGib ("progs/gib3.mdl", -20);
	else if (Q2M_ModelsOk ())
		Q2M_ExtraGibs ();
	else
		ThrowGib ("progs/gib1.mdl", -20);
	if (random () < 0.25)
		BQA_ThrowViscera (-20);
	if (random () < 0.5)
		BQA_SplatterAt (self.origin, '0 0 -1', TRUE);
};

void() BQA_MakePuddle =
{
	particle (self.origin, '0 0 20', 73, 40);
	BQA_SplatterAt (self.origin, '0 0 -1', TRUE);
};

void() BQA_CorpseTwitchRestore =
{
	self.frame = self.wait;
	self.avelocity = '0 0 0';
	self.think = SUB_Null;
	self.nextthink = -1;
};

void(entity attacker, float damage) BQA_CorpsePain =
{
	local vector dir;

	SpawnBlood (self.origin, '0 0 40', damage);
	dir = '0 0 -1';
	if (attacker != world)
	{
		dir = self.origin - attacker.origin;
		if (vlen (dir) < 1)
			dir = '0 0 8';
		dir = normalize (dir);
		self.velocity = dir * 80 + '0 0 40';
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.avelocity_x = (random () - 0.5) * 180;
		self.avelocity_y = (random () - 0.5) * 180;
		self.avelocity_z = (random () - 0.5) * 90;
	}
	BQA_SplatterAt (self.origin, dir, TRUE);
	if (self.frame > 0)
	{
		self.wait = self.frame;
		self.frame = self.frame - 1;
	}
	self.think = BQA_CorpseTwitchRestore;
	self.nextthink = time + 0.15;
};

void() BQA_CorpseReady =
{
	local entity corpse;

	corpse = self.owner;
	if (corpse == world)
	{
		remove (self);
		return;
	}
	if (corpse.health > 0)
	{
		remove (self);
		return;
	}
	if (corpse.model == string_null)
	{
		remove (self);
		return;
	}

	corpse.takedamage = DAMAGE_YES;
	corpse.health = 60;
	corpse.th_die = BQA_GibCorpse;
	corpse.th_pain = BQA_CorpsePain;
	corpse.th_melee = SUB_Null;
	corpse.th_missile = SUB_Null;
	corpse.th_run = SUB_Null;
	corpse.th_walk = SUB_Null;
	corpse.th_stand = SUB_Null;
	corpse.touch = SUB_Null;
	corpse.think = SUB_Null;
	corpse.nextthink = -1;
	corpse.enemy = world;
	corpse.solid = SOLID_CORPSE;
	setsize (corpse, '-16 -16 0', '16 16 8');
	corpse.flags = corpse.flags - (corpse.flags & FL_MONSTER);
	remove (self);
};

void() BQA_SetupCorpse =
{
	local entity h;

	if (self.health <= -40)
		return;
	if (self.q2_kind)
		return;
	if (!((self.flags & FL_MONSTER) || (self.classname == "player")))
		return;

	BQA_MakePuddle ();

	h = spawn ();
	h.classname = "corpse_setup";
	h.owner = self;
	h.nextthink = time + 1.8;
	h.think = BQA_CorpseReady;
};

void() BQA_MeleeGlorySip =
{
	local entity atk;

	atk = self.enemy;
	if (atk == world)
		return;
	if (!atk.melee_glory)
		return;
	if (!(atk.flags & FL_CLIENT))
		return;
	if (atk.health <= 0)
		return;
	if (atk.health >= atk.max_health)
		return;

	atk.health = atk.health + 10;
	if (atk.health > atk.max_health)
		atk.health = atk.max_health;
	sound (atk, CHAN_ITEM, "items/n_health.wav", 1, ATTN_NORM);
};

void() BQA_MeleeDismember =
{
	local entity atk;
	local float style;
	local vector kick;

	atk = self.enemy;
	if (atk == world)
		return;
	if (!(atk.flags & FL_CLIENT))
		return;

	style = atk.melee_style;
	if (style < 1)
		return;

	if (style == 1)
	{
		ThrowGib ("progs/gib1.mdl", -80);
		ThrowGib ("progs/gib2.mdl", -80);
		if (Q2M_ModelsOk ())
			Q2M_ExtraGibs ();
		SpawnBlood (self.origin + '0 0 24', '0 0 80', 30);
	}
	else if (style == 2)
	{
		ThrowGib ("progs/gib1.mdl", -90);
		ThrowGib ("progs/gib2.mdl", -90);
		ThrowGib ("progs/gib3.mdl", -90);
		ThrowGib ("progs/gib1.mdl", -90);
		if (Q2M_ModelsOk ())
		{
			Q2M_ExtraGibs ();
			Q2M_ExtraGibs ();
		}
		SpawnMeatSpray (self.origin, '0 0 140');
		SpawnMeatSpray (self.origin + '8 8 16', '80 -40 80');
		SpawnBlood (self.origin, '0 0 100', 50);
	}
	else if (style == 3)
	{
		kick = self.origin - atk.origin;
		kick_z = 0;
		if (vlen (kick) < 1)
			kick = '1 0 0';
		kick = normalize (kick);
		self.velocity = kick * 700 + '0 0 380';
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		ThrowGib ("progs/gib3.mdl", -110);
		ThrowGib ("progs/gib2.mdl", -110);
		if (Q2M_ModelsOk ())
			Q2M_ExtraGibs ();
		SpawnBlood (self.origin, '40 0 60', 40);
	}

	if (atk.melee_glory)
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

	BQA_ThrowViscera (-80);
};

void() BQA_OnKilledExtra =
{
	local entity atk;

	SpawnBlood (self.origin, '0 0 90', 55);
	SpawnBlood (self.origin + '8 0 16', '40 0 40', 35);
	SpawnBlood (self.origin + '-8 8 8', '0 40 50', 25);
	SpawnBlood (self.origin + '0 -8 20', '20 20 70', 30);
	particle (self.origin, '0 0 60', 73, 110);
	particle (self.origin, '0 0 40', 225, 40);
	particle (self.origin, '20 0 50', 73, 50);
	BQA_SplatterAt (self.origin, '0 0 -1', TRUE);
	BQA_ThrowViscera (-60);
	if (self.health <= -40 && Q2M_ModelsOk ())
		Q2M_ExtraGibs ();

	BQA_MeleeDismember ();
	BQA_MeleeGlorySip ();

	atk = self.enemy;
	if (atk.classname == "player" && atk.melee_glory)
		BQA_PulseSlowmo (atk);

	if (self.enemy != world)
	{
		self.enemy.melee_glory = 0;
		self.enemy.melee_style = 0;
	}

	if (self.health <= -40)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		sound (self, CHAN_BODY, "player/axhit1.wav", 1, ATTN_NORM);
		if (atk.classname == "player" && atk.super_damage_finished > time)
		{
			particle (self.origin, '0 0 120', 73, 80);
			particle (self.origin, '0 0 80', 225, 60);
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_EXPLOSION);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
		}
		if ((self.flags & FL_MONSTER) && cvar("brutal_nogibchain") == 0)
		{
			if (atk == world)
				atk = self;
			T_RadiusDamage (self, atk, 20, self);
		}
		BQA_DropCarnageVial ();
	}

	BQA_SetupCorpse ();
};

void() BQA_DnumThink =
{
	if (time >= self.ltime || self.origin_z <= self.wait)
	{
		BQA_UnlinkDnum (self);
		remove (self);
		return;
	}
	self.velocity_z = self.velocity_z - 6;
	self.nextthink = time + 0.05;
};

void(vector org, float digit, float floor_z) BQA_SpawnDigit =
{
	local entity new;
	local entity e;

	new = spawn ();
	new.classname = "bqa_dnum";
	new.movetype = MOVETYPE_FLY;
	new.solid = SOLID_NOT;
	setmodel (new, "progs/bqa_dnum.spr");
	new.frame = digit;
	setsize (new, '0 0 0', '0 0 0');
	setorigin (new, org);
	new.velocity = '0 0 40';
	new.wait = (org_z + floor_z) * 0.5;
	new.ltime = time + 1.5;
	new.think = BQA_DnumThink;
	new.nextthink = time + 0.05;
	new.bqa_next = world;
	if (bqa_numdnums >= 16)
	{
		e = bqa_dnums;
		if (e != world)
		{
			BQA_UnlinkDnum (e);
			remove (e);
		}
	}
	if (bqa_dnums == world)
		bqa_dnums = new;
	else
		bqa_lastdnum.bqa_next = new;
	bqa_lastdnum = new;
	bqa_numdnums = bqa_numdnums + 1;
};

void(entity targ, float take) BQA_ShowDamNum =
{
	local float n;
	local float hun;
	local float ten;
	local float one;
	local float floor_z;
	local vector org;

	if (targ == world)
		return;
	n = floor (take);
	if (n < 1)
		return;
	if (n > 999)
		n = 999;
	hun = floor (n / 100);
	ten = floor ((n - (hun * 100)) / 10);
	one = n - (hun * 100) - (ten * 10);
	org = targ.origin;
	org_z = targ.absmax_z + 8;
	floor_z = targ.absmin_z;
	if (hun > 0)
	{
		BQA_SpawnDigit (org - '4 0 0', hun, floor_z);
		BQA_SpawnDigit (org, ten, floor_z);
		BQA_SpawnDigit (org + '4 0 0', one, floor_z);
	}
	else if (ten > 0)
	{
		BQA_SpawnDigit (org - '2 0 0', ten, floor_z);
		BQA_SpawnDigit (org + '2 0 0', one, floor_z);
	}
	else
		BQA_SpawnDigit (org, one, floor_z);
};

void(entity targ, entity inflictor, entity attacker, float take) BQA_OnDamageFX =
{
	if (take < 1)
		return;

	if (attacker == world)
		return;
	if (!(attacker.flags & FL_CLIENT))
		return;
	if (targ == attacker)
		return;
	if (!((targ.flags & FL_MONSTER) || (targ.flags & FL_CLIENT)))
		return;

	BQA_ShowDamNum (targ, take);
};

void() BQA_SawTouch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.has_chainsaw)
		return;

	other.has_chainsaw = 1;
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	centerprint (other, "You got the Chainsaw\n");
	sprint (other, "You got the Chainsaw\n");
	remove (self);
};

void() BQA_DropChainsaw =
{
	local entity saw;

	saw = spawn ();
	saw.classname = "item_chainsaw";
	saw.movetype = MOVETYPE_TOSS;
	saw.solid = SOLID_TRIGGER;
	saw.origin = self.origin + '0 0 24';
	saw.velocity = '0 0 200';
	saw.touch = BQA_SawTouch;
	saw.nextthink = time + 60;
	saw.think = SUB_Remove;
	setmodel (saw, "progs/g_rock2.mdl");
	setsize (saw, '-16 -16 0', '16 16 56');
};

void() BQA_MjolnirTouch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.has_mjolnir)
		return;

	other.has_mjolnir = 1;
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	centerprint (other, "You got the Hammer\n");
	sprint (other, "You got the Hammer\n");
	remove (self);
};

void() BQA_DropMjolnir =
{
	local entity ham;

	ham = spawn ();
	ham.classname = "item_mjolnir";
	ham.movetype = MOVETYPE_TOSS;
	ham.solid = SOLID_TRIGGER;
	ham.origin = self.origin + '0 0 24';
	ham.velocity = '0 0 200';
	ham.touch = BQA_MjolnirTouch;
	ham.nextthink = time + 60;
	ham.think = SUB_Remove;
	setmodel (ham, "progs/g_hammer.mdl");
	setsize (ham, '-16 -16 0', '16 16 56');
};

void() BQA_FireOffhandProx =
{
	local entity missile;

	if (self.health <= 0)
		return;
	if (self.ammo_rockets < 1)
		return;

	self.ammo_rockets = self.ammo_rockets - 1;
	if (self.weapon == IT_GRENADE_LAUNCHER || self.weapon == IT_ROCKET_LAUNCHER)
		self.currentammo = self.ammo_rockets;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;

	makevectors (self.v_angle);
	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "proximity_grenade";
	missile.velocity = v_forward * 600 + v_up * 200;
	missile.avelocity = '100 600 100';
	missile.angles = vectoangles (missile.velocity);
	missile.touch = BQA_ProxTouch;
	missile.nextthink = time + 1.2;
	missile.think = BQA_ProxThink;
	missile.attack_finished = time + 12;
	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward * 16 + '0 0 16');
};

void() BQA_ExplSpriteThink =
{
	self.frame = self.frame + 1;
	if (self.frame > 5)
	{
		remove (self);
		return;
	}
	self.nextthink = time + 0.05;
};

float(entity e) BQA_IsFlesh =
{
	if (e == world)
		return FALSE;
	if (e.flags & FL_MONSTER)
		return TRUE;
	if (e.flags & FL_CLIENT)
		return TRUE;
	return FALSE;
};

void() BQA_ExplosionFX =
{
	local entity e;
	local float i;
	local float flesh;
	local vector org;

	org = self.origin;
	flesh = BQA_IsFlesh (self);
	particle (org, '0 0 90', 225, 80);
	particle (org, '0 0 40', 225, 50);
	particle (org, '0 0 120', 0, 60);
	particle (org + '0 0 12', '20 0 80', 0, 40);

	i = 0;
	while (i < 2)
	{
		e = spawn ();
		e.movetype = MOVETYPE_NONE;
		e.solid = SOLID_NOT;
		e.origin = org;
		e.origin_x = org_x + (random() - 0.5) * 24;
		e.origin_y = org_y + (random() - 0.5) * 24;
		e.origin_z = org_z + random() * 10;
		setmodel (e, "progs/s_explod.spr");
		setorigin (e, e.origin);
		e.frame = 0;
		e.nextthink = time + 0.05;
		e.think = BQA_ExplSpriteThink;
		i = i + 1;
	}

	i = 0;
	while (i < 7)
	{
		if (i < 3 || flesh)
		{
			e = spawn ();
			e.classname = "expl_debris";
			e.movetype = MOVETYPE_BOUNCE;
			e.solid = SOLID_NOT;
			e.velocity_x = (random() - 0.5) * 420;
			e.velocity_y = (random() - 0.5) * 420;
			e.velocity_z = 140 + random() * 280;
			e.avelocity = '300 400 200';
			if (i < 3)
				setmodel (e, "progs/s_spike.mdl");
			else if (i < 5)
				setmodel (e, "progs/gib1.mdl");
			else
				setmodel (e, "progs/gib3.mdl");
			setsize (e, '0 0 0', '0 0 0');
			setorigin (e, org);
			e.nextthink = time + 1.8 + random();
			e.think = SUB_Remove;
		}
		i = i + 1;
	}
};

void(string mdl, float spd) BQA_ThrowDebris =
{
	local entity e;

	e = spawn ();
	e.classname = "expl_debris";
	e.movetype = MOVETYPE_BOUNCE;
	e.solid = SOLID_NOT;
	e.velocity_x = (random () - 0.5) * spd * 420;
	e.velocity_y = (random () - 0.5) * spd * 420;
	e.velocity_z = 160 + random () * 320;
	e.avelocity = '400 500 300';
	setmodel (e, mdl);
	setsize (e, '0 0 0', '0 0 0');
	setorigin (e, self.origin);
	e.nextthink = time + 2.5 + random ();
	e.think = SUB_Remove;
};

void(entity atk) BQA_BarrelBoom =
{
	if (atk == world)
		atk = self;
	T_RadiusDamage (self, atk, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);
	self.origin_z = self.origin_z + 32;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() BQA_ProxExplode =
{
	local float rad;

	rad = 120;
	if (self.owner != world)
	{
		if (self.owner.super_damage_finished > time || self.owner.invincible_finished > time)
			rad = 180;
	}
	T_RadiusDamage (self, self.owner, rad, self);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BQA_ExplosionFX ();
	if (rad > 120)
		BQA_ExplosionFX ();
	remove (self);
};

void() BQA_ProxTouch =
{
	if (other == self.owner)
		return;
	if (other.takedamage && ((other.flags & FL_MONSTER) || (other.flags & FL_CLIENT)))
		BQA_ProxExplode ();
};

void() BQA_ProxThink =
{
	local entity head;
	local entity e;

	if (time > self.attack_finished)
	{
		BQA_ProxExplode ();
		return;
	}

	head = findradius (self.origin, 80);
	while (head)
	{
		e = head;
		head = head.chain;
		if (e != self.owner && e.health > 0)
		{
			if ((e.flags & FL_MONSTER) || (e.flags & FL_CLIENT))
			{
				if (vlen (e.origin - self.origin) < 80)
				{
					BQA_ProxExplode ();
					return;
				}
			}
		}
	}

	self.nextthink = time + 0.2;
	self.think = BQA_ProxThink;
};

void() BQA_EjectCasing =
{
	local entity c;

	makevectors (self.v_angle);
	c = spawn ();
	c.classname = "shell_casing";
	c.movetype = MOVETYPE_BOUNCE;
	c.solid = SOLID_NOT;
	c.velocity = v_right * (80 + random() * 40) + v_up * (80 + random() * 40) + v_forward * 20;
	c.avelocity = '200 400 100';
	c.nextthink = time + 20;
	c.think = SUB_Remove;
	setmodel (c, "progs/s_spike.mdl");
	setsize (c, '0 0 0', '0 0 0');
	setorigin (c, self.origin + '0 0 16' + v_right * 8 + v_forward * 12);
};

void(float force) BQA_Recoil =
{
	makevectors (self.v_angle);
	self.velocity = self.velocity - v_forward * force;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
};

void(entity first, float dmg) BQA_ChainLightning =
{
	local entity head;
	local entity e;
	local float n;

	if (first == world)
		return;

	n = 0;
	head = findradius (first.origin, 180);
	while (head)
	{
		e = head;
		head = head.chain;
		if (n < 3 && e != first && e != self && e.health > 0)
		{
			if ((e.flags & FL_MONSTER) || (e.flags & FL_CLIENT))
			{
				if (!(teamplay && (e.flags & FL_CLIENT) && e.team > 0 && e.team == self.team))
				{
					traceline (first.origin + '0 0 16', e.origin + '0 0 16', TRUE, first);
					if (trace_fraction == 1 || trace_ent == e)
					{
						WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
						WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
						WriteEntity (MSG_BROADCAST, first);
						WriteCoord (MSG_BROADCAST, first.origin_x);
						WriteCoord (MSG_BROADCAST, first.origin_y);
						WriteCoord (MSG_BROADCAST, first.origin_z + 16);
						WriteCoord (MSG_BROADCAST, e.origin_x);
						WriteCoord (MSG_BROADCAST, e.origin_y);
						WriteCoord (MSG_BROADCAST, e.origin_z + 16);
						T_Damage (e, self, self, dmg * 0.45);
						n = n + 1;
					}
				}
			}
		}
	}
};

void() BQA_RadiusShake =
{
	if (!(self.flags & FL_CLIENT))
		return;
	self.punchangle_x = self.punchangle_x - 8;
	self.punchangle_z = self.punchangle_z + (random() - 0.5) * 6;
};

#ifndef BQA_HAS_VORELINGS
void() BQA_TryVorelings =
{
};
#endif

void() BQA_MaybeElite =
{
	if (deathmatch)
		return;
	if (self.bqa_elite)
		return;
	if (!(self.flags & FL_MONSTER))
		return;
	if (self.classname == "monster_oldone")
		return;
	if (self.classname == "monster_boss")
		return;
	if (random() >= 0.08)
		return;

	self.bqa_elite = 1;
	self.health = self.health * 1.5;
	self.max_health = self.health;
	self.effects = self.effects | EF_QUADLIGHT;
};

void() BQA_AxeTouch =
{
	if (other == self.owner)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	if (other.takedamage)
	{
		SpawnBlood (other.origin, '0 0 0', 25);
		T_Damage (other, self, self.owner, 25);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	remove (self);
};

void() BQA_KnightThrowAxe =
{
	local entity axe;
	local vector dir;

	if (self.enemy == world)
		return;
	dir = (self.enemy.origin + '0 0 16') - (self.origin + '0 0 20');
	if (vlen (dir) < 80)
		return;
	dir = normalize (dir);

	sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	axe = spawn ();
	axe.classname = "knight_axe";
	axe.owner = self;
	axe.movetype = MOVETYPE_FLYMISSILE;
	axe.solid = SOLID_BBOX;
	axe.velocity = dir * 700;
	if (self.bqa_elite)
		axe.velocity = axe.velocity * 1.25;
	axe.avelocity = '300 400 200';
	axe.angles = vectoangles (axe.velocity);
	axe.touch = BQA_AxeTouch;
	axe.think = SUB_Remove;
	axe.nextthink = time + 3;
	setmodel (axe, "progs/spike.mdl");
	setsize (axe, '0 0 0', '0 0 0');
	setorigin (axe, self.origin + '0 0 20' + dir * 16);
};

float(entity inflictor, entity attacker) BQA_IsCook =
{
	if (inflictor.classname == "missile")
		return TRUE;
	if (inflictor.classname == "grenade")
		return TRUE;
	if (inflictor.classname == "ogre_grenade")
		return TRUE;
	if (inflictor.classname == "proximity_grenade")
		return TRUE;
	if (attacker.weapon == IT_LIGHTNING)
		return TRUE;
	return FALSE;
};

float(entity targ, vector hit, float dmg) BQA_HeadshotDamage =
{
	local float top;

	if (deathmatch)
		return dmg;
	if (targ == world)
		return dmg;
	if (!(targ.flags & FL_MONSTER))
		return dmg;
	if (targ.classname == "monster_oldone")
		return dmg;
	if (targ.classname == "monster_boss")
		return dmg;

	top = targ.origin_z + targ.maxs_z;
	if (hit_z < top - targ.size_z * 0.45)
		return dmg;

	targ.bqa_headshot = 1;
	return dmg * 1.5;
};

float() BQA_CrushRadius =
{
	if (self.owner == world)
		return 120;
	if (self.owner.super_damage_finished > time)
		return 180;
	if (self.owner.invincible_finished > time)
		return 180;
	return 120;
};

void() BQA_CarnageTouch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (!T_Heal (other, 10, 0))
		return;
	sound (other, CHAN_ITEM, "items/n_health.wav", 1, ATTN_NORM);
	remove (self);
};

void() BQA_DropCarnageVial =
{
	local entity v;

	if (deathmatch)
		return;
	if (!(self.flags & FL_MONSTER))
		return;
	if (random() >= 0.2)
		return;

	v = spawn ();
	v.classname = "item_carnage";
	v.movetype = MOVETYPE_TOSS;
	v.solid = SOLID_TRIGGER;
	v.origin = self.origin + '0 0 24';
	v.velocity = '0 0 180';
	v.touch = BQA_CarnageTouch;
	v.nextthink = time + 15;
	v.think = SUB_Remove;
	setmodel (v, "maps/b_bh10.bsp");
	setsize (v, '-8 -8 0', '8 8 16');
	setorigin (v, v.origin);
};

void() BQA_ClearSlowmo =
{
	stuffcmd (self, "slowmo 1\n");
};

void(entity atk) BQA_PulseSlowmo =
{
	local entity h;

	if (atk.classname != "player")
		return;
	if (!atk.melee_glory)
		return;

	h = find (world, classname, "bqa_slowmo");
	while (h != world)
	{
		if (h.owner == atk)
			return;
		h = find (h, classname, "bqa_slowmo");
	}

	stuffcmd (atk, "slowmo 0.35\n");
	h = spawn ();
	h.classname = "bqa_slowmo";
	h.owner = atk;
	h.nextthink = time + 0.25;
	h.think = BQA_ResetSlowmo;
};

void() BQA_ResetSlowmo =
{
	if (self.owner.classname == "player")
		stuffcmd (self.owner, "slowmo 1\n");
	remove (self);
};
