class_name LanguageManager

class LangTypes:
	const ENGLISH := "en"
	const SPANISH := "es"

static var language: String = ""

# region 	GETTERs
static func initialized() -> bool: return language != ""

static func is_english() -> bool: return language == LangTypes.ENGLISH

static func is_spanish() -> bool: return language == LangTypes.SPANISH

static func is_OS_english(prefer_browser_on_web: bool = true) -> bool:
	var loc: String = OS.get_locale() # "es_AR", "en_US", "en", etc.

	if prefer_browser_on_web and OS.has_feature("web"):
		var js := """
			(function(){
				var l = (navigator.languages && navigator.languages[0]) || navigator.language || "";
				return l;
			})()
		"""
		var res: Variant = JavaScriptBridge.eval(js)
		if typeof(res) == TYPE_STRING and not String(res).is_empty():
			loc = String(res)

	if loc.is_empty():
		return false # sin info, consideramos que NO es inglés

	loc = loc.replace("-", "_")
	var lang := loc.split("_", false, 2)[0].to_lower()
	return lang == "en"
# endregion	GETTERs

# region 	SETTERs
static func set_from_OS() -> void:
	if is_OS_english(): return set_english()
	return set_spanish()

static func set_english() -> void:
	language = LangTypes.ENGLISH
	TranslationServer.set_locale(language)
	EventBus.emit_lang_changed()

static func set_spanish() -> void:
	language = LangTypes.SPANISH
	TranslationServer.set_locale(language)
	EventBus.emit_lang_changed()
# endregion	SETTERs

