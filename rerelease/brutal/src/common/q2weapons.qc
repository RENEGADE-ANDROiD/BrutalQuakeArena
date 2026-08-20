// Shared Q2-style FX for vanilla guns and Q2/COTV monsters. No player Q2 guns.

void() player_run;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;

void() Q2_Precache =
{
	precache_model ("progs/q2_laser.mdl");
};

void() Q2_ClearHeld =
{
	self.q2_held = 0;
	self.q2_spin = 0;
};

void() Q2_PlayerDied =
{
	local entity f;

	self.q2_spin = 0;
	f = self.q2_flash;
	if (f != world)
	{
		remove (f);
		self.q2_flash = world;
	}
};

float() Q2_SetCurrentAmmo =
{
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

void() Q2_FlashOff =
{
	self.effects = 0;
};

void(entity e, float bright) Q2_Muzzle =
{
	local entity f;

	e.effects = e.effects | EF_MUZZLEFLASH;
	f = e.q2_flash;
	if (f == world)
	{
		f = spawn ();
		f.movetype = MOVETYPE_NOCLIP;
		f.solid = SOLID_NOT;
		f.owner = e;
		e.q2_flash = f;
	}
	setorigin (f, e.origin + '0 0 22');
	if (bright >= 2)
		f.effects = EF_QUADLIGHT;
	else if (bright)
		f.effects = EF_BRIGHTLIGHT;
	else
		f.effects = EF_DIMLIGHT;
	f.think = Q2_FlashOff;
	f.nextthink = time + 0.12;
};

void(vector org, vector vel, float color, float count) Q2_Sparks =
{
	particle (org, vel, color, count);
};

void(vector org, float style) Q2_Impact =
{
	local entity f;

	if (style == 1)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		Q2_Sparks (org, '0 0 80', COLOR_CYAN, 80);
		Q2_Sparks (org, '20 0 40', COLOR_BLUE, 40);
	}
	else if (style == 2)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		Q2_Sparks (org, '0 0 120', COLOR_CYAN, 120);
		Q2_Sparks (org, '0 0 60', COLOR_WHITE, 80);
	}
	else if (style == 3)
	{
		Q2_Sparks (org, '0 0 140', COLOR_ORANGE, 120);
		Q2_Sparks (org, '30 0 80', COLOR_RED, 80);
		Q2_Sparks (org, '0 0 40', COLOR_YELLOW, 60);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		Q2_Sparks (org, '0 0 50', COLOR_YELLOW, 40);
	}
	if (style >= 1)
	{
		f = spawn ();
		f.movetype = MOVETYPE_NOCLIP;
		f.solid = SOLID_NOT;
		setorigin (f, org);
		if (style >= 2)
			f.effects = EF_BRIGHTLIGHT;
		else
			f.effects = EF_DIMLIGHT;
		f.think = SUB_Remove;
		f.nextthink = time + 0.15;
	}
};

void(vector a, vector b) Q2_RailTrail =
{
	local vector p, d, side, up, off;
	local float n, i, az;

	d = b - a;
	n = vlen (d);
	if (n < 1)
		return;
	d = d * (1 / n);
	az = d_z;
	if (az < 0)
		az = 0 - az;
	if (az < 0.9)
	{
		side_x = d_y;
		side_y = 0 - d_x;
		side_z = 0;
	}
	else
	{
		side_x = 1;
		side_y = 0;
		side_z = 0;
	}
	side = normalize (side);
	up_x = d_y * side_z - d_z * side_y;
	up_y = d_z * side_x - d_x * side_z;
	up_z = d_x * side_y - d_y * side_x;
	p = a;
	i = 0;
	while (n > 0)
	{
		if (i == 0)
			off = side * 10;
		else if (i == 1)
			off = up * 10;
		else if (i == 2)
			off = side * -10;
		else
			off = up * -10;
		Q2_Sparks (p + off, '0 0 24', COLOR_CYAN, 8);
		Q2_Sparks (p, '0 0 12', COLOR_WHITE, 5);
		p = p + d * 24;
		n = n - 24;
		i = i + 1;
		if (i > 3)
			i = 0;
	}
};

void() Q2_BoltThink =
{
	Q2_Sparks (self.origin, '0 0 24', COLOR_CYAN, 10);
	if (time > self.ltime)
	{
		remove (self);
		return;
	}
	self.nextthink = time + 0.05;
};

void() Q2_BlasterTouch =
{
	if (other == self.owner)
		return;
	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	Q2_Impact (self.origin, 1);
	if (other.takedamage)
		T_Damage (other, self, self.owner, 15);
	remove (self);
};

float() Q2_Attack =
{
	return FALSE;
};

void() Q2_Impulse =
{
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
	return 0;
};

float(float dir) Q2_Cycle =
{
	if (dir >= 0)
	{
#ifdef BQA_HAS_IT_MJOLNIR
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
		self.q2_held = 0;
		self.melee_held = 0;
		return FALSE;
	}

#ifdef BQA_HAS_IT_MJOLNIR
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
		return FALSE;
	}
#endif
	self.q2_held = 0;
	self.melee_held = 0;
	return FALSE;
};

float() Q2_TossCurrent =
{
	return FALSE;
};

void() weapon_q2machinegun = { remove (self); };
void() weapon_q2chaingun = { remove (self); };
void() weapon_q2hyperblaster = { remove (self); };
void() weapon_q2railgun = { remove (self); };
void() weapon_q2bfg = { remove (self); };
