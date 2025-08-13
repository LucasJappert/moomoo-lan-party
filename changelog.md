# Here you can find all the changes made to the game 🎮📜

📆 xx/07/2025

- ✅ Create item Deadeye that grants a chance to ignore the target's evasion
- ✅ Generate a skill/item that gives a chance to summon skeletons with each attack
- ✅ Move the player to an appropriate position when casting a spell on an enemy that is out of range
- ✅ Check for a stun with a longer duration over another
- ✅ Added an item that grants +30% Movement Speed, +30% Attack Speed, and +30 Strength, Agility, and Intelligence.
- ✅ Added an item that grants +30% Physical and Magical Defense and +1000 HP.
- ✅ Added an item that grants +40% Lifesteal, +20% chance to Stun, and +200 Physical & Magical Attack.
- ✅ Added an item that grants +100 Intelligence and +2000 HP, with a 20% chance when hit by a physical attack to unleash 5 lightning bolts at random enemies within range, each dealing magic damage based on Intelligence.
- ✅ Crear escena inicial + Selección de lenguaje + Música
- ✅ Allow enemies to use items
- ✅ Every 2 normal rounds, generate an extra special round with 4 bosses, which have extra attributes and 4 random skills.
- ✅ Add Ghostplate item that grants +20% physical and magical defense, and 20% evasion.
- ✅ Add Swift Mirage item that grants 15% AS, 15% evasion and +10 to all attributes
- ✅ Agregar item Soul Pact: Each physical attack inflicts either Burn or Poison, dealing 15 magic damage per second for 5 seconds (up to 10 stacks). This ability costs no mana, but sacrifices 15 HP from the user on each hit.
- ✅ Add item Phantom Edge that grants 20% critical chance (150% extra damage). Also increases agility by 20 points.
- ✅ Create item Multi Shot that adds 2 new extra projectiles, which deal 50% of the original damage. It also increases attack range by 50
- ✅ Create item Stunning Edge that grants a 20% (10% for ranged units) chance to stun the target for 2 seconds.
- ✅ Add item that gives +15 int and +5 str/agi.
- ✅ Add item that gives +15 str and +5 int/agi.
- ✅ Add item that gives +15 agi and +5 str/int.
- ✅ Do not dim passive skills when we are silenced. Dim skills not learned.
- ✅ Add a border to the unit we are attacking and also to the one we are hovering over
- ✅ Rearranging items in the inventory, being able to sell them
- ✅ Add in-game statistics, such as time elapsed, damage dealt, damage taken, etc
- ✅ Implement some effect when skill cooldown is completed
- ✅ Add text over effect slots, such as the level of the Blood Fury effect or the remaining time of the effect
- ✅ Check stun effect and duration for when it is stunned and receives another stun. Add regressive progress bars for stun and silence
- ✅ Improve enemy skill levels when repeating waves
- ✅ Improve enemy spawn animation
- ✅ Improve creature spawn, it's causing a jump when we create multiple of them at once (before 4ms p/u, after 1ms p/u). Huge improvements in the CombatStats class
- ✅ Add bleeding effect on the ground, also perhaps when an entity dies
- ✅ Create new enemy Blow Digger, its special skill is to explode after dying, causing huge damage to nearby enemies
- ✅ Add DemonBolt projectile
- ✅ Create wave 7 with EnemyReflector and EnemyCrimsonWarlock enemies
- ✅ Add reflection effect for Pain Echo skill
- ✅ Create skill Pain Echo that reflects a percentage of received damage to the attacker (type of reflected damage is pure)
- ✅ Auto-attack the nearest enemy when done attacking another enemy
- ✅ Improve pause and add pause scene
- ✅ Pause enemies and world when player dies (Game Over scene)
- ✅ Add item that grants 40 points of agi, str and int (Power Core)
- ✅ Add item that grants a 25% lifesteal (Blood Edge)
- ✅ Fix bug where spellcasting was not limited by spell's distance itself
- ✅ Create system to buy items
- ✅ Create new Shuriken projectile
- ✅ Create a wind effect on the Shuriken projectile
- ✅ Create skill that silences and causes damage over time for a certain period
- ✅ Add fire sound when some skill of fire is active
- ✅ Create 2 new enemy types to later configure wave 6 (Dead Shield and Silent Shuriken)
- ✅ New enemy Infernal Minotaur and Night Archer
- ✅ Configure enemies for wave 5
- ✅ Add animation when clicking to move to a tile
- ✅ Add button to advance the wave
- ✅ Configure new wave with archer creatures that slow with frost
- ✅ Add Cinderflame Wielder creature that uses Burning Presence skill
- ✅ Add Ember Fiend creature that accompanies Cinderflame Wielder
- ✅ Add Burning Presence skill that sets all tiles around the player on fire
- ✅ Create fire effect for later use in spells and abilities
- ✅ Add ice sound effects when receiving damage with such effect
- ✅ Add new enemy that grants a protective shield to its allies (SHIELDED CORE)
- ✅ Add active skill that grants a protective shield of magic and physical defense (SHIELDED CORE)
- ✅ Improve dying animation, body moves up, dissolving and becoming transparent (it looks great!)
- ✅ Agregar efecto de respiracion a las entidades
- ✅ Create defeat screen and statistics to play again
- ✅ Create a tutorial to show the controls inside picker hero scene

