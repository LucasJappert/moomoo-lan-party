class_name GUIStatsHelper

static func _ready(gui: GUIScene):
	gui._str_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("STRENGTH", CombatStats.STRENGTH_PROPERTIES if LanguageManager.is_english() else CombatStats.ES_STRENGTH_PROPERTIES)
	)
	gui._str_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._agi_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("AGILITY", CombatStats.AGILITY_PROPERTIES if LanguageManager.is_english() else CombatStats.ES_AGILITY_PROPERTIES)
	)
	gui._agi_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._int_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("INTELLIGENCE", CombatStats.INTELLIGENCE_PROPERTIES if LanguageManager.is_english() else CombatStats.ES_INTELLIGENCE_PROPERTIES)
	)
	gui._int_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._damage_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("DAMAGE", "Physical damage")
	)
	gui._damage_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	gui._magic_power_multiplier_value.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		MyTooltip.show_tooltip("Magic extra damage", "Increases the final damage dealt by magic skills based on the hero's intelligence.")
	)
	gui._magic_power_multiplier_value.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

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
