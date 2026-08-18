// Jump coyote, jump buffer, and landing punch (Q2 remaster feel, Q1 physics)

void() MP_DoJump =
{
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.button2 = 0;
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
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
	if (self.flags & FL_ONGROUND)
		self.jump_coyote = time;
	else if (self.button2 && self.waterlevel < 2 && !(self.flags & FL_WATERJUMP))
		self.jump_buf = time;
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
	if (!(self.flags & FL_ONGROUND))
		return;
	if (!self.jump_buf)
		return;
	if ((time - self.jump_buf) <= 0.1)
	{
		if (self.waterlevel < 2 && !(self.flags & FL_WATERJUMP) && self.health > 0)
			MP_DoJump ();
	}
	self.jump_buf = 0;
};