📆 09/07/2025

- ✅ Lightning effect as projectile for hero Lightning Warden
- ✅ Add death animation to enemies (dissolve effect using a shader)
- ✅ Create a module to play random nighttime sounds. Also, a first try at a background music
- ✅ Create hero selection scene
- ✅ Consider magical damage, add it to the total magical damage generated by the skill
- ✅ Update stun animation (new StunEffect class)
- ✅ New hero Lightning Warden - Voltrix (Guardian of Lightning)
- ✅ Add skill Storm Wrath that summons a fierce thunderstorm for 6 seconds, automatically casting Shock Spear on random enemies every 1 second. Each cast replicates the full effects of the Shock Spear skill
- ✅ Add skill that after each spell cast, electrifies nearby enemies, dealing xx% of the enemy's total life
- ✅ Add skill Shock Spear: Invokes a ray of lightning that deals magical damage and stuns the target as well as nearby enemies
- ✅ Add skill Arc Lightning Storm: Emits a wave of magical energy that damages all nearby enemies in a small area
- ✅ Change the GUI when we left-click on another entity
- ✅ Fix the problem of emoticons in web (now using OpenSansEmoji)

# -----------------------------------------------------------------------------------------------

📆 02/07/2025

- ✅ Configure new hero 🧙 Kael Dravok 🧙
- ✅ Add animation for Unbreakable skill
- ✅ Add a skill that makes you immune to all damage for a certain time when activated
- ✅ Add a skill that, when activated, accumulates all damage received by the hero. After 7 seconds, 10/20/30% of that accumulated damage will be released as damage to all enemies within a radius of 3 tiles
- ✅ Add a skill that stuns all enemies within 2 tiles for 2/3/4 seconds. It also deals damage of 30/40/50% of the total strength
- ✅ Add a skill that when activated grants 20/30/40% increased attack speed for 6 seconds. During this time, the hero is silenced
- ✅ Add information about different levels in skill descriptions
- ✅ Fix bugs with items in the GUI
- ✅ Show health and mana bars above enemies that are attacking
- ✅ Fix targeting system. We should prioritize visualizing the avatar of the unit that is selected with left click. If there is no unit clicked with left click, then we should show the target that we are attacking

📆 30/06/2025

- ✅ Darken item slot when on cooldown
- ✅ Create a skill that every 5/4/3 attacks performs a multiple attack to 2/3/4 extra enemies
- ✅ Configure 2 heroes (🧙Blood Warden🧙 and 🧙Frostbane Arcanist🧙)
- ✅ Enable upgrading of the special skill (number 4) at levels 6, 9, and 12
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

  📆 23/06/2025

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

  📆 21/06/2025

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
