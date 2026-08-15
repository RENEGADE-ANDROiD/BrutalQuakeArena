// Combat Plus-style extras that work in remaster QuakeC

void(string gibname, float dm) ThrowGib;
void(string gibname, float dm) ThrowHead;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() W_SetCurrentAmmo;
void() SUB_Remove;
void() SUB_Null;
void() CP_ProxTouch;
void() CP_ProxThink;
void() CP_ProxExplode;
void() CP_ResetSlowmo;

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
	corpse.solid = SOLID_BBOX;
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

void() CP_OnKilledExtra =
{
	local entity h;

	SpawnBlood (self.origin, '0 0 90', 40);
	SpawnBlood (self.origin + '8 0 16', '40 0 40', 25);
	particle (self.origin, '0 0 60', 73, 80);

	if (self.health <= -40)
	{
		if (self.enemy.classname == "player")
		{
			stuffcmd (self.enemy, "slowmo 0.35\n");
			h = spawn ();
			h.owner = self.enemy;
			h.nextthink = time + 0.45;
			h.think = CP_ResetSlowmo;
		}
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

void() CP_ProxExplode =
{
	T_RadiusDamage (self, self.owner, 120, self);
	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
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

void() CP_WoundedThink =
{
	if (self.health > 30)
		return;
	if (time < self.wounded_next)
		return;

	if (self.health <= 15)
	{
		self.wounded_next = time + 0.45;
		self.punchangle_x = self.punchangle_x + (random() - 0.5) * 6;
		self.punchangle_y = self.punchangle_y + (random() - 0.5) * 4;
		sound (self, CHAN_VOICE, "player/lburn1.wav", 0.35, ATTN_NORM);
	}
	else
	{
		self.wounded_next = time + 0.8;
		self.punchangle_x = self.punchangle_x + (random() - 0.5) * 3;
		self.punchangle_y = self.punchangle_y + (random() - 0.5) * 2;
		sound (self, CHAN_VOICE, "player/lburn1.wav", 0.2, ATTN_NORM);
	}
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

void() CP_ResetSlowmo =
{
	if (self.owner.classname == "player")
		stuffcmd (self.owner, "slowmo 1\n");
	remove (self);
};
