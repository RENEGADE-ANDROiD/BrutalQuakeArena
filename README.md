Brutal Quake Arena — Quick melee, meathook, extra gore, enemy elites and Glory Kill rewards for Quake 2021 Re-Release, including 1997 Rocket Arena with local and invite play + optional Quake 2 Enemies (Q2 Rerelease/Call of the Void) mix.

Campaign overlays load automatically — do **not** put `game brutal` in Steam Launch Options.  **INSTALLATION** instructions located below.

See Options > Input to bind Axe for Quick Melee and Grapple Hook for Meathook. Arena and prox keys are in `default.cfg`. Rebind in the console: `bind p "impulse 71"`.

Turn **Enhanced Models** off under Options > Display so Authentic Models & Quake 2 Enemy models show. Authentic Models ammo, health, and exploding boxes still replace with Enhanced Models on.

Steam achievements: Single Player → **New Game** → official episode. Do not use Level Select. Rocket Arena maps are Deathmatch-only and do not grant campaign achievements.

**Campaigns**
* Original Quake (id1)
* Scourge of Armagon (hipnotic)
* Dissolution of Eternity (rogue)
* Dimension of the Past (dopa)
* Dimension of the Machine (mg1)
* CTF (ctf)

**Controls**
* Axe / F (impulse 1 or 50) — quick melee. Locks on and lunges if a monster or player is in a short forward cone, then swings. Failed lunge still swings. Wounded monsters (40 HP or less) are glory-killed: guaranteed gib, brief slow-mo, and a small health sip.
* Chainsaw in each campaign, dropped by Ogre's.
* Grappling Hook / C (impulse 22 or 52) — meathook. Latch onto world or zip to players. In campaign, a monster latch yanks them to you. Tap again to detach.
* Mjolnir (Hammer) in each campaign, dropped by Knights.
* Impulse 215 / N — offhand proximity grenade (does not switch weapons; uses a rocket)
* Impulse 68 / I — Rocket Arena wins / losses / skill
* Impulse 69 / O — Rocket Arena line position (or practice / break)
* Impulse 70 / B — Rocket Arena take a break or return to the line
* Impulse 71 / P — add an Arena bot (max 3)
* Impulse 72 / K — remove Arena bots

**Melee and hook**
* Quick axe melee with lock-on lunge (128 unit range)
* Glory kill on wounded campaign monsters: extra gibs, slow-mo, +10 health (not above max)
* Random Chainsaw \& Mjolnir swing on the melee key if you have looted them. Axe pops extra meat, saw throws more chunks, hammer launches the body.
* Meathook zips you to world (and to players). In Single Player / Coop it yanks hooked monsters to you. Tap again to detach.

**Visuals**
* Full [Authentic Models](https://github.com/NightFright2k19/quake_authmdl) set (Enhanced Models off): monsters, weapons, player, armor, items, gibs, flames, eyes, teleporter, projectiles
* Improved ammo, health, and exploding boxes (work with Enhanced Models on)
* Scourge of Armagon and Dissolution extras (prox, hammer, Rogue guns/boxes)

**Gore**
* Q2 Gore Mix
* Heavier blood sprays on hits and deaths
* Extra meat chunks on hard hits
* More gibs that last longer
* Blood puddles under corpses
* Shootable corpses (melee or rockets explode them)
* Head-high shotgun and nail hits do extra damage and always gib
* Gibbed monsters can pop nearby wounded ones (console `brutal_nogibchain 1` to turn off)
* Rockets, grenades, prox, and lightning cook kills into gibs

**Combat extras**
* Offhand proximity grenade
* Lightning gun chain lightning to nearby enemies
* Shotgun / super shotgun shell casings
* Weapon recoil on shotguns, grenades, and rockets
* Explosion screen shake
* Bigger explosions with extra fire, smoke, and debris
* Quad and Pentagram make melee instagib and explosions larger
* Ammo and health crates stay until you are actually full
* Unused monster idles: grunt reload, ogre saw-rev, knight kneel
* Rare Vorelings from a Vore
* Nailgun grunts and defender enforcers
* Rare possessed elites (more HP, quad glow, faster shots)
* Knights throw an axe at range; ogres toss a second grenade
* Carnage vials (10 HP) sometimes drop from gibs

**Rocket Arena**
Final Arena 1.20 maps and sounds are included. Every player needs this mod installed. Custom matches do not appear in Find Match / the public browser — invite friends.
* **Local Play:** Multiplayer → Local Play → Deathmatch → episode **Quake** → Arena maps (ArenaX and the rest). Set **Number of Bots** to 0 (remaster bots need `.nav` files these maps do not have). Add QC bots with **P**.
* **Online host:** Multiplayer → Start Match → Deathmatch → episode **Quake** → Arena map → start → invite. Same bot rule. Joiners need this mod.
* Console: `game brutal` then `exec arena.cfg` (put `arena.cfg` in `Users\<UserName>\Saved Games\Nightdive Studios\Quake\`). Linux / Proton: `steamapps/compatdata/2310/pfx/drive_c/users/steamuser/Saved Games/Nightdive Studios/Quake/`. Fully quit after — New Game only shows Rocket Arena.
* Deathmatch episode **Quake** — 46 classic arenas in the map list (not New Game)
* Alone: full loadout practice (100 HP, 200 armor, all guns)
* Two or more: 1v1, 10-second lock, FIGHT, winner stays
* Impulse 68 stats, 69 line position, 70 break
* Impulse 71 / **P** adds a mid-to-hard named bot (Crush, Nailer, Bolt, Hopper, Sawbone, Vault, blunt, GrendelKhan, Godavine, Makavelli, Immortal, Thresh, JohnCarmack, JohnRomero, DrDeath, h0s3r, PiLL). Impulse 72 / **K** removes them. None have perfect aim.

See `farena_readme.txt` for the original map list and authors.

**INSTALLATION**
Be sure the contents in the 'rerelease' folder are copied to your 'rerelease' folder!  Not in Quake\id1

Copy the arena.cfg to:

Steam → Quake → Properties → Installed Files → Browse → open `rerelease`. 
On SteamOS, copy files in Desktop Mode. 
On Bazzite, show hidden files to see `~/.local`. Typical `rerelease` roots:

* Internal: `~/.local/share/Steam/steamapps/common/Quake/rerelease/`
* SD / extra disk: `/run/media/<user-or-system>/<LABEL>/steamapps/common/Quake/rerelease/`
* Flatpak Steam: `~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Quake/rerelease/`

**Credit**:

Q1 Monster, weapon, player, and pickup models: [Authentic Models for Quake](https://github.com/NightFright2k19/quake_authmdl) (NightFright and contributors). See `auth_mdl.txt`.

Quake 2 Enemy extras from Quake 2 Rerelease, & Call of the Void (https://www.moddb.com/mods/quake-ii-call-of-the-void) created by Rest in Pixels (00_Zombie_00, Raton and Drugod)

Rocket Arena / Final Arena 1.20: David “crt” Wright and PlanetQuake (1997). Greg “TerMy” Wiles, Andrew “Kolinahr” Wu (sounds), Matt “WhiteFang” Ayres (NetQuake port), Telefragged Arena and the map authors listed in `farena_readme.txt`. Rules recreated in new QuakeC with credit; original RA server progs are not shipped.


Brutal Sprite enhancements from the Doom community!
Gore: Nashgore Addons: Damage Numbers
