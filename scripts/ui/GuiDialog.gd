extends CanvasLayer

# --- Señales ---
# Se emite cuando toda una secuencia de diálogo ha terminado.
signal dialogue_finished

# --- Nodos de la Interfaz ---
# Arrastra los nodos correspondientes desde tu escena a estos campos en el Inspector de Godot.
@export var name_label: Label
@export var text_label: DialogueLabel # Cambiado a DialogueLabel del plugin
@export var avatar_texture: TextureRect
@export var typewriter_sound: AudioStreamPlayer # Mantener si el plugin no lo maneja directamente
@export var dialog_node: Control # El nodo Control/Panel que contiene todo el diálogo

# --- Variables de Diálogo ---
@export var fade_duration: float = 0.3 # Duración de la animación de desvanecimiento
@export var dialogue_resource: DialogueResource # Nuevo: para cargar el archivo .dialogue

var current_dialogue_line: DialogueLine # Para almacenar la línea actual del plugin
var current_dialogue_title: String # Para el título de la secuencia actual

@onready var GameManager = get_node("/root/GameManager") # Mantener mi GameManager

func _ready():
	visible = false # Oculto al inicio
	
	if not is_instance_valid(dialog_node):
		push_error("¡ERROR en GuiDialog.gd! La variable 'dialog_node' no está asignada en el Inspector al inicio. Arrastra el nodo 'Dialog' a ella.")
	else:
		print("GuiDialog: dialog_node es válido en _ready().")
		print("GuiDialog: CanvasLayer Layer es: ", layer)
	
	# Conectamos la señal global del GameManager para mostrar diálogos
	GameManager.show_dialogue_requested.connect(start_dialogue_from_game_manager)
	
	# Conectar la señal finished_typing del DialogueLabel
	text_label.finished_typing.connect(_on_text_label_finished_typing)

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		if text_label.is_typing_out(): # Usar la función correcta del DialogueLabel
			text_label.finish_typing() # Mostrar todo el texto de golpe
		else:
			_display_next_line() # Pasar a la siguiente línea

# Inicia una nueva secuencia de diálogo (llamado desde GameManager)
func start_dialogue_from_game_manager(sequence_name: String):
	current_dialogue_title = sequence_name
	start_dialogue(dialogue_resource, current_dialogue_title)

# Inicia una nueva secuencia de diálogo (usando el plugin)
func start_dialogue(resource: DialogueResource, title: String):
	print("GuiDialog: start_dialogue llamado con recurso y título: ", title)
	dialogue_resource = resource
	current_dialogue_title = title
	
	# Animación de aparición
	if not is_instance_valid(dialog_node):
		push_error("¡ERROR en GuiDialog.gd! La variable 'dialog_node' no está asignada en el Inspector. Arrastra el nodo 'Dialog' a ella.")
		return
	
	dialog_node.modulate = Color(1, 1, 1, 0) # Empezar invisible
	dialog_node.visible = true # Asegurarse de que el nodo hijo sea visible
	visible = true
	print("GuiDialog: Cuadro de diálogo visible y animando aparición. dialog_node.visible: ", dialog_node.visible, ", dialog_node.modulate: ", dialog_node.modulate)
	var tween = create_tween()
	tween.tween_property(dialog_node, "modulate", Color(1, 1, 1, 1), fade_duration)
	tween.tween_callback(_display_next_line)

# Muestra la siguiente línea de la cola de diálogos
func _display_next_line():
	current_dialogue_line = await DialogueManager.get_next_dialogue_line(dialogue_resource, current_dialogue_title)
	
	if current_dialogue_line.is_end:
		_finish_dialogue_sequence()
		return
	
	# Actualizar nombre y avatar
	name_label.text = current_dialogue_line.character # El plugin ya da el nombre del personaje
	# Asignar avatar (el plugin puede tener su propia forma, o podemos mapear aquí)
	_update_avatar(current_dialogue_line.character)
	
	text_label.start_typing(current_dialogue_line) # Usar la función del DialogueLabel
	
	current_dialogue_title = current_dialogue_line.next_id # Actualizar para la siguiente línea
	print("GuiDialog: Mostrando línea. Personaje: ", current_dialogue_line.character, ", Texto: ", current_dialogue_line.text)

func _update_avatar(character_name: String):
	# Aquí puedes mapear el nombre del personaje a la ruta de su avatar
	var avatar_path = ""
	match character_name:
		"Cifra":
			avatar_path = "res://assets/sprites/avatars/cifra.jpg"
		"MM":
			avatar_path = "res://assets/sprites/avatars/MM.png"
		"IA":
			avatar_path = "res://assets/sprites/avatars/IA.jpg"
		_:
			avatar_path = "" # Avatar por defecto o vacío
	
	if not avatar_path.is_empty():
		avatar_texture.texture = load(avatar_path)
	else:
		avatar_texture.texture = null # Ocultar avatar si no hay

func _on_text_label_finished_typing():
	# Se llama cuando el DialogueLabel termina de escribir
	# Aquí puedes añadir lógica si necesitas hacer algo después de que cada línea se escriba completamente
	pass

func _finish_dialogue_sequence():
	# Animación de desvanecimiento
	var tween = create_tween()
	tween.tween_property(dialog_node, "modulate", Color(1, 1, 1, 0), fade_duration)
	tween.tween_callback(func():
		visible = false
		emit_signal("dialogue_finished")
	)
	print("GuiDialog: Secuencia de diálogo terminada.")
