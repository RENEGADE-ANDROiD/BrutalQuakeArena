// Combat Plus-style extras that work in remaster QuakeC

void(string gibname, float dm) ThrowGib;
void(string gibname, float dm) ThrowHead;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void(vector org, vector vel) SpawnMeatSpray;
float(entity e, float healamount, float ignore) T_Heal;
void() W_SetCurrentAmmo;
void() SUB_Remove;
void() SUB_Null;
void() CP_ProxTouch;
void() CP_ProxThink;
void() CP_ProxExplode;
void() CP_ExplosionFX;
void() CP_ResetSlowmo;
void() CP_AxeTouch;
void() CP_CarnageTouch;
void() CP_DropCarnageVial;

void() CP_GibThink =
{
	if (time > self.ltime)
	{
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

void() CP_GibCorpse =
{
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowGib ("progs/gib1.mdl", -60);
	ThrowGib ("progs/gib2.mdl", -60);
	ThrowGib ("progs/gib3.mdl", -60);
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_TOSS;
	setmodel (self, string_null);
	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
};

void() CP_FleshSplat =
{
	local float r;

	if (self.health <= 0)
		return;
	if (!((self.flags & FL_MONSTER) || (self.flags & FL_CLIENT)))
		return;

	r = random ();
	if (r < 0.33)
		ThrowGib ("progs/gib1.mdl", -20);
	else if (r < 0.66)
		ThrowGib ("progs/gib2.mdl", -20);
	else
		ThrowGib ("progs/gib3.mdl", -20);
};

void() CP_MakePuddle =
{
	local entity p;

	p = spawn ();
	p.classname = "blood_puddle";
	p.movetype = MOVETYPE_NONE;
	p.solid = SOLID_NOT;
	p.origin = self.origin;
	setmodel (p, "progs/gib1.mdl");
	setsize (p, '0 0 0', '0 0 0');
	p.angles = '90 0 0';
	p.avelocity = '0 0 0';
	setorigin (p, self.origin);
	traceline (p.origin + '0 0 8', p.origin - '0 0 256', TRUE, p);
	if (trace_fraction < 1)
		setorigin (p, trace_endpos);
	particle (self.origin, '0 0 20', 73, 40);
	p.nextthink = time + 40;
	p.think = SUB_Remove;
};

void(entity attacker, float damage) CP_CorpsePain =
{
	local vector dir;

	if (attacker != world)
	{
		dir = self.origin - attacker.origin;
		if (vlen (dir) < 1)
			dir = '0 0 8';
		dir = normalize (dir);
		self.velocity = dir * 420 + '0 0 280';
		self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	CP_GibCorpse ();
};

void() CP_CorpseReady =
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
	corpse.th_die = CP_GibCorpse;
	corpse.th_pain = CP_CorpsePain;
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

void() CP_SetupCorpse =
{
	local entity h;

	if (self.health <= -40)
		return;
	if (!((self.flags & FL_MONSTER) || (self.classname == "player")))
		return;

	CP_MakePuddle ();

	h = spawn ();
	h.classname = "corpse_setup";
	h.owner = self;
	h.nextthink = time + 1.8;
	h.think = CP_CorpseReady;
};

void() CP_MeleeGlorySip =
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

void() CP_MeleeDismember =
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
		SpawnBlood (self.origin + '0 0 24', '0 0 80', 30);
	}
	else if (style == 2)
	{
		ThrowGib ("progs/gib1.mdl", -90);
		ThrowGib ("progs/gib2.mdl", -90);
		ThrowGib ("progs/gib3.mdl", -90);
		ThrowGib ("progs/gib1.mdl", -90);
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
		SpawnBlood (self.origin, '40 0 60', 40);
	}

	if (atk.melee_glory)
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
};

void() CP_OnKilledExtra =
{
	local entity h;
	local entity atk;

	SpawnBlood (self.origin, '0 0 90', 55);
	SpawnBlood (self.origin + '8 0 16', '40 0 40', 35);
	SpawnBlood (self.origin + '-8 8 8', '0 40 50', 25);
	particle (self.origin, '0 0 60', 73, 110);
	particle (self.origin, '0 0 40', 225, 40);

	CP_MeleeDismember ();
	CP_MeleeGlorySip ();

	atk = self.enemy;
	if (self.health <= -40)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		sound (self, CHAN_BODY, "player/axhit1.wav", 1, ATTN_NORM);
		if (atk.classname == "player")
		{
			stuffcmd (atk, "slowmo 0.35\n");
			h = spawn ();
			h.owner = atk;
			h.nextthink = time + 0.45;
			h.think = CP_ResetSlowmo;
			if (atk.super_damage_finished > time)
			{
				particle (self.origin, '0 0 120', 73, 80);
				particle (self.origin, '0 0 80', 225, 60);
				WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
				WriteByte (MSG_BROADCAST, TE_EXPLOSION);
				WriteCoord (MSG_BROADCAST, self.origin_x);
				WriteCoord (MSG_BROADCAST, self.origin_y);
				WriteCoord (MSG_BROADCAST, self.origin_z);
			}
		}
		if ((self.flags & FL_MONSTER) && cvar("brutal_nogibchain") == 0)
		{
			if (atk == world)
				atk = self;
			T_RadiusDamage (self, atk, 20, self);
		}
		CP_DropCarnageVial ();
	}

	if (self.enemy != world)
	{
		self.enemy.melee_glory = 0;
		self.enemy.melee_style = 0;
	}

	CP_SetupCorpse ();
};

void() CP_SawTouch =
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

