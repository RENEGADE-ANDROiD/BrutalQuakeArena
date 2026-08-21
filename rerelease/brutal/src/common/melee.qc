// Dedicated axe melee (impulse 1 or 50)

void() W_Attack;
void() SuperDamageSound;
void() W_SetCurrentAmmo;
void() W_MeathookRelease;
void() W_MeleeLungeThink;
void() W_MeleeDoSwing;
void(entity targ) W_MeleeStartLunge;
void(entity ply, entity targ) W_MeleeAimYaw;
void(entity ply, entity targ) W_MeleeLungeDash;
entity() W_MeleeFindLungeTarget;
float(entity e) RA_IsGhost;

void(entity ply) W_MeleeHitFeel =
{
	if (ply == world)
		return;

	ply.punchangle_x = ply.punchangle_x - 2;
	ply.punchangle_z = ply.punchangle_z + (random() - 0.5) * 2;
};

void(entity ply, entity targ) W_MeleeAimYaw =
{
	local vector dir;

	if (ply == world || targ == world)
		return;

	dir = (targ.origin + '0 0 20') - ply.origin;
	dir_z = 0;
	if (vlen (dir) < 1)
		return;

	ply.angles_y = vectoyaw (dir);
	ply.v_angle_y = ply.angles_y;
	ply.fixangle = TRUE;
};

void(entity ply, entity targ) W_MeleeLungeDash =
{
	local vector dir;
	local float climb;

	if (ply == world || targ == world)
		return;

	dir = (targ.origin + '0 0 20') - ply.origin;
	climb = dir_z;
	dir_z = 0;
	if (vlen (dir) < 1)
		return;
	dir = normalize (dir);

	ply.velocity_x = dir_x * 650;
	ply.velocity_y = dir_y * 650;
	if (climb > 32)
	{
		if (climb > 48)
			climb = 48;
		ply.flags = ply.flags - (ply.flags & FL_ONGROUND);
		ply.velocity_z = climb * 4;
	}
	else
		ply.velocity_z = 0;
};

float(entity targ) W_MeleeIsGlory =
{
	if (deathmatch)
		return FALSE;
	if (targ == world)
		return FALSE;
	if (!(targ.flags & FL_MONSTER))
		return FALSE;
	if (targ.health <= 0 || targ.health > 40)
		return FALSE;
	if (targ.classname == "monster_oldone")
		return FALSE;
	if (targ.classname == "monster_boss")
		return FALSE;
	return TRUE;
};

float(entity targ, float dmg) W_MeleeHitDamage =
{
	local float style;

	style = 1;
	if (self.melee_saw)
		style = 2;
	else if (self.melee_hammer)
		style = 3;
	self.melee_style = style;

	if (self.melee_glory)
	{
		if (targ != world && targ == self.melee_target && (targ.flags & FL_MONSTER) && targ.health > 0)
		{
			if (dmg < targ.health + 55)
				dmg = targ.health + 55;
		}
	}
	else if (self.super_damage_finished > time || self.invincible_finished > time)
	{
		if (targ != world && (targ.flags & FL_MONSTER) && targ.health > 0)
		{
			if (dmg < targ.health + 55)
				dmg = targ.health + 55;
		}
	}

	return dmg;
};

void() W_MeleeClear =
{
	if (!self.melee_active)
		return;

	self.melee_active = 0;
	self.melee_lunge = 0;
	self.melee_target = world;
	self.melee_glory = 0;
	self.melee_style = 0;
	if (self.melee_restore)
		self.weapon = self.melee_restore;
	self.melee_restore = 0;
};

void() W_MeleeRestore =
{
	if (!self.melee_active)
		return;

	W_MeleeClear ();
	W_SetCurrentAmmo ();
};

void() W_MeleeDoSwing =
{
	local float old_af;
	local float tries;

	self.melee_lunge = 0;
	if (self.health <= 0 || self.deadflag)
	{
		W_MeleeRestore ();
		return;
	}

	self.melee_saw = 0;
	self.melee_hammer = 0;
	if (W_MeleeIsGlory (self.melee_target))
		self.melee_glory = 1;
	else
		self.melee_glory = 0;
#ifdef BQA_HAS_IT_MJOLNIR
	if (self.items & IT_MJOLNIR)
		self.has_mjolnir = 1;
#endif
	tries = 0;
	self.melee_cycle = self.melee_cycle + 1;
	if (self.melee_cycle > 2)
		self.melee_cycle = 0;
	while (tries < 3)
	{
		if (self.melee_cycle == 0)
			break;
		if (self.melee_cycle == 1 && self.has_mjolnir)
			break;
		if (self.melee_cycle == 2 && self.has_chainsaw)
			break;
		self.melee_cycle = self.melee_cycle + 1;
		if (self.melee_cycle > 2)
			self.melee_cycle = 0;
		tries = tries + 1;
	}
	if (self.melee_cycle == 1)
	{
		self.melee_hammer = 1;
		self.weaponmodel = "progs/v_hammer.mdl";
	}
	else
	{
		if (self.melee_cycle == 2)
			self.melee_saw = 1;
		self.weaponmodel = "progs/v_axe.mdl";
	}

	old_af = self.attack_finished;
	SuperDamageSound ();
	W_Attack ();
	if (self.melee_active && self.attack_finished <= old_af)
		W_MeleeRestore ();
};

