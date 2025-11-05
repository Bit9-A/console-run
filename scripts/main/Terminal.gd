extends Node2D

# Este script controlará la escena principal de la terminal.
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot:
#
# - Terminal (Node2D, con este script adjunto)
#   |
#   |- Background (TextureRect)
#   |  - Propiedades: Layout -> Full Rect, para que ocupe toda la pantalla.
#   |
#   |- GameMonitor (SubViewportContainer)
#   |  - Propiedades: Configura su tamaño y posición para que parezca un monitor.
#   |  - Propiedad 'Stretch' activada para que la escena de carrera se ajuste.
#   |  |
#   |  `- SubViewport
#   |    |
#   |    `- Carrera (instancia de Carrera.tscn, la crearemos en la Fase 2)
#   |
#   `- HUD (instancia de HUD.tscn, la crearemos en la Fase 3)
#
#
# --- CONEXIÓN DE SEÑALES (Hacer esto en el Editor de Godot) ---
#
# 1. Conectar la señal `answer_selected` del HUD al GameManager:
#    - Selecciona el nodo HUD en la escena Terminal.
#    - Ve a la pestaña "Node" -> "Signals".
#    - Haz doble clic en la señal `answer_selected(correct: bool)`.
#    - En el diálogo, selecciona el nodo GameManager (si está como Autoload) o el nodo raíz Terminal.
#    - Crea o selecciona la función `_on_hud_answer_selected(is_correct)`.
#
# 2. Conectar las señales del GameManager al HUD y al PlayerCar:
#    - En el script `Terminal.gd`, en la función `_ready`, añade las siguientes líneas:
#
#      GameManager.apply_penalty.connect($Carrera/PlayerCar.apply_penalty)
#      GameManager.new_question_requested.connect($HUD.show_question)
#      GameManager.time_updated.connect($HUD.update_time_bar)
#
#      (Asegúrate de que las rutas a PlayerCar y HUD sean correctas)
#

# Pre-cargamos las escenas que vamos a necesitar instanciar.
# Las crearemos en las próximas fases, por ahora las dejamos comentadas.
# const CarreraScene = preload("res://scenes/main/Carrera.tscn")
# const HUDScene = preload("res://scenes/ui/HUD.tscn")

@onready var carrera_node = $GameMonitor/SubViewport/Carrera
@onready var hud_node = $HUD

func _ready():
	# Cuando la terminal esté lista, conectamos todas las señales.
	print("Terminal iniciada. Conectando sistemas...")

	# --- Conexiones de Señales ---
	# Conectamos la respuesta del HUD al GameManager
	hud_node.answer_selected.connect(GameManager._on_hud_answer_selected)

	# Conectamos las señales del GameManager a los nodos correspondientes
	GameManager.apply_penalty.connect(carrera_node.get_node("PlayerCar").apply_penalty)
	GameManager.new_question_requested.connect(hud_node.show_question)
	GameManager.time_updated.connect(hud_node.update_time_bar)
	
	# Le pasamos las referencias de los nodos al GameManager para que pueda usarlas si es necesario
	GameManager.hud_node = hud_node
	GameManager.player_car_node = carrera_node.get_node("PlayerCar")

	# ¡Iniciamos el juego!
	GameManager.start_game()
