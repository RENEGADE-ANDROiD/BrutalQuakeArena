// Jump coyote, jump buffer, landing punch, and Q2 remaster trick jumps

.vector	mp_prevel;
.float	mp_wasground;
.float	mp_trick;
.float	mp_trick_z;

void() MP_DoJump =
{
	if (self.mp_trick)
	{
		if ((time - self.mp_trick) <= 0.06)
			self.velocity_z = self.mp_trick_z;
		self.mp_trick = 0;
	}

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.button2 = 0;
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
	if (self.velocity_z < 270)
		self.velocity_z = 270;
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
	self.mp_prevel = self.velocity;
	if (self.mp_trick)
	{
		if ((time - self.mp_trick) > 0.06)
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
		return;
	}
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.waterlevel >= 2 || (self.flags & FL_WATERJUMP))
	{
		self.mp_trick = 0;
		return;
	}

	landed = 0;
	if ((self.flags & FL_ONGROUND) && (self.mp_wasground == 0))
		landed = 1;

	if (landed)
	{
		if (self.mp_prevel_z >= 100)
		{
			self.mp_trick = time;
			self.mp_trick_z = self.mp_prevel_z;
		}
		else
			self.mp_trick = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		return;
	if (!(self.flags & FL_JUMPRELEASED))
	{
		self.jump_buf = 0;
		return;
	}
	if (!self.jump_buf)
		return;
	if ((time - self.jump_buf) <= 0.06)
	{
		if (self.waterlevel < 2 && !(self.flags & FL_WATERJUMP) && self.health > 0)
			MP_DoJump ();
	}
	self.jump_buf = 0;
};
