extends CharacterBody2D

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
@onready var ani = $ani_minotauro
@onready var area_vision = $Area2D
@export var max_health := 100
var health := 100

@onready var barra_vida = $barraVida

var img_100 = preload("res://enemigos/barraVidaEne/vida100.png")
var img_50 = preload("res://enemigos/barraVidaEne/vida50.png")
var img_0  = preload("res://enemigos/barraVidaEne/vida0.png")
@export var speed = 100
@export var damage_al_jugador = 10


var sentido = 1
var atacando = false


func _ready():
	area_vision.monitoring = true
	add_to_group("enemies")
	health = max_health
	actualizar_interfaz_vida()


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

	ani.play("walk")
	ani.flip_h = (sentido == -1)
	area_vision.scale.x = sentido


func hacer_ataque(objetivo):

	atacando = true
	velocity.x = 0
	ani.play("attack")

	await get_tree().create_timer(0.25).timeout

	if objetivo and objetivo.has_method("take_damage"):
		objetivo.take_damage(damage_al_jugador)

	await ani.animation_finished
	await get_tree().create_timer(0.5).timeout

	atacando = false


func take_damage(amount):
	health -= 50  # Cada golpe baja exactamente 50%
	health = clamp(health, 0, max_health)

	print("Vida Minotauro: ", health)

	ani.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	ani.modulate = Color.WHITE

	actualizar_interfaz_vida()

	if health <= 0:
		die()
func actualizar_interfaz_vida():
	if not barra_vida:
		return

	var porcentaje = (float(health) / max_health) * 100.0

	if porcentaje >= 100:
		barra_vida.texture = img_100
	elif porcentaje >= 50:
		barra_vida.texture = img_50
	elif porcentaje > 0:
		barra_vida.texture = img_50
	else:
		barra_vida.texture = img_0

func die():
	queue_free()