void() CP_DropChainsaw =
{
	local entity saw;

	saw = spawn ();
	saw.classname = "item_chainsaw";
	saw.movetype = MOVETYPE_TOSS;
	saw.solid = SOLID_TRIGGER;
	saw.origin = self.origin + '0 0 24';
	saw.velocity = '0 0 200';
	saw.touch = CP_SawTouch;
	saw.nextthink = time + 60;
	saw.think = SUB_Remove;
	setmodel (saw, "progs/g_rock2.mdl");
	setsize (saw, '-16 -16 0', '16 16 56');
};

void() CP_MjolnirTouch =
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

void() CP_DropMjolnir =
{
	local entity ham;

	ham = spawn ();
	ham.classname = "item_mjolnir";
	ham.movetype = MOVETYPE_TOSS;
	ham.solid = SOLID_TRIGGER;
	ham.origin = self.origin + '0 0 24';
	ham.velocity = '0 0 200';
	ham.touch = CP_MjolnirTouch;
	ham.nextthink = time + 60;
	ham.think = SUB_Remove;
	setmodel (ham, "progs/g_hammer.mdl");
	setsize (ham, '-16 -16 0', '16 16 56');
};

void() CP_FireOffhandProx =
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
	missile.touch = CP_ProxTouch;
	missile.nextthink = time + 1.2;
	missile.think = CP_ProxThink;
	missile.attack_finished = time + 12;
	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward * 16 + '0 0 16');
};

void() CP_ExplSpriteThink =
{
	self.frame = self.frame + 1;
	if (self.frame > 5)
	{
		remove (self);
		return;
	}
	self.nextthink = time + 0.05;
};

void() CP_ExplosionFX =
{
	local entity e;
	local float i;
	local vector org;

	org = self.origin;
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
		e.scale = 1.8 + random() * 0.8;
		e.frame = 0;
		e.nextthink = time + 0.05;
		e.think = CP_ExplSpriteThink;
		i = i + 1;
	}

	i = 0;
	while (i < 7)
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
		e.scale = 0.45 + random() * 0.35;
		setsize (e, '0 0 0', '0 0 0');
		setorigin (e, org);
		e.nextthink = time + 1.8 + random();
		e.think = SUB_Remove;
		i = i + 1;
	}
};

void() CP_ProxExplode =
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
	CP_ExplosionFX ();
	if (rad > 120)
		CP_ExplosionFX ();
	remove (self);
};

void() CP_ProxTouch =
{
	if (other == self.owner)
		return;
	if (other.takedamage && ((other.flags & FL_MONSTER) || (other.flags & FL_CLIENT)))
		CP_ProxExplode ();
};

void() CP_ProxThink =
{
	local entity head;
	local entity e;

	if (time > self.attack_finished)
	{
		CP_ProxExplode ();
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
					CP_ProxExplode ();
					return;
				}
			}
		}
	}

	self.nextthink = time + 0.2;
	self.think = CP_ProxThink;
};

void() CP_EjectCasing =
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

void(float force) CP_Recoil =
{
	makevectors (self.v_angle);
	self.velocity = self.velocity - v_forward * force;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
};

void(entity first, float dmg) CP_ChainLightning =
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

void() CP_RadiusShake =
{
	if (!(self.flags & FL_CLIENT))
		return;
	self.punchangle_x = self.punchangle_x - 8;
	self.punchangle_z = self.punchangle_z + (random() - 0.5) * 6;
};

#ifndef CP_HAS_VORELINGS
void() CP_TryVorelings =
{
};
#endif

void() CP_MaybeElite =
{
	if (deathmatch)
		return;
	if (self.cp_elite)
		return;
	if (!(self.flags & FL_MONSTER))
		return;
	if (self.classname == "monster_oldone")
		return;
	if (self.classname == "monster_boss")
		return;
	if (random() >= 0.08)
		return;

	self.cp_elite = 1;
	self.health = self.health * 1.5;
	self.max_health = self.health;
	self.effects = self.effects | EF_QUADLIGHT;
};

void() CP_AxeTouch =
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

void() CP_KnightThrowAxe =
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
	if (self.cp_elite)
		axe.velocity = axe.velocity * 1.25;
	axe.avelocity = '300 400 200';
	axe.angles = vectoangles (axe.velocity);
	axe.touch = CP_AxeTouch;
	axe.think = SUB_Remove;
	axe.nextthink = time + 3;
	setmodel (axe, "progs/spike.mdl");
	setsize (axe, '0 0 0', '0 0 0');
	setorigin (axe, self.origin + '0 0 20' + dir * 16);
};

float(entity inflictor, entity attacker) CP_IsCook =
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

float(entity targ, vector hit, float dmg) CP_HeadshotDamage =
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

	targ.cp_headshot = 1;
	return dmg * 1.5;
};

float() CP_CrushRadius =
{
	if (self.owner == world)
		return 120;
	if (self.owner.super_damage_finished > time)
		return 180;
	if (self.owner.invincible_finished > time)
		return 180;
	return 120;
};

void() CP_CarnageTouch =
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

void() CP_DropCarnageVial =
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
	v.touch = CP_CarnageTouch;
	v.nextthink = time + 15;
	v.think = SUB_Remove;
	setmodel (v, "maps/b_bh10.bsp");
	setsize (v, '-8 -8 0', '8 8 16');
	setorigin (v, v.origin);
};

void() CP_ResetSlowmo =
{
	if (self.owner.classname == "player")
		stuffcmd (self.owner, "slowmo 1\n");
	remove (self);
};
