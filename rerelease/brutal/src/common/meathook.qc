// Dedicated meathook (impulse 52): latch onto world or enemies and zip.

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(vector org, vector vel, float damage) SpawnBlood;

void() MeatHookRemove;
void() MeatHookPull;
void() MeatHookMiss;
void() MeatHookTouch;
void(entity ply) W_MeleeHitFeel;

void() W_MeathookRelease =
{
	local entity h;

	h = self.meat_hook;
	if (h != world)
	{
		self.meat_hook = world;
		self.meat_hooked = 0;
		self.meat_hook_cd = time + 0.3;
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
	remove (self);
};

void() MeatHookMiss =
{
	MeatHookRemove ();
};

void() MeatHookPull =
{
	local entity ply;
	local vector dir;
	local float dist;

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

	if (self.enemy != world)
	{
		if (self.enemy.health <= 0)
		{
			MeatHookRemove ();
			return;
		}
		setorigin (self, self.enemy.origin + '0 0 16');
	}

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

	self.nextthink = time + 0.05;
	self.think = MeatHookPull;
};

void() MeatHookTouch =
{
	local entity ply;

	if (other == self.owner)
		return;
	if (other.classname == "meathook")
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
		setorigin (self, other.origin + '0 0 16');
	}
	else
	{
		self.enemy = world;
		sound (self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
		setorigin (self, self.origin);
	}
};

void() W_FireMeathook =
{
	local entity hook;
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
	hook.think = MeatHookMiss;
	hook.nextthink = time + 0.4;
	hook.effects = EF_DIMLIGHT;
	setmodel (hook, "progs/hook.mdl");
	setsize (hook, '-4 -4 -4', '4 4 4');
	setorigin (hook, org + v_forward * 16);

	self.meat_hook = hook;
	self.meat_hooked = 0;
};
