extends Node

# Este Singleton es el cerebro del juego. Controla el estado, el tiempo y el flujo.

# --- Señales ---
signal new_question_requested(question_data)
signal distance_updated(distance)
signal game_over_signal
signal police_lunge_requested

# --- Variables de Estado ---
enum GameState { PLAYING, GAME_OVER }
var current_state: GameState = GameState.PLAYING

# --- Referencias a Nodos ---
# Estas referencias deben ser asignadas desde la escena principal (Level.tscn)
var player_car: Node2D
var police_car: Node2D

func _process(delta):
	if current_state == GameState.PLAYING:
		if is_instance_valid(player_car) and is_instance_valid(police_car):
			# Calculamos la distancia horizontal entre los coches
			var distance = player_car.global_position.x - police_car.global_position.x
			distance_updated.emit(distance)
			
			# Condición de Game Over
			if distance <= 0:
				game_over()

func start_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	ask_new_question()
	print("Juego iniciado.")

func ask_new_question():
	var question = QuestionManager.get_new_question()
	new_question_requested.emit(question)

func _on_hud_answer_selected(is_correct: bool):
	if not is_instance_valid(player_car):
		return

	if is_correct:
		player_car.boost()
	else:
		player_car.stall()
		police_lunge_requested.emit() # ¡Ordenamos a la policía que embista!
	
	# Pedimos la siguiente pregunta después de un breve momento
	# (Asegúrate de tener un Timer llamado 'QuestionDelayTimer' en la escena del GameManager)
	if has_node("QuestionDelayTimer"):
		$QuestionDelayTimer.start()
	else: # Si no existe el timer, pedimos la pregunta inmediatamente
		ask_new_question()


func _on_question_delay_timer_timeout():
	ask_new_question()

func game_over():
	if current_state == GameState.GAME_OVER:
		return # Evita que se llame múltiples veces
		
	print("GAME OVER - ¡Te han atrapado!")
	current_state = GameState.GAME_OVER
	game_over_signal.emit()
	get_tree().paused = true
