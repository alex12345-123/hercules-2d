extends CharacterBody2D

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@export var speed = 100

var sentido = 1
func _physics_process(delta: float) -> void:
	
	velocity.y += gravity * delta
	if is_on_wall():
		sentido = -sentido
		
	
	if sentido ==1 && $derecha.is_colliding():
		velocity.x = speed
		$ani_gargon.flip_h = false
	else:
		sentido = -1
	

	if sentido == -1 && $izquierda.is_colliding():
		velocity.x = -speed
		$ani_gargon.flip_h = true
	else:
		sentido = 1
	move_and_slide()
