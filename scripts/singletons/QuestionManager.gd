extends Node

# Este Singleton se encarga de cargar y gestionar el banco de preguntas.

# Ruta al archivo JSON que contiene las preguntas.
const QUESTIONS_PATH = "res://data/questions.json"

# Array para almacenar todas las preguntas cargadas.
var questions: Array = []

func _ready():
	# Cargamos las preguntas del archivo JSON al iniciar el juego.
	load_questions()

# Carga las preguntas desde el archivo JSON.
func load_questions():
	var file = FileAccess.open(QUESTIONS_PATH, FileAccess.READ)
	if file == null:
		print("Error: No se pudo encontrar el archivo de preguntas en ", QUESTIONS_PATH)
		return

	var content = file.get_as_text()
	var json = JSON.parse_string(content)

	if json:
		questions = json.questions
		print("Se cargaron ", questions.size(), " preguntas.")
	else:
		print("Error: No se pudo parsear el archivo JSON de preguntas.")
	
	# Mezclamos las preguntas para que aparezcan en orden aleatorio.
	questions.shuffle()

# Devuelve una nueva pregunta del array.
# Si ya no quedan preguntas, las vuelve a mezclar y empieza de nuevo.
func get_new_question() -> Dictionary:
	if questions.is_empty():
		print("Se acabaron las preguntas. Volviendo a empezar.")
		load_questions() # Vuelve a cargar y mezclar

	if questions.is_empty():
		# Si después de recargar sigue vacío, es que no hay preguntas en el archivo.
		return {
			"question": "ERROR: No hay preguntas disponibles.",
			"answers": ["A", "B", "C", "D"],
			"correct_answer_index": 0
		}

	# Saca la última pregunta del array y la devuelve.
	return questions.pop_back()
