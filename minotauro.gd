extends CharacterBody2D


@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@export var speed = 100
# Variable para indicar si vamos hacia delante (1) o atrás (-1)
var sentido = 1
func _physics_process(delta: float) -> void:
	# Establecemos la velocidad
	velocity.y += gravity * delta
	if is_on_wall():
		sentido = -sentido
		
	## Si el detector delantero está detectando suelo y vamos en esa dirección
	if sentido ==1 && $derecha.is_colliding():
		velocity.x = speed
		$ani_minotauro.flip_h = false
	else:
		sentido = -1
	
	## Si el detector trasero está detectando suelo y vamos en esa dirección
	if sentido == -1 && $izquierda.is_colliding():
		velocity.x = -speed
		$ani_minotauro.flip_h = true
	else:
		sentido = 1

	# Refrescamos el juego
	move_and_slide()
