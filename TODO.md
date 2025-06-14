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

- ✅ Mejorar el mapa agregando árboles, cercas, etc.
- ✅ Corregir movimientos en diagonal cuando en realidad no se deberia permitir si los tiles adyacentes estan bloqueados.
- ✅ Agregar plantas sobre el terreno, como cactus, utilizando un unico atlas.
- ✅ Comenzar a agregar algunos sonidos de hits, criticos, etc.
- ✅ Ocultar barra de vida en enemigos si no reciben daño
- ✅ Setear sprites por codigo en enemigos
- ✅ Apply skills only on boss enemies (4 bosses per wave)
- ✅ Implement new types of projectiles
- ✅ Critical hits in yellow color
- ✅ Implement system for adding effects over time (useful for buffs, debuffs, etc). Class CombatEffect.
- ✅ Implement skill of reducing attack and movement with freeze.
- ✅ Check bug of attack speed of my pj when it is stuned/frozen several times
- ✅ Implement skill with chances of stun and its respective animation.
- ✅ Review hover over enemies and give a reddish color to hovered enemies.
- ✅ Stop movement and attack when clicking to attack an enemy
- ✅ Implement camera movement with mouse (not fixed to player)
- ✅ Move towards target when player wants to attack an enemy but is out of range.
- ✅ Add life-stealing skill.
- ✅ Implement skills in enemies (also useful for heroes later)
- ✅ Set sprites by code in heroes
- ✅ Sync Moomoo
- ✅ Start drawing the 4 abilities on the bottom bar
- ✅ Start showing my player stats
- ✅ Fix sprite position in enemies
- ✅ Draw avatar in the left panel and the hero's name
- ✅ Shift + click function to move to a tile
- ✅ Fix clicks outside grid
- ✅ Implement regeneration logic for health and mana
- ✅ Add target avatar at the top left
- ✅ Print FPS (drops below 60 when laptop is plugged in)
- ✅ Move and attack target when out of range doing nothing.
- ✅ Update my player's avatar and the entities being attacked.
- ✅ Implement tooltip to show information when hovering over certain elements, such as skills.
- ✅ Draw effects of my player
- ✅ Draw effects of my target
- ✅ Move to_dict and from_dict to a helper
- ✅ Check synchronization of sprite projectiles
- ✅ Refactor spawn functions
- ✅ Fix sprite on target panel
- ✅ Remove extends Node from CombatStats. Free unused objects. Significant memory improvement.
- ✅ Remove basemana and basehp and move them to stats.
- ✅ Fix object synchronization for clients that join the room.
- ✅ Fix stuck movements when near Moomoo
- ✅ Correct attack when changing target while already attacking another one
- 🟡 Start implementing experience and leveling logic
- 🟡 Start building ingame UI
- 🟡 Set first hero types
- 🟡 Start logic for strength, agility, and intelligence attributes
- Mantener relacion aspecto de 16:9
- Permitir movimientos en diagonal cuando es posible
- Agregar skill activo de rayo
- Agregar items de pociones de hp (tres niveles, +1 regenera 200 de hp, +2 regenera 500 y +3 regenera 2000)
- Agregar skill de velocidad de ataque de un 25%
- Agregar skill de daño en area
- Agregar skill de disparo multiple
- Agregar skill que causa un x2 cuando el ataque es por la espalda del enemigo.
- Agregar skill que cada 5 ataques regenera el 5% de la vida total a todos los aliados
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
- Corregir movimiento cuando se quiere atacar un enemigo fuera de rango, el jugador se mueve a la posicion inicial del target, pero si este se mueve no se actualiza tal destino en el path.
