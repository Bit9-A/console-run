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
@export var base_speed: float = -300.0      # Velocidad base constante
@export var boost_speed: float = -500.0     # Velocidad al acertar una pregunta
@export var stall_speed: float = -100.0     # Velocidad al fallar
@export var boost_duration: float = -2.0    # Duración del boost en segundos

# Timer para controlar la duración del boost/stall
var effect_timer: Timer

func _ready():
	# Creamos un Timer en el código para no tener que añadirlo en el editor
	effect_timer = Timer.new()
	add_child(effect_timer)
	effect_timer.one_shot = true
	effect_timer.timeout.connect(_on_effect_timer_timeout)

func _physics_process(delta):
	# El coche siempre se mueve hacia la derecha (X positivo)
	velocity.x = base_speed
	velocity.y = 0
	
	move_and_slide()

# --- Funciones de Control de Velocidad ---

# Se llama desde GameManager al acertar una pregunta
func boost():
	print("¡Boost activado!")
	base_speed = boost_speed
	effect_timer.start(boost_duration)

# Se llama desde GameManager al fallar una pregunta
func stall():
	print("¡Motor fallando! Velocidad reducida.")
	base_speed = stall_speed
	effect_timer.start(boost_duration) # Usamos la misma duración para el stall

# Cuando el temporizador de efecto termina, volvemos a la velocidad normal
func _on_effect_timer_timeout():
	print("Velocidad normal restaurada.")
	base_speed = 300.0 # Volvemos al valor inicial
