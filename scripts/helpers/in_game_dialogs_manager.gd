class_name InGameDialogsManager

static var _rich_chat: RichTextLabel
static var _fade_tween: Tween

static func get_chat_label() -> RichTextLabel:
	return GameManager.get_gui_scene().rich_chat

static func show(text: String, visible_time_in_seconds: float = 5) -> void:
	if not _rich_chat: _rich_chat = get_chat_label()

	
	_rich_chat.clear()
	# Start fully visible and set new text
	_rich_chat.modulate.a = 1.0
	_rich_chat.append_text(text)
	# var chat_height = _rich_chat.get_content_height()
	# _rich_chat.set_size(Vector2(_rich_chat.size.x, chat_height))

	# Kill previous tween (if any) to avoid overlapping animations
	if is_instance_valid(_fade_tween): _fade_tween.kill()

	# Create a new tween: wait 5s, then fade out over 4s
	_fade_tween = _rich_chat.create_tween()
	_fade_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_interval(visible_time_in_seconds) # <-- hold visible 5s
	_fade_tween.tween_property(_rich_chat, "modulate:a", 0.0, 4.0) # <-- fade to 0 in 4s


# --- Datos ES tipados ---
const ES_WAVES: Array[String] = [
	"- ???: El aire vibra... mi corazón late otra vez.", # 0 (prólogo / antes ronda 1)
	"- ???: Forasteros... vienen a interrumpir mi sueño.", # 1
	"- ???: Ya siento la corrupción acercándose... como si me buscara.", # 2 (Boss)
	"- ???: ¿Por qué defienden lo que no entienden?", # 3
	"- ???: El eco del Corazón Primordial... retumba en las entrañas.", # 4 (Boss)
	"- ???: Sus cuerpos caen, pero su energía... vuelve a mí.", # 5
	"- ???: Nada puede contener este despertar... ni siquiera ustedes.", # 6 (Boss)
	"- ???: Cada golpe que dan... todo me fortalece.", # 7
	"- ???: La máscara caerá pronto... verán quién protege el corazón.", # 8 (Boss)
	"- ???: Ya no distingo si me ayudan... o me apresuran.", # 9
	"- ???: El velo se rasga... la realidad tiembla.", # 10
	"- ???: Creen luchar contra el caos... pero lo alimentan.", # 11
	"- ???: La última prueba... y el sello se romperá." # 12 (última horda)
]
const ES_REVELATION: Array[String] = [
	"- MooMoo: Gracias... me han defendido bien.",
	"- MooMoo: Pero ya no los necesito."
]
const ES_BOSS_75: String = "- MooMoo: Siento el poder fluir... ¡más allá de este mundo!"
const ES_BOSS_50: String = "- MooMoo: No me resistan... únanse a mí en la eternidad."
const ES_BOSS_25: String = "- MooMoo: ¡El corazón late con furia! ¡El velo se abrirá!"
const ES_FINAL_WIN: String = "- MooMoo: He visto más allá del velo... y lo que acecha no pertenece a este mundo. Él se aproxima... y este triunfo apenas retrasa su llegada."
const ES_FINAL_LOSE: String = "- MooMoo: El corazón late desatado... y con cada pulso la corrupción se expande. El mundo se inclinará ante mí... y nada podrá detener el amanecer de la oscuridad."

# --- Datos EN tipados ---
const EN_WAVES: Array[String] = [
	"- ???: The air trembles... my heart beats once more.", # 0
	"- ???: Strangers... you come to disturb my slumber.", # 1
	"- ???: I feel the corruption drawing near... as if it seeks me.", # 2 (Boss)
	"- ???: Why do you defend what you do not understand?", # 3
	"- ???: The Primordial Heart’s echo resounds through the earth.", # 4 (Boss)
	"- ???: Their bodies fall, but their energy... returns to me.", # 5
	"- ???: Nothing can contain this awakening... not even you.", # 6 (Boss)
	"- ???: Every strike you make... strengthens me.", # 7
	"- ???: The mask will soon fall... you’ll see who guards the heart.", # 8 (Boss)
	"- ???: I no longer know if you aid me... or hasten me.", # 9
	"- ???: The veil tears... reality trembles.", # 10
	"- ???: You think you fight chaos... but you feed it.", # 11
	"- ???: The last trial... and the seal shall break." # 12
]
const EN_REVELATION: Array[String] = [
	"- MooMoo: Thank you... you have defended me well.",
	"- MooMoo: But I no longer need you."
]
const EN_BOSS_75: String = "- MooMoo: I feel the power flowing... beyond this world!"
const EN_BOSS_50: String = "- MooMoo: Do not resist me... join me in eternity."
const EN_BOSS_25: String = "- MooMoo: The Heart beats with fury! The veil shall open!"
const EN_FINAL_WIN: String = "- MooMoo: I have seen beyond the veil... and what lurks there does not belong to this world. He is coming... and this victory only delays his arrival."
const EN_FINAL_LOSE: String = "- MooMoo: The Heart beats unbound... and with every pulse the corruption spreads. The world shall bow before me... and nothing can prevent the dawn of darkness."

const ES_THANKS: String = "Gracias por jugar a MooRaiders. Tu aventura nos inspira a seguir mejorando. ¡Cualquier sugerencia será muy bienvenida!"
const EN_THANKS: String = "Thank you for playing MooRaiders. Your adventure inspires us to keep improving. Any suggestions are most welcome!"

# --- Diccionario raíz (por si querés inspeccionarlo/serializarlo) ---
const DB: Dictionary = {
	"es": {
		"wave": ES_WAVES,
		"revelation": ES_REVELATION,
		"boss_75": ES_BOSS_75,
		"boss_50": ES_BOSS_50,
		"boss_25": ES_BOSS_25,
		"final_win": ES_FINAL_WIN,
		"final_lose": ES_FINAL_LOSE,
		"thanks": ES_THANKS,
	},
	"en": {
		"wave": EN_WAVES,
		"revelation": EN_REVELATION,
		"boss_75": EN_BOSS_75,
		"boss_50": EN_BOSS_50,
		"boss_25": EN_BOSS_25,
		"final_win": EN_FINAL_WIN,
		"final_lose": EN_FINAL_LOSE,
		"thanks": EN_THANKS,
	}
}

# --- API simple ---
static func wave(index: int) -> String:
	var lang := LanguageManager.language
	var arr: Array[String] = DB[lang]["wave"]
	index = clamp(index, 0, arr.size() - 1)
	return arr[index]

# Funciones explícitas para estados del boss (evitamos recordar claves):
static func moomoo_wake_up() -> String:
	var arr: Array[String] = DB[LanguageManager.language]["revelation"]
	return "\n".join(arr)
static func boss_hp_75() -> String:
	return DB[LanguageManager.language]["boss_75"]
static func boss_hp_50() -> String:
	return DB[LanguageManager.language]["boss_50"]
static func boss_hp_25() -> String:
	return DB[LanguageManager.language]["boss_25"]

# Mensaje final
static func final_message(did_win: bool) -> String:
	if did_win: return DB[LanguageManager.language]["final_win"]
	return DB[LanguageManager.language]["final_lose"]

# Gracias
static func thanks() -> String:
	return DB[LanguageManager.language]["thanks"]