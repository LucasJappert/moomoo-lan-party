# ✅ TODO List – MooMoo LAN Party – 🔵 In Progress 🟡 Paused ✅ Done

⚠️ Keep multiplayer in mind, but for now focus on the game as a prototype. ⚠️

📍 [Go to Roadmap](./roadmap.md)  
📝 [Go to Changelog](./changelog.md)

- Quitar foco cuando hacemos click en botones (con espacio se activan)
- Permitir que la camara siga al personaje
- Revisar skill que explota
- Ver problema de sonido de flechas y escarcha
- Save game from the last completed round (filesystem-based saves to restore later).
- Keep tuning items for special rounds.
- Add cloud effect.
- Add rain and lightning effects.
- Add a button to mute/unmute the game.
- Add a few more items.
- Create a skill with a 20% chance to stun the attacker each time the hero is hit.
- Add an item that grants +30% Physical and Magical Attack, plus an extra effect.
- Create an item that spawns 2 clones of the wearer, with the same stats, where each clone takes +60% extra damage.

- Implement a bleed effect proportional to damage dealt.
- Remove MooMoo’s summons when MooMoo dies.
- Make MooMoo switch to **ranged** attacks under 50% HP and equip a **Multishot**-style item.
- Add health bars for MooMoo and the player.
- Add visual effects to MooMoo based on its states.
- Replace the border indicator with an arrow (so we can recolor via shaders).
- Create Round 9 with one enemy that throws blades and another that throws rocks.
- Add an item that deals **splash** damage around the target (different from cleave).
- Implement an **item crafting** system.
- Rebalance round XP (aim for ~2 levels per round).
- Limit sounds to what’s visible on screen.
- Add fixed (“pinned”) HP bars for MooMoo and the player in a convenient UI spot.

- Add red screen edges/animation when low on health.
- Add a toggleable skill that gives a chance to instantly kill non-boss enemies; costs 20 mana per attack.
- Add a passive skill: after killing an enemy, turn it into 3 skeletons that fight for the player.
- Increase learned skill levels for enemies.
- Add a skill with a chance to create clones on each physical attack.
- Create a tooltip with details for the hovered target.
- Add a fifth skill unlocked at level 20.
- Replace “skill levels” with a **point-allocation system**.
- Refactor the GUI by splitting it into panels (TOP-LEFT, BOTTOM-LEFT, BOTTOM-RIGHT).
- Add an item/skill that, when activated, grants immunity to spells and certain debuffs (e.g., silence).
- Add more ambient SFX.
- Enemy wave system: increasing difficulty each wave; every 3 waves consider a “boss-only” wave with 4 bosses.
- Point/score system.
- Show cleave attack info in the GUI.
- Add a **debug panel** with options like “kill all enemies,” etc.
- Add a score that factors **how fast** each wave is cleared.
- Implement damage/heal-over-time systems.
- Review hovered-target behavior when many enemies overlap.
- Add a skill that summons skeletons after killing an enemy.
- Add a +25% attack speed skill.
- Add a skill that deals **2× damage when attacking from behind**.
- Add a skill that, every 5 attacks, heals 5% max HP to all allies.
- Create a lobby scene to **create/join rooms**.
- Implement various status animations on entities (freeze, bleed, etc.).
- Implement tile-based animations (fire, healing, freezing, etc.).
- Start the lobby flow for creating/joining rooms.
- Add small moving objects in the world (plants, critters, clouds, etc.).
- Multi-client testing via the browser.
- Add more enemy types. MooMoo will have ~30 waves, each with 2 enemy types (≈60 total). Each enemy should have 1 special ability (passive or active) → ~60 abilities.
  - Alternative: Design ~3 abilities and assign 3 random abilities to each enemy to create a wide variety of combinations—on top of unique attack type, range, attack speed, etc.
- Add bleeding VFX whenever an entity takes damage.
- Add more hero types. For the first phase, ~10 different heroes with 4 skills each and an ultimate.
- Encapsulate get/set logic.
- Fix movement when attacking an out-of-range enemy: the player moves to the target’s **initial** position but doesn’t update the path if the target keeps moving.

# #################################### 🧠 PATHFINDING STRATEGY – HIGH PRIORITY

We must **improve pathfinding** so movement feels more natural and polished, similar to _Dota_.  
Some decisions currently feel rigid or too direct. We want smoother steering, smarter avoidance, and better collision handling when units swarm.

📌 **Reference Guide:**  
[Pathfinding Guide for 2D Top-View Tiles in Godot 4.3 (by casraf.dev)](https://casraf.dev/2024/09/pathfinding-guide-for-2d-top-view-tiles-in-godot-4-3/)

This guide covers advanced techniques such as flow fields, dynamic obstacle updates, and practical patterns for top-down games.