entity() W_MeleeFindLungeTarget =
{
	local entity head;
	local entity best;
	local entity e;
	local vector dir;
	local vector look;
	local float dist;
	local float best_dist;
	local float facing;

	best = world;
	best_dist = 128;

	makevectors (self.v_angle);
	look = v_forward;
	look_z = 0;
	if (vlen (look) < 0.1)
		look = '1 0 0';
	look = normalize (look);

	head = findradius (self.origin, 128);
	while (head)
	{
		e = head;
		head = head.chain;

		if (e != self && e.health > 0 && !RA_IsGhost (e))
		{
			if ((e.flags & FL_MONSTER) || (e.flags & FL_CLIENT))
			{
				if (!(teamplay && (e.flags & FL_CLIENT) && e.team > 0 && e.team == self.team))
				{
					dir = (e.origin + '0 0 20') - self.origin;
					dist = vlen (dir);
					if (dist > 0 && dist <= 128)
					{
						dir_z = 0;
						if (vlen (dir) > 0.1)
						{
							dir = normalize (dir);
							facing = dir * look;
							if (facing >= 0.5)
							{
								traceline (self.origin + '0 0 16', e.origin + '0 0 20', FALSE, self);
								if (trace_fraction == 1 || trace_ent == e)
								{
									if (W_MeleeIsGlory (e))
										dist = dist - 48;
									if (dist < best_dist)
									{
										best_dist = dist;
										best = e;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	return best;
};

void() W_MeleeLungeThink =
{
	local entity helper;
	local entity ply;
	local entity targ;
	local vector dir;
	local float dist;
	local float blocked;

	helper = self;
	ply = helper.owner;
	targ = helper.enemy;
	blocked = 0;

	if (ply == world || ply.health <= 0 || ply.deadflag)
	{
		if (ply != world)
		{
			ply.melee_lunge = 0;
			ply.melee_target = world;
			if (ply.melee_active)
			{
				self = ply;
				W_MeleeRestore ();
			}
		}
		remove (helper);
		return;
	}

	if (targ == world || targ.health <= 0)
		blocked = 1;
	else if (time >= helper.attack_finished)
		blocked = 1;
	else
	{
		dir = (targ.origin + '0 0 20') - ply.origin;
		dist = vlen (dir);
		if (dist < 48)
			blocked = 1;
		else
		{
			traceline (ply.origin + '0 0 16', targ.origin + '0 0 20', TRUE, ply);
			if (trace_fraction < 1 && trace_ent != targ)
				blocked = 1;
		}
	}

	if (blocked)
	{
		remove (helper);
		self = ply;
		W_MeleeDoSwing ();
		return;
	}

	W_MeleeAimYaw (ply, targ);
	W_MeleeLungeDash (ply, targ);

	helper.nextthink = time + 0.05;
	helper.think = W_MeleeLungeThink;
};

void(entity targ) W_MeleeStartLunge =
{
	local entity h;

	if (self.meat_hook != world)
		W_MeathookRelease ();

	self.melee_target = targ;
	W_MeleeAimYaw (self, targ);
	W_MeleeLungeDash (self, targ);

	self.melee_lunge = 1;

	h = spawn ();
	h.classname = "melee_lunge";
	h.owner = self;
	h.enemy = targ;
	h.movetype = MOVETYPE_NONE;
	h.solid = SOLID_NOT;
	h.attack_finished = time + 0.25;
	h.nextthink = time + 0.05;
	h.think = W_MeleeLungeThink;
	setorigin (h, self.origin);
};

void() W_QuickMelee =
{
	local entity targ;

	if (self.health <= 0)
		return;
	if (self.deadflag)
		return;
	if (self.melee_lunge)
		return;
	if (self.melee_active)
	{
		if (time < self.attack_finished)
			return;
		W_MeleeRestore ();
	}

	if (self.weapon == IT_AXE)
		self.melee_restore = IT_AXE;
	else
		self.melee_restore = self.weapon;
	self.melee_active = 1;
	self.weapon = IT_AXE;
	self.weaponmodel = "progs/v_axe.mdl";
	self.weaponframe = 0;
	self.currentammo = 0;

	targ = W_MeleeFindLungeTarget ();
	if (targ != world)
	{
		if (W_MeleeIsGlory (targ))
			self.melee_glory = 1;
		else
			self.melee_glory = 0;
		W_MeleeStartLunge (targ);
		return;
	}

	self.melee_target = world;
	W_MeleeDoSwing ();
};
