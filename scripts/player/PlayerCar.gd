extends CharacterBody2D

# Este script controla el coche del jugador.
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot para PlayerCar.tscn:
#
# - PlayerCar (CharacterBody2D, con este script adjunto)
#   |
#   |- Sprite (Sprite2D o AnimatedSprite2D)
#   |
#   `- Collision (CollisionShape2D)
#

# --- Variables de Movimiento ---
@export var base_speed: float = -300.0      # Velocidad base constante (ahora hacia la izquierda)
@export var boost_speed_factor: float = 1.5 # Factor de velocidad al acertar
@export var stall_speed_factor: float = 0.5 # Factor de velocidad al fallar
@export var effect_duration: float = 2.0    # Duración del boost/stall en segundos
@export var distance_gain_on_correct: float = -100.0 # Cuánto se aleja del policía al acertar (moviéndose a la izquierda)

# Velocidad base original para resetear
var original_base_speed: float

# Timer para controlar la duración del boost/stall
var effect_timer: Timer

func _ready():
	original_base_speed = base_speed # Guardar la velocidad base original
	# Creamos un Timer en el código para no tener que añadirlo en el editor
	effect_timer = Timer.new()
	add_child(effect_timer)
	effect_timer.one_shot = true
	effect_timer.timeout.connect(_on_effect_timer_timeout)

func _physics_process(delta):
	# El coche siempre se mueve hacia la izquierda (X negativo)
	velocity.x = base_speed
	velocity.y = 0
	
	move_and_slide()

# --- Funciones de Control de Velocidad y Posición ---

# Se llama desde GameManager al acertar una pregunta
func boost_and_distance_away():
	print("¡Boost activado y alejándose!")
	base_speed *= boost_speed_factor
	global_position.x += distance_gain_on_correct # Se aleja del policía (moviéndose a la izquierda)
	effect_timer.start(effect_duration)

# Se llama desde GameManager al fallar una pregunta
func stall_and_police_lunge():
	print("¡Motor fallando! Velocidad reducida.")
	base_speed *= stall_speed_factor
	effect_timer.start(effect_duration)

# Cuando el temporizador de efecto termina, volvemos a la velocidad normal
func _on_effect_timer_timeout():
	print("Velocidad normal restaurada.")
	base_speed = original_base_speed # Volvemos al valor inicial
