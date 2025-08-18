class_name InitialDialogsManager

# region 	INITIAL DIALOGS
const ENGLISH_INITIAL_DIALOGS: Array[String] = [
	"Millennia ago, the Eternal Lands were protected by an ancient creature known as MooMoo — a mystical being who preserved the balance between chaos and harmony...",
	"It was said that its energy was the life source of the world... but deep within its core pulsed a forbidden power: the Seed of Chaos.",
	"Over time, civilizations forgot its purpose and began to worship it as a sleeping god.\nBut now... something has disturbed its slumber..."
]
const SPANISH_INITIAL_DIALOGS: Array[String] = [
	"Hace milenios, las Tierras Eternas estaban protegidas por una criatura ancestral conocida como MooMoo, un ser místico que preservaba el equilibrio entre el caos y la armonía...",
	"Se decía que su energía era la fuente de vida del mundo... pero en lo profundo de su núcleo latía un poder prohibido: la Semilla del Caos.",
	"Con el paso del tiempo, las civilizaciones olvidaron su propósito y comenzaron a adorarlo como a un dios dormido.\nPero ahora... algo ha perturbado su reposo..."
]
static func get_initial_dialogs() -> Array[String]:
	if LanguageManager.is_english(): return ENGLISH_INITIAL_DIALOGS
	return SPANISH_INITIAL_DIALOGS
# endregion INITIAL DIALOGS

# region 	DIALOGS BETWEEN WAVES
const ENGLISH_WAVE_DIALOGS: Array[String] = [
	"El aire se vuelve denso... como si algo más que los enemigos estuviera despertando.",
	"Alguien o algo está guiando a estas criaturas. Esto no es un ataque aleatorio...",
	"Siento una presencia... antigua... familiar... como un eco olvidado en el tiempo.",
	"Cada vez están más cerca... y sin embargo, no parece que quieran destruirnos. Están buscando algo.",
	"El suelo tiembla. El latido se intensifica. ¿Es posible...? ¿Está despertando?",
	"Ya no hay dudas. MooMoo ha despertado. Pero no como lo recordábamos..."
]
const SPANISH_WAVE_DIALOGS: Array[String] = [
	"The air grows heavy... as if something beyond the enemies is awakening.",
	"Someone—or something—is guiding these creatures. This is no random assault...",
	"I feel a presence... ancient... familiar... like an echo lost in time.",
	"They draw closer... yet they don't seem to want to destroy us. They're searching for something.",
	"The ground trembles. The pulse grows stronger. Could it be...? Is it awakening?",
	"There is no doubt now. MooMoo has awakened. But not as we remembered it..."
]
static func get_wave_dialogs() -> Array[String]:
	if LanguageManager.is_english(): return ENGLISH_WAVE_DIALOGS
	return SPANISH_WAVE_DIALOGS
# endregion DIALOGS BETWEEN WAVES

# region 	FINAL DIALOGS
const ENGLISH_FINAL_DIALOG_LOSS: Array[String] = [
	"MooMoo has been consumed by the Seed of Chaos. No longer a guardian—now ruin incarnate. The balance has collapsed...",
	"The Eternal Lands burn in silence. We don’t know if what we’ve unleashed can be contained... only that this was merely the beginning."
]
const SPANISH_FINAL_DIALOG_LOSS: Array[String] = [
	"MooMoo ha sido consumido por la Semilla del Caos. Ya no es guardián, sino ruina encarnada. El equilibrio ha colapsado...",
	"Las Tierras Eternas arden en silencio. No sabemos si lo que hemos liberado puede ser contenido... solo que esto fue apenas el principio."
]
static func get_final_dialogs_loss() -> Array[String]:
	if LanguageManager.is_english(): return ENGLISH_FINAL_DIALOG_LOSS
	return SPANISH_FINAL_DIALOG_LOSS

const ENGLISH_FINAL_DIALOG_WIN: Array[String] = [
	"MooMoo fell to its knees, torn between memory and corruption. For a fleeting moment, light overcame the chaos...",
	"But the Seed still pulses. What awakened will not sleep again. The Eternal Lands await the next storm."
]
const SPANISH_FINAL_DIALOG_WIN: Array[String] = [
	"MooMoo cayó de rodillas, desgarrado entre la memoria y la corrupción. Durante un instante, la luz superó al caos...",
	"Pero la Semilla aún late. Lo que se despertó no volverá a dormir. Las Tierras Eternas aguardan la próxima tormenta."
]
static func get_final_dialogs_win() -> Array[String]:
	if LanguageManager.is_english(): return ENGLISH_FINAL_DIALOG_WIN
	return SPANISH_FINAL_DIALOG_WIN
# endregion FINAL DIALOGS