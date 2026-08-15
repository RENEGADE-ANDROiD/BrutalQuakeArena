Brutal Quake Arena — melee, meathook, extra gore, and Combat Plus-style extras for Quake 2021 Re-Release.

Copy contents to your Steam Quake install directory.

Add 'game brutal' to Launch Options.  See Options>Input to bind Axe for Quick Melee and Grapple Hook for Meathook. Arena and prox keys are in `default.cfg`. Rebind in the console: `bind p "impulse 71"`.

Turn **Enhanced Models** off under Options > Display so Authentic Models show. Ammo, health, and exploding boxes still replace with Enhanced Models on.



**Campaigns**

* Original Quake (id1)
* Scourge of Armagon (hipnotic)
* Dissolution of Eternity (rogue)
* Dimension of the Past (dopa)
* Dimension of the Machine (mg1)
* CTF (ctf)



**Controls**

* Axe / F (impulse 1 or 50) — quick melee. Locks on and lunges if a monster or player is in a short forward cone, then swings. Failed lunge still swings.
* Chainsaw in each campaign, dropped by Ogre's.
* Grappling Hook / C (impulse 22 or 52) — meathook. Latch onto world or enemies and zip to the point. Tap again to detach.
* Mjolnir (Hammer) in each campaign, dropped by Knights.
* Impulse 215 / N — offhand proximity grenade (does not switch weapons; uses a rocket)
* Impulse 68 / I — Rocket Arena wins / losses / skill
* Impulse 69 / O — Rocket Arena line position (or practice / break)
* Impulse 70 / B — Rocket Arena take a break or return to the line
* Impulse 71 / P — add an Arena bot (max 3)
* Impulse 72 / K — remove Arena bots



**Melee and hook**

* Quick axe melee with lock-on lunge (128 unit range)
* Random Chainsaw \& Mjolnir swing on the melee key if you have looted them.
* Meathook zips you to the latch on world or enemies. Tap again to detach.



**Visuals**

* Full [Authentic Models](https://github.com/NightFright2k19/quake_authmdl) set (Enhanced Models off): monsters, weapons, player, armor, items, gibs, flames, eyes, teleporter, projectiles
* Improved ammo, health, and exploding boxes (work with Enhanced Models on)
* Scourge of Armagon and Dissolution extras (prox, hammer, Rogue guns/boxes)



**Gore**

* Heavier blood sprays on hits and deaths
* Extra meat chunks on hard hits
* More gibs that last longer
* Blood puddles under corpses
* Shootable corpses (gib them after they fall)



**Combat extras**

* Offhand proximity grenade
* Lightning gun chain lightning to nearby enemies
* Shotgun / super shotgun shell casings
* Weapon recoil on shotguns, grenades, and rockets
* Explosion screen shake
* Wounded heartbeat and shaky aim at low health
* Ammo and health crates stay until you are actually full
* Unused monster idles: grunt reload, ogre saw-rev, knight kneel
* Rare Vorelings from a Vore
* Nailgun grunts and defender enforcers



**Rocket Arena**

Final Arena 1.20 maps and sounds are included. Local / listen deathmatch only — remaster matchmaking may ignore custom mods.

* `map arenax` (or `exec arena.cfg`) — 46 classic arenas
* Alone: full loadout practice (100 HP, 200 armor, all guns)
* Two or more: 1v1, 10-second lock, FIGHT, winner stays
* Impulse 68 stats, 69 line position, 70 break
* Impulse 71 adds a mid-to-hard named bot (Crush, Nailer, Bolt, Hopper, Sawbone, Vault, blunt, GrendelKhan, Godavine, Makavelli, Immortal, Thresh, JohnCarmack, JohnRomero, DrDeath, h0s3r, PiLL). Impulse 72 removes them. None have perfect aim.

See `farena_readme.txt` for the original map list and authors.



**Credit**: **RENEGADE ANDROiD**

Monster, weapon, player, and pickup models: [Authentic Models for Quake](https://github.com/NightFright2k19/quake_authmdl) (NightFright and contributors). See `auth_mdl.txt`.

Rocket Arena / Final Arena 1.20: David “crt” Wright and PlanetQuake (1997). Greg “TerMy” Wiles, Andrew “Kolinahr” Wu (sounds), Matt “WhiteFang” Ayres (NetQuake port), Telefragged Arena and the map authors listed in `farena_readme.txt`. Rules recreated in new QuakeC with credit; original RA server progs are not shipped.