## 🧠 Diccionario con las traducciones
static var _translations := {
	"The Eternal Guardian": {LangTypes.SPANISH: "El Guardián Eterno"},
	"Skills:": {LangTypes.SPANISH: "Habilidades:"},
	"<< Hover your mouse here": {LangTypes.SPANISH: "<< Deslizá el mouse aquí"},
	"TUTORIAL": {LangTypes.SPANISH: "TUTORIAL"},
	"JOIN THE BATTLE": {LangTypes.SPANISH: "UNITE A LA BATALLA"},
	"RESUME": {LangTypes.SPANISH: "REANUDAR"},
	"Resume": {LangTypes.SPANISH: "Reanudar"},
	"RESTART": {LangTypes.SPANISH: "REINICIAR"},
	"Restart": {LangTypes.SPANISH: "Reiniciar"},
	"MENU": {LangTypes.SPANISH: "OPCIONES"},
	"EXIT GAME": {LangTypes.SPANISH: "SALIR DEL JUEGO"},
	"Exit game": {LangTypes.SPANISH: "Salir del juego"},
	"Hide": {LangTypes.SPANISH: "Ocultar"},
	"Shop": {LangTypes.SPANISH: "Tienda"},
	"YOU WIN": {LangTypes.SPANISH: "HAS GANADO"},
	"YOU LOST": {LangTypes.SPANISH: "HAS PERDIDO"},
	"Start now!": {LangTypes.SPANISH: "Empezar ahora!"},
	"Extra Projectiles Percent Damage": {LangTypes.SPANISH: "Daño por proyectil adicional (%)"},
	"Extra Projectiles": {LangTypes.SPANISH: "Proyectiles adicionales"},
	"Level": {LangTypes.SPANISH: "Nivel"},
	"Cleave Percent": {LangTypes.SPANISH: "Daño en área (%)"},
	"Cleave Range": {LangTypes.SPANISH: "Rango de daño en área (tiles)"},
	"HP": {LangTypes.SPANISH: "Vida"},
	"Hp": {LangTypes.SPANISH: "Vida"},
	"Mana": {LangTypes.SPANISH: "Maná"},
	"Physical Defense Points": {LangTypes.SPANISH: "Puntos Defensa Física"},
	"Magic Defense Points": {LangTypes.SPANISH: "Puntos Defensa Mágica"},
	"Evasion": {LangTypes.SPANISH: "Evasión"},
	"Crit Chance": {LangTypes.SPANISH: "Probabilidad de Crítico"},
	"Crit Multiplier": {LangTypes.SPANISH: "Multiplicador de Crítico"},
	"Stun Chance": {LangTypes.SPANISH: "Probabilidad de Aturdir"},
	"Stun Duration": {LangTypes.SPANISH: "Duración de Aturdimiento"},
	"Silence Duration": {LangTypes.SPANISH: "Duración de Silencio"},
	"Attack Range": {LangTypes.SPANISH: "Rango de Ataque"},
	"Physical Attack Power": {LangTypes.SPANISH: "Poder de Ataque Físico"},
	"Physical Attack Power Percent": {LangTypes.SPANISH: "Poder de Ataque Físico (%)"},
	"Magic Attack Power": {LangTypes.SPANISH: "Poder de Ataque Mágico"},
	"Magic Attack Power Percent": {LangTypes.SPANISH: "Poder de Ataque Mágico (%)"},
	"Attack Speed": {LangTypes.SPANISH: "Velocidad de Ataque"},
	"Attack Speed Percent": {LangTypes.SPANISH: "Velocidad de Ataque (%)"},
	"Move Speed": {LangTypes.SPANISH: "Velocidad de Movimiento"},
	"Move Speed Percent": {LangTypes.SPANISH: "Velocidad de Movimiento (%)"},
	"Freeze Duration": {LangTypes.SPANISH: "Duración de Congelamiento"},
	"Life Steal Percent": {LangTypes.SPANISH: "Robo de Vida (%)"},
	"HP Regeneration Points": {LangTypes.SPANISH: "Regeneración de Vida"},
	"HP Regeneration Points Percent": {LangTypes.SPANISH: "Regeneración de Vida (%)"},
	"Mana Regeneration Points": {LangTypes.SPANISH: "Regeneración de Maná"},
	"Mana Regeneration Points Percent": {LangTypes.SPANISH: "Regeneración de Maná (%)"},
	"Percent Mana To Burn": {LangTypes.SPANISH: "Porcentaje de Maná a Quemar"},
	"Chance To Ignore Evasion": {LangTypes.SPANISH: "Probabilidad de Ignorar Evasión"},
	"Agility": {LangTypes.SPANISH: "Agilidad"},
	"Strength": {LangTypes.SPANISH: "Fuerza"},
	"Intelligence": {LangTypes.SPANISH: "Inteligencia"},
	"Duration": {LangTypes.SPANISH: "Duración"},
	"Area of Effect": {LangTypes.SPANISH: "Área de efecto"},
	"tiles": {LangTypes.SPANISH: "tiles"},
	"Cast Range": {LangTypes.SPANISH: "Rango de lanzamiento"},
	"Mana Cost": {LangTypes.SPANISH: "Costo de maná"},
	"Cooldown": {LangTypes.SPANISH: "Tiempo de reutilización"},
	"Max Targets": {LangTypes.SPANISH: "Objetivos máximos"},
	"Max Stacks": {LangTypes.SPANISH: "Acumulaciones máximas"},
	"Damage Type": {LangTypes.SPANISH: "Tipo de daño"},
	"Can't use this\n skill on allies": {LangTypes.SPANISH: "No puedes usar esta\n habilidad en aliados"},
	"pure": {LangTypes.SPANISH: "puro"},
	"physical": {LangTypes.SPANISH: "físico"},
	"magic": {LangTypes.SPANISH: "mágico"},
	"Not enough gold": {LangTypes.SPANISH: "No tienes suficiente oro"},
	"Not enough space": {LangTypes.SPANISH: "No tienes suficiente espacio"},
	"You Win": {LangTypes.SPANISH: "Has ganado"},
	"You Lose": {LangTypes.SPANISH: "Has perdido"},
	"Consumables": {LangTypes.SPANISH: "Consumibles"},
	"Equipment Level 1": {LangTypes.SPANISH: "Equipos Nivel 1"},
	"Equipment Level 2": {LangTypes.SPANISH: "Equipos Nivel 2"},
	"Equipment Level 3": {LangTypes.SPANISH: "Equipos Nivel 3"},
}

## ✅ Traducción basada en clave
static func translate(original_text: String) -> String:
	# ⚠️ Ignorar si es número (aunque venga como string)
	if original_text.is_valid_int() or original_text.is_valid_float(): return original_text

	# ⚠️ Ignorar si es una sola letra (alfabética)
	if original_text.length() == 1: return original_text

	# Buscar en diccionario
	if not _translations.has(original_text):
		push_warning("Missing translation key: '%s'" % original_text)
		return original_text

	if not _translations[original_text].has(language):
		if language != LangTypes.ENGLISH: push_warning("Missing translation for '%s' in language '%s'" % [original_text, language])
		return original_text

	return _translations[original_text][language]

static func translate_ui(root: Node) -> void:
	for child in root.get_children():
		_translate_node(child)
		# Recursividad
		if child.get_child_count() > 0:
			translate_ui(child)

static func _translate_node(node: Node) -> void:
	# Solo traducimos si el nodo tiene propiedad 'text' y es un String
	if "text" in node and typeof(node.text) == TYPE_STRING:
		var original: String = node.text
		var translated := translate(original)
		if translated != original:
			node.text = translated