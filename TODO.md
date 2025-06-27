# 🧠 PATHFINDING STRATEGY – HIGH PRIORITY

We must **improve the pathfinding logic** so that movement feels more natural and polished, similar to games like _Dota_.

Currently, some path decisions feel rigid or too direct. We want to aim for smoother movement behavior, intelligent avoidance, and better collision handling when units crowd together.

📌 **Reference Guide:**  
[Pathfinding Guide for 2D Top-View Tiles in Godot 4.3 (by casraf.dev)](https://casraf.dev/2024/09/pathfinding-guide-for-2d-top-view-tiles-in-godot-4-3/)

This guide provides advanced techniques such as flow fields, dynamic obstacle adjustments, and practical examples for top-down games.

---

# ✅ TODO List – MooMoo LAN Party

This file tracks upcoming features and tasks in development. Contributions are welcome!

---

## ✅ IMPLEMENTED (for reference)

- [x] LAN connection between players.
- [x] Player spawning using MultiplayerSpawner.
- [x] Player movement via CharacterBody2D.
- [x] Player synchronization using MultiplayerSynchronizer.

---

## 🔄 BASIC MULTIPLAYER SYNC

- [x] Set up a separate MultiplayerSpawner for enemies.
- [x] Control enemies only from the server (`is_multiplayer_authority()`).
- [x] Synchronize enemy state using MultiplayerSynchronizer (position, animation, HP).
- [x] Enable interpolation for smoother enemy movement.
- [x] Sort all nodes (enemies, players, Moomoo) by Y position.

---

## 🔄 ENTITY CLASS

- [x] Implement a state machine for the Entity class to handle different states (e.g. idle, moving, attacking, dead).

---

## 👾 ENEMIES & WAVES

- [x] Create reusable `Enemy.tscn` scene.
- [x] Implement wave-based enemy spawning system.
- [x] Move enemies using Godot's PathFinding2D.
- [x] Add basic AI (chase nearest player, or move towards Moomoo if none are in range).
- [x] Handle collisions and damage between players and enemies.
- [x] Enemy death handling and cleanup.

---

## ⚔️ COMBAT & PROGRESSION

- [x] Add health system (`hp`) for players and enemies.
- [ ] Add player experience and leveling system.
- [ ] Implement player abilities (Q, W, E, R).
- [ ] Create shop system to buy items (UI + gold).
- [ ] Sync damage, effects, and auras.

---

## 📡 NETWORK OPTIMIZATION

- [ ] Implement `update_enemy_visibility_for_peer(peer_id)` function to reduce sync traffic.
- [ ] Assign sync authority only to clients near each enemy.
- [ ] Add visibility update cooldown (every 1–2s).
- [ ] Group enemies by zones/chunks for larger maps.

---

## 🧭 UI & FEEDBACK

- [ ] Hero selection screen on connect.
- [ ] Health bar and name display over each player/enemy.
- [ ] UI for gold, experience, and abilities.
- [ ] Game over screen (win/lose).

---

## 🛠️ OTHER USEFUL FEATURES

- [ ] Provide `.bat` or `.sh` launch scripts for easy startup.
- [ ] Add logging system for debugging multiplayer sync.
- [ ] Save stats at end of game session.
- [ ] Optional: local joystick/gamepad support.

---

Let’s build MooMoo LAN Party together! 🐮

MY TODOs: 🔵🟡✅

- Crear escena de elección de héroes
- Implementar sistema de asignación de puntos en lugar de skills level
- Agregar item que brinda un 20% de lifesteal
- Capear ciertas stats como defensas y evasion.
- Agregar un item/skill que al activarlo te hace inmune a los hechizos y a ciertos debuffs como silencios.
- Agregar un item/skill que te hace inmune a todo daño durante cierto tiempo al activarlo.
- Agregar otros efectos de sonidos para el ambiente
- Configure enemy types for wave 2
- Sistema de rondas de enemigos aumentando las dificultades en cada oleada, cada 3 oleadas podríamos hacer una de solamente 4 boses
- Sistema de puntos
- Agregar info de Cleave attack a la gui
- Ordenar efectos por nombre
- Agregar panel debugger con opciones para matar todos los enemigos, etc.
- Agregar sistema de selección de Héroe
- Agregar un score que tenga en cuenta la velocidad con que se avanza a cada oleada
- Sistema de daños/curas en el tiempo
- Revisar target hovered cuando hay muchos enemigos
- Agregar skill que invoca esqueletos luego de matar a un enemigo
- Agregar skill de velocidad de ataque de un 25%
- Agregar skill de daño en area
- Agregar skill de disparo multiple
- Agregar skill que causa un x2 cuando el ataque es por la espalda del enemigo.
- Agregar skill que cada 5 ataques regenera el 5% de la vida total a todos los aliados
- Agregar skill que invoca copias de si mismo con cierta chance ante cada ataque
- Sistema de elección de Héroe
- Crear escena para crear y unirse a salas.
- Implementar animaciones varias como congelamiento, sangrado, sobre entidades
- Implementar animaciones sobre tiles, como fuego, sanacion, congelamiento.
- Configurar daños, hp, defensas, etc según el número de wave
- Comenzar la escena para crear y unirse a salas
- Agregar objetos mobiles sobre el terreno como plantas, bichos, nubes, etc.
- Pruebas de multiclientes por el navegador
- Agregar mas tipos de enemigos. El moomoo tendra unas 30 oleadas, cada oleada con 2 tipos de enemigos, entonces necesitariamos unos 60 tipos. Cada enemigo tendra 1 habilidad especial, pasiva o activa, por lo cual necesitaremos tambien unas 60 habilidades.
  Otra opción es crear unas 3 habilidades, y que los enemigos tendrían 3 de ellas asignadas aleatoriamente. De esta manera se podría crear una amplia variabilidad de combinaciones. Sumado a que cada enemigo tiene su tipo de ataque, su rango de ataque, velocidad de ataque, etc.
- Agregar efectos de sangrado cada vez que una entidad recibo un daño
- Agregar mas tipos de héroes. En esta primera etapa bastaría con 10 diferentes tipos con sus respectivas 4 habilidades y una ulti.
- Encapsular lógica de get/set
- Implementar un shader para el efecto de cooldown de habilidades
- Corregir movimiento cuando se quiere atacar un enemigo fuera de rango, el jugador se mueve a la posicion inicial del target, pero si este se mueve no se actualiza tal destino en el path.

- ✅ Darken item slot when on cooldown
- ✅ Create a skill that every 5/4/3 attacks performs a multiple attack to 2/3/4 extra enemies
- ✅ Configure 2 heroes (BLOOD_WARDEN and Frostbane Arcanist)
- ✅ Enable upgrading of the special skill (number 4) at levels 6, 12, and 18
- ✅ Animation for when an attack is made or a spell is cast
- ✅ Add skill that drains enemy's mana on each physical hit, certain % of drained mana is converted into damage
- ✅ Add skill that gives xx% attack effectiveness, i.e. ignores enemy evasion
- ✅ Add item that provides a passive area damage of 30% of the total physical damage dealt
- ✅ Add skill that provides a passive area damage of 20%/30%/40% of the total physical damage dealt
- ✅ Add skill that grants extra physical damage and attack speed for every 10% of lost health
- ✅ Add stat that gives chances of attacks not missing, i.e. ignoring enemy evasion
- ✅ Implement the observer pattern (subscribers) where necessary
- ✅ Redesign effects logic and how they are added to the GUI. Fix bugs for Blood Fury skill
- ✅ Apply lifesteal only when attacking the target (do not apply to damage caused by cleave)
- ✅ Allow unevadable attacks
- ✅ Improvements in object cloning
- ✅ Reorder stats in the GUI. Add a tooltip that provides extra information depending on the stat.
- ✅ Check the issue with the ready function that overrides the stats set in instances

  23/06/2025

- ✅ Gold coin sound when the player earns gold. Provide gold when each wave of enemies finishes.
- ✅ Add sound for boss-type enemies
- ✅ Show health and mana bars when pressing ALT
- ✅ Configure enemy types for wave 1
- ✅ Countdown before starting each wave
- ✅ Add gold to players when an enemy dies
- ✅ Improvements for when there are many objects on the map (review the pathfinding). Still working on it.
- ✅ Review exp when attacking an enemy
- ✅ Enemy spellcasting system
- ✅ Verify that health and mana bars disappear after a certain time without taking damage
- ✅ Show mana bar for enemies

  21/06/2025

- ✅ Provide some exp when attacking or healing
- ✅ Add animation when leveling up
- ✅ Skill progression system when leveling up, automatic increase of base stats, level-up animation
- ✅ Improvements in object cloning (we can continue to enhance it)
- ✅ Use items and skills by clicking from the inventory
- ✅ Fix case when hero is in range of multiple enemies and doesn't change target if we click on a different enemy
- ✅ Mute when losing focus on the game window
- ✅ Add item that gives 20% chance to stun an enemy
- ✅ Enable camera movement by holding down the mouse wheel
- ✅ Fix item synchronization between clients. Remove the item when the quantity is 0.
- ✅ Add hp potion items (three levels, +1 restores 200 hp, +2 restores 500, and +3 restores 2000). Consider item synchronization.
- ✅ Implement maintain terrain with Q
- ✅ Check synchronization of effects on the target (solved with \_add_current_effects() method).
- ✅ Sync animations with RPC messages
- ✅ Add active skill of lightning and implement the necessary features in the skill slot (such as remaining time for use)
- ✅ Allow diagonal movements when possible
- ✅ Maintain an aspect ratio of 16:9
- ✅ Correct attack when changing target while already attacking another one
- ✅ Fix stuck movements when near Moomoo
- ✅ Fix object synchronization for clients that join the room.
- ✅ Remove basemana and basehp and move them to stats.
- ✅ Remove extends Node from CombatStats. Free unused objects. Significant memory improvement.
- ✅ Fix sprite on target panel
- ✅ Refactor spawn functions
- ✅ Check synchronization of sprite projectiles
- ✅ Move to_dict and from_dict to a helper
- ✅ Draw effects of my target
- ✅ Draw effects of my player
- ✅ Implement tooltip to show information when hovering over certain elements, such as skills.
- ✅ Update my player's avatar and the entities being attacked.
- ✅ Move and attack target when out of range doing nothing.
- ✅ Print FPS (drops below 60 when laptop is plugged in)
- ✅ Add target avatar at the top left
- ✅ Implement regeneration logic for health and mana
- ✅ Fix clicks outside grid
- ✅ Shift + click function to move to a tile
- ✅ Draw avatar in the left panel and the hero's name
- ✅ Fix sprite position in enemies
- ✅ Start logic for strength, agility, and intelligence attributes
- ✅ Set first hero types
- ✅ Start building ingame UI
- ✅ Start implementing experience and leveling logic
- ✅ Set sprites by code in heroes
- ✅ Sync Moomoo
- ✅ Start drawing the 4 abilities on the bottom bar
- ✅ Start showing my player stats
- ✅ Move towards target when player wants to attack an enemy but is out of range.
- ✅ Implement camera movement with mouse (not fixed to player)
- ✅ Stop movement and attack when clicking to attack an enemy
- ✅ Review hover over enemies and give a reddish color to hovered enemies.
- ✅ Check bug of attack speed of my pj when it is stuned/frozen several times
- ✅ Implement skill with chances of stun and its respective animation.
- ✅ Implement system for adding effects over time (useful for buffs, debuffs, etc). Class CombatEffect.
- ✅ Critical hits in yellow color
- ✅ Implement new types of projectiles
- ✅ Apply skills only on boss enemies (4 bosses per wave)
- ✅ Ocultar barra de vida en enemigos si no reciben daño
- ✅ Comenzar a agregar algunos sonidos de hits, criticos, etc.
- ✅ Agregar plantas sobre el terreno, como cactus, utilizando un unico atlas.
- ✅ Corregir movimientos en diagonal cuando en realidad no se deberia permitir si los tiles adyacentes estan bloqueados.
- ✅ Agregar objetos mobiles sobre el terreno
