// Arcane Dimensions v1.80 classnames -> id1 Brutal equivalents.

void() monster_army;
void() monster_ogre;
void() monster_wizard;
void() monster_shambler;
void() monster_hell_knight;
void() monster_enforcer;
void() monster_zombie;
void() monster_knight;
void() monster_fish;
void() monster_tarbaby;
void() monster_shalrath;
void() monster_oldone;
void() monster_boss;
void() weapon_lightning;
void() weapon_supershotgun;
void() item_artifact_envirosuit;
void() item_artifact_super_damage;
void() item_artifact_invulnerability;
void() item_health;
void() item_key1;

void() ad_as_army =
{
	monster_army ();
};

void() ad_as_enforcer =
{
	monster_enforcer ();
};

void() ad_as_defender =
{
	self.bqa_defender = 1;
	self.skin = 1;
	monster_enforcer ();
};

void() ad_as_flyer =
{
	monster_wizard ();
};

void() ad_as_knight =
{
	monster_knight ();
};

void() ad_as_ogre =
{
	monster_ogre ();
};

void() ad_as_shambler =
{
	monster_shambler ();
};

void() ad_as_shambler_hi =
{
	monster_shambler ();
	if (self.health > 0 && !self.q2_kind)
	{
		self.health = 1200;
		self.max_health = 1200;
	}
};

void() monster_army_rocket = { ad_as_army (); };
void() monster_army_grenade = { ad_as_army (); };
void() monster_army_plasma = { ad_as_army (); };

void() monster_eel = { monster_fish (); };
void() monster_lostsoul = { ad_as_flyer (); };
void() monster_steelclaw = { monster_tarbaby (); };
void() monster_scorpion = { monster_tarbaby (); };
void() monster_spider = { monster_tarbaby (); };
void() monster_voreling = { monster_tarbaby (); };
void() monster_swampling = { monster_tarbaby (); };
void() monster_zombiek = { monster_zombie (); };
void() monster_mummy = { monster_zombie (); };
void() monster_boil = { monster_tarbaby (); };

void() monster_defender = { ad_as_defender (); };
void() monster_pyro = { ad_as_enforcer (); };
void() monster_fumigator = { ad_as_enforcer (); };
void() monster_jim = { ad_as_flyer (); };
void() monster_eliminator = { ad_as_defender (); };
void() monster_centurion = { ad_as_knight (); };
void() monster_dfury = { ad_as_knight (); };
void() monster_dcrossbow = { monster_knight (); };
void() monster_dguard = { ad_as_knight (); };
void() monster_dknight = { ad_as_knight (); };
void() monster_dsergeant = { ad_as_knight (); };
void() monster_hell_pointknight = { ad_as_knight (); };

void() monster_ogre_fishing = { ad_as_ogre (); };
void() monster_ogre_fishing_ghost = { remove (self); };
void() monster_hogre = { ad_as_ogre (); };
void() monster_hogremac = { ad_as_ogre (); };
void() monster_hogreham = { ad_as_ogre (); };

void() monster_golem = { ad_as_shambler (); };
void() monster_drole = { ad_as_shambler (); };
void() monster_minotaur = { ad_as_shambler (); };
void() monster_freddie = { ad_as_shambler (); };
void() monster_seeker = { ad_as_shambler (); };
void() monster_wraith = { monster_shalrath (); };
void() monster_skullwiz = { ad_as_flyer (); };
void() monster_gargoyle = { ad_as_flyer (); };
void() monster_gaunt = { ad_as_flyer (); };
void() monster_floyd = { ad_as_enforcer (); };

void() monster_turretbal = { ad_as_enforcer (); };
void() monster_sweeper = { ad_as_flyer (); };
void() monster_psyder = { ad_as_shambler_hi (); };
void() monster_baron = { ad_as_shambler_hi (); };
void() monster_dprince = { ad_as_shambler_hi (); };
void() monster_megaforce = { ad_as_defender (); };
void() monster_deflector = { ad_as_shambler_hi (); };
void() monster_mammoth = { ad_as_shambler_hi (); };
void() monster_judicator = { ad_as_shambler_hi (); };
void() monster_justice = { ad_as_shambler (); };
void() monster_boglord = { ad_as_shambler_hi (); };
void() monster_nour = { ad_as_shambler_hi (); };
void() monster_shub = { monster_oldone (); };
void() monster_shubupsd = { monster_oldone (); };
void() monster_chthon = { monster_boss (); };
void() monster_icegolem = { ad_as_shambler_hi (); };
void() monster_eidolon = { ad_as_shambler_hi (); };
void() monster_icegolem_wavetrig = { remove (self); };
void() monster_eidolon_wavetrig = { remove (self); };

void() monster_skullwizminion = { monster_tarbaby (); };
void() monster_minotaurminion = { ad_as_flyer (); };
void() monster_shalrathminion = { monster_tarbaby (); };
void() monster_wraithminion = { monster_tarbaby (); };
void() monster_wraithminion2 = { monster_tarbaby (); };
void() monster_nourminion = { ad_as_flyer (); };
void() monster_judgeminion = { ad_as_flyer (); };

void() weapon_upgrade_lg =
{
	self.classname = "weapon_lightning";
	weapon_lightning ();
};

void() weapon_upgrade_ssg =
{
	self.classname = "weapon_supershotgun";
	weapon_supershotgun ();
};

void() weapon_upgrade_axe =
{
	remove (self);
};

void() item_artifact_jumpboots =
{
	self.classname = "item_artifact_envirosuit";
	item_artifact_envirosuit ();
};

void() item_artifact_lavashield =
{
	self.classname = "item_artifact_envirosuit";
	item_artifact_envirosuit ();
};

void() item_artifact_blastbelt =
{
	self.classname = "item_artifact_invulnerability";
	item_artifact_invulnerability ();
};

void() item_artifact_tomeofpower =
{
	self.classname = "item_artifact_super_damage";
	item_artifact_super_damage ();
};

void() item_artifact_nail_piercer =
{
	self.classname = "item_artifact_super_damage";
	item_artifact_super_damage ();
};

void() item_artifact_sharp_shooter =
{
	self.classname = "item_artifact_super_damage";
	item_artifact_super_damage ();
};

void() item_healthvial =
{
	item_health ();
};

void() item_custom =
{
	item_health ();
};
