extends GridContainer

func _ready():
	print("HeroPickerScene ready")
	EventBusHeroPicker.connect_to_hero_selected(func(player: Player): _on_hero_selected(player))
	
func _on_hero_selected(player: Player) -> void:
	print("Hero selected: ", player)
	_set_skills(player)

func _set_skills(_hero: Entity) -> void:
	var _slots := get_skill_slots()
	for i in range(_slots.size()):
		var _skill: Skill = _hero._skills[i] if i < _hero._skills.size() else null
		_slots[i].skill_updated(_skill, _hero, i + 1)

func get_skill_slots() -> Array[SkillSlot]:
	var result: Array[SkillSlot] = []
	for child in get_children():
		if child is SkillSlot:
			result.append(child as SkillSlot)
	return result
