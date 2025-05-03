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

## 👾 ENEMIES & WAVES

- [x] Create reusable `Enemy.tscn` scene.
- [x] Implement wave-based enemy spawning system.
- [ ] Move enemies using Godot's PathFinding2D.
- [ ] Add basic AI (chase nearest player).
- [ ] Handle collisions and damage between players and enemies.
- [ ] Enemy death handling and cleanup.

---

## ⚔️ COMBAT & PROGRESSION

- [ ] Add health system (`hp`) for players and enemies.
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
