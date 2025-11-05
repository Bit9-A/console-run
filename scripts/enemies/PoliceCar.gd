extends CharacterBody2D

# Este script controla las patrullas de policía.
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot para PoliceCar.tscn:
#
# - PoliceCar (CharacterBody2D, con este script adjunto)
#   |
#   |- Sprite (Sprite2D o AnimatedSprite2D)
#   |
#   `- Collision (CollisionShape2D)
#

# --- Variables de Persecución ---
@export var target: Node2D = null # El nodo del jugador, se asignará desde la escena
@export var follow_distance: float = 200.0 # Distancia que intenta mantener detrás del jugador
@export var catch_up_speed_factor: float = 1.1 # Qué tan rápido acelera para alcanzar al jugador
@export var lunge_speed_boost: float = 400.0 # Boost de velocidad extra durante la embestida
@export var lunge_duration: float = 0.5      # Duración de la embestida en segundos

var current_speed: float = 0.0
var is_lunging: bool = false
var lunge_timer: Timer

func _ready():
	# Creamos un Timer para la embestida
	lunge_timer = Timer.new()
	add_child(lunge_timer)
	lunge_timer.one_shot = true
	lunge_timer.timeout.connect(_on_lunge_timer_timeout)

func _physics_process(delta):
	if is_instance_valid(target):
		# Calculamos la distancia actual al jugador
		var distance_to_target = global_position.distance_to(target.global_position)
		
		# Calculamos la velocidad objetivo de la patrulla.
		# Es la velocidad del jugador más un extra para alcanzarlo si está lejos.
		var target_speed = target.velocity.x
		if distance_to_target > follow_distance:
			target_speed *= catch_up_speed_factor
			
		# Suavizamos la velocidad actual para que no cambie bruscamente
		current_speed = lerp(current_speed, target_speed, delta * 2.0)
		
		# Si está en modo embestida, añade el boost de velocidad
		if is_lunging:
			velocity.x = current_speed + lunge_speed_boost
		else:
			velocity.x = current_speed
		
		velocity.y = 0
	else:
		# Si no hay objetivo, la patrulla no se mueve
		velocity = Vector2.ZERO
	
	move_and_slide()

# --- Funciones de Embestida ---

# Se llama desde GameManager cuando el jugador falla una pregunta
func lunge():
	if not is_lunging:
		print("¡La policía embiste!")
		is_lunging = true
		lunge_timer.start(lunge_duration)

func _on_lunge_timer_timeout():
	print("La embestida de la policía ha terminado.")
	is_lunging = false
