extends CharacterBody2D

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
@onready var ani = $ani_bicho
@onready var area_vision = $Area2D

@export var speed = 100
@export var damage_al_jugador = 10
@export var health = 50 

var sentido = 1
var atacando = false


func _ready():
	area_vision.monitoring = true
	add_to_group("enemies")


func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	for body in area_vision.get_overlapping_bodies():
		if body.is_in_group("jugadores") and not atacando:
			hacer_ataque(body)

	if atacando:
		velocity.x = 0
	else:
		patrullar()

	move_and_slide()


func patrullar():

	if is_on_wall() \
	or (sentido == 1 and not $derecha.is_colliding()) \
	or (sentido == -1 and not $izquierda.is_colliding()):
		sentido = -sentido

	velocity.x = sentido * speed

	ani.play("reposo")
	ani.flip_h = (sentido == 1)
	


func hacer_ataque(objetivo):

	atacando = true
	velocity.x = 0
	ani.play("ataque")

	await get_tree().create_timer(0.25).timeout

	if objetivo and objetivo.has_method("take_damage"):
		objetivo.take_damage(damage_al_jugador)

	await ani.animation_finished
	await get_tree().create_timer(0.5).timeout

	atacando = false


func take_damage(amount):
	health -= amount
	print("Bicho herido! Vida restante: ", health)

	ani.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	ani.modulate = Color.WHITE

	if health <= 0:
		die()


func die():
	queue_free()
