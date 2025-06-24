class_name GUIStatsHelper

static func _ready(gui: GUI):
	gui._str_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("STRENGTH", CombatStats.STRENGTH_PROPERTIES)
	)
	gui._str_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._agi_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("AGILITY", CombatStats.AGILITY_PROPERTIES)
	)
	gui._agi_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._int_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("INTELLIGENCE", CombatStats.INTELLIGENCE_PROPERTIES)
	)
	gui._int_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._damage_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("DAMAGE", "Physical and magic damage")
	)
	gui._damage_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._defense_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("DEFENSE", "Physical and magic defense")
	)
	gui._defense_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._move_speed_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("MOVE SPEED", "Tiles per second")
	)
	gui._move_speed_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._attack_speed_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("ATTACK SPEED", "Attacks per second")
	)
	gui._attack_speed_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())
