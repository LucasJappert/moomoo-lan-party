extends Control

@onready var nine_patch_rect = %NinePatchRect
@onready var mouse_message_label = %MouseMessageLabel

const DESCRIPTION = "
	Welcome to [b]MooRaiders[/b]! Here's a quick guide to help you get started:

	[b]⚡ Basic Controls[/b]
	• [b]Move and Attack:[/b] Right-click to move your hero — clicking on an enemy will also trigger an attack.  
	• [b]Camera Focus:[/b] Press [i]Spacebar[/i] to center the camera on your hero.  
	• [b]Zoom:[/b] Use the [i]mouse wheel[/i] to zoom in and out.  
	• [b]Inspect Units:[/b] Hold [i]Ctrl[/i] and click on any unit to view its stats. Press [i]Spacebar[/i] again to quickly return to your hero.  
	• [b]Pause/Resume:[/b] Press [i]F11[/i] to pause or resume the game at any time.

	[b]⚡ Skills and Leveling[/b]
	• At the start, you can learn [b]one of four skills[/b] shown in the bottom-right corner.  
	• Each time you level up, you can [b]learn or upgrade[/b] a skill of your choice.  
	• The [b]special skill[/b] (far right) becomes available at [b]Level 6[/b].

	[b]⚡ Items[/b]
	• Use the number keys [b]1 to 6[/b] to activate items from your inventory, also located in the bottom-right.

	[b]⚡ Gameplay Style[/b]
	The gameplay is inspired by games like [i]Dota[/i] or [i]League of Legends[/i], with real-time action, skill selection, and strategic positioning.

	[i]Let us know if you have any questions or suggestions — and most importantly, have fun defending the statue![/i] ⚔️
"

func _ready():
	nine_patch_rect.connect("mouse_entered", func(): _on_mouse_entered())
	nine_patch_rect.connect("mouse_exited", func(): _on_mouse_exited())

func _on_mouse_entered():
	MyTooltip.show_tooltip("📖 How to Play MooRaiders – Quick Tutorial", DESCRIPTION, 36)

func _on_mouse_exited():
	MyTooltip.hide_tooltip()

func hide_mouse_message_label():
	mouse_message_label.visible = false