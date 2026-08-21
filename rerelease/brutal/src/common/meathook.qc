// Dedicated meathook (impulse 52): latch onto world or enemies and zip.

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(vector org, vector vel, float damage) SpawnBlood;

void() MeatHookRemove;
void() MeatHookPull;
void() MeatHookMiss;
void() MeatHookTouch;
void() MeatHookFly;
void() MeatHookSpawnChain;
void() MeatHookUpdateChain;
void() MeatHookFreeChain;
void(entity ply) W_MeleeHitFeel;
entity(vector org) BQA_BiggestGibNear;

void() MeatHookFreeChain =
{
	local entity e;
	local entity n;

	e = self.goalentity;
	self.goalentity = world;
	while (e != world)
	{
		n = e.bqa_next;
		remove (e);
		e = n;
	}
};

void() MeatHookUpdateChain =
{
	local entity ply;
	local entity e;
	local vector start;
	local vector dir;
	local vector org;
	local float i;
	local float extra;

	ply = self.owner;
	if (ply == world)
		return;

	makevectors (ply.v_angle);
	start = ply.origin + v_forward * 8 - v_up * 8;
	start_z = start_z + 8;
	dir = self.origin - start;

	extra = 55 + ply.v_angle_x;
	if (extra < 15)
		extra = 15;
	if (extra > 70)
		extra = 70;

	e = self.goalentity;
	i = 1;
	while (e != world)
	{
		org = start + dir * (i / 15);
		e.angles = vectoangles (dir);
		e.angles_x = e.angles_x + extra;
		setorigin (e, org);
		e = e.bqa_next;
		i = i + 1;
	}
};

void() MeatHookSpawnChain =
{
	local entity e;
	local entity prev;
	local float i;

	prev = world;
	i = 0;
	while (i < 14)
	{
		e = spawn ();
		e.classname = "hook_chain";
		e.movetype = MOVETYPE_NONE;
		e.solid = SOLID_NOT;
		e.owner = self;
		setmodel (e, "progs/bqa_chain.spr");
		e.scale = 1;
		setsize (e, '0 0 0', '0 0 0');
		if (prev == world)
			self.goalentity = e;
		else
			prev.bqa_next = e;
		prev = e;
		i = i + 1;
	}
	MeatHookUpdateChain ();
};

void() W_MeathookRelease =
{
	local entity h;
	local entity old;

	h = self.meat_hook;
	if (h != world)
	{
		self.meat_hook = world;
		self.meat_hooked = 0;
		self.meat_hook_cd = time + 0.3;
		old = self;
		self = h;
		MeatHookFreeChain ();
		self = old;
		remove (h);
	}
};

void() MeatHookRemove =
{
	local entity ply;

	ply = self.owner;
	if (ply != world)
	{
		if (ply.meat_hook == self)
		{
			ply.meat_hook = world;
			ply.meat_hooked = 0;
			ply.meat_hook_cd = time + 0.3;
		}
	}
	MeatHookFreeChain ();
	remove (self);
};

void() MeatHookMiss =
{
	MeatHookRemove ();
};

float(entity prey) MeatHookYankable =
{
	if (prey == world)
		return FALSE;
	if (!(prey.flags & FL_MONSTER))
		return FALSE;
	if (prey.health <= 0)
		return FALSE;
	if (prey.classname == "monster_oldone")
		return FALSE;
	if (prey.classname == "monster_boss")
		return FALSE;
	if (prey.classname == "monster_ogre")
		return FALSE;
	if (prey.classname == "monster_ogre_marksman")
		return FALSE;
	if (prey.classname == "monster_shambler")
		return FALSE;
	if (prey.classname == "monster_shalrath")
		return FALSE;
	if (prey.classname == "monster_q2tank")
		return FALSE;
	if (prey.classname == "monster_q2shamstr")
		return FALSE;
	if (prey.classname == "monster_q2shamacud")
		return FALSE;
	if (prey.classname == "monster_q2vorestr")
		return FALSE;
	if (prey.classname == "monster_q2ironvore")
		return FALSE;
	return TRUE;
};

