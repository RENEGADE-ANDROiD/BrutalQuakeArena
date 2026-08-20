// Alkaline 1.2 classnames used by Liminal Spaces Jam -> id1 Brutal equivalents.

void() monster_army;
void() monster_ogre;
void() monster_wizard;
void() monster_shambler;
void() monster_hell_knight;
void() monster_enforcer;
void() monster_zombie;

void() monster_nailgrunt =
{
	self.bqa_nailgrunt = 1;
	monster_army ();
};

void() monster_ogreb =
{
	monster_ogre ();
};

void() monster_hunter =
{
	monster_wizard ();
};

void() monster_bambler =
{
	monster_shambler ();
	if (self.health > 0)
	{
		self.health = 250;
		self.max_health = 250;
	}
};

void() monster_edie =
{
	monster_ogre ();
};

void() monster_centurion =
{
	monster_hell_knight ();
};

void() monster_dreadnaught =
{
	monster_shambler ();
	if (self.health > 0)
	{
		self.health = 900;
		self.max_health = 900;
	}
};

void() monster_super_enforcer =
{
	self.bqa_defender = 1;
	self.skin = 1;
	monster_enforcer ();
};

void() monster_zombie2 =
{
	monster_zombie ();
};

void() monster_spawn =
{
	monster_army ();
};

void() misc_scientist =
{
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	setsize (self, '-16 -16 -24', '16 16 40');
};
