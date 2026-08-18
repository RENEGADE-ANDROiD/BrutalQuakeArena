// Quake 2 guns as extra Brutal slots (nails / cells). Centered view MDLs.

float	Q2_MG = 1;
float	Q2_CG = 2;
float	Q2_HYPER = 4;
float	Q2_RAIL = 8;
float	Q2_BFG = 16;

void() player_run;
void() player_nail1;
void() player_light1;
void() player_rocket1;
void() StartItem;
void() spike_touch;
float() crandom;
void() BecomeExplosion;
void() bound_other_ammo;

float() Q2_ModelsOk =
{
	if (cvar("r_md5models") > 0)
		return FALSE;
	if (cvar("brutal_noq2weapons") > 0)
		return FALSE;
	if (cvar("brutal_q2weapons") < 0)
		return FALSE;
	return TRUE;
};

float() Q2_WeaponsEnabled =
{
	return Q2_ModelsOk ();
};

float() Q2_PoolReplaceOk =
{
	if (deathmatch)
		return FALSE;
	return Q2_ModelsOk ();
};

float(float bit) Q2_Has =
{
	if (self.q2weap & bit)
		return TRUE;
	return FALSE;
};

void() Q2_Precache =
{
	precache_model ("progs/v_machn.mdl");
	precache_model ("progs/v_chain.mdl");
	precache_model ("progs/v_hyperb.mdl");
	precache_model ("progs/v_rail.mdl");
	precache_model ("progs/v_bfg.mdl");
	precache_model ("progs/g_machn.mdl");
	precache_model ("progs/g_chain.mdl");
	precache_model ("progs/g_hyperb.mdl");
	precache_model ("progs/g_rail.mdl");
	precache_model ("progs/g_bfg.mdl");
	precache_sound ("weapons/machgf1b.wav");
	precache_sound ("weapons/machgf2b.wav");
	precache_sound ("weapons/machgf3b.wav");
	precache_sound ("weapons/machgf4b.wav");
	precache_sound ("weapons/machgf5b.wav");
	precache_sound ("weapons/chngnu1a.wav");
	precache_sound ("weapons/chngnl1a.wav");
	precache_sound ("weapons/chngnd1a.wav");
	precache_sound ("weapons/hyprbf1a.wav");
	precache_sound ("weapons/railgf1a.wav");
	precache_sound ("weapons/bfg__f1y.wav");
	precache_sound ("weapons/bfg__x1b.wav");
};

void(float held) Q2_Select =
{
	self.q2_held = held;
	self.melee_held = 0;
	self.q2_spin = 0;
	if (held == 1)
		self.weapon = IT_NAILGUN;
	else if (held == 2)
		self.weapon = IT_SUPER_NAILGUN;
	else
		self.weapon = IT_LIGHTNING;
	W_SetCurrentAmmo ();
};

void(float bit) Q2_Give =
{
	self.q2weap = self.q2weap | bit;
};

void() Q2_ClearHeld =
{
	self.q2_held = 0;
	self.q2_spin = 0;
};

float() Q2_SetCurrentAmmo =
{
	if (self.q2_held == 1)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_machn.mdl";
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
		self.items = self.items | IT_NAILS;
		return TRUE;
	}
	if (self.q2_held == 2)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_chain.mdl";
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
		self.items = self.items | IT_NAILS;
		return TRUE;
	}
	if (self.q2_held == 3)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_hyperb.mdl";
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
		self.items = self.items | IT_CELLS;
		return TRUE;
	}
	if (self.q2_held == 4)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_rail.mdl";
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
		self.items = self.items | IT_CELLS;
		return TRUE;
	}
	if (self.q2_held == 5)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_bfg.mdl";
		self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
		self.items = self.items | IT_CELLS;
		return TRUE;
	}
	if (self.weapon == IT_AXE && self.melee_held == 1 && self.has_mjolnir)
	{
		player_run ();
		self.weaponframe = 0;
		self.currentammo = 0;
		self.weaponmodel = "progs/v_hammer.mdl";
		return TRUE;
	}
	return FALSE;
};

