// Shared spawn stubs for Alkaline / AD overlays on id1 Brutal QC.
// Instant teleports and breakables are playable. Puzzles, ladders, fog,
// and Hipnotic rotation are inert so maps still load.

void() hurt_touch;
void() InitTrigger;
void() teleport_use;
void() trigger_push;
void() trigger_hurt;
void() light;
void() func_wall;
void() func_illusionary;
void() info_player_start;
void() weapon_lightning;
void() weapon_supershotgun;
void() weapon_grenadelauncher;
void() item_key1;
void() item_armor1;
void() item_artifact_envirosuit;
void() item_artifact_super_damage;
void() BQA_SawTouch;

//=============================================================================
// Instant teleport (no fog, no lock, keep velocity)
//=============================================================================

void() instadest_touch =
{
	local entity t;

	if (self.targetname != string_null)
	{
		if (self.nextthink < time)
			return;
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

	if (!self.target)
		return;

	t = find (world, targetname, self.target);
	if (!t)
		return;

	SUB_UseTargets ();
	setorigin (other, t.origin);

	if (other.flags & FL_ONGROUND)
		other.flags = other.flags - FL_ONGROUND;
};

void() trigger_teleport_instadestination =
{
	InitTrigger ();
	self.touch = instadest_touch;
	self.use = teleport_use;
};

//=============================================================================
// Breakable brush
//=============================================================================

void() breakable_die =
{
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	SUB_UseTargets ();
	remove (self);
};

void() func_breakable =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
	if (!self.health)
		self.health = 20;
	self.max_health = self.health;
	self.takedamage = DAMAGE_YES;
	self.th_die = breakable_die;
};

void() func_breakable_wall =
{
	func_breakable ();
};

void() func_breakable_spawner =
{
	func_breakable ();
};

//=============================================================================
// Simple aliases
//=============================================================================

void() trigger_jumppad =
{
	trigger_push ();
};

void() trigger_void =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 100000;
};

void() info_player_start_test =
{
	info_player_start ();
};

void() light_beacon =
{
	light ();
};

void() light_fixture1 =
{
	light ();
};

//=============================================================================
// Text / sound
//=============================================================================

void() textstory_fire =
{
	local entity pl;

	pl = other;
	if (pl.classname != "player")
		pl = activator;
	if (pl.classname != "player")
		return;
	if (self.attack_finished > time)
		return;
	self.attack_finished = time + 2;
	if (self.message != string_null)
		centerprint (pl, self.message);
	SUB_UseTargets ();
};

void() trigger_textstory =
{
	InitTrigger ();
	self.touch = textstory_fire;
	self.use = textstory_fire;
};

void() target_textstory =
{
	self.use = textstory_fire;
};

void() play_sound_triggered_use =
{
	if (self.noise != string_null)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
};

void() play_sound_triggered =
{
	if (self.noise != string_null)
		precache_sound (self.noise);
	self.use = play_sound_triggered_use;
};

void() play_sound_repeat =
{
	if (self.noise != string_null)
	{
		precache_sound (self.noise);
		ambientsound (self.origin, self.noise, 0.5, ATTN_STATIC);
	}
};

void() ambient_general =
{
	if (self.noise != string_null)
	{
		precache_sound (self.noise);
		ambientsound (self.origin, self.noise, 0.5, ATTN_STATIC);
	}
};

//=============================================================================
// Weapons / items shared by both packs
//=============================================================================

void() weapon_laser_gun =
{
	self.classname = "weapon_lightning";
	weapon_lightning ();
};

void() weapon_proximity_gun =
{
	self.classname = "weapon_grenadelauncher";
	weapon_grenadelauncher ();
};

void() weapon_shotgun =
{
	self.classname = "weapon_supershotgun";
	weapon_supershotgun ();
};

void() BQA_AxeStubTouch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	remove (self);
};

void() weapon_axe =
{
	precache_sound ("weapons/lock4.wav");
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setmodel (self, string_null);
	setsize (self, '-16 -16 0', '16 16 56');
	self.touch = BQA_AxeStubTouch;
};

void() weapon_chainsaw =
{
	precache_sound ("weapons/lock4.wav");
	precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	setsize (self, '-16 -16 0', '16 16 56');
	self.touch = BQA_SawTouch;
};

void() item_armor_shard =
{
	item_armor1 ();
	self.armorvalue = 5;
};

void() item_jboots =
{
	self.classname = "item_artifact_envirosuit";
	item_artifact_envirosuit ();
};

void() item_circuitboard =
{
	self.classname = "item_key1";
	item_key1 ();
};

void() item_key_custom =
{
	self.classname = "item_key1";
	item_key1 ();
};

void() item_keyx =
{
	self.classname = "item_key1";
	item_key1 ();
};

void() item_artifact_trifecta =
{
	self.classname = "item_artifact_super_damage";
	item_artifact_super_damage ();
};

//=============================================================================
// Solid-at-rest brushes (no Hipnotic rotate)
//=============================================================================

void() func_movewall =
{
	func_wall ();
};

void() rotate_object =
{
	func_wall ();
};

void() func_rotate_door =
{
	func_wall ();
};

void() func_rotate_entity =
{
	func_wall ();
};

void() func_bob =
{
	func_wall ();
};

void() func_bobbing =
{
	func_wall ();
};

void() func_new_plat =
{
	func_wall ();
};

void() func_togglevisiblewall =
{
	func_wall ();
};

void() func_togglewall =
{
	func_wall ();
};

void() func_shadow =
{
	func_illusionary ();
};

void() func_fade =
{
	func_illusionary ();
};

void() misc_model =
{
	if (self.model != string_null)
	{
		precache_model (self.model);
		setmodel (self, self.model);
	}
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
};

void() misc_modeltrain =
{
	misc_model ();
};

//=============================================================================
// Load-but-noop
//=============================================================================

void() compat_noop_point =
{
	remove (self);
};

void() compat_noop_trigger =
{
	InitTrigger ();
};

void() target_setstate = { compat_noop_point (); };
void() trigger_filter = { compat_noop_trigger (); };
void() trigger_ladder = { compat_noop_trigger (); };
void() trigger_fog = { compat_noop_trigger (); };
void() trigger_fogblend = { compat_noop_trigger (); };
void() target_fogblend = { compat_noop_point (); };
void() target_skybox = { compat_noop_point (); };
void() trigger_everything = { compat_noop_trigger (); };
void() trigger_touchplate = { compat_noop_trigger (); };
void() trigger_float = { compat_noop_trigger (); };
void() trigger_removeitems = { compat_noop_trigger (); };
void() trigger_repeat = { compat_noop_trigger (); };
void() trigger_usekey = { compat_noop_trigger (); };
void() trigger_setgravity = { compat_noop_trigger (); };
void() trigger_globalgravity = { compat_noop_trigger (); };
void() target_move = { compat_noop_point (); };
void() target_autosave = { compat_noop_point (); };
void() target_infight = { compat_noop_point (); };
void() target_startpath = { compat_noop_point (); };
void() target_screenshake = { compat_noop_point (); };
void() target_hurt = { trigger_hurt (); };
void() target_setdoor = { compat_noop_point (); };
void() target_explosion = { compat_noop_point (); };
void() misc_changemusic = { compat_noop_point (); };
void() misc_drip = { compat_noop_point (); };
void() misc_sparks = { compat_noop_point (); };
void() misc_splash = { compat_noop_point (); };
void() misc_flag = { compat_noop_point (); };
void() path_angry = { compat_noop_point (); };
void() info_rotate = { compat_noop_point (); };
void() group = { compat_noop_point (); };
