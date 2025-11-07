extends Node2D

# Asigna estos nodos desde el editor arrastrándolos aquí
@export var player_car: Node2D
@export var police_car: Node2D
@export var in_game_hud: CanvasLayer # Variable para tu escena de HUD del juego
@export var gui_dialog: CanvasLayer # Variable para tu escena de diálogo
@export var initial_police_offset: float = 500.0 # Distancia inicial de la policía detrás del jugador

func _ready():
	# --- Verificación de Nodos Asignados ---
	if not is_instance_valid(player_car):
		push_error("¡ERROR en Level.gd! No has arrastrado el nodo del PlayerCar al campo 'Player Car' en el Inspector.")
		return
	if not is_instance_valid(police_car):
		push_error("¡ERROR en Level.gd! No has arrastrado el nodo del PoliceCar al campo 'Police Car' en el Inspector.")
		return
	if not is_instance_valid(in_game_hud):
		push_error("¡ERROR en Level.gd! No has arrastrado tu escena de HUD del juego al campo 'In Game Hud' en el Inspector.")
		return
	if not is_instance_valid(gui_dialog):
		push_error("¡ERROR en Level.gd! No has arrastrado tu escena de Diálogo al campo 'Gui Dialog' en el Inspector.")
		return
	
	# Ocultar el HUD del juego al inicio, se mostrará después del diálogo
	in_game_hud.hide()

	# --- Asignar referencias al GameManager ---
	GameManager.player_car = player_car
	GameManager.police_car = police_car
	GameManager.in_game_hud = in_game_hud # Nueva referencia
	GameManager.gui_dialog = gui_dialog # Nueva referencia

	# --- Verificación de Scripts ---
	if not in_game_hud.has_method("show_question"):
		push_error("¡ERROR en Level.gd! El script 'HUD.gd' no parece estar adjuntado al nodo raíz de tu escena InGameHUD.")
		return
	if not gui_dialog.has_method("start_dialogue_from_game_manager"): # Actualizado para la nueva función
		push_error("¡ERROR en Level.gd! El script 'GuiDialog.gd' no parece estar adjuntado al nodo raíz de tu escena GUI_Dialog o no tiene la función 'start_dialogue_from_game_manager'.")
		return

	# --- Conectar señales del GameManager al HUD y a la Policía ---
	GameManager.new_question_requested.connect(in_game_hud.show_question)
	GameManager.distance_updated.connect(in_game_hud.update_distance)
	GameManager.police_lunge_requested.connect(police_car.lunge)
	GameManager.show_dialogue_requested.connect(gui_dialog.start_dialogue_from_game_manager) # Conexión actualizada
	GameManager.game_over_signal.connect(gui_dialog.show) # Ejemplo: mostrar diálogo de Game Over

	# --- Conectar señales del HUD al GameManager ---
	in_game_hud.answer_selected.connect(GameManager._on_hud_answer_selected)

	# --- Conectar señal de diálogo terminado para iniciar la persecución ---
	gui_dialog.dialogue_finished.connect(_on_intro_dialogue_finished)

	# --- Configurar Posiciones Iniciales ---
	# Aseguramos que la policía empiece a la derecha del jugador
	police_car.global_position.x = player_car.global_position.x + initial_police_offset
	# La policía no se mueve durante el diálogo de introducción
	police_car.set_physics_process(false)
	player_car.set_physics_process(false) # El jugador tampoco se mueve durante el diálogo

	# --- Iniciar el juego (GameManager se encargará de los estados) ---
	GameManager.change_state(GameManager.GameState.INTRO_DIALOGUE)

func _on_intro_dialogue_finished():
	print("Diálogo de introducción terminado. Iniciando persecución.")
	in_game_hud.show() # Mostrar el HUD del juego
	police_car.set_physics_process(true) # La policía empieza a moverse
	player_car.set_physics_process(true) # El jugador empieza a moverse
	GameManager.start_chase() # GameManager cambia al estado de persecución
