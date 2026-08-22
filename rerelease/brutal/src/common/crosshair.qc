// Screen-center expanding HUD crosshair. Fire opens it; damage glitches it.
// Tiny pre-sized alias quads. No laser. No traceline. No alias .scale.

float XH_DIST = 32;
float XH_SIZE = 16 * 32 / 110;
float XH_ALPHA = 0.6;

float(entity e) RA_IsGhost;

void() XH_Precache =
{
	precache_model ("progs/xh_axe.mdl");
	precache_model ("progs/xh_gren.mdl");
	precache_model ("progs/xh_nail.mdl");
	precache_model ("progs/xh_sng.mdl");
	precache_model ("progs/xh_rock.mdl");
	precache_model ("progs/xh_prox.mdl");
	precache_model ("progs/xh_hammer.mdl");
};

string() XH_ModelForWeapon =
{
	local string wm;

	if (self.melee_active)
	{
		if (self.melee_hammer)
			return "progs/xh_hammer.mdl";
		return "progs/xh_axe.mdl";
	}

	wm = self.weaponmodel;
	if (wm == "progs/v_prox.mdl")
		return "progs/xh_prox.mdl";
	if (wm == "progs/v_hammer.mdl")
		return "progs/xh_hammer.mdl";
	if (wm == "progs/v_lava.mdl")
		return "progs/xh_nail.mdl";
	if (wm == "progs/v_lava2.mdl")
		return "progs/xh_sng.mdl";
	if (wm == "progs/v_multi.mdl")
		return "progs/xh_rock.mdl";
	if (wm == "progs/v_multi2.mdl")
		return "progs/xh_gren.mdl";
	if (wm == "progs/v_plasma.mdl")
		return "progs/xh_sng.mdl";

	if (self.weapon == IT_AXE)
		return "progs/xh_axe.mdl";
	if (self.weapon == IT_SUPER_SHOTGUN)
		return "progs/xh_axe.mdl";
	if (self.weapon == IT_SHOTGUN)
		return "progs/xh_axe.mdl";
	if (self.weapon == IT_GRENADE_LAUNCHER)
		return "progs/xh_gren.mdl";
	if (self.weapon == IT_NAILGUN)
		return "progs/xh_nail.mdl";
	if (self.weapon == IT_SUPER_NAILGUN)
		return "progs/xh_sng.mdl";
	if (self.weapon == IT_LIGHTNING)
		return "progs/xh_sng.mdl";
	if (self.weapon == IT_ROCKET_LAUNCHER)
		return "progs/xh_rock.mdl";

#ifdef BQA_HAS_IT_MJOLNIR
	if (self.weapon == IT_MJOLNIR)
		return "progs/xh_hammer.mdl";
	if (self.weapon == IT_PROXIMITY_GUN)
		return "progs/xh_prox.mdl";
	if (self.weapon == IT_LASER_CANNON)
		return "progs/xh_sng.mdl";
#endif

	return "progs/xh_nail.mdl";
};

float() XH_HoldFire =
{
	if (!self.button0)
		return FALSE;
	if (self.weapon == IT_LIGHTNING)
		return TRUE;
	if (self.weapon == IT_SUPER_NAILGUN)
		return TRUE;
	if (self.weaponmodel == "progs/v_lava2.mdl")
		return TRUE;
	if (self.weaponmodel == "progs/v_plasma.mdl")
		return TRUE;
#ifdef BQA_HAS_IT_MJOLNIR
	if (self.weapon == IT_LASER_CANNON)
		return TRUE;
#endif
	return FALSE;
};

float() XH_Kick =
{
	if (self.weapon == IT_SHOTGUN)
		return 1;
	if (self.weapon == IT_SUPER_SHOTGUN)
		return 1;
	if (self.weapon == IT_GRENADE_LAUNCHER)
		return 1;
	if (self.weaponmodel == "progs/v_multi2.mdl")
		return 1;
	return 0.7;
};

void(entity e, vector ang) XH_Face =
{
	e.angles_x = 0 - ang_x;
	e.angles_y = ang_y;
	e.angles_z = 0;
};

void(entity e, string mdl) XH_SetModel =
{
	if (e == world)
		return;
	if (e.model == mdl)
		return;
	setmodel (e, mdl);
};

