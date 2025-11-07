extends CanvasLayer

# Este script controla toda la Interfaz de Usuario (HUD).
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot para HUD.tscn:
#
# - HUD (CanvasLayer, con este script adjunto)
#   |
#   |- TimeBar (TextureProgressBar) <- ¡AÑADE ESTE NODO!
#   |
#   |- WarningIndicators (HBoxContainer) <- ¡AÑADE ESTE NODO!
#   |  `- Warning1 (TextureRect/Label)
#   |  `- Warning2 (TextureRect/Label)
#   |
#   |- DistanceLabel (Label) - Para mostrar la distancia a la policía
#   |
#   `- QuestionPanel (Panel)
#      |
#      |- QuestionLabel (Label) - Para el texto de la pregunta
#      |
#      `- AnswersBox (VBoxContainer) - Para organizar los botones
#         |
#         |- AnswerButton1 (Button)
#         |- AnswerButton2 (Button)
#         |- AnswerButton3 (Button)
#         `- AnswerButton4 (Button)
#

# --- Señales ---
signal answer_selected(is_successful: bool)

# --- Variables ---
# Arrastra los nodos correspondientes desde tu escena a estos campos en el Inspector de Godot.
@export var time_bar: TextureProgressBar
@export var warning_indicators_container: BoxContainer # Contenedor de los indicadores de advertencia
@export var distance_label: Label
@export var question_label: Label
@export var answers_container: BoxContainer # El nodo que contiene los botones de respuesta

var answer_buttons: Array[Button] = []
var warning_icons: Array[Control] = [] # Para los indicadores visuales de advertencia
var current_question: Dictionary

func _ready():
	# Obtenemos los botones del contenedor y los filtramos
	for child in answers_container.get_children():
		if child is Button:
			answer_buttons.append(child)
			child.pressed.connect(_on_answer_button_pressed.bind(child))
		else:
			push_warning("El nodo '%s' en Answers Container no es un botón y será ignorado." % child.name)
	
	# Obtenemos los indicadores de advertencia y los filtramos para asegurar que sean solo Control
	if warning_indicators_container:
		for child in warning_indicators_container.get_children():
			if child is Control:
				warning_icons.append(child)
				child.visible = false # Ocultamos todas las advertencias al inicio
			else:
				push_warning("El nodo '%s' en Warning Indicators Container no es un Control y será ignorado." % child.name)

	# Conectamos las señales globales del GameManager (¡CORREGIDO!)
	# La conexión para show_dialogue_requested DEBE hacerse en Level.gd
	GameManager.time_updated.connect(update_time_bar)
	GameManager.warnings_updated.connect(update_warnings)


# Muestra una nueva pregunta en el HUD
func show_question(question_data: Dictionary):
	current_question = question_data
	question_label.text = current_question.question
	
	# Reseteamos el estilo de los botones
	for button in answer_buttons:
		button.modulate = Color.WHITE
		button.disabled = false
	
	# Asignamos el texto a cada botón de respuesta
	for i in range(answer_buttons.size()):
		var answer_text = ""
		if current_question.type == "single_choice":
			answer_text = current_question.answers[i]
		elif current_question.type == "percentage_choice":
			answer_text = current_question.answers[i].text
		
		answer_buttons[i].text = answer_text

# Se llama cuando uno de los botones de respuesta es presionado
func _on_answer_button_pressed(button_pressed):
	var selected_answer_index = answer_buttons.find(button_pressed)
	var is_successful: bool = false
	
	# Deshabilitamos los botones para evitar múltiples respuestas
	for button in answer_buttons:
		button.disabled = true

	if current_question.type == "single_choice":
		is_successful = (selected_answer_index == current_question.correct_answer_index)
		if is_successful:
			print("¡Respuesta correcta!")
			button_pressed.modulate = Color.GREEN
		else:
			print("Respuesta incorrecta.")
			button_pressed.modulate = Color.RED
			if current_question.has("correct_answer_index"):
				answer_buttons[current_question.correct_answer_index].modulate = Color.GREEN
	
	elif current_question.type == "percentage_choice":
		var success_chance = current_question.answers[selected_answer_index].success_chance
		var random_roll = randi_range(0, 99)
		
		is_successful = (random_roll < success_chance)
		
		if is_successful:
			print("¡Respuesta exitosa con ", success_chance, "% de probabilidad!")
			button_pressed.modulate = Color.GREEN
		else:
			print("Respuesta fallida con ", success_chance, "% de probabilidad.")
			button_pressed.modulate = Color.RED
		
		# Mostrar todos los porcentajes después de responder
		for i in range(answer_buttons.size()):
			var chance = current_question.answers[i].success_chance
			answer_buttons[i].text += " (" + str(chance) + "%)"
			if answer_buttons[i] != button_pressed:
				if randi_range(0, 99) < chance:
					answer_buttons[i].modulate = Color.GREEN * 0.7
				else:
					answer_buttons[i].modulate = Color.RED * 0.7

	answer_selected.emit(is_successful)
	question_label.text = "..."


# Función para actualizar la barra de tiempo
func update_time_bar(current_time_val: float, max_time_val: float):
	time_bar.max_value = max_time_val
	time_bar.value = current_time_val

# Función para actualizar los indicadores de advertencia
func update_warnings(current_warnings_val: int, max_warnings_val: int):
	for i in range(warning_icons.size()):
		if i < current_warnings_val:
			warning_icons[i].visible = true # Muestra la advertencia
		else:
			warning_icons[i].visible = false # Oculta la advertencia

# Función para actualizar la distancia mostrada en el HUD
func update_distance(distance_val: float):
	distance_label.text = "Distancia: %d m" % int(distance_val)
