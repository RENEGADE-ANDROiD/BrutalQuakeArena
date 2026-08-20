// Overlay-only Tremor cheats. Included before the patched id1 weapons/client
// copies so official src/id1 files stay unchanged.
// 52 remains the meathook; silver key is impulse 58.

void() SetNewParms;
void() DecodeLevelParms;
void() W_SetCurrentAmmo;

float	tremor_shotgun_start;

void() TREMOR_ApplyShotgunNow =
{
	SetNewParms ();
	DecodeLevelParms ();
	W_SetCurrentAmmo ();
};

void() TREMOR_ToggleShotgunStart =
{
	if (tremor_shotgun_start)
	{
		tremor_shotgun_start = 0;
		centerprint (self, "Shotgun Start OFF\n");
	}
	else
	{
		tremor_shotgun_start = 1;
		centerprint (self, "Shotgun Start ON\nInventory resets between maps\n");
		TREMOR_ApplyShotgunNow ();
	}
};

void() TREMOR_GiveSilverKey =
{
	self.items = self.items | IT_KEY1;
	centerprint (self, "Silver key\n");
};

void() TREMOR_GiveGoldKey =
{
	self.items = self.items | IT_KEY2;
	centerprint (self, "Gold key\n");
};

void(float bit, string msg) TREMOR_GiveRune =
{
	serverflags = serverflags | bit;
	centerprint (self, msg);
};

float() TREMOR_Impulse =
{
	if (self.impulse == 51)
	{
		TREMOR_ToggleShotgunStart ();
		return TRUE;
	}
	if (self.impulse == 53)
	{
		TREMOR_GiveGoldKey ();
		return TRUE;
	}
	if (self.impulse == 54)
	{
		TREMOR_GiveRune (1, "Episode 1 rune\n");
		return TRUE;
	}
	if (self.impulse == 55)
	{
		TREMOR_GiveRune (2, "Episode 2 rune\n");
		return TRUE;
	}
	if (self.impulse == 56)
	{
		TREMOR_GiveRune (4, "Episode 3 rune\n");
		return TRUE;
	}
	if (self.impulse == 57)
	{
		TREMOR_GiveRune (8, "Episode 4 rune\n");
		return TRUE;
	}
	if (self.impulse == 58)
	{
		TREMOR_GiveSilverKey ();
		return TRUE;
	}
	return FALSE;
};