entity(string cls) XH_MakeEnt =
{
	local entity e;

	e = spawn ();
	e.classname = cls;
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	e.takedamage = DAMAGE_NO;
	return e;
};

void(entity e) XH_ClearEnt =
{
	if (e == world)
		return;
	e.model = string_null;
	e.modelindex = 0;
};

void() XH_Hide =
{
	if (self.xh_hud != world)
		self.xh_hud.velocity = '0 0 0';
	XH_ClearEnt (self.xh_hud);
	XH_ClearEnt (self.xh_glitch);
};

void() XH_Ensure =
{
	if (self.xh_hud == world || self.xh_hud.classname != "bqa_xh")
		self.xh_hud = XH_MakeEnt ("bqa_xh");
	if (self.xh_glitch == world || self.xh_glitch.classname != "bqa_xh_glitch")
		self.xh_glitch = XH_MakeEnt ("bqa_xh_glitch");
};

void() XH_Update =
{
	local vector org;
	local vector jorg;
	local vector aim;
	local string mdl;
	local float kick;
	local float fr;
	local float hold;
	local float elapsed;
	local float frac;
	local float amp;
	local float jit;
	local float texel;

	if (self.xh_skip == 1)
	{
		stuffcmd (self, "cl_skipCrosshair 0\n");
		self.xh_skip = 0;
	}

	if (deathmatch || coop || cvar("brutal_nocrosshair") > 0)
	{
		XH_Hide ();
		return;
	}

	if (self.view_ofs == '0 0 0')
	{
		XH_Hide ();
		return;
	}
	if (self.deadflag)
	{
		XH_Hide ();
		return;
	}
	if (self.health <= 0)
	{
		XH_Hide ();
		return;
	}
	if (RA_IsGhost (self))
	{
		XH_Hide ();
		return;
	}
	if (self.weaponmodel == string_null || self.weaponmodel == "")
	{
		XH_Hide ();
		return;
	}

	XH_Ensure ();
	aim = self.v_angle;
	makevectors (aim);
	texel = XH_SIZE / 16;
	org = self.origin + self.view_ofs + v_forward * XH_DIST;
	org = org - v_right * (0.5 * texel) + v_up * (0.5 * texel);
	mdl = XH_ModelForWeapon ();

	if (self.dmg_take > 0)
		self.xh_pain = time + 1.25;

	hold = XH_HoldFire ();
	if (time < self.attack_finished || hold)
	{
		kick = XH_Kick ();
		self.xh_open = self.xh_open + 0.22;
		if (self.xh_open > kick)
			self.xh_open = kick;
	}
	else
	{
		self.xh_open = self.xh_open - 0.14;
		if (self.xh_open < 0)
			self.xh_open = 0;
	}

	fr = floor (self.xh_open * 12);
	if (fr > 12)
		fr = 12;

	if (time < self.xh_pain && !self.button0 && !hold)
	{
		elapsed = 1.25 - (self.xh_pain - time);
		frac = elapsed / 0.625;
		frac = frac - floor (frac);
		if (frac < 0.5)
			amp = frac * 2;
		else
			amp = (1 - frac) * 2;
		fr = 13 + floor (amp * 7.99);
		if (amp <= 0)
			XH_ClearEnt (self.xh_glitch);
		else
		{
			makevectors (self.v_angle + self.punchangle);
			jit = amp * 0.7 * texel;
			jorg = org + v_right * ((random () - 0.5) * jit) + v_up * ((random () - 0.5) * jit);
			XH_SetModel (self.xh_glitch, mdl);
			self.xh_glitch.movetype = MOVETYPE_NONE;
			self.xh_glitch.velocity = '0 0 0';
			self.xh_glitch.alpha = XH_ALPHA;
			self.xh_glitch.skin = fr;
			self.xh_glitch.frame = 0;
			XH_Face (self.xh_glitch, self.v_angle + self.punchangle);
			setorigin (self.xh_glitch, jorg);
		}
	}
	else
		XH_ClearEnt (self.xh_glitch);

	XH_SetModel (self.xh_hud, mdl);
	self.xh_hud.movetype = MOVETYPE_NONE;
	self.xh_hud.velocity = '0 0 0';
	self.xh_hud.alpha = XH_ALPHA;
	self.xh_hud.skin = fr;
	self.xh_hud.frame = 0;
	XH_Face (self.xh_hud, aim);
	setorigin (self.xh_hud, org);
};