void() MeatHookPull =
{
	local entity ply;
	local entity prey;
	local vector dir;
	local float dist;
	local float yank;

	ply = self.owner;
	if (ply == world || ply.health <= 0)
	{
		MeatHookRemove ();
		return;
	}

	if (time > self.attack_finished)
	{
		MeatHookRemove ();
		return;
	}

	prey = self.enemy;
	if (prey != world)
	{
		if (prey.classname == "gib")
		{
			dir = ply.origin - prey.origin;
			dist = vlen (dir);
			if (dist < 64)
			{
				W_MeleeHitFeel (ply);
				MeatHookRemove ();
				return;
			}

			dir = normalize (dir);
			prey.flags = prey.flags - (prey.flags & FL_ONGROUND);
			prey.velocity = dir * 800;
			prey.velocity_z = prey.velocity_z + 40;
			setorigin (self, prey.origin + '0 0 16');
			MeatHookUpdateChain ();
			self.nextthink = time + 0.05;
			self.think = MeatHookPull;
			return;
		}
		if (prey.health <= 0)
		{
			MeatHookRemove ();
			return;
		}
		setorigin (self, prey.origin + '0 0 16');
	}

	yank = 0;
	if (!deathmatch && MeatHookYankable (prey))
		yank = 1;

	if (yank)
	{
		dir = ply.origin - prey.origin;
		dist = vlen (dir);
		if (dist < 64)
		{
			W_MeleeHitFeel (ply);
			MeatHookRemove ();
			return;
		}

		dir = normalize (dir);
		prey.flags = prey.flags - (prey.flags & FL_ONGROUND);
		prey.velocity = dir * 800;
		prey.velocity_z = prey.velocity_z + 40;
		setorigin (self, prey.origin + '0 0 16');
	}
	else
	{
		dir = self.origin - ply.origin;
		dist = vlen (dir);
		if (dist < 64)
		{
			W_MeleeHitFeel (ply);
			MeatHookRemove ();
			return;
		}

		dir = normalize (dir);
		ply.flags = ply.flags - (ply.flags & FL_ONGROUND);
		ply.velocity = dir * 800;
	}

	MeatHookUpdateChain ();
	self.nextthink = time + 0.05;
	self.think = MeatHookPull;
};

void() MeatHookTouch =
{
	local entity ply;
	local entity chunk;

	if (other == self.owner)
		return;
	if (other.classname == "meathook")
		return;
	if (other.classname == "hook_chain")
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		MeatHookRemove ();
		return;
	}

	ply = self.owner;

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	self.attack_finished = time + 20;
	self.nextthink = time + 0.05;
	self.think = MeatHookPull;

	if (ply != world)
	{
		ply.meat_hooked = 1;
		W_MeleeHitFeel (ply);
	}

	if (other.takedamage)
	{
		self.enemy = other;
		sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
		SpawnBlood (other.origin, '0 0 0', 20);
		T_Damage (other, self, ply, 10);
		if (other.health <= -40)
		{
			chunk = BQA_BiggestGibNear (other.origin);
			if (chunk != world)
				self.enemy = chunk;
		}
		setorigin (self, other.origin + '0 0 16');
	}
	else
	{
		self.enemy = world;
		sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
		setorigin (self, self.origin);
	}

	MeatHookUpdateChain ();
};

void() MeatHookFly =
{
	if (time > self.ltime)
	{
		MeatHookMiss ();
		return;
	}

	MeatHookUpdateChain ();
	self.nextthink = time + 0.05;
	self.think = MeatHookFly;
};

void() W_FireMeathook =
{
	local entity hook;
	local entity old;
	local vector org;

	if (self.health <= 0)
		return;
	if (self.deadflag)
		return;

	if (self.meat_hook != world)
	{
		W_MeathookRelease ();
		return;
	}

	if (time < self.meat_hook_cd)
		return;

	makevectors (self.v_angle);
	org = self.origin + '0 0 16';

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);

	hook = spawn ();
	hook.classname = "meathook";
	hook.owner = self;
	hook.movetype = MOVETYPE_FLYMISSILE;
	hook.solid = SOLID_BBOX;
	hook.angles = vectoangles (v_forward);
	hook.velocity = v_forward * 2000;
	hook.touch = MeatHookTouch;
	hook.ltime = time + 0.4;
	hook.think = MeatHookFly;
	hook.nextthink = time + 0.05;
	hook.effects = EF_DIMLIGHT;
	setmodel (hook, "progs/hook.mdl");
	setsize (hook, '-4 -4 -4', '4 4 4');
	setorigin (hook, org + v_forward * 16);

	self.meat_hook = hook;
	self.meat_hooked = 0;

	old = self;
	self = hook;
	MeatHookSpawnChain ();
	self = old;
};
