extends Node2D

# Este script gestiona la simulación de la carrera.
# Se ejecutará dentro de un SubViewport en la escena Terminal.
#
# ESTRUCTURA DE ESCENA RECOMENDADA en Godot para Carrera.tscn:
#
# - Carrera (Node2D, con este script adjunto)
#   |
#   |- Background (TextureRect) - La carretera
#   |
#   |- PlayerCar (instancia de PlayerCar.tscn)
#   |
#   `- SpawnTimer (Timer) - Para generar patrullas
#

# Pre-cargamos la escena del coche del jugador
# La crearemos a continuación.
# const PlayerCarScene = preload("res://scenes/player/PlayerCar.tscn")

func _ready():
	# Al iniciar la carrera, instanciamos el coche del jugador.
	print("Simulación de carrera iniciada.")
	
	# Descomentar cuando la escena PlayerCar.tscn esté creada:
	# var player = PlayerCarScene.instantiate()
	# add_child(player)

func _process(delta):
	# Aquí irá la lógica principal de la simulación,
	# como mover el fondo para crear un efecto de scroll infinito.
	pass
