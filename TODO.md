# ✅ TODO List – MooMoo LAN Party - 🔵In Progress🟡Paused✅Done

⚠️ Keep multiplayer in mind, but for now focus on the game part as a prototype ⚠️

📍 [Go to Roadmap](./roadmap.md)  
📝 [Go to Changelog](./changelog.md)

- 🔵 Generar skill/item que da chances de invocar esqueletos ante cada ataque
- ✅ Acercar player cuando casteamos un hechizo fuera de rango
- ✅ Ver stun con mayor duracion sobre otro
- COnfigurar skills moomoo en cada state
- Desarrollar historia y mostrar diálogos en diferentes momentos
- Agregar item epicos a bosses enemigos
- Aumentar dificultar de rondas normales y especiales
- Efecto de sangrado de acuerdo al daño causado
- Al finalizar las rondas, el moomoo se revela en contra del jugador. Agregar efectos en el suelo como rajaduras con lava. Hacer caer meteoritos desde el cielo, etc.
- Agregar afecto de nubes
- Agregar efecto de lluvia y rayos
- Agregar boton para mutear el juego
- Agregar algunos items más
- Crear skill que brinda un 20% de stunear al enemigo ante cada ataque recibido
- Agregar item que brinda un +30% de ataque mágico y físico y algo mas

- Crear ronda numero 9, con un enemigo que lanza cuchillas y otro que lanza piedras
- Agregar un item que brinda daño splash a todo alreadedor del target (es diferente al cleave)
- Implementar sistema de craft de items
- Regular exp por ronda (deberiamos permitir avanzar 2 niveles por ronda aprox)
- Sonidos limitarlos a la vista en pantalla
- Agregar barra de vida del moomoo y del pj fijas en algun lugar comodo
- Modificar particulas en la explosión de proyectil natura ball

- Ver sonidos que entran en loop indebidamente
- Agregar bordes rojos/animación cuando tenemos poca vida
- Agregar skill, la cual puede activarse o desactivarse, que brindaría chances de matar al enemigo al instante (no aplica a bosses). Consume 20 de mana en cada ataque.
- Agregar skill pasiva que luego de matar un enemigo lo transforma en 3 esqueletos que lucharán para él.
- Aumentar nivel de habilidad aprendida en enemgios
- Agregar skill que brinda chances de crear copias de sí mismo ante cada ataque físico.
- Crear tooltip con descripcion del target
- Agregar quinta skill al nivel 20
- Implementar sistema de asignación de puntos en lugar de skills level
- Refactorizar escena GUI (dividir en escenas separadas la parte top-left, bottom-right, etc.)
- Capear stats como defensas y evasion.
- Agregar un item/skill que al activarlo te hace inmune a los hechizos y a ciertos debuffs como silencios.
- Refactor the GUI by dividing it into panels (TOP-LEFT, BOTTOM-LEFT, BOTTOM-RIGHT)
- Agregar otros efectos de sonidos para el ambiente
- Configure enemy types for wave 2
- Sistema de rondas de enemigos aumentando las dificultades en cada oleada, cada 3 oleadas podríamos hacer una de solamente 4 boses
- Sistema de puntos
- Agregar info de Cleave attack a la gui
- Agregar panel debugger con opciones para matar todos los enemigos, etc.
- Agregar sistema de selección de Héroe
- Agregar un score que tenga en cuenta la velocidad con que se avanza a cada oleada
- Sistema de daños/curas en el tiempo
- Revisar target hovered cuando hay muchos enemigos
- Agregar skill que invoca esqueletos luego de matar a un enemigo
- Agregar skill de velocidad de ataque de un 25%
- Agregar skill que causa un x2 cuando el ataque es por la espalda del enemigo.
- Agregar skill que cada 5 ataques regenera el 5% de la vida total a todos los aliados
- Crear escena para crear y unirse a salas.
- Implementar animaciones varias como congelamiento, sangrado, sobre entidades
- Implementar animaciones sobre tiles, como fuego, sanacion, congelamiento.
- Configurar daños, hp, defensas, etc según el número de wave
- Comenzar la escena para crear y unirse a salas
- Agregar objetos mobiles sobre el terreno como plantas, bichos, nubes, etc.
- Pruebas de multiclientes por el navegador
- Agregar mas tipos de enemigos. El moomoo tendra unas 30 oleadas, cada oleada con 2 tipos de enemigos, entonces necesitariamos unos 60 tipos. Cada enemigo tendra 1 habilidad especial, pasiva o activa, por lo cual necesitaremos tambien unas 60 habilidades.
  Otra opción es crear unas 3 habilidades, y que los enemigos tendrían 3 de ellas asignadas aleatoriamente. De esta manera se podría crear una amplia variabilidad de combinaciones. Sumado a que cada enemigo tiene su tipo de ataque, su rango de ataque, velocidad de ataque, etc.
- Agregar efectos de sangrado cada vez que una entidad recibo un daño
- Agregar mas tipos de héroes. En esta primera etapa bastaría con 10 diferentes tipos con sus respectivas 4 habilidades y una ulti.
- Encapsular lógica de get/set
- Corregir movimiento cuando se quiere atacar un enemigo fuera de rango, el jugador se mueve a la posicion inicial del target, pero si este se mueve no se actualiza tal destino en el path.

# #################################### 🧠 PATHFINDING STRATEGY – HIGH PRIORITY

We must **improve the pathfinding logic** so that movement feels more natural and polished, similar to games like _Dota_.

Currently, some path decisions feel rigid or too direct. We want to aim for smoother movement behavior, intelligent avoidance, and better collision handling when units crowd together.

📌 **Reference Guide:**  
[Pathfinding Guide for 2D Top-View Tiles in Godot 4.3 (by casraf.dev)](https://casraf.dev/2024/09/pathfinding-guide-for-2d-top-view-tiles-in-godot-4-3/)

This guide provides advanced techniques such as flow fields, dynamic obstacle adjustments, and practical examples for top-down games.
