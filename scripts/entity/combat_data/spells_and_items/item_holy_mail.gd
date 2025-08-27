class_name ItemHolyMail

extends Item

const NAME = "Holy Mail"
const ICON_SLOT = Vector2(11, 1)


static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_physical_defense_points(20)
	_ITEMS[NAME].set_magic_defense_points(20)
	_ITEMS[NAME].set_evasion(0.1)
	_ITEMS[NAME].set_hp_regeneration_points(20)
	_ITEMS[NAME].set_hp(300)
	_ITEMS[NAME].buy_price = 1300
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_float(_ITEMS[NAME].get_physical_defense_points()) + " physical defense points, " + StringHelpers.format_float(_ITEMS[NAME].get_magic_defense_points()) + " magic defense points, " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " evasion, " + StringHelpers.format_float(_ITEMS[NAME].get_hp_regeneration_points()) + " HP regeneration points and " + str(_ITEMS[NAME].get_hp()) + " HP.";

	_ITEMS[NAME].es_description = "Otorga " + StringHelpers.format_float(_ITEMS[NAME].get_physical_defense_points()) + " puntos de defensa física, " + StringHelpers.format_float(_ITEMS[NAME].get_magic_defense_points()) + " puntos de defensa mágica, " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " de evasión, " + StringHelpers.format_float(_ITEMS[NAME].get_hp_regeneration_points()) + " puntos de regeneración de vida y " + str(_ITEMS[NAME].get_hp()) + " puntos de vida.";
