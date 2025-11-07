extends Node

# Este Singleton es el cerebro del juego. Controla el estado, el tiempo, las advertencias y el flujo de juego.

# --- Señales ---
signal new_question_requested(question_data)
signal distance_updated(distance)
signal game_over_signal
signal police_lunge_requested
signal show_dialogue_requested(dialogue_resource: DialogueResource, title: String) # Modificado para el plugin
signal time_updated(current_time, max_time)
signal warnings_updated(current_warnings, max_warnings)

# --- Variables de Juego ---
@export var intro_dialogue_resource: DialogueResource # Nuevo: para cargar el archivo .dialogue de la intro
@export var initial_time: float = 60.0      # Tiempo inicial en segundos
@export var time_gain_on_correct: float = 10.0 # Segundos ganados por respuesta correcta
@export var time_loss_on_wrong: float = 15.0 # Segundos perdidos por respuesta incorrecta
@export var max_police_warnings: int = 2   # Número de advertencias antes del Game Over
@export var police_capture_distance: float = 50.0 # Distancia a la que la policía te captura

var current_time: float
var current_police_warnings: int
var game_paused_for_dialogue: bool = false

# --- Estados del Juego ---
enum GameState { INTRO_DIALOGUE, CHASE_GAMEPLAY, GAME_OVER }
var current_state: GameState = GameState.INTRO_DIALOGUE

# --- Referencias a Nodos (asignadas desde Level.gd) ---
var player_car: Node2D
var police_car: Node2D
var in_game_hud: CanvasLayer
var gui_dialog: CanvasLayer

# Timer para el decremento de la barra de tiempo
var game_timer: Timer

func _ready():
	# Inicializamos el generador de números aleatorios
	seed(Time.get_unix_time_from_system())
	randi() # Llamada inicial para "mezclar" el generador

	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = 1.0 # Decrementa cada segundo
	game_timer.autostart = false
	game_timer.timeout.connect(_on_game_timer_timeout)

	# El juego comienza en estado de diálogo
	change_state(GameState.INTRO_DIALOGUE)

func _process(delta):
	if current_state == GameState.CHASE_GAMEPLAY and not game_paused_for_dialogue:
		# Calculamos y actualizamos la distancia
		if is_instance_valid(player_car) and is_instance_valid(police_car):
			# Distancia: policía a la derecha del jugador, así que policía.x - jugador.x
			var distance = police_car.global_position.x - player_car.global_position.x
			distance_updated.emit(abs(distance)) # Emitir el valor absoluto de la distancia
			
			# Condición de Game Over por captura (si la distancia es muy pequeña o negativa)
			if distance <= police_capture_distance:
				game_over_by_capture()

func change_state(new_state: GameState):
	print("GameManager: Cambiando estado de ", current_state, " a ", new_state)
	current_state = new_state
	match current_state:
		GameState.INTRO_DIALOGUE:
			print("Estado: Diálogo de Introducción")
			get_tree().paused = true # Pausamos el juego de fondo
			if not is_instance_valid(intro_dialogue_resource):
				push_error("¡ERROR en GameManager.gd! La variable 'intro_dialogue_resource' no está asignada en el Inspector. Arrastra tu archivo .dialogue de la intro a ella.")
				# Si no hay recurso, intentar emitir diálogo terminado para no bloquear el juego, pero verificar si gui_dialog es válido
				if is_instance_valid(gui_dialog):
					gui_dialog.emit_signal("dialogue_finished")
				else:
					push_error("¡ERROR en GameManager.gd! 'gui_dialog' no está asignado, no se puede emitir 'dialogue_finished'. Asegúrate de arrastrar la escena GUI_Dialog.tscn al campo 'Gui Dialog' en el Inspector de Level.gd.")
				return
			show_dialogue_requested.emit(intro_dialogue_resource, "intro") # Inicia el diálogo de intro con el recurso
			print("Ejecuta Dialogo")
		GameState.CHASE_GAMEPLAY:
			print("Estado: Persecución en Curso")
			get_tree().paused = false # Reanudamos el juego
			current_time = initial_time
			current_police_warnings = 0
			time_updated.emit(current_time, initial_time)
			warnings_updated.emit(current_police_warnings, max_police_warnings)
			game_timer.start() # Inicia el decremento del tiempo
			ask_new_question() # Pide la primera pregunta
			# Aseguramos que la policía empiece detrás del jugador (esto lo hará Level.gd)
			# police_car.global_position.x = player_car.global_position.x - initial_police_offset
		GameState.GAME_OVER:
			print("Estado: Game Over")
			get_tree().paused = true
			game_timer.stop()
			game_over_signal.emit() # Señal para que el HUD muestre la pantalla de Game Over

# --- Funciones de Control de Juego ---

func start_chase():
	change_state(GameState.CHASE_GAMEPLAY)

func ask_new_question():
	var question = QuestionManager.get_new_question()
	new_question_requested.emit(question)

func _on_game_timer_timeout():
	if current_state == GameState.CHASE_GAMEPLAY and not game_paused_for_dialogue:
		current_time -= 1
		time_updated.emit(current_time, initial_time)
		if current_time <= 0:
			game_over_by_time()

func _on_hud_answer_selected(is_successful: bool):
	if not is_instance_valid(player_car):
		return

	if is_successful:
		current_time += time_gain_on_correct
		player_car.boost_and_distance_away()
	else:
		current_time -= time_loss_on_wrong
		player_car.stall_and_police_lunge()
		
		# Lógica de advertencias (antiguo sistema)
		if current_state == GameState.CHASE_GAMEPLAY:
			current_police_warnings += 1
			warnings_updated.emit(current_police_warnings, max_police_warnings)
			if current_police_warnings >= max_police_warnings:
				game_over_by_warnings() # Nuevo Game Over por advertencias

	# Nos aseguramos de que el tiempo no supere el máximo
	current_time = min(current_time, initial_time)
	
	# Pedimos la siguiente pregunta después de un breve momento
	if has_node("QuestionDelayTimer"):
		$QuestionDelayTimer.start()
	else:
		ask_new_question()

func _on_question_delay_timer_timeout():
	ask_new_question()

# --- Funciones de Game Over ---

func game_over_by_time():
	print("GAME OVER - ¡Se acabó el tiempo!")
	change_state(GameState.GAME_OVER)

func game_over_by_capture():
	print("GAME OVER - ¡La policía te ha capturado!")
	change_state(GameState.GAME_OVER)

func game_over_by_warnings():
	print("GAME OVER - ¡Demasiadas advertencias! La policía te ha capturado.")
	change_state(GameState.GAME_OVER)

# --- Funciones para Diálogo ---
func pause_game_for_dialogue(pause: bool):
	game_paused_for_dialogue = pause
	if current_state == GameState.CHASE_GAMEPLAY:
		if pause:
			game_timer.stop()
		else:
			game_timer.start()
