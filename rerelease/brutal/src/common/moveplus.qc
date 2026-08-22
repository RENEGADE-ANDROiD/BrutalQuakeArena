// Jump coyote, jump buffer, landing punch, Q2 remaster trick jumps,
// bunnyhop friction skip, and Q2-style air turn.

.vector	mp_prevel;
.float	mp_wasground;
.float	mp_trick;
.vector	mp_airxy;
.float	mp_hadair;
float	mp_didcvars;

void() MP_ApplyMoveCvars =
{
	if (mp_didcvars)
		return;
	mp_didcvars = 1;
	cvar_set ("sv_maxspeed", "310");
	cvar_set ("sv_friction", "5");
};

float() MP_MoveBusy =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return TRUE;
	if (self.waterlevel >= 2)
		return TRUE;
	if (self.flags & FL_WATERJUMP)
		return TRUE;
	if (self.meat_hooked)
		return TRUE;
	if (self.meat_hook != world)
		return TRUE;
	return FALSE;
};

void() MP_AirTurn =
{
	local vector wish;
	local float speed, wlen, currentspeed, addspeed, accelspeed;

	if (self.flags & FL_ONGROUND)
		return;
	if (MP_MoveBusy ())
		return;

	wish = self.velocity;
	wish_z = 0;
	speed = vlen (wish);
	if (speed < 200)
		return;

	makevectors (self.v_angle);
	wish = v_forward;
	wish_z = 0;
	wlen = vlen (wish);
	if (wlen < 0.001)
		return;
	wish_x = wish_x / wlen;
	wish_y = wish_y / wlen;
	wish_z = 0;

	currentspeed = self.velocity_x * wish_x + self.velocity_y * wish_y;
	if (currentspeed <= 0)
		return;

	addspeed = 300 - currentspeed;
	if (addspeed <= 0)
		return;
	accelspeed = frametime * 300;
	if (accelspeed > addspeed)
		accelspeed = addspeed;
	self.velocity_x = self.velocity_x + accelspeed * wish_x;
	self.velocity_y = self.velocity_y + accelspeed * wish_y;
};

void() MP_DoJump =
{
	local float jump_height, oldspeed, newspeed;
	local vector xy;

	if (self.mp_hadair)
	{
		xy = self.mp_airxy;
		xy_z = 0;
		oldspeed = vlen (xy);
		xy = self.velocity;
		xy_z = 0;
		newspeed = vlen (xy);
		if (oldspeed > newspeed)
		{
			self.velocity_x = self.mp_airxy_x;
			self.velocity_y = self.mp_airxy_y;
		}
	}

	jump_height = 270;
	if (self.mp_trick)
	{
		if ((time - self.mp_trick) <= 0.064)
			jump_height = 378;
		self.mp_trick = 0;
	}

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.button2 = 0;
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + jump_height;
	if (self.velocity_z < jump_height)
		self.velocity_z = jump_height;
	self.jump_coyote = 0;
	self.jump_buf = 0;
};

float() MP_CanCoyote =
{
	if (self.waterlevel >= 2)
		return FALSE;
	if (self.flags & FL_WATERJUMP)
		return FALSE;
	if (!self.jump_coyote)
		return FALSE;
	if ((time - self.jump_coyote) > 0.08)
		return FALSE;
	return TRUE;
};

void() MP_PreThink =
{
	MP_ApplyMoveCvars ();
	self.mp_prevel = self.velocity;
	if (self.mp_trick)
	{
		if ((time - self.mp_trick) > 0.064)
			self.mp_trick = 0;
	}

	if (self.flags & FL_ONGROUND)
	{
		self.mp_wasground = 1;
		self.jump_coyote = time;
	}
	else
	{
		self.mp_wasground = 0;
		if (self.button2 && self.waterlevel < 2 && !(self.flags & FL_WATERJUMP))
			self.jump_buf = time;
		MP_AirTurn ();
	}
};

void(float impact) MP_LandPunch =
{
	if (impact >= -300)
		return;
	if (impact < -650)
		self.punchangle_x = self.punchangle_x + 4;
	else
		self.punchangle_x = self.punchangle_x + 2;
};

void() MP_PostThink =
{
	local float landed;

	if (self.health <= 0)
	{
		self.mp_trick = 0;
		self.jump_buf = 0;
		self.mp_hadair = 0;
		return;
	}
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.waterlevel >= 2 || (self.flags & FL_WATERJUMP))
	{
		self.mp_trick = 0;
		self.mp_hadair = 0;
		return;
	}

	landed = 0;
	if ((self.flags & FL_ONGROUND) && (self.mp_wasground == 0))
		landed = 1;

	if (landed)
	{
		if (self.mp_prevel_z >= 100)
			self.mp_trick = time;
		else
			self.mp_trick = 0;
	}

	if (!(self.flags & FL_ONGROUND))
	{
		if (!MP_MoveBusy ())
		{
			self.mp_airxy_x = self.velocity_x;
			self.mp_airxy_y = self.velocity_y;
			self.mp_hadair = 1;
		}
		return;
	}

	if (!(self.flags & FL_JUMPRELEASED))
	{
		self.jump_buf = 0;
		self.mp_hadair = 0;
		return;
	}
	if (!self.jump_buf)
	{
		self.mp_hadair = 0;
		return;
	}
	if ((time - self.jump_buf) <= 0.06)
	{
		if (self.waterlevel < 2 && !(self.flags & FL_WATERJUMP) && self.health > 0)
			MP_DoJump ();
	}
	self.jump_buf = 0;

	if (!(self.flags & FL_ONGROUND))
	{
		if (!MP_MoveBusy ())
		{
			self.mp_airxy_x = self.velocity_x;
			self.mp_airxy_y = self.velocity_y;
			self.mp_hadair = 1;
		}
	}
	else
		self.mp_hadair = 0;
};
