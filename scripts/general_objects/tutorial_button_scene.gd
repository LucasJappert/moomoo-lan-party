extends Control

@onready var nine_patch_rect = %NinePatchRect
@onready var mouse_message_label = %MouseMessageLabel

const ENGLISH_DESCRIPTION = "
	[b]⚡ Basic Controls[/b]
	• [b]Move and Attack:[/b] Right-click to move your hero — clicking on an enemy will also trigger an attack.
	• [b]Use Skills:[/b] Click on a skill to use it, then click on the target to select it. Alternatively, you can use the hotkey associated with the skill.  
	• [b]Camera Focus:[/b] Press [i]Spacebar[/i] to center the camera on your hero.  
	• [b]Zoom:[/b] Use the [i]mouse wheel[/i] to zoom in and out.  
	• [b]Inspect Units:[/b] Click on any unit to view its stats. Press [i]Spacebar[/i] again to quickly return to your hero.  
	• [b]Pause/Resume and Options:[/b] Press [i]Escape[/i] to pause or resume the game at any time. While paused, you can also open the [b]Options[/b] menu.

	[b]⚡ Skills and Leveling[/b]
	• At the start, you can learn [b]one of four skills[/b] shown in the bottom-right corner.  
	• Each time you level up, you can [b]learn or upgrade[/b] a skill of your choice.  
	• The [b]special skill[/b] (far right) becomes available at [b]Level 6[/b].

	[b]⚡ Items[/b]
	• You can purchase items by opening the [b]Shop[/b] and right-clicking on the item you wish to acquire.
	• Use the number keys [b]1 to 6[/b] to activate items from your inventory, also located in the bottom-right.

	[b]⚡ Gameplay Style[/b]
	The gameplay is inspired by games like [i]Dota[/i] or [i]League of Legends[/i], with real-time action, skill selection, and strategic positioning.

	[i]Let us know if you have any questions or suggestions — and most importantly, have fun defending the statue![/i] ⚔️
"
const SPANISH_DESCRIPTION = "
	[b]⚡ Controles Básicos[/b]
	• [b]Mover y Atacar:[/b] Haz clic derecho para mover a tu héroe — si haces clic sobre un enemigo, también lo atacarás.
	• [b]Usar Habilidades:[/b] Haz clic sobre una habilidad para activarla y luego clic en el objetivo. También puedes usar la tecla rápida asignada a la habilidad.  
	• [b]Centrar Cámara:[/b] Presiona [i]Espacio[/i] para centrar la cámara en tu héroe.  
	• [b]Zoom:[/b] Usa la [i]rueda del mouse[/i] para acercar o alejar la vista.  
	• [b]Inspeccionar Unidades:[/b] Haz clic en cualquier unidad para ver sus estadísticas. Presiona [i]Espacio[/i] nuevamente para volver rápidamente a tu héroe.  
	• [b]Pausar/Reanudar y Opciones:[/b] Presiona [i]Escape[/i] para pausar o reanudar el juego en cualquier momento. Mientras está pausado, también puedes abrir el menú de [b]Opciones[/b].

	[b]⚡ Habilidades y Subida de Nivel[/b]
	• Al comenzar, puedes aprender [b]una de las cuatro habilidades[/b] que aparecen en la esquina inferior derecha.  
	• Cada vez que subas de nivel, puedes [b]aprender o mejorar[/b] una habilidad de tu elección.  
	• La [b]habilidad especial[/b] (la última a la derecha) se desbloquea al alcanzar el [b]Nivel 6[/b].

	[b]⚡ Objetos[/b]
	• Puedes comprar objetos abriendo la [b]Tienda[/b] y haciendo clic derecho sobre el objeto que deseas adquirir.
	• Usa las teclas del [b]1 al 6[/b] para activar objetos desde tu inventario, ubicado también en la esquina inferior derecha.

	[b]⚡ Estilo de Juego[/b]
	La jugabilidad está inspirada en juegos como [i]Dota[/i] o [i]League of Legends[/i], con acción en tiempo real, selección de habilidades y posicionamiento estratégico.

	[i]¡Contanos si tenés preguntas o sugerencias — y lo más importante, divertite defendiendo la estatua![/i] ⚔️
"
const EN_TITLE = "📖 How to Play MooRaiders - Quick Tutorial"
const ES_TITLE = "📖 Como jugar MooRaiders - Breve Tutorial"

func _ready():
	nine_patch_rect.connect("mouse_entered", func(): _on_mouse_entered())
	nine_patch_rect.connect("mouse_exited", func(): _on_mouse_exited())

func _on_mouse_entered() -> void:
	if LanguageManager.is_english():
		return MyTooltip.show_tooltip(EN_TITLE, ENGLISH_DESCRIPTION, 36)

	return MyTooltip.show_tooltip(ES_TITLE, SPANISH_DESCRIPTION, 36)
	

func _on_mouse_exited():
	MyTooltip.hide_tooltip()

func hide_mouse_message_label():
	mouse_message_label.visible = false