void() Q2_FireHitscan =
{
	local vector org, dir;

	org = self.origin + '0 0 16';
	dir = v_forward + v_right * crandom () * 0.03 + v_up * crandom () * 0.03;
	traceline (org, org + dir * 2048, FALSE, self);
	if (trace_ent.takedamage)
		T_Damage (trace_ent, self, self, 8);
	else if (trace_fraction < 1)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);
	}
};

void() Q2_FireMG =
{
	local float r;

	if (self.ammo_nails < 1)
		return;
	r = random ();
	if (r < 0.2)
		sound (self, CHAN_WEAPON, "weapons/machgf1b.wav", 1, ATTN_NORM);
	else if (r < 0.4)
		sound (self, CHAN_WEAPON, "weapons/machgf2b.wav", 1, ATTN_NORM);
	else if (r < 0.6)
		sound (self, CHAN_WEAPON, "weapons/machgf3b.wav", 1, ATTN_NORM);
	else if (r < 0.8)
		sound (self, CHAN_WEAPON, "weapons/machgf4b.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "weapons/machgf5b.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	self.punchangle_x = self.punchangle_x - 1;
	Q2_FireHitscan ();
	self.attack_finished = time + 0.1;
};

void() Q2_FireCG =
{
	if (self.ammo_nails < 1)
		return;
	if (!self.q2_spin || time > (self.q2_spin + 1))
	{
		sound (self, CHAN_WEAPON, "weapons/chngnu1a.wav", 1, ATTN_NORM);
		self.q2_spin = time + 0.45;
		self.attack_finished = self.q2_spin;
		return;
	}
	if (time < self.q2_spin)
	{
		self.attack_finished = self.q2_spin;
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/chngnl1a.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	if (self.ammo_nails > 0)
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	self.punchangle_x = self.punchangle_x - 1;
	Q2_FireHitscan ();
	Q2_FireHitscan ();
	self.attack_finished = time + 0.05;
};

void() Q2_FireHyper =
{
	local vector org;

	if (self.ammo_cells < 1)
		return;
	sound (self, CHAN_WEAPON, "weapons/hyprbf1a.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	self.punchangle_x = self.punchangle_x - 1;
	org = self.origin + '0 0 16';
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles (v_forward);
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
	newmis.velocity = v_forward * 1000;
	self.attack_finished = time + 0.1;
};

void() Q2_FireRail =
{
	local vector org;

	if (self.ammo_cells < 10)
		return;
	sound (self, CHAN_WEAPON, "weapons/railgf1a.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - 10;
	self.punchangle_x = self.punchangle_x - 3;
	org = self.origin + '0 0 16';
	traceline (org, org + v_forward * 8192, FALSE, self);
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
		T_Damage (trace_ent, self, self, 120);
	self.attack_finished = time + 1.5;
};

void() Q2_BFGTouch =
{
	if (other == self.owner)
		return;
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bfg__x1b.wav", 1, ATTN_NORM);
	T_RadiusDamage (self, self.owner, 200, self.owner);
	self.owner = world;
	BecomeExplosion ();
};

void() Q2_FireBFG =
{
	if (self.ammo_cells < 40)
		return;
	sound (self, CHAN_WEAPON, "weapons/bfg__f1y.wav", 1, ATTN_NORM);
	self.currentammo = self.ammo_cells = self.ammo_cells - 40;
	self.punchangle_x = self.punchangle_x - 4;
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "q2_bfg";
	newmis.touch = Q2_BFGTouch;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, self.origin + v_forward * 8 + '0 0 16');
	newmis.velocity = v_forward * 400;
	newmis.angles = vectoangles (newmis.velocity);
	self.attack_finished = time + 1.1;
};

float() Q2_Attack =
{
	if (!self.q2_held)
		return FALSE;
	makevectors (self.v_angle);
	self.show_hostile = time + 1;
	if (self.q2_held == 1)
	{
		if (self.ammo_nails < 1)
			return FALSE;
		player_nail1 ();
		Q2_FireMG ();
		return TRUE;
	}
	if (self.q2_held == 2)
	{
		if (self.ammo_nails < 1)
			return FALSE;
		player_nail1 ();
		Q2_FireCG ();
		return TRUE;
	}
	if (self.q2_held == 3)
	{
		if (self.ammo_cells < 1)
			return FALSE;
		player_nail1 ();
		Q2_FireHyper ();
		return TRUE;
	}
	if (self.q2_held == 4)
	{
		if (self.ammo_cells < 10)
			return FALSE;
		player_light1 ();
		Q2_FireRail ();
		return TRUE;
	}
	if (self.q2_held == 5)
	{
		if (self.ammo_cells < 40)
			return FALSE;
		player_rocket1 ();
		Q2_FireBFG ();
		return TRUE;
	}
	return FALSE;
};

void() Q2_Impulse =
{
	if (self.impulse == 80)
	{
		if (Q2_Has (Q2_MG))
			Q2_Select (1);
		self.impulse = 0;
	}
	else if (self.impulse == 81)
	{
		if (Q2_Has (Q2_CG))
			Q2_Select (2);
		self.impulse = 0;
	}
	else if (self.impulse == 82)
	{
		if (Q2_Has (Q2_HYPER))
			Q2_Select (3);
		self.impulse = 0;
	}
	else if (self.impulse == 83)
	{
		if (Q2_Has (Q2_RAIL))
			Q2_Select (4);
		self.impulse = 0;
	}
	else if (self.impulse == 84)
	{
		if (Q2_Has (Q2_BFG))
			Q2_Select (5);
		self.impulse = 0;
	}
};

void(float held) Q2_SelectMelee =
{
	self.q2_held = 0;
	self.q2_spin = 0;
	self.melee_held = held;
	self.weapon = IT_AXE;
	W_SetCurrentAmmo ();
};

float() Q2_BestWeapon =
{
	if (Q2_Has (Q2_RAIL) && self.ammo_cells >= 10 && self.waterlevel <= 1)
	{
		self.q2_held = 4;
		return IT_LIGHTNING;
	}
	if (Q2_Has (Q2_HYPER) && self.ammo_cells >= 1)
	{
		self.q2_held = 3;
		return IT_LIGHTNING;
	}
	if (Q2_Has (Q2_CG) && self.ammo_nails >= 2)
	{
		self.q2_held = 2;
		return IT_SUPER_NAILGUN;
	}
	if (Q2_Has (Q2_MG) && self.ammo_nails >= 1)
	{
		self.q2_held = 1;
		return IT_NAILGUN;
	}
	if (Q2_Has (Q2_BFG) && self.ammo_cells >= 40)
	{
		self.q2_held = 5;
		return IT_LIGHTNING;
	}
	return 0;
};

float() Q2_PickNextCell =
{
	if (Q2_Has (Q2_RAIL) && self.ammo_cells >= 10)
	{
		Q2_Select (4);
		return TRUE;
	}
	if (Q2_Has (Q2_HYPER) && self.ammo_cells >= 1)
	{
		Q2_Select (3);
		return TRUE;
	}
	if (Q2_Has (Q2_BFG) && self.ammo_cells >= 40)
	{
		Q2_Select (5);
		return TRUE;
	}
	return FALSE;
};

float() Q2_PickPrevCell =
{
	if (Q2_Has (Q2_BFG) && self.ammo_cells >= 40)
	{
		Q2_Select (5);
		return TRUE;
	}
	if (Q2_Has (Q2_HYPER) && self.ammo_cells >= 1)
	{
		Q2_Select (3);
		return TRUE;
	}
	if (Q2_Has (Q2_RAIL) && self.ammo_cells >= 10)
	{
		Q2_Select (4);
		return TRUE;
	}
	return FALSE;
};

float(float dir) Q2_Cycle =
{
	if (dir >= 0)
	{
#ifdef CP_HAS_IT_MJOLNIR
		if (self.weapon == IT_MJOLNIR && self.has_chainsaw)
		{
			Q2_SelectMelee (2);
			return TRUE;
		}
		if (self.weapon == IT_AXE && self.melee_held == 2)
		{
			Q2_SelectMelee (0);
			return TRUE;
		}
#else
		if (self.weapon == IT_AXE)
		{
			if (self.melee_held == 0 && self.has_mjolnir)
			{
				Q2_SelectMelee (1);
				return TRUE;
			}
			if (self.melee_held <= 1 && self.has_chainsaw)
			{
				Q2_SelectMelee (2);
				return TRUE;
			}
			self.melee_held = 0;
			return FALSE;
		}
#endif
		if (self.weapon == IT_SUPER_SHOTGUN)
		{
			if (self.items & IT_NAILGUN)
				return FALSE;
			if (Q2_Has (Q2_MG) && self.ammo_nails >= 1)
			{
				Q2_Select (1);
				return TRUE;
			}
			return FALSE;
		}
		if (self.weapon == IT_NAILGUN)
		{
			if (self.q2_held == 0 && Q2_Has (Q2_MG) && self.ammo_nails >= 1)
			{
				Q2_Select (1);
				return TRUE;
			}
			self.q2_held = 0;
			if (!(self.items & IT_SUPER_NAILGUN) && Q2_Has (Q2_CG) && self.ammo_nails >= 1)
			{
				Q2_Select (2);
				return TRUE;
			}
			return FALSE;
		}
		if (self.weapon == IT_SUPER_NAILGUN)
		{
			if (self.q2_held == 0 && Q2_Has (Q2_CG) && self.ammo_nails >= 1)
			{
				Q2_Select (2);
				return TRUE;
			}
			self.q2_held = 0;
			return FALSE;
		}
		if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			if (self.items & IT_LIGHTNING)
				return FALSE;
			return Q2_PickNextCell ();
		}
		if (self.weapon == IT_LIGHTNING)
		{
			if (self.q2_held == 0)
				return Q2_PickNextCell ();
			if (self.q2_held == 4)
			{
				if (Q2_Has (Q2_HYPER) && self.ammo_cells >= 1)
				{
					Q2_Select (3);
					return TRUE;
				}
				if (Q2_Has (Q2_BFG) && self.ammo_cells >= 40)
				{
					Q2_Select (5);
					return TRUE;
				}
				self.q2_held = 0;
				return FALSE;
			}
			if (self.q2_held == 3)
			{
				if (Q2_Has (Q2_BFG) && self.ammo_cells >= 40)
				{
					Q2_Select (5);
					return TRUE;
				}
				self.q2_held = 0;
				return FALSE;
			}
			self.q2_held = 0;
			return FALSE;
		}
		self.q2_held = 0;
		self.melee_held = 0;
		return FALSE;
	}

#ifdef CP_HAS_IT_MJOLNIR
	if (self.weapon == IT_AXE)
	{
		if (self.melee_held == 0 && self.has_chainsaw)
		{
			Q2_SelectMelee (2);
			return TRUE;
		}
		if (self.melee_held == 2)
		{
			self.q2_held = 0;
			self.melee_held = 0;
			self.weapon = IT_MJOLNIR;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		return FALSE;
	}
	if (self.weapon == IT_LASER_CANNON)
	{
		if (Q2_PickPrevCell ())
			return TRUE;
		return FALSE;
	}
#else
	if (self.weapon == IT_SHOTGUN)
	{
		if (self.has_chainsaw)
		{
			Q2_SelectMelee (2);
			return TRUE;
		}
		if (self.has_mjolnir)
		{
			Q2_SelectMelee (1);
			return TRUE;
		}
		return FALSE;
	}
	if (self.weapon == IT_AXE)
	{
		if (self.melee_held == 2)
		{
			if (self.has_mjolnir)
			{
				Q2_SelectMelee (1);
				return TRUE;
			}
			Q2_SelectMelee (0);
			return TRUE;
		}
		if (self.melee_held == 1)
		{
			Q2_SelectMelee (0);
			return TRUE;
		}
		if (Q2_PickPrevCell ())
			return TRUE;
		return FALSE;
	}
#endif
	if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		if (self.items & IT_SUPER_NAILGUN)
			return FALSE;
		if (Q2_Has (Q2_CG) && self.ammo_nails >= 1)
		{
			Q2_Select (2);
			return TRUE;
		}
		return FALSE;
	}
	if (self.weapon == IT_SUPER_NAILGUN)
	{
		if (self.q2_held == 2)
		{
			self.q2_held = 0;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		if (Q2_Has (Q2_CG) && self.ammo_nails >= 1)
		{
			Q2_Select (2);
			return TRUE;
		}
		if (!(self.items & IT_NAILGUN) && Q2_Has (Q2_MG) && self.ammo_nails >= 1)
		{
			Q2_Select (1);
			return TRUE;
		}
		return FALSE;
	}
	if (self.weapon == IT_NAILGUN)
	{
		if (self.q2_held == 1)
		{
			self.q2_held = 0;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		if (Q2_Has (Q2_MG) && self.ammo_nails >= 1)
		{
			Q2_Select (1);
			return TRUE;
		}
		return FALSE;
	}
	if (self.weapon == IT_LIGHTNING)
	{
		if (self.q2_held == 5)
		{
			if (Q2_Has (Q2_HYPER) && self.ammo_cells >= 1)
			{
				Q2_Select (3);
				return TRUE;
			}
			if (Q2_Has (Q2_RAIL) && self.ammo_cells >= 10)
			{
				Q2_Select (4);
				return TRUE;
			}
			self.q2_held = 0;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		if (self.q2_held == 3)
		{
			if (Q2_Has (Q2_RAIL) && self.ammo_cells >= 10)
			{
				Q2_Select (4);
				return TRUE;
			}
			self.q2_held = 0;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		if (self.q2_held == 4)
		{
			self.q2_held = 0;
			W_SetCurrentAmmo ();
			return TRUE;
		}
		return FALSE;
	}
	self.q2_held = 0;
	self.melee_held = 0;
	return FALSE;
};

void() Q2_Touch =
{
	local float bit, nails, cells;
	local entity prev;

	if (!(other.flags & FL_CLIENT))
		return;

	bit = 0;
	nails = 0;
	cells = 0;
	if (self.classname == "weapon_q2machinegun")
	{
		bit = Q2_MG;
		nails = 30;
	}
	else if (self.classname == "weapon_q2chaingun")
	{
		bit = Q2_CG;
		nails = 30;
	}
	else if (self.classname == "weapon_q2hyperblaster")
	{
		bit = Q2_HYPER;
		cells = 15;
	}
	else if (self.classname == "weapon_q2railgun")
	{
		bit = Q2_RAIL;
		cells = 15;
	}
	else if (self.classname == "weapon_q2bfg")
	{
		bit = Q2_BFG;
		cells = 15;
	}
	else
		return;

	if ((other.q2weap & bit) && (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5))
		return;

	other.q2weap = other.q2weap | bit;
	other.ammo_nails = other.ammo_nails + nails;
	other.ammo_cells = other.ammo_cells + cells;
	sprint (other, "$qc_got_item", self.netname);
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	prev = self;
	self = other;
	bound_other_ammo ();
	if (bit == Q2_MG)
		Q2_Select (1);
	else if (bit == Q2_CG)
		Q2_Select (2);
	else if (bit == Q2_HYPER)
		Q2_Select (3);
	else if (bit == Q2_RAIL)
		Q2_Select (4);
	else
		Q2_Select (5);
	self = prev;

	if (!(coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5))
		remove (prev);
};

void(string mdl, string cls, string nm) Q2_Become =
{
	self.classname = cls;
	self.netname = nm;
	setmodel (self, mdl);
	self.touch = Q2_Touch;
	setsize (self, '-16 -16 0', '16 16 56');
	self.avelocity = '0 300 0';
	StartItem ();
};

float(float kind) Q2_TryReplace =
{
	local float r;

	if (!Q2_PoolReplaceOk ())
		return FALSE;
	r = random ();
	if (kind == 1)
	{
		if (r >= 0.5)
			return FALSE;
		Q2_Become ("progs/g_machn.mdl", "weapon_q2machinegun", "Machinegun");
		return TRUE;
	}
	if (kind == 2)
	{
		if (r >= 0.5)
			return FALSE;
		Q2_Become ("progs/g_chain.mdl", "weapon_q2chaingun", "Chaingun");
		return TRUE;
	}
	if (kind == 3)
	{
		if (r >= 0.5)
			return FALSE;
		if (random () < 0.5)
			Q2_Become ("progs/g_rail.mdl", "weapon_q2railgun", "Railgun");
		else
			Q2_Become ("progs/g_hyperb.mdl", "weapon_q2hyperblaster", "Hyperblaster");
		return TRUE;
	}
	if (kind == 4)
	{
		if (r >= 0.15)
			return FALSE;
		Q2_Become ("progs/g_bfg.mdl", "weapon_q2bfg", "BFG10K");
		return TRUE;
	}
	return FALSE;
};

void() weapon_q2machinegun =
{
	Q2_Become ("progs/g_machn.mdl", "weapon_q2machinegun", "Machinegun");
};

void() weapon_q2chaingun =
{
	Q2_Become ("progs/g_chain.mdl", "weapon_q2chaingun", "Chaingun");
};

void() weapon_q2hyperblaster =
{
	Q2_Become ("progs/g_hyperb.mdl", "weapon_q2hyperblaster", "Hyperblaster");
};

void() weapon_q2railgun =
{
	Q2_Become ("progs/g_rail.mdl", "weapon_q2railgun", "Railgun");
};

void() weapon_q2bfg =
{
	Q2_Become ("progs/g_bfg.mdl", "weapon_q2bfg", "BFG10K");
};

void() Q2_GrantArena =
{
	if (!Q2_WeaponsEnabled ())
		return;
	self.q2weap = Q2_MG + Q2_CG + Q2_HYPER + Q2_RAIL + Q2_BFG;
};

float() Q2_TossCurrent =
{
	local entity item;
	local string mdl, cls, nm;
	local float bit;

	if (!self.q2_held)
		return FALSE;
	bit = 0;
	mdl = string_null;
	cls = string_null;
	nm = string_null;
	if (self.q2_held == 1)
	{
		bit = Q2_MG;
		mdl = "progs/g_machn.mdl";
		cls = "weapon_q2machinegun";
		nm = "Machinegun";
	}
	else if (self.q2_held == 2)
	{
		bit = Q2_CG;
		mdl = "progs/g_chain.mdl";
		cls = "weapon_q2chaingun";
		nm = "Chaingun";
	}
	else if (self.q2_held == 3)
	{
		bit = Q2_HYPER;
		mdl = "progs/g_hyperb.mdl";
		cls = "weapon_q2hyperblaster";
		nm = "Hyperblaster";
	}
	else if (self.q2_held == 4)
	{
		bit = Q2_RAIL;
		mdl = "progs/g_rail.mdl";
		cls = "weapon_q2railgun";
		nm = "Railgun";
	}
	else if (self.q2_held == 5)
	{
		bit = Q2_BFG;
		mdl = "progs/g_bfg.mdl";
		cls = "weapon_q2bfg";
		nm = "BFG10K";
	}
	else
		return FALSE;

	item = spawn ();
	item.owner = self;
	setorigin (item, self.origin + '0 0 16');
	item.velocity = aim (self, 1000);
	item.velocity = item.velocity * 500;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_BOUNCE;
	item.classname = cls;
	item.netname = nm;
	setmodel (item, mdl);
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = Q2_Touch;
	item.think = SUB_Remove;
	item.nextthink = time + 120;
	self.q2weap = self.q2weap - (self.q2weap & bit);
	self.q2_held = 0;
	return TRUE;
};
