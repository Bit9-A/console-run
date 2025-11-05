extends CanvasLayer

# Este script controla toda la Interfaz de Usuario (HUD).
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot para HUD.tscn:
#
# - HUD (CanvasLayer, con este script adjunto)
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
# Se emite cuando el jugador selecciona una respuesta.
signal answer_selected(correct: bool)

# --- Variables ---
@onready var distance_label = $DistanceLabel
@onready var question_label = $QuestionPanel/QuestionLabel
@onready var answer_buttons = $QuestionPanel/AnswersBox.get_children()

var current_question: Dictionary

func _ready():
	# Conectamos las señales de los botones a una función.
	for button in answer_buttons:
		button.pressed.connect(_on_answer_button_pressed.bind(button))
	
	# Pedimos la primera pregunta
	# get_new_question() # Lo llamaremos desde GameManager


# Muestra una nueva pregunta en el HUD
func show_question(question_data: Dictionary):
	current_question = question_data
	question_label.text = current_question.question
	
	# Asignamos el texto a cada botón de respuesta
	for i in range(answer_buttons.size()):
		answer_buttons[i].text = current_question.answers[i]

# Se llama cuando uno de los botones de respuesta es presionado
func _on_answer_button_pressed(button_pressed):
	var selected_answer_index = answer_buttons.find(button_pressed)
	var is_correct = (selected_answer_index == current_question.correct_answer_index)
	
	if is_correct:
		print("¡Respuesta correcta!")
	else:
		print("Respuesta incorrecta.")
		
	# Emitimos la señal con el resultado
	answer_selected.emit(is_correct)
	
# Ocultamos las preguntas temporalmente hasta que GameManager pida la siguiente
	question_label.text = "..."


# Función para actualizar la etiqueta de distancia
func update_distance(distance: float):
	# Formateamos el texto para que muestre la distancia con un decimal
	distance_label.text = "Distancia: %.1f m" % distance
