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

MY TODOs:

- ✅ Mejorar el mapa agregando árboles, cercas, etc.
- ✅ Corregir movimientos en diagonal cuando en realidad no se deberia permitir si los tiles adyacentes estan bloqueados.
- ✅ Agregar plantas sobre el terreno, como cactus, utilizando un unico atlas.
- ✅ Comenzar a agregar algunos sonidos de hits, criticos, etc.
- ✅ Ocultar barra de vida en enemigos si no reciben daño
- Setear sprites por codigo, tanto en enemigos como en heroes
- Comenzar con la interfaz de usuario ingame
- Comenzar la escena para crear y unirse a salas
- Agregar objetos mobiles sobre el terreno como plantas, bichos, nubes, etc.
- Agregar mas tipos de enemigos. El moomoo tendra unas 30 oleadas, cada oleada con 2 tipos de enemigos, entonces necesitariamos unos 60 tipos. Cada enemigo tendra 1 habilidad especial, pasiva o activa, por lo cual necesitaremos tambien unas 60 habilidades.
  Otra opción es crear unas 3 habilidades, y que los enemigos tendrían 3 de ellas asignadas aleatoriamente. De esta manera se podría crear una amplia variabilidad de combinaciones. Sumado a que cada enemigo tiene su tipo de ataque, su rango de ataque, velocidad de ataque, etc.
- Agregar efectos de sangrado cada vez que una entidad recibo un daño
- Agregar mas tipos de héroes. En esta primera etapa bastaría con 10 diferentes tipos con sus respectivas 4 habilidades y una ulti.